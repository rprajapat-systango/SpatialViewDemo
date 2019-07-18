//
//  WMShapeView.h
//  SpatialViewDemo
//
//  Created by SGVVN on 02/07/19.
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
@class WMShapeView;

@protocol WMShapeViewDelegate <NSObject>
- (void) didTapOnView:(WMShapeView *)shape;
@end


@interface WMShapeView : UIView
//- (instancetype)initWithFrame:(CGRect)frame type:(Shape)shape title:(NSString *)title andColor:(UIColor *)color withDelegate:(id<WMShapeViewDelegate>) delegate;
- (instancetype)initWithModel:(WMShape *)shapeModel withDelegate:(id<WMShapeViewDelegate>)delegate;
@property(assign) UIColor *borderColor;
@property(assign) NSString *identifier;
@property(nonatomic, assign) BOOL isSelected;
@end



NS_ASSUME_NONNULL_END
