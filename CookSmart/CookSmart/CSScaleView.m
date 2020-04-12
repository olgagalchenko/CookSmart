//
//  CSScaleView.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/24/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSScaleView.h"
#import "cake-Swift.h"

#define SCALE_TILE_HEIGHT       200.0

@interface CSScaleView()

@property (nonatomic, readwrite, assign) CGFloat accumulatedOffset;
@property (nonatomic, readwrite, strong) UIView *tileContainer;
@property (nonatomic, readwrite, assign) NSUInteger unitsPerTile;
@property (nonatomic, readwrite, assign) CGFloat previousContentOffset;
@property (nonatomic, readwrite, strong) NSDate *prevTime;

@end

@implementation CSScaleView

- (id)init
{
    if ((self = [super init]))
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecode
{
    if ((self = [super initWithCoder:aDecode]))
    {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.bounces = NO;
    self.pagingEnabled = NO;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = NO;
    self.bouncesZoom = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height*10);
    self.accumulatedOffset = 0;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [tapRecognizer addTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapRecognizer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.delegate respondsToSelector:@selector(isSnapping)] && [self.delegate performSelector:@selector(isSnapping)])
    {
        // We snap these views to values in an animated way. We don't want to be messing with the contentOffset
        // and tile moves inside an animation block. For that reason, we will forego this work during the snapping animation.
        return;
    }
    
    CGFloat currentOffset = self.contentOffset.y;
    CGFloat targetContentOffset = getTargetContentOffset(self);
#define OFFSET_THRESHOLD     (self.bounds.size.height)
    CGFloat maxOffset = targetContentOffset + OFFSET_THRESHOLD;
    CGFloat minOffset = targetContentOffset - OFFSET_THRESHOLD;
    CGFloat newOffset = currentOffset;
    if (currentOffset > maxOffset ||
        (currentOffset < minOffset && self.accumulatedOffset > 0))
    {
        newOffset = MIN(targetContentOffset, currentOffset + self.accumulatedOffset);
    }
    
    if (currentOffset != newOffset)
    {
        CGFloat dyCounteract = currentOffset - newOffset;
        
        setScrollViewOffset(self, CGPointMake(self.contentOffset.x, newOffset), NO);
        self.previousContentOffset = newOffset;
        self.tileContainer.center = CGPointMake(self.tileContainer.center.x, self.tileContainer.center.y - dyCounteract);
        self.accumulatedOffset += dyCounteract;
    }
    
    CGRect visibleBounds = [self convertRect:[self bounds] toView:self.tileContainer];
    
    CGFloat minimumVisibleY = CGRectGetMinY(visibleBounds);
    CGFloat maximumVisibleY = CGRectGetMaxY(visibleBounds);
    for (ScaleTile *tile in self.tileContainer.subviews)
    {
        CGRect tileFrame = tile.frame;
        CGFloat maxY = CGRectGetMaxY(tileFrame);
        CGFloat minY = CGRectGetMinY(tileFrame);
        
        if (minY > maximumVisibleY &&
            tileFrame.origin.y - (self.tileContainer.subviews.count - 2)*SCALE_TILE_HEIGHT > minimumVisibleY)
        {
            CGFloat decreaseFactor = (self.tileContainer.subviews.count)*SCALE_TILE_HEIGHT;
            CGFloat offBy = minY - maximumVisibleY;
            CGFloat timesDecreaseFactor = ceil(offBy/decreaseFactor);
            tile.frame = CGRectMake(0, tileFrame.origin.y - timesDecreaseFactor*decreaseFactor, self.bounds.size.width, SCALE_TILE_HEIGHT);
            tile.value = unitsPerPoint(self)*(tile.frame.origin.y);
        }
        else if (maxY < minimumVisibleY &&
                 tileFrame.origin.y + (self.tileContainer.subviews.count - 1)*SCALE_TILE_HEIGHT < maximumVisibleY)
        {
            CGFloat increaseFactor = (self.tileContainer.subviews.count)*SCALE_TILE_HEIGHT;
            CGFloat offBy = minimumVisibleY - maxY;
            CGFloat timesIncreaseFactor = ceil(offBy/increaseFactor);
            tile.frame = CGRectMake(0, tileFrame.origin.y + timesIncreaseFactor*increaseFactor, self.bounds.size.width, SCALE_TILE_HEIGHT);
            tile.value = unitsPerPoint(self)*(tile.frame.origin.y);
        }
    }
}

