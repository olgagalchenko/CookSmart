//
//  CSUnitPickerCenterLineView.m
//  CookSmart
//
//  Created by Vova Galchenko on 3/1/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSUnitPickerCenterLineView.h"

#define UNIT_LABEL_WIDTH        110

@implementation CSUnitPickerCenterLineView

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [RED_LINE_COLOR setFill];
    CGContextFillRect(ctx, self.bounds);
    [BACKGROUND_COLOR setFill];
    CGContextFillRect(ctx, CGRectMake(self.bounds.size.width/4 - UNIT_LABEL_WIDTH/2, 0, UNIT_LABEL_WIDTH, self.bounds.size.height));
    CGContextFillRect(ctx, CGRectMake((3*self.bounds.size.width)/4 - UNIT_LABEL_WIDTH/2, 0, UNIT_LABEL_WIDTH, self.bounds.size.height));
}

@end
