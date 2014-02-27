//
//  CSMagnifyingView.m
//  CookSmart
//
//  Created by Vova Galchenko on 2/27/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSGlassView.h"

#define SHADOW_SIZE     5

@implementation CSGlassView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Pass through all events
    return NO;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.025] setFill];
    CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - SHADOW_SIZE));
    CGContextSetLineWidth(ctx, 0.5);
    [[[UIColor blackColor] colorWithAlphaComponent:0.08] setStroke];
    CGPoint line[2];
    line[0] = CGPointMake(0, self.bounds.size.height - SHADOW_SIZE);
    line[1] = CGPointMake(self.bounds.size.width, self.bounds.size.height - SHADOW_SIZE);
    CGContextAddLines(ctx, line, 2);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGFloat locations[2] = {0.0, 1.0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *colors = @[(__bridge id)[[[UIColor blackColor] colorWithAlphaComponent:0.075]  CGColor],
                        (__bridge id)[[[UIColor blackColor] colorWithAlphaComponent:0] CGColor]];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, self.bounds.size.height - SHADOW_SIZE), CGPointMake(0, self.bounds.size.height), 0);
}

@end
