//
//  ViewController.m
//  SpatialViewDemo
//
//  Created by SGVVN on 02/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "ViewController.h"
#import "WMShapeView.h"

@interface ViewController (){
    NSArray *dataSource;
}

@end

@implementation ViewController

- (void)setupSpatialView {
    self.spatialView.delegate = self;
    self.spatialView.actionDelegate = self;
    self.spatialView.dataSource = self;
    self.spatialView.margin = 20;
    self.spatialView.minimumZoomScale = 0.1;
    self.spatialView.maximumZoomScale = 2.0;
    [self.spatialView reloadShapes];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dataSource = [self getShapesModel];
    [self setupSpatialView];
}

#pragma mark WMSpatialViewDatasource
- (NSInteger)numberOfItems{
    return dataSource.count;
}

- (WMShapeView *)spatialView:(WMSpatialView *)spatialView viewForItem:(NSInteger)index{
    if (index < dataSource.count){
        WMShape *shapeModel = [dataSource objectAtIndex:index];
        WMShapeView *shape = [[WMShapeView alloc] initWithModel:shapeModel withDelegate:self];
        return shape;
    }
     return nil;
}

#pragma mark WMSpatialViewDelaget


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


- (void)didTapOnView:(nonnull WMShapeView *)shape {
    
}

#pragma Helper Methods

- (NSArray *)getShapesModel {
    NSMutableArray *shapes = [NSMutableArray new];
    
    WMShape *shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(50, 50, 200, 200);
    shapeModel.title = @"100";
    shapeModel.shapeType = ELLIPSE;
    shapeModel.fillColor = [UIColor redColor];
    [shapes addObject:shapeModel];
    
    shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(300, 50, 300, 200);
    shapeModel.title = @"102";
    shapeModel.shapeType = ELLIPSE;
    shapeModel.fillColor = [UIColor blueColor];
    [shapes addObject:shapeModel];
    
    
    shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(650, 50, 120, 570);
    shapeModel.title = @"103";
    shapeModel.shapeType = RECTANGLE;
    shapeModel.fillColor = [UIColor greenColor];
    [shapes addObject:shapeModel];
    
    
    shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(50, 300, 200, 300);
    shapeModel.title = @"104";
    shapeModel.shapeType = RECTANGLE;
    shapeModel.fillColor = [UIColor greenColor];
    [shapes addObject:shapeModel];
    
    
    shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(300, 300, 140, 140);
    shapeModel.title = @"105";
    shapeModel.shapeType = DIAMOND;
    shapeModel.fillColor = [UIColor yellowColor];
    [shapes addObject:shapeModel];
    
    shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(460, 300, 140, 140);
    shapeModel.title = @"106";
    shapeModel.shapeType = DIAMOND;
    shapeModel.fillColor = [UIColor yellowColor];
    [shapes addObject:shapeModel];
    
    
    shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(300, 460, 140, 140);
    shapeModel.title = @"107";
    shapeModel.shapeType = TRIANGLE;
    shapeModel.fillColor = [UIColor yellowColor];
    [shapes addObject:shapeModel];
    
    
    shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(460, 460, 140, 140);
    shapeModel.title = @"108";
    shapeModel.shapeType = TRIANGLE;
    shapeModel.fillColor = [UIColor yellowColor];
    shapeModel.angle = 45;
    [shapes addObject:shapeModel];
    
    return [shapes copy];
}


@end
