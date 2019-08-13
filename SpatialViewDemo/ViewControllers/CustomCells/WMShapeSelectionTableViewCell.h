//
//  WMShapeSelectionTableViewCell.h
//  SpatialViewDemo
//
//  Created by SGVVN on 13/08/19.
//  Copyright © 2019 Systango. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "WMSpatialViewShape.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMShapeSelectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet WMSpatialViewShape *shapeView;
@property (weak, nonatomic) IBOutlet UILabel *lblShapeTitle;

@end

NS_ASSUME_NONNULL_END
