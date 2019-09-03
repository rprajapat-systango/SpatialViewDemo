//
//  WMShapeOutlineView.h
//  SpatialViewDemo
//
//  Created by Systango on 03/09/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMSpatialView.h"
#import "WMSpatialViewShape.h"

NS_ASSUME_NONNULL_BEGIN
@class WMSpatialView;

@protocol WMShapeOutlineViewDelegate <NSObject>
- (void)removeShape:(WMSpatialViewShape *)shape;
- (void)copyShape:(WMSpatialViewShape *)shape;
@end

@interface WMShapeOutlineView : UIView
@property WMSpatialView *spatialView;
@property WMSpatialViewShape *selectedShape;

@property (weak) id<WMShapeOutlineViewDelegate> delegate;
//- (IBAction)deleteShape:(UIButton *)sender;
//- (IBAction)rotateShape:(UIButton *)sender;
//- (IBAction)copyShape:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
