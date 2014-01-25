//
//  CSScaleTile.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/24/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSScaleTile.h"

#define EIGHTH_LINE_LENGTH      7
#define QUARTER_LINE_LENGTH     13

@interface CSScaleTile()

@property (nonatomic, readwrite, strong) UILabel *valueLabel;
@property (nonatomic, readwrite, assign) CSScaleViewScaleDisplayMode scaleDisplayMode;

@end

@implementation CSScaleTile

- (id)initWithFrame:(CGRect)frame scaleDisplayMode:(CSScaleViewScaleDisplayMode)scaleDisplayMode
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clearsContextBeforeDrawing = YES;
        self.scaleDisplayMode = scaleDisplayMode;
        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        [self.valueLabel setBackgroundColor:[UIColor clearColor]];
        [self.valueLabel setTextColor:[UIColor blackColor]];
        self.valueLabel.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
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
    [self.valueLabel setText:text];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGPoint line[2];
    CGContextSetLineWidth(ctx, 1.0);
    
    float eighthStartX, eighthEndX, quarterStartX, quarterEndX;
    switch (self.scaleDisplayMode)
    {
        case CSScaleViewScaleDisplayModeLeft:
            eighthStartX = 0;
            eighthEndX = EIGHTH_LINE_LENGTH;
            quarterStartX = 0;
            quarterEndX = QUARTER_LINE_LENGTH;
            break;
        case CSScaleViewScaleDisplayModeRight:
            eighthStartX = self.bounds.size.width - EIGHTH_LINE_LENGTH;
            eighthEndX = self.bounds.size.width;
            quarterStartX = self.bounds.size.width - QUARTER_LINE_LENGTH;
            quarterEndX = self.bounds.size.width;
            break;
        default:
            NSAssert(NO, @"Unknown scale display mode: %d", self.scaleDisplayMode);
            break;
    }
    for (float y = self.bounds.size.height/8; y < self.bounds.size.height; y += self.bounds.size.height/4)
    {
        line[0] = CGPointMake(eighthStartX, y);
        line[1] = CGPointMake(eighthEndX, y);
        CGContextAddLines(ctx, line, 2);
    }
    CGContextDrawPath(ctx, kCGPathStroke);
    
    for (float y = 0.5; y < self.bounds.size.height; y += self.bounds.size.height/4)
    {
        line[0] = CGPointMake(quarterStartX, y);
        line[1] = CGPointMake(quarterEndX, y);
        CGContextAddLines(ctx, line, 2);
    }
    CGContextDrawPath(ctx, kCGPathStroke);
}

@end
