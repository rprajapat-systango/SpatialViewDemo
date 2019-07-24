//
//  WMShape.h
//  SpatialViewDemo
//
//  Created by Systango on 17/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMShape : NSObject
@property(assign) CGRect frame;
@property(assign) UIColor *fillColor;
@property(assign) UIColor *borderColor;
@property(assign) NSString *title;
@property(assign) int shapeType;
@property(assign) float angle;

@end

NS_ASSUME_NONNULL_END
