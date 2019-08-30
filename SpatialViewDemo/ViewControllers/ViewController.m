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
    NSArray *originalItems;
    WMSpatialViewShape *selectedShape;
    CGRect previousShapeFrame;
    CGRect previousOutlineFrame;
    CGPoint previousTouchPoint;
    Shape selectedShapeType;
    WMSpatialViewShape *shapeToCopy;
    CGSize aspectRatio;
}

@property (strong, nonatomic) IBOutlet UIView *viewShapeSelection;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet WMSpatialView *spatialView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segemnt;
@property (weak, nonatomic) IBOutlet UIView *iPhoneContainer;
@property (weak, nonatomic) IBOutlet UIView *iPadContainer;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.segemnt addTarget:self action:@selector(changeLayout:) forControlEvents:UIControlEventValueChanged];
    
    aspectRatio = CGSizeMake(8.5, 11.0);
    dataSource = [self getShapesModel];
    [self setupSpatialView];
    selectedShapeType = NONE;
    [self showFooterView:NO withAnimation:NO];
    self.iPhoneContainer.hidden = YES;
    _iPhoneContainer.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _iPhoneContainer.layer.borderWidth = 1.0f;
    
}

- (void)changeLayout:(UISegmentedControl *)sender{
     [self saveAllShapes:nil];
    CGRect frame = CGRectZero;
    [self.spatialView removeFromSuperview];
    if (sender.selectedSegmentIndex == 0){
        frame.size = self.iPadContainer.bounds.size;
        [self.iPadContainer addSubview:self.spatialView];
        self.spatialView.frame = frame;
        self.iPhoneContainer.hidden = YES;
        self.iPadContainer.hidden = NO;
    }else{
        frame.size = self.iPhoneContainer.bounds.size;
        [self.iPhoneContainer addSubview:self.spatialView];
        self.spatialView.frame = frame;
        self.iPhoneContainer.hidden = NO;
        self.iPadContainer.hidden = YES;
    }
    self.spatialView.contentOffset = CGPointMake(0, 0);
    [self resetAllShapes:nil];
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
    [self perfomrActionOnShapeUsingMenuOption:sender.tag];
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
//    NSString *json = @"";
//    for (WMShape *model in originalItems) {
//        if (json.length != 0){
//
//        }else{
//            json = [json stringByAppendingString:model.description];
//        }
//    }
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
        case Delete:
            // Code for delete shape
            NSLog(@"Delete");
            if (selectedShape){
                [self removeItemFromDatasource:selectedShape];
            }
            break;
        case Copy:
            // Code for copy shape
            NSLog(@"Copy");
            if (selectedShape){
                shapeToCopy = selectedShape;
                selectedShapeType = selectedShape.shapeType;
                [self showFooterView:YES withAnimation:YES];
                [self.spatialView clearSelection];
            }
            break;
        default:
            break;
    }
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
    if (shapeToCopy){
        shapeModel.frame = shapeToCopy.bounds;
        shapeModel.angle = [shapeToCopy getAngleFromTransform];
    }else{
        float minSize = MIN(self.spatialView.contentView.bounds.size.width, self.spatialView.contentView.bounds.size.height);
        CGSize shapeSize = CGSizeMake(minSize*self.spatialView.zoomScale/7, minSize*self.spatialView.zoomScale/7);
        shapeModel.frame = CGRectMake(point.x-shapeSize.width/2, point.y-shapeSize.height/2, shapeSize.width, shapeSize.height);
    }
    
    shapeModel.title = @"100";
    shapeModel.shapeType = (int)selectedShapeType;
    shapeModel.fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    WMSpatialViewShape *shape = [[WMSpatialViewShape alloc] initWithModel:shapeModel aspectRatio:spatialView.contentView.bounds.size];
    [shape rotateByAngle:shapeModel.angle];
    shape.center = point;
    shapeModel.frame = shape.frame;
    [self addItemIntoDatasource:shapeModel];
    
    selectedShapeType = NONE;
    shapeToCopy = nil;
    return shape;
}

- (void)spatialView:(WMSpatialView *)spatialView didAddShape:(WMSpatialViewShape *)shape{
    NSLog(@"Shape Added successfully");
    [self showFooterView:NO withAnimation:YES];
}

#pragma Helper Methods

- (NSArray *)getShapesModel {
    NSMutableArray *shapes = [NSMutableArray new];

//    WMShape *shapeModel = [[WMShape alloc] init];
//    shapeModel.frame = CGRectMake(50, 50, 200, 200);
//    shapeModel.title = @"100";
//    shapeModel.shapeType = ELLIPSE;
//    shapeModel.fillColor = [UIColor redColor];
//    [shapes addObject:shapeModel];
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

- (void)removeItemFromDatasource:(WMSpatialViewShape *)shape{
    [self.spatialView removeShape:selectedShape];
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:dataSource];
    [mArray removeObject:shape.shapeModel];
    dataSource = [mArray copy];
}



@end
