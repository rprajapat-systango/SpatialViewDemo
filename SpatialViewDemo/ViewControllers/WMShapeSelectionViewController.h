//
//  WMShapeSelectionViewController.h
//  SpatialViewDemo
//
//  Created by SGVVN on 13/08/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMSpatialView.h"

@protocol WMShapeSelectionDelegate <NSObject>

- (void)didSelectShapeWithType:(Shape) type;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WMShapeSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property(weak) id<WMShapeSelectionDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
