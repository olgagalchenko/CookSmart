//
//  CSScaleTile.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/24/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSScaleTile.h"

#define EIGHTH_LINE_LENGTH      15
#define QUARTER_LINE_LENGTH     30
#define MINOR_LINE_THICKNESS    1.0
#define WHOLE_LINE_LENGTH       80
#define WHOLE_LINE_THICKNESS    4.0
#define TEXT_BOX_PADDING        10
#define TEXT_BOX_HEIGHT         20

@interface CSScaleTile()

@property (nonatomic, readwrite, strong) UILabel *valueLabel;

@end

@implementation CSScaleTile

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.opaque = YES;
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        [self.valueLabel setBackgroundColor:BACKGROUND_COLOR];
        [self.valueLabel setTextColor:[UIColor grayColor]];
        self.valueLabel.bounds = CGRectMake(0, 0, frame.size.width, TEXT_BOX_HEIGHT);
        self.valueLabel.center = CGPointMake(frame.size.width/2, 0);
        [self addSubview:self.valueLabel];
    }
    return self;
}

- (void)setValue:(float)value
{
    _value = value;
    NSString *text;
    if (value >= 0)
    {
        text = [NSString stringWithFormat:@"%1.0f", _value];
    }
    else
    {
        text = @"";
    }
    NSDictionary *attributes = @{NSFontAttributeName: self.valueLabel.font};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.bounds.size.width, TEXT_BOX_HEIGHT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    self.valueLabel.bounds = CGRectMake(0, 0, rect.size.width + TEXT_BOX_PADDING, TEXT_BOX_HEIGHT);
    [self.valueLabel setText:text];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGPoint line[2];
    [[UIColor grayColor] setStroke];
    CGContextSetLineWidth(ctx, MINOR_LINE_THICKNESS);
    
    for (float y = (self.bounds.size.height/8); y < self.bounds.size.height; y += self.bounds.size.height/4)
    {
        line[0] = CGPointMake((self.bounds.size.width - EIGHTH_LINE_LENGTH)/2, y);
        line[1] = CGPointMake((self.bounds.size.width + EIGHTH_LINE_LENGTH)/2, y);
        CGContextAddLines(ctx, line, 2);
    }
    CGContextDrawPath(ctx, kCGPathStroke);
    
    for (float y = 0.5 + self.bounds.size.height/4; y < self.bounds.size.height; y += self.bounds.size.height/4)
    {
        line[0] = CGPointMake((self.bounds.size.width - QUARTER_LINE_LENGTH)/2, y);
        line[1] = CGPointMake((self.bounds.size.width + QUARTER_LINE_LENGTH)/2, y);
        CGContextAddLines(ctx, line, 2);
    }
    CGContextDrawPath(ctx, kCGPathStroke);
    
    [[UIColor blackColor] setStroke];
    CGContextSetLineWidth(ctx, WHOLE_LINE_THICKNESS);
    line[0] = CGPointMake((self.bounds.size.width - WHOLE_LINE_LENGTH)/2, 0.0);
    line[1] = CGPointMake((self.bounds.size.width + WHOLE_LINE_LENGTH)/2, 0.0);
    CGContextAddLines(ctx, line, 2);
    CGContextDrawPath(ctx, kCGPathStroke);
}

@end