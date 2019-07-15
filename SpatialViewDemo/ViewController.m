//
//  ViewController.m
//  SpatialViewDemo
//
//  Created by SGVVN on 02/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "ViewController.h"
#import "WMShapeView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spatialView.margin = 20;
    self.spatialView.delegate = self;
    [self.spatialView loadViewsOnCanvas];
    [self setZoomScale];
}

-(void)setZoomScale{
    self.spatialView.minimumZoomScale = 0.1;
    self.spatialView.maximumZoomScale = 2.0;
//    self.spatialView.minimumZoomScale = MIN(self.spatialView.bounds.size.width /self.spatialView.contentView.bounds.size.width, self.spatialView.bounds.size.height / self.spatialView.contentView.bounds.size.height);
//
//    if (self.spatialView.zoomScale < self.spatialView.minimumZoomScale){
//            self.spatialView.zoomScale = self.spatialView.minimumZoomScale;
//    }
}

#pragma mark UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return scrollView.subviews[0];
}     // return a view that will be scaled. if delegate returns nil, nothing happens
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    NSLog(@"View rect %@", NSStringFromCGRect(view.frame));
} // called before the scroll view begins zooming its content

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    NSLog(@"New scale set to %01f", scale);
} // scale between minimum and maximum. called after any 'bounce' animations

@end
