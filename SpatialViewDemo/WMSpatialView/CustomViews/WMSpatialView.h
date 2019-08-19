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

NS_ASSUME_NONNULL_BEGIN

@class WMSpatialView;

@protocol WMSpatialViewDelegate <NSObject>
- (void) spatialView:(WMSpatialView *)spatialView didSelectItem:(WMSpatialViewShape *)shape;
- (BOOL) spatialView:(WMSpatialView *) spatialView shouldDrawShapeOnPosition:(CGPoint)pos;
- (WMSpatialViewShape *)spatialView:(WMSpatialView *)spatialView shapeToAddAt:(CGPoint) point;
@end

@protocol WMSpatialViewDataSource <NSObject>
- (NSInteger) numberOfItems;
- (WMSpatialViewShape *) spatialView:(WMSpatialView *)spatialView viewForItem:(NSInteger)index;
- (nullable UIView *) spatialView:(WMSpatialView *)spatialView outlineViewForShape:(WMSpatialViewShape *)shape;

@end

@interface WMSpatialView : UIScrollView <WMSpatialViewShapeDelegate, UIScrollViewDelegate>
@property (assign, nonatomic) NSInteger margin;

@property (weak) id<WMSpatialViewDataSource> dataSource;
@property (weak) id<WMSpatialViewDelegate> actionDelegate;

@property (assign) BOOL allowOverlappingView;

@property (strong) WMGraphView *contentView;
- (void)reloadShapes;
- (void)clearSelection;
- (void)contentViewSizeToFit;
- (BOOL) isOverlappingView:(WMSpatialViewShape *)shape;
- (void) setFocusOnView:(WMSpatialViewShape *)shape;
- (void)setOutlineViewOverShape:(WMSpatialViewShape *)shape;
- (void)clearAll;
- (void) removeShape:(WMSpatialViewShape *)selectedShape;
@end

NS_ASSUME_NONNULL_END
