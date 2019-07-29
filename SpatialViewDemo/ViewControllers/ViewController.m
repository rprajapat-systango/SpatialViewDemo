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

typedef enum : NSUInteger {
    Up = 10,
    Right = 20,
    Down = 30,
    Left = 40,
    Aspect = 50,
} WMSpatialViewDragDirection;

@interface ViewController (){
    NSArray *dataSource;
    WMSpatialViewMenuOptions selectedMenuOption;
    WMSpatialViewShape *selectedShape;
    CGRect previousShapeFrame;
    CGRect previousOutlineFrame;
    CGPoint previousTouchPoint;
}

@property (strong, nonatomic) IBOutlet UIView *viewShapeSelection;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedMenuOption = Rotate;
    dataSource = [self getShapesModel];
    [self setupSpatialView];
}

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
//        [UIView animateWithDuration:0.30 animations:^{
        
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
//            }];
    }
    [self.spatialView contentViewSizeToFit];
}

- (void)setupSpatialView {
//    self.spatialView.delegate = self;
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

- (UIView *)spatialView:(WMSpatialView *)spatialView outlineViewForShape:(WMSpatialViewShape *)shape{
    CGRect shapeRect = CGRectZero;
    shapeRect.size = CGSizeMake(shape.bounds.size.width+70, shape.bounds.size.height+70);
    _viewShapeSelection.frame = shapeRect;
    _viewShapeSelection.transform = shape.transform;
    _viewShapeSelection.center = shape.center;
    [self setGestureOnButtons:_viewShapeSelection];
    return _viewShapeSelection;
}

- (void)setGestureOnButtons:(UIView *)view{
    NSArray *arrTAGs = @[@10, @20, @30, @40, @50];
    for (NSNumber *tag in arrTAGs) {
        UIView *button = [view viewWithTag:tag.integerValue];
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [button addGestureRecognizer:gesture];
    }
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
    CGPoint location = [gesture locationInView:self.spatialView.contentView];
    UIButton *button = (UIButton *)gesture.view;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Begin");
            // Disable scroll view gesture to making focus on selected shape.
            self.spatialView.userInteractionEnabled = NO;
            previousShapeFrame = selectedShape.frame;
            previousOutlineFrame = _viewShapeSelection.frame;
            previousTouchPoint = location;
            break;
        case UIGestureRecognizerStateChanged:
            self.spatialView.userInteractionEnabled = YES;
            
            float deltaX = location.x - previousTouchPoint.x;;
            float deltaY = location.y - previousTouchPoint.y;;
            
            CGRect previousRect = selectedShape.frame;
            CGRect outlineFrame = _viewShapeSelection.frame;
            
            switch (button.tag) {
                case Left:
                    NSLog(@"Left");
                    previousRect.origin.x += deltaX;
                    outlineFrame.origin.x += deltaX;
                    previousRect.size.width -= deltaX;
                    outlineFrame.size.width -= deltaX;
                    break;
                case Right:
                    previousRect.size.width += deltaX;
                    outlineFrame.size.width += deltaX;
                    NSLog(@"Right");
                    break;
                case Up:
                    NSLog(@"Up");
                    previousRect.origin.y += deltaY;
                    outlineFrame.origin.y += deltaY;
                    previousRect.size.height -= deltaY;
                    outlineFrame.size.height -= deltaY;
                    break;
                case Down:
                    // Updating frame of selected shape;
                    previousRect.size.height += deltaY;
                    outlineFrame.size.height += deltaY;
                    NSLog(@"Down");
                    break;
                case Aspect:
                    // Updating frame of selected shape;
                    previousRect.size.width += (deltaX+deltaY)/2;
                    previousRect.size.height += (deltaX+deltaY)/2;
                    outlineFrame.size.width += deltaX;
                    outlineFrame.size.height += deltaY;
                    NSLog(@"Down");
                    break;
                default:
                    break;
            }
            
            selectedShape.frame = previousRect;
            // Updating frame of the outline view;
            _viewShapeSelection.frame = outlineFrame;
            [selectedShape setNeedsDisplay];
            
            [self.spatialView contentViewSizeToFit];
            previousTouchPoint = location;
            break;
        default:
            if([self.spatialView isOverlappingView:selectedShape]){
                selectedShape.frame = previousShapeFrame;
                _viewShapeSelection.frame = previousOutlineFrame;
            }
            self.spatialView.userInteractionEnabled = YES;
            break;
    }
}

@end