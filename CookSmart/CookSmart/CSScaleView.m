//
//  CSScaleView.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/24/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSScaleView.h"
#import "CSScaleTile.h"

#define SCALE_TILE_HEIGHT       200.0

@interface CSScaleView()

@property (nonatomic, readwrite, assign) CGFloat accumulatedOffset;
@property (nonatomic, readwrite, strong) UIView *tileContainer;
@property (nonatomic, readwrite, assign) NSUInteger unitsPerTile;

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
    self.scrollsToTop = NO;
    self.pagingEnabled = NO;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = NO;
    self.bouncesZoom = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height*2);
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
    
    CGFloat currentOffset = self.contentOffset.y;
    CGFloat contentHeight = self.contentSize.height;
#define OFFSET_EDGE_PROXIMITY_THRESHOLD     (.25*self.bounds.size.height)
    CGFloat maxOffset = (contentHeight - self.bounds.size.height) - OFFSET_EDGE_PROXIMITY_THRESHOLD;
    CGFloat minOffset = OFFSET_EDGE_PROXIMITY_THRESHOLD;
    CGFloat newOffset = currentOffset;
    if (currentOffset > maxOffset)
    {
        newOffset = minOffset;
    }
    else if (currentOffset < minOffset && self.accumulatedOffset > 0)
    {
        newOffset = MIN(maxOffset, currentOffset + self.accumulatedOffset);
    }
    
    if (currentOffset != newOffset)
    {
        CGFloat dyCounteract = currentOffset - newOffset;
        
        setScrollViewOffset(self, CGPointMake(self.contentOffset.x, newOffset), NO);
        self.tileContainer.center = CGPointMake(self.tileContainer.center.x, self.tileContainer.center.y - dyCounteract);
        self.accumulatedOffset += dyCounteract;
    }
    
    CGRect visibleBounds = [self convertRect:[self bounds] toView:self.tileContainer];
    
    CGFloat minimumVisibleY = CGRectGetMinY(visibleBounds);
    CGFloat maximumVisibleY = CGRectGetMaxY(visibleBounds);
    for (CSScaleTile *tile in self.tileContainer.subviews)
    {
        CGRect tileFrame = tile.frame;
        CGFloat maxY = CGRectGetMaxY(tileFrame);
        CGFloat minY = CGRectGetMinY(tileFrame);
        
        if (minY > maximumVisibleY &&
            tile.frame.origin.y - (self.tileContainer.subviews.count - 1)*SCALE_TILE_HEIGHT > minimumVisibleY)
        {
            tile.frame = CGRectMake(0, tile.frame.origin.y - (self.tileContainer.subviews.count)*SCALE_TILE_HEIGHT, self.bounds.size.width, SCALE_TILE_HEIGHT);
            tile.value -= self.tileContainer.subviews.count*self.unitsPerTile;
        }
        else if (maxY < minimumVisibleY &&
                 tile.frame.origin.y + (self.tileContainer.subviews.count)*SCALE_TILE_HEIGHT < maximumVisibleY)
        {
            tile.frame = CGRectMake(0, tile.frame.origin.y + (self.tileContainer.subviews.count)*SCALE_TILE_HEIGHT, self.bounds.size.width, SCALE_TILE_HEIGHT);
            tile.value += self.tileContainer.subviews.count*self.unitsPerTile;
        }
    }
}

- (void)configureScaleViewWithInitialCenterValue:(float)centerValue
                                           scale:(NSUInteger)unitsPerTile
{
    if (!self.tileContainer)
    {
        self.tileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
    }
    else
    {
        self.tileContainer.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    }
    for (CSScaleView *subview in self.tileContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    setScrollViewOffset(self, CGPointMake(0, 0), NO);
    int numTiles = ((int)self.bounds.size.height)/SCALE_TILE_HEIGHT + 2;
    CGFloat lowestTileY = 0;
    for (int i = 0; i < numTiles; i++)
    {
        CSScaleTile *tile = [[CSScaleTile alloc] initWithFrame:CGRectMake(0, lowestTileY, self.bounds.size.width, SCALE_TILE_HEIGHT)];
        [self.tileContainer addSubview:tile];
        lowestTileY += SCALE_TILE_HEIGHT;
    }
    [self addSubview:self.tileContainer];
    
    NSUInteger midTileIndex = (self.tileContainer.subviews.count - 1)/2;
    NSUInteger roundedCenterValue = (NSUInteger) round(centerValue);
    roundedCenterValue = roundedCenterValue - roundedCenterValue%unitsPerTile;
    self.unitsPerTile = unitsPerTile;
    for (int i = 0; i < self.tileContainer.subviews.count; i++)
    {
        [(CSScaleTile *)self.tileContainer.subviews[i] setValue:roundedCenterValue + (i - midTileIndex)*unitsPerTile];
    }
    self.accumulatedOffset = ((roundedCenterValue - midTileIndex*unitsPerTile)/unitsPerTile)*SCALE_TILE_HEIGHT + self.bounds.size.height/2;
    
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
    return (SCALE_TILE_HEIGHT/scaleView.unitsPerTile);
}

static inline void setScrollViewOffset(CSScaleView *scaleView, CGPoint newContentOffset, BOOL cancelDeceleration)
{
    id delegate = scaleView.delegate;
    scaleView.delegate = nil;
    if (cancelDeceleration)
    {
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
