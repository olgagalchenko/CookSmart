//
//  CSMagnifyingView.h
//  CookSmart
//
//  Created by Vova Galchenko on 2/27/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGlassView : UIView

@property (nonatomic, weak) IBOutlet UIView *viewToMagnify;

- (id)initWithMagnifiedView: (UIView *)magnifiedView;

@end
