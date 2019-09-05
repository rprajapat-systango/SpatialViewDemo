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
    WMSpatialViewShapeRectangle = 0,
    WMSpatialViewShapeEllips,
    WMSpatialViewShapeDiamond,
    WMSpatialViewShapeTriangle,
    WMSpatialViewShapeNone = -1
    
} Shape;
@class WMSpatialViewShape;

@protocol WMSpatialViewShapeDelegate <NSObject>
- (void) didTapOnView:(WMSpatialViewShape *)shape;
@end


@interface WMSpatialViewShape : UIView
- (instancetype)initWithModel:(WMShape *)shapeModel aspectRatio:(CGSize)aspectRatio;
@property(strong, retain) UIColor *borderColor;
@property(assign) NSString *identifier;
@property (strong, nonatomic) UIStackView *stackView;
@property(nonatomic, assign) BOOL isSelected;
@property (weak) id<WMSpatialViewShapeDelegate> delegate;
@property(assign) Shape shapeType;
@property (strong, nonatomic) WMShape *shapeModel;
- (void)configureWithType:(Shape)type;
- (CGFloat)getAngleFromTransform;
- (void)rotateByAngle:(CGFloat)angle;
@end

NS_ASSUME_NONNULL_END
