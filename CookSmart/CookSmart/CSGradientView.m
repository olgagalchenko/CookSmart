//
//  CSGradientView.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/24/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSGradientView.h"

#define GRADIENT_PADDING    10

@interface CSGradientView()

@property (nonatomic, readwrite, assign) CGFloat gradientStart;

@end

@implementation CSGradientView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.opaque = NO;
        self.clearsContextBeforeDrawing = YES;
        self.gradientStart = 0;
        for (UIView *subview in self.subviews)
        {
            if (CGRectGetMaxY(subview.frame) > self.gradientStart)
            {
                self.gradientStart = CGRectGetMaxY(subview.frame);
            }
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [BACKGROUND_COLOR setFill];
    CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.gradientStart));
    CGFloat locations[2] = {0.0, 1.0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *colors = @[(__bridge id)[BACKGROUND_COLOR CGColor],
                        (__bridge id)[[BACKGROUND_COLOR colorWithAlphaComponent:0] CGColor]];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, self.gradientStart), CGPointMake(0, self.bounds.size.height), 0);
}

@end
