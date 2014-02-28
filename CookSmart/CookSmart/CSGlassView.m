//
//  CSMagnifyingView.m
//  CookSmart
//
//  Created by Vova Galchenko on 2/27/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSGlassView.h"

#define SHADOW_SIZE         5
#define MAGNIFYING_FACTOR   1.1

@implementation CSGlassView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.opaque = YES;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0, SHADOW_SIZE);
        self.layer.shadowOpacity = 0.075;
        
        CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
        [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Pass through all events
    return NO;
}

- (UIImage *)imageUnderGlass
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [[UIScreen mainScreen] scale]);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPoint imageUnderGlassOrigin = [self.viewToMagnify convertPoint:CGPointMake(0, 0) fromView:self];
    CGContextTranslateCTM(ctx, -imageUnderGlassOrigin.x, -imageUnderGlassOrigin.y);
    [self.viewToMagnify.layer.presentationLayer renderInContext:ctx];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

- (void)drawRect:(CGRect)rect
{
    CGImageRef imageUnderGlass = [[self imageUnderGlass] CGImage];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height/2);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, 0, -self.bounds.size.height/2);
    
    CGContextTranslateCTM(ctx, self.bounds.size.width/2, self.bounds.size.height/2);
    CGContextScaleCTM(ctx, MAGNIFYING_FACTOR, MAGNIFYING_FACTOR);
    CGContextTranslateCTM(ctx, -self.bounds.size.width/2, -self.bounds.size.height/2);
    
    CGContextDrawImage(ctx, self.bounds, imageUnderGlass);
    
    CGContextRestoreGState(ctx);
    [[UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:0.025] setFill];
    CGContextFillRect(ctx, self.bounds);
    CGContextSetLineWidth(ctx, 0.5);
    [[[UIColor blackColor] colorWithAlphaComponent:0.1] setStroke];
    CGPoint line[2];
    line[0] = CGPointMake(0, self.bounds.size.height);
    line[1] = CGPointMake(self.bounds.size.width, self.bounds.size.height);
    CGContextAddLines(ctx, line, 2);
    CGContextDrawPath(ctx, kCGPathStroke);
}

@end
