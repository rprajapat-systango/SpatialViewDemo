//
//  WMShapeOutlineView.h
//  SpatialViewDemo
//
//  Created by Systango on 03/09/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMSpatialViewShape.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WMShapeOutlineViewDelegate <NSObject>
- (void)removeShape:(WMSpatialViewShape *)shape;
- (void)copyShape:(WMSpatialViewShape *)shape;
- (void)rotateShape:(WMSpatialViewShape *)shape;
@end

@interface WMShapeOutlineView : UIView
@property WMSpatialViewShape *selectedShape;

@property (weak) id<WMShapeOutlineViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
