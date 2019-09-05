//
//  ViewController.h
//  SpatialViewDemo
//
//  Created by Systango on 02/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMSpatialView.h"
#import "WMShapeSelectionViewController.h"
#import "WMShapeOutlineView.h"

@interface ViewController : UIViewController<UIScrollViewDelegate,WMShapeSelectionDelegate ,WMSpatialViewDelegate, WMSpatialViewDataSource>



@end

