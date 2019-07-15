//
//  ViewController.h
//  SpatialViewDemo
//
//  Created by SGVVN on 02/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMSpatialView.h"

@interface ViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet WMSpatialView *spatialView;

@end

