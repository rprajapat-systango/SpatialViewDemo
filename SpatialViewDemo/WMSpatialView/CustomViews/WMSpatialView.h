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

@interface WMSpatialView : UIScrollView <WMShapeViewDelegate>
@property (assign, nonatomic) NSInteger margin;

@property (strong) WMGraphView *contentView;
- (void)loadShapes:(NSArray *)shapes;

@end

NS_ASSUME_NONNULL_END
