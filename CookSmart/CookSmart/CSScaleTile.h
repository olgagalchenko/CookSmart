//
//  CSScaleTile.h
//  CookSmart
//
//  Created by Vova Galchenko on 1/24/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSScaleTile : UIView

- (id)initWithFrame:(CGRect)frame mirror:(BOOL)mirror;

@property (nonatomic, readwrite, assign) float value;

@end
