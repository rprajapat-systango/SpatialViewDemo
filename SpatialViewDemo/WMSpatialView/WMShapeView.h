//
//  WMShapeView.h
//  SpatialViewDemo
//
//  Created by SGVVN on 02/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RECTANGLE = 0,
    CIRCLE,
    ELLIPSE,
    DIAMOND
} Shape;


@interface WMShapeView : UIView
- (instancetype)initWithFrame:(CGRect)frame type:(Shape)shape title:(NSString *)title andColor:(UIColor *)color;
@property(assign) UIColor *borderColor;
@end



NS_ASSUME_NONNULL_END
