//
//  WMSpatialViewShape.h
//  SpatialViewDemo
//
//  Created by Systango on 02/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMShape.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RECTANGLE = 0,
    CIRCLE,
    ELLIPSE,
    DIAMOND,
    TRIANGLE
} Shape;
@class WMSpatialViewShape;

@protocol WMSpatialViewShapeDelegate <NSObject>
- (void) didTapOnView:(WMSpatialViewShape *)shape;
@end


@interface WMSpatialViewShape : UIView
- (instancetype)initWithModel:(WMShape *)shapeModel;
@property(assign) UIColor *borderColor;
@property(assign) NSString *identifier;
@property (strong, nonatomic) UIStackView *stackView;
@property(nonatomic, assign) BOOL isSelected;
@property (weak) id<WMSpatialViewShapeDelegate> delegate;
@end

NS_ASSUME_NONNULL_END