- (void)configureScaleViewWithInitialCenterValue:(float)centerValue
                                           scale:(NSUInteger)unitsPerTile
                                          mirror:(BOOL)mirror
{
    self.unitsPerTile = unitsPerTile;
    setScrollViewOffset(self, CGPointMake(0, 0), NO);
    if (!self.tileContainer)
    {
        self.tileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    else
    {
        self.tileContainer.frame = CGRectMake(0, 0, 0, 0);
    }
    for (ScaleTile *subview in self.tileContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    [self addSubview:self.tileContainer];
    int i = 0;
    CGPoint centerPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float actualCenterValue = 0;
    for (CGFloat lowestTileY = 0; lowestTileY < self.contentSize.height/2; lowestTileY += SCALE_TILE_HEIGHT, i++)
    {
        CGRect tileRect = CGRectMake(0, lowestTileY, self.bounds.size.width, SCALE_TILE_HEIGHT);
        float tileValue = i*unitsPerTile;
        ScaleTile *tile = [[ScaleTile alloc] initWithFrame:tileRect mirror:mirror];
        [tile setValue:tileValue];
        [self.tileContainer addSubview:tile];
        if (CGRectContainsPoint(tileRect, centerPoint))
        {
            actualCenterValue = tileValue + unitsPerPoint(self)*(centerPoint.y - tileRect.origin.y);
        }
    }

    self.accumulatedOffset = actualCenterValue*ptsPerUnit(self);
    [self setCenterValue:centerValue cancelDeceleration:YES];
}


- (CGFloat)virtualContentOffset
{
    return self.contentOffset.y + self.accumulatedOffset;
}

- (float)getCenterValue
{
    CGFloat offset = [self virtualContentOffset];
    return offset*unitsPerPoint(self);
}

- (void)setCenterValue:(float)newCenterValue cancelDeceleration:(BOOL)cancelDeceleration
{
    setScrollViewOffset(self, CGPointMake(0, ptsPerUnit(self)*newCenterValue - self.accumulatedOffset), cancelDeceleration);
}

static inline CGFloat unitsPerPoint(CSScaleView *scaleView)
{
    return (scaleView.unitsPerTile/SCALE_TILE_HEIGHT);
}

static inline CGFloat ptsPerUnit(CSScaleView *scaleView)
{
  CGFloat pts = (SCALE_TILE_HEIGHT/scaleView.unitsPerTile);
  if (isnan(pts)) {
    return 0;
  }
    return pts;
}

static inline CGFloat getTargetContentOffset(CSScaleView *scaleView)
{
    CGFloat centerX = scaleView.contentSize.height/2;
    return centerX - scaleView.bounds.size.height/2;
}

static inline void setScrollViewOffset(CSScaleView *scaleView, CGPoint newContentOffset, BOOL cancelDeceleration)
{
  if (isnan(newContentOffset.y)) {
    return;
  }
    id delegate = scaleView.delegate;
    scaleView.delegate = nil;
    if (cancelDeceleration)
    {
      NSLog(@"%f", newContentOffset.y);
        [scaleView setContentOffset:newContentOffset animated:NO];
    }
    else
    {
        scaleView.contentOffset = newContentOffset;
    }
    scaleView.delegate = delegate;
}

- (void)handleTap:(UIGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(scaleViewTapped:)])
    {
        [self.delegate performSelector:@selector(scaleViewTapped:) withObject:self];
    }
}

@end
