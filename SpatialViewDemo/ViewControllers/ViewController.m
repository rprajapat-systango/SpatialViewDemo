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

typedef enum : NSUInteger {
    Rotate = 100,
    Resize = 200,
    Delete = 300,
    Copy = 400,
} WMSpatialViewMenuOptions;

@interface ViewController (){
    NSArray *dataSource;
    WMSpatialViewShape *selectedShape;
    CGRect previousShapeFrame;
    CGRect previousOutlineFrame;
    CGPoint previousTouchPoint;
    Shape selectedShapeType;
}

@property (strong, nonatomic) IBOutlet UIView *viewShapeSelection;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    dataSource = [self getShapesModel];
    [self setupSpatialView];
    selectedShapeType = NONE;
    [self showFooterView:NO withAnimation:NO] ;
}

- (IBAction)menuOptionTapped:(UIButton *)sender {
    [self perfomrActionOnShapeUsingMenuOption:sender.tag];
}

- (IBAction)addShapeAction:(UIButton *)sender {
    
}

- (IBAction)allowOverlappingAction:(UISwitch *)sender {
    self.spatialView.allowOverlappingView = sender.isOn;
}

- (IBAction)resetAllShapes:(id)sender {
    [self.spatialView clearAll];
    [self.spatialView reloadShapes];
}

- (void)perfomrActionOnShapeUsingMenuOption:(WMSpatialViewMenuOptions)option{
    switch (option) {
        case Rotate:
            // Code for rotate shape
            NSLog(@"Rotate");
            [selectedShape rotateByAngle:M_PI_2/2];
            [self.spatialView setOutlineViewOverShape:selectedShape];
            [self.spatialView contentViewSizeToFit];
            break;
        case Resize:
            // Code for resize shape
            NSLog(@"Resize");
            break;
        case Delete:
            // Code for move shape
            NSLog(@"Delete");
            if (selectedShape){
                [self removeItemFromDatasource:selectedShape];
            }
            break;
        case Copy:
            // Code for delete shape
            NSLog(@"Copy");
//            [self.spatialView clearSelection];
            if (selectedShape){
                selectedShapeType = selectedShape.shapeType;
                [self showFooterView:YES withAnimation:YES];
            }
            break;
    }
}

- (void)setupSpatialView {
    self.spatialView.actionDelegate = self;
    self.spatialView.dataSource = self;
    self.spatialView.margin = 20;
    self.spatialView.minimumZoomScale = 0.4;
    self.spatialView.maximumZoomScale = 1.5;
    [self.spatialView reloadShapes];
}

#pragma mark WMSpatialViewDatasource
- (NSInteger)numberOfItems{
    return dataSource.count;
}

- (WMSpatialViewShape *)spatialView:(WMSpatialView *)spatialView viewForItem:(NSInteger)index{
    if (index < dataSource.count){
        WMShape *shapeModel = [dataSource objectAtIndex:index];
        WMSpatialViewShape *shape = [[WMSpatialViewShape alloc] initWithModel:shapeModel];
        return shape;
    }
     return nil;
}

- (void)spatialView:(WMSpatialView *)spatialView didSelectItem:(WMSpatialViewShape *)shape{
    _viewShapeSelection.transform = CGAffineTransformIdentity;
    if (selectedShape == shape)
    {
        selectedShape = nil;
        [_viewShapeSelection removeFromSuperview];
    }else{
        selectedShape = shape;
        [spatialView.contentView bringSubviewToFront:shape];
        [self.spatialView scrollRectToVisible:selectedShape.frame animated:NO];
    }
}

- (UIView *)spatialView:(WMSpatialView *)spatialView outlineViewForShape:(WMSpatialViewShape *)shape{
    return _viewShapeSelection;
}

- (BOOL)spatialView:(WMSpatialView *)spatialView shouldDrawShapeOnPosition:(CGPoint)pos{
    return selectedShapeType != NONE;
}

