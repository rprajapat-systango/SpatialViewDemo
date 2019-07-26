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

@property (strong) WMGraphView *contentView;
- (void)reloadShapes;
- (void)clearSelection;
- (void)contentViewSizeToFit;
- (BOOL) isOverlappingView:(WMSpatialViewShape *)shape;
- (void) setFocusOnView:(WMSpatialViewShape *)shape;

@end

NS_ASSUME_NONNULL_END
