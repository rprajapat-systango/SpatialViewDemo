//
//  WMSpatialView.h
//  SpatialViewDemo
//
//  Created by Systango on 05/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMGraphView.h"
#import "WMSpatialViewShape.h"
#import "WMShapeOutlineView.h"

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    Up = 10,
    Right = 20,
    Down = 30,
    Left = 40,
    Aspect = 50,
} WMSpatialViewDragDirection;


@class WMSpatialView;
@class WMShapeOutlineView;

@protocol WMSpatialViewDelegate <NSObject>
- (void) spatialView:(WMSpatialView *)spatialView didSelectItem:(WMSpatialViewShape *)shape;
- (BOOL) spatialView:(WMSpatialView *) spatialView shouldDrawShapeOnPosition:(CGPoint)pos;
- (WMSpatialViewShape *)spatialView:(WMSpatialView *)spatialView shapeToAddAt:(CGPoint) point copyShapeFrom:(WMSpatialViewShape *)copyingShape;
- (void)spatialView:(WMSpatialView *)spatialView willAddShape:(WMSpatialViewShape *)shape;
- (void)spatialView:(WMSpatialView *)spatialView didAddShape:(WMSpatialViewShape *) shape;
@end

@protocol WMSpatialViewDataSource <NSObject>
- (NSInteger)numberOfItemsInSpatialView:(WMSpatialView *)spatialView;
- (WMSpatialViewShape *) spatialView:(WMSpatialView *)spatialView viewForItem:(NSInteger)index;
- (nullable WMShapeOutlineView *) spatialView:(WMSpatialView *)spatialView outlineViewForShape:(WMSpatialViewShape *)shape;

@end

@interface WMSpatialView : UIScrollView <WMSpatialViewShapeDelegate, UIScrollViewDelegate, WMShapeOutlineViewDelegate>
@property (assign, nonatomic) NSInteger margin;

@property (weak) id<WMSpatialViewDataSource> dataSource;
@property (weak) id<WMSpatialViewDelegate> actionDelegate;

@property (assign) BOOL allowOverlappingView;
@property (assign) CGSize aspectRatio;

@property (strong) WMGraphView *contentView;
- (void)reloadShapes;
- (void)clearSelection;
- (void)contentViewSizeToFit;
- (BOOL) isOverlappingView:(WMSpatialViewShape *)shape;
- (void) setFocusOnView:(WMSpatialViewShape *)shape;
- (void)setOutlineViewOverShape:(WMSpatialViewShape *)shape;
- (void)clearAll;
- (NSArray *)saveAllShapes;
- (void)setMinMaxZoomScale;
- (void) removeShape:(WMSpatialViewShape *)selectedShape;
+ (BOOL)isDeviceTypeIpad;
@end

NS_ASSUME_NONNULL_END
