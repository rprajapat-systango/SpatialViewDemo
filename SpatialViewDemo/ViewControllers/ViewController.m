//
//  ViewController.m
//  SpatialViewDemo
//
//  Created by Systango on 02/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "ViewController.h"
#import "WMSpatialViewShape.h"

typedef enum : NSUInteger {
    Rotate = 100,
    Resize = 200,
    Move = 300,
    Exit = 400,
} WMSpatialViewMenuOptions;

@interface ViewController (){
    NSArray *dataSource;
    WMSpatialViewMenuOptions selectedMenuOption;
    WMSpatialViewShape *selectedShape;
}

//@property (weak, nonatomic) IBOutlet UIView *viewMenu;
@property (strong, nonatomic) IBOutlet UIView *viewShapeSelection;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    selectedMenuOption = Rotate;
    dataSource = [self getShapesModel];
    [self setupSpatialView];
}

//- (void)setSelectedMenuButton:(UIButton *)sender{
//    for (int tag = 100; tag <= 300; tag += 100 ) {
//        UIButton *menuButton = [_viewMenu viewWithTag:tag];
//        if (menuButton == sender){
//            [menuButton setSelected: !sender.isSelected];
//        }else{
//            [menuButton setSelected:NO];
//        }
//    }
//}

- (IBAction)menuOptionTapped:(UIButton *)sender {
    [self perfomrActionOnShapeUsingMenuOption:sender.tag];
}

- (void)perfomrActionOnShapeUsingMenuOption:(WMSpatialViewMenuOptions)option{
    switch (option) {
        case Rotate:
            // Code for rotate shape
            NSLog(@"Rotate");
            [self rotateShapeViewByAngle:M_PI_2];
            break;
        case Resize:
            // Code for resize shape
            NSLog(@"Resize");
            break;
        case Move:
            // Code for move shape
            NSLog(@"Move");
            break;
        case Exit:
            // Code for delete shape
            NSLog(@"Exit");
            [self.spatialView clearSelection];
            break;
    }
}

- (void)rotateShapeViewByAngle:(CGFloat)angle{
    if (selectedShape){
        CGAffineTransform transform = selectedShape.transform;
        transform = CGAffineTransformConcat(transform,
                                            CGAffineTransformMakeRotation(angle));
        selectedShape.transform = transform;
        _viewShapeSelection.transform = transform;
        
        // Reverse transfroming the subview of shapeview;
        CGAffineTransform stackViewTransform = selectedShape.stackView.transform;
        stackViewTransform = CGAffineTransformConcat(stackViewTransform,
                                            CGAffineTransformMakeRotation(-angle));
        selectedShape.stackView.transform = stackViewTransform;
    }
    [self.spatialView contentViewSizeToFit];
}

- (void)setupSpatialView {
    self.spatialView.delegate = self;
    self.spatialView.actionDelegate = self;
    self.spatialView.dataSource = self;
    self.spatialView.margin = 20;
    self.spatialView.minimumZoomScale = 0.1;
    self.spatialView.maximumZoomScale = 2.0;
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

- (void)spatialView:(WMSpatialView *)spatialView didSelectItem:(WMSpatialViewShape *)shape{
    _viewShapeSelection.transform = CGAffineTransformIdentity;
    if (selectedShape == shape)
    {
        selectedShape = nil;
        [_viewShapeSelection removeFromSuperview];
    }else{
        selectedShape = shape;
        CGRect shapeRect = CGRectZero;
        shapeRect.size = CGSizeMake(shape.bounds.size.width+70, shape.bounds.size.height+70);
        _viewShapeSelection.frame = shapeRect;
        _viewShapeSelection.transform = shape.transform;
        _viewShapeSelection.center = shape.center;
        [spatialView.contentView bringSubviewToFront:shape];
        [spatialView.contentView addSubview:_viewShapeSelection];
        
        [_viewShapeSelection addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
        
    }
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
    shapeModel.fillColor = [UIColor brownColor];
    [shapes addObject:shapeModel];
    
    
    shapeModel = [[WMShape alloc] init];
    shapeModel.frame = CGRectMake(460, 460, 140, 140);
    shapeModel.title = @"108";
    shapeModel.shapeType = TRIANGLE;
    shapeModel.fillColor = [UIColor brownColor];
    shapeModel.angle = 45;
    [shapes addObject:shapeModel];
    
    return [shapes copy];
}

// Pan gesture

// GEsture
- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
//    CGPoint location = [gesture locationInView:self.spatialView.contentView];
//    selectedShape.center = location;
//    return;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // Get the location of the touch in the view we're dragging.
        CGPoint location = [gesture locationInView:_viewShapeSelection];

        // Now to fix the rotation we set a new anchor point to where our finger touched. Remember AnchorPoints are 0.0 - 1.0 so we need to convert from points to that by dividing
        [selectedShape.layer setAnchorPoint:CGPointMake(location.x/selectedShape.frame.size.width, location.y/selectedShape.frame.size.height)];
        
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        // Calculate Our New Angle
//        UIButton *button = [_viewShapeSelection viewWithTag:200];
        CGPoint p1 = [gesture locationInView:selectedShape];
//        CGPoint p1 = button.center;
        CGPoint p2 = selectedShape.center;
        
        float adjacent = p2.x-p1.x;
        float opposite = p2.y-p1.y;
        
        float angle = atan2f(adjacent, opposite);
        
        // Get the location of our touch, this time in the context of the superview.
        CGPoint location = [gesture locationInView:self.view];
        
        // Set the center to that exact point, We don't need complicated original point translations anymore because we have changed the anchor point.
        [selectedShape setCenter:CGPointMake(location.x, location.y)];
        
        [self rotateShapeViewByAngle:(angle*-1)];
        // Rotate our view by the calculated angle around our new anchor point.
        // [selectedShape setTransform:CGAffineTransformMakeRotation(angle*-1)];
        
    }
}




@end
