//
//  WMSpatialView.h
//  SpatialViewDemo
//
//  Created by SGVVN on 05/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMSpatialView : UIScrollView
@property (assign, nonatomic) NSInteger margin;

@property (strong) UIView *contentView;
- (void)loadViewsOnCanvas;

@end

NS_ASSUME_NONNULL_END
