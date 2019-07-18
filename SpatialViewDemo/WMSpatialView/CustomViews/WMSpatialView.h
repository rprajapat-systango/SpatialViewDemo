//
//  WMSpatialView.h
//  SpatialViewDemo
//
//  Created by SGVVN on 05/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMGraphView.h"
#import "WMShapeView.h"

NS_ASSUME_NONNULL_BEGIN

@class WMSpatialView;

@protocol WMSpatialViewDelegate <NSObject>
- (void) didSelectItem:(WMShapeView *)shape;
@end

@protocol WMSpatialViewDataSource <NSObject>
- (NSInteger) numberOfItems;
- (WMShapeView *) spatialView:(WMSpatialView *)spatialView viewForItem:(NSInteger)index;
@end

@interface WMSpatialView : UIScrollView <WMShapeViewDelegate>
@property (assign, nonatomic) NSInteger margin;

@property (weak) id<WMSpatialViewDataSource> dataSource;
@property (weak) id<WMSpatialViewDelegate> actionDelegate;

@property (strong) WMGraphView *contentView;
- (void)reloadShapes;

@end

NS_ASSUME_NONNULL_END
