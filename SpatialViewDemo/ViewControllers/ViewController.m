//
//  ViewController.m
//  SpatialViewDemo
//
//  Created by Systango on 02/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "ViewController.h"
#import "WMSpatialViewShape.h"
#import "WMShapeSelectionViewController.h"

@interface ViewController (){
    NSArray *dataSource;
    NSArray *originalItems;
    Shape selectedShapeType;
    CGSize aspectRatio;
}

@property (strong, nonatomic) IBOutlet WMShapeOutlineView *shapeOutlineView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet WMSpatialView *spatialView;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    aspectRatio = CGSizeMake(8.5, 11.0);
    dataSource = [self getShapesModel];
    [self setupSpatialView];
    selectedShapeType = WMSpatialViewShapeNone;
    [self showFooterView:NO withAnimation:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.spatialView contentViewSizeToFit];
}

- (void)setupSpatialView {
    self.spatialView.allowOverlappingView = YES;
    [self.spatialView setAspectRatio:aspectRatio];
    self.spatialView.actionDelegate = self;
    self.spatialView.dataSource = self;
    self.spatialView.margin = 2;
    [self.spatialView setMinMaxZoomScale];
    [self.spatialView reloadShapes];
}

- (void)showFooterView:(BOOL)isShow withAnimation:(BOOL) animated{
    NSLayoutConstraint *heightConstraint;
    for (NSLayoutConstraint *constraint in self.footerView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            heightConstraint = constraint;
            break;
        }
    }
    if (animated){
        [UIView animateWithDuration:0.4 animations:^{
            heightConstraint.constant = isShow ? 40.0 : 0.0;
        }];
    }else{
        heightConstraint.constant = isShow ? 40.0 : 0.0;
    }
}

- (IBAction)menuOptionTapped:(UIButton *)sender {
   
}

- (IBAction)allowOverlappingAction:(UISwitch *)sender {
    self.spatialView.allowOverlappingView = sender.isOn;
}

- (IBAction)resetAllShapes:(id)sender {
    dataSource = originalItems;
    [self.spatialView clearAll];
    [self.spatialView reloadShapes];
}

- (IBAction)saveAllShapes:(id)sender {
    originalItems = [self.spatialView saveAllShapes];
}

#pragma mark WMSpatialViewDatasource
- (NSInteger)numberOfItemsInSpatialView:(WMSpatialView *)spatialView {
    return dataSource.count;
}

- (WMSpatialViewShape *)spatialView:(WMSpatialView *)spatialView viewForItem:(NSInteger)index{
    if (index < dataSource.count){
        WMShape *shapeModel = [dataSource objectAtIndex:index];
        WMSpatialViewShape *shape = [[WMSpatialViewShape alloc] initWithModel:shapeModel aspectRatio:spatialView.contentView.bounds.size];
        [shape rotateByAngle:shapeModel.angle];
        return shape;
    }
    return nil;
}

- (void)spatialView:(WMSpatialView *)spatialView didSelectItem:(WMSpatialViewShape *)shape{
    
}

- (WMShapeOutlineView *)spatialView:(WMSpatialView *)spatialView outlineViewForShape:(WMSpatialViewShape *)shape{
    return _shapeOutlineView;
}

- (BOOL)spatialView:(WMSpatialView *)spatialView shouldDrawShapeOnPosition:(CGPoint)pos{
    return selectedShapeType != WMSpatialViewShapeNone;
}

- (WMSpatialViewShape *)spatialView:(WMSpatialView *)spatialView shapeToAddAt:(CGPoint) point copyShapeFrom:(WMSpatialViewShape *)copyingShape{
    WMShape *shapeModel = [[WMShape alloc] init];
    if (copyingShape){
        CGSize shapeSize = copyingShape.bounds.size;
        shapeModel.frame = CGRectMake(point.x-shapeSize.width/2, point.y-shapeSize.height/2, shapeSize.width, shapeSize.height);
        shapeModel.shapeType = (int)copyingShape.shapeType;
        shapeModel.angle = [copyingShape getAngleFromTransform];
    }else{
        float minSize = MIN(self.spatialView.contentView.bounds.size.width, self.spatialView.contentView.bounds.size.height);
        CGSize shapeSize = CGSizeMake(minSize*self.spatialView.zoomScale/7, minSize*self.spatialView.zoomScale/7);
        shapeModel.frame = CGRectMake(point.x-shapeSize.width/2, point.y-shapeSize.height/2, shapeSize.width, shapeSize.height);
        shapeModel.shapeType = (int)selectedShapeType;
    }
    
    shapeModel.title = @"100";
    shapeModel.fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    
    NSLog(@"shape Model color %@" , shapeModel);
    
    WMSpatialViewShape *shape = [[WMSpatialViewShape alloc] initWithModel:shapeModel aspectRatio:spatialView.contentView.bounds.size];
    if(shapeModel.angle != 0.0){
        [shape rotateByAngle:shapeModel.angle];
    }
    
    shape.center = point;
    shapeModel.frame = shape.frame;
    [self addItemIntoDatasource:shapeModel];
    [shape setNeedsDisplay];
    selectedShapeType = WMSpatialViewShapeNone;
    copyingShape = nil;
    return shape;
}


- (void)spatialView:(WMSpatialView *)spatialView willAddShape:(WMSpatialViewShape *)shape{
    [self showFooterView:YES withAnimation:YES];
    [self.spatialView clearSelection];
}

- (void)spatialView:(WMSpatialView *)spatialView didAddShape:(WMSpatialViewShape *)shape{
    NSLog(@"Shape Added successfully");
    [self showFooterView:NO withAnimation:YES];
}

#pragma Helper Methods

- (NSArray *)getShapesModel {
    NSMutableArray *shapes = [NSMutableArray new];

    return [shapes copy];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"segueShapeSelection"]){
        WMShapeSelectionViewController *vc = (WMShapeSelectionViewController *)segue.destinationViewController;
        vc.preferredContentSize = CGSizeMake(300, 225);
        vc.delegate = self;
    }
}

#pragma mark WMShapeSelectionDelegate

- (void)didSelectShapeWithType:(Shape) type{
    NSLog(@"Selected Shape %lu",(unsigned long)type);
    self.footerView.hidden = NO;
    selectedShapeType = type;
    [self showFooterView:YES withAnimation:YES];
}

- (void)addItemIntoDatasource:(WMShape *)shapeModel{
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:dataSource];
    [mArray addObject:shapeModel];
    dataSource = [mArray copy];
}

@end
