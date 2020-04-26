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

@interface CSGlassView()

@property (nonatomic, weak) UIView *magnifiedView;
@property (nonatomic, weak) UIView *glassening;
@property (nonatomic, weak) CADisplayLink *displayLink;

@end

@implementation CSGlassView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.opaque = YES;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0, SHADOW_SIZE);
        self.layer.shadowOpacity = 0.075;
        
        UIView *glassening = [[UIView alloc] init];
        [self addSubview:self.glassening];
        self.glassening = glassening;
        self.glassening.opaque = NO;
        self.glassening.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:0.025];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(observeSceneLifecycle:)
                                                     name:UISceneWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(observeSceneLifecycle:)
                                                     name:UISceneDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.glassening.frame = self.bounds;
}

- (void)observeSceneLifecycle: (NSNotification *)sceneLifecycleChangeNotification
{
    if (((UIScene *)[sceneLifecycleChangeNotification object]) == self.window.windowScene) {
        if ([[sceneLifecycleChangeNotification name] isEqualToString:UISceneDidEnterBackgroundNotification]) {
            [self.displayLink invalidate];
        } else if ([[sceneLifecycleChangeNotification name] isEqualToString:UISceneWillEnterForegroundNotification]) {
            CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshMagnifiedView)];
            [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            self.displayLink = displayLink;
        }
    }
}


- (void)refreshMagnifiedView
{
    [self.magnifiedView removeFromSuperview];
    CGPoint imageUnderGlassOrigin = [self.viewToMagnify convertPoint:CGPointMake(0, 0) fromView:self];
    CGFloat widthIncrease = (MAGNIFYING_FACTOR - 1)*self.bounds.size.width;
    CGFloat heightIncrease = (MAGNIFYING_FACTOR - 1)*self.bounds.size.height;
    
    UIView *magnifiedView = [self.viewToMagnify resizableSnapshotViewFromRect:CGRectMake(
                                                                                         imageUnderGlassOrigin.x + widthIncrease/2,
                                                                                         imageUnderGlassOrigin.y + heightIncrease/2,
                                                                                         self.bounds.size.width - widthIncrease,
                                                                                         self.bounds.size.height - heightIncrease
                                                                                         )
                                                           afterScreenUpdates:NO
                                                                withCapInsets:UIEdgeInsetsZero];
    
    
    magnifiedView.frame = self.bounds;
    [self insertSubview:magnifiedView atIndex:0];
    self.magnifiedView = magnifiedView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Pass through all events
    return NO;
}

@end