- (WMSpatialViewShape *)spatialView:(WMSpatialView *)spatialView shapeToAddAt:(CGPoint) point{
    WMShape *shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(0, 0, 200, 200);
    shapeModel.title = @"100";
    shapeModel.shapeType = (int)selectedShapeType;
    shapeModel.fillColor = [UIColor purpleColor];//[UIColor colorWithRed:158.0/255.0    green:255.0/255.0 blue:158.0/255.0 alpha:1.0];
    
    WMSpatialViewShape *shape = [[WMSpatialViewShape alloc] initWithModel:shapeModel];
    shape.center = point;
    shapeModel.frame = shape.frame;
    [self addItemIntoDatasource:shapeModel];
    
    selectedShapeType = NONE;
    return shape;
}

- (void)spatialView:(WMSpatialView *)spatialView didAddShape:(WMSpatialViewShape *)shape{
    NSLog(@"Shape Added successfully");
    [self showFooterView:NO withAnimation:YES];
}

#pragma Helper Methods

- (NSArray *)getShapesModel {
    NSMutableArray *shapes = [NSMutableArray new];
//
    WMShape *shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(50, 50, 200, 200);
    shapeModel.title = @"100";
    shapeModel.shapeType = ELLIPSE;
    shapeModel.fillColor = [UIColor colorWithRed:0.35 green:0.64 blue:0.25 alpha:1.0]; //[UIColor cyanColor];
    [shapes addObject:shapeModel];
//
//    shapeModel = [[WMShape alloc] init];
//    shapeModel.frame = CGRectMake(300, 50, 300, 200);
//    shapeModel.title = @"102";
//    shapeModel.shapeType = ELLIPSE;
//    shapeModel.fillColor = [UIColor blueColor];
//    [shapes addObject:shapeModel];
//
//    shapeModel = [[WMShape alloc] init];
//    shapeModel.frame = CGRectMake(650, 50, 120, 570);
//    shapeModel.title = @"103";
//    shapeModel.shapeType = RECTANGLE;
//    shapeModel.fillColor = [UIColor greenColor];
//    [shapes addObject:shapeModel];
//
//    shapeModel = [[WMShape alloc] init];
//    shapeModel.frame = CGRectMake(50, 300, 200, 300);
//    shapeModel.title = @"104";
//    shapeModel.shapeType = RECTANGLE;
//    shapeModel.fillColor = [UIColor greenColor];
//    [shapes addObject:shapeModel];
//
//    shapeModel = [[WMShape alloc] init];
//    shapeModel.frame = CGRectMake(300, 300, 140, 140);
//    shapeModel.title = @"105";
//    shapeModel.shapeType = DIAMOND;
//    shapeModel.fillColor = [UIColor yellowColor];
//    [shapes addObject:shapeModel];
//
//    shapeModel = [[WMShape alloc] init];
//    shapeModel.frame = CGRectMake(460, 300, 140, 140);
//    shapeModel.title = @"106";
//    shapeModel.shapeType = DIAMOND;
//    shapeModel.fillColor = [UIColor yellowColor];
//    [shapes addObject:shapeModel];
//
//    shapeModel = [[WMShape alloc] init];
//    shapeModel.frame = CGRectMake(300, 460, 140, 140);
//    shapeModel.title = @"107";
//    shapeModel.shapeType = TRIANGLE;
//    shapeModel.fillColor = [UIColor brownColor];
//    [shapes addObject:shapeModel];
//
//    shapeModel = [[WMShape alloc] init];
//    shapeModel.frame = CGRectMake(460, 460, 140, 140);
//    shapeModel.title = @"108";
//    shapeModel.shapeType = TRIANGLE;
//    shapeModel.fillColor = [UIColor brownColor];
//    shapeModel.angle = 45;
//    [shapes addObject:shapeModel];
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

- (void)removeItemFromDatasource:(WMSpatialViewShape *)shapeModel{
    [self.spatialView removeShape:selectedShape];
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:dataSource];
    [mArray removeObject:shapeModel];
    dataSource = [mArray copy];
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

@end
