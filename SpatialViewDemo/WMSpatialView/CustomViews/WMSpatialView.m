//
//  WMSpatialView.m
//  SpatialViewDemo
//
//  Created by Systango on 05/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMSpatialView.h"
#import "WMSpatialViewShape.h"

#define MIN_WIDTH 150
#define MIN_HEIGHT 150

typedef enum : NSUInteger {
    Up = 10,
    Right = 20,
    Down = 30,
    Left = 40,
    Aspect = 50,
} WMSpatialViewDragDirection;

@interface WMSpatialView(){
    NSMutableArray *arrSelectedItems;
    UIView *viewShapeOutline;
    CGPoint fromPosition;
    CGPoint previousTouchPosition;
    CGRect previousOutlineFrame;

    CGAffineTransform previousShapeTransform;
}

@end

@implementation WMSpatialView

- (void)reloadShapes{
    self.delegate = self;
    arrSelectedItems = [NSMutableArray new];
    // Clear spatial view if it's content alrady rendered.
    if (_contentView) {
        [_contentView removeFromSuperview];
    }else{
        self.contentView = [[WMGraphView alloc] init];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOutside)]];
        
    }
    [self addSubview:_contentView];
    
    // Adding a all view shapes
    NSInteger totalItems;
    if ([self.dataSource respondsToSelector:@selector(numberOfItems)]){
        totalItems = [self.dataSource numberOfItems];
    }else{
        NSLog(@"method numberOfItems not found in %@", self.dataSource.description);
        return;
    }
    
    if ([self.dataSource respondsToSelector:@selector(spatialView:viewForItem:)]){
        for (int i = 0; i < totalItems; i++) {
            WMSpatialViewShape *shapeView = [self.dataSource spatialView:self viewForItem:i];
            shapeView.delegate = self;
            if (shapeView) {
                [_contentView addSubview:shapeView];
            }
        }
    }else{
        NSLog(@"method spatialView:viewForItem: not found in %@", self.dataSource.description);
        return;
    }
    
    [self contentViewSizeToFit];
}

-(void) tapOutside{
    [self clearSelection];
}

- (void)clearSelection{
    for (WMSpatialViewShape *oldSelection in arrSelectedItems) {
        oldSelection.isSelected = NO;
        [arrSelectedItems removeObject: oldSelection];
        if ([self.actionDelegate respondsToSelector:@selector(spatialView:didSelectItem:)]){
            [self.actionDelegate spatialView:self didSelectItem:oldSelection];
        }
    }
    
    if(viewShapeOutline){
        [viewShapeOutline removeFromSuperview];
    }
     
}

- (void)didTapOnView:(WMSpatialViewShape *)shape{

    if (arrSelectedItems.count){
        WMSpatialViewShape *oldSelection = (WMSpatialViewShape *)arrSelectedItems.firstObject;
        oldSelection.isSelected = NO;
        [arrSelectedItems removeObject: oldSelection];
        if(shape != oldSelection){
            shape.isSelected = YES;
            [arrSelectedItems addObject:shape];
        }
    }else{
        [arrSelectedItems addObject:shape];
        shape.isSelected = YES;
    }

    if ([self.actionDelegate respondsToSelector:@selector(spatialView:didSelectItem:)]){
        [self.actionDelegate spatialView:self didSelectItem:shape];
    }
    
    if ([self.dataSource respondsToSelector:@selector(spatialView:outlineViewForShape:)]){
       viewShapeOutline = [self.dataSource spatialView:self outlineViewForShape:shape];
        if(viewShapeOutline){
            [self.contentView addSubview:viewShapeOutline];
            [self setGestureOnButtons:viewShapeOutline];
        }
    }
}

- (void) contentViewSizeToFit{
    CGRect rect = CGRectZero;
    for (UIView *view in self.contentView.subviews) {
        if (view == viewShapeOutline) continue;
        rect = CGRectUnion(rect, view.frame);
    }
    CGSize contentSize = rect.size;
    contentSize.width += 2*self.margin;
    contentSize.height += 2*self.margin;
    
    _contentView.frame = CGRectMake(0, 0, contentSize.width*self.zoomScale, contentSize.height*self.zoomScale);
    self.contentSize = _contentView.frame.size;
  //  [self.contentView setNeedsDisplay];
}

- (BOOL) isOverlappingView:(WMSpatialViewShape *)shape{
    for (UIView *view in self.contentView.subviews) {
        if (view == shape) continue;
        if ([view isKindOfClass:[WMSpatialViewShape class]]){
            if (CGRectIntersectsRect(shape.frame, view.frame)){
                return YES;
            }
        }
    }
    return NO;
}

- (void) setFocusOnView:(WMSpatialViewShape *)shape{
    /*
    CGPoint offset = self.contentOffset;
    CGSize frameSize = self.frame.size;
    
    CGRect shapeRect = shape.frame;
    float maxX = shapeRect.origin.x + shapeRect.size.width+self.margin;
    float maxY = shapeRect.origin.y + shapeRect.size.height+self.margin;
    
    if (maxX > frameSize.width-offset.x){
        offset.x = (maxX - frameSize.width);
        [self setContentOffset:offset];
    }
    
    if (maxY > frameSize.width-offset.y){
        offset.x = (maxX - frameSize.width);
        [self setContentOffset:offset];
    }
    */
}

#pragma mark UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return scrollView.subviews[0];
}

#pragma UIPanGestureRecognizer selector
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (arrSelectedItems.count == 0 || gesture.view == self) return;
    WMSpatialViewShape *selectedShape = arrSelectedItems.firstObject;
    
    CGPoint location = [gesture locationInView:self.contentView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Begin");
            // Disable scroll view gesture to making focus on selected shape.
            self.userInteractionEnabled = NO;
            fromPosition = selectedShape.center;
            viewShapeOutline.alpha = 0.0;
            previousTouchPosition = location;
            break;
        case UIGestureRecognizerStateChanged:
            self.userInteractionEnabled = YES;
            // Avoid to drag the shape outside of graph view
            NSLog(@"Location [%f, %f]",location.x, location.y);
            // set the new location of the shape via drag an drop
            float deltaX = location.x - previousTouchPosition.x;
            float deltaY = location.y - previousTouchPosition.y;
            
            CGPoint newCenterPoint = CGPointMake(selectedShape.center.x + deltaX, selectedShape.center.y + deltaY);

            if ((newCenterPoint.x < (self.margin + selectedShape.frame.size.width/2))  ){
                newCenterPoint.x = self.margin + selectedShape.frame.size.width/2;
            }
            if ((newCenterPoint.y < (self.margin + selectedShape.frame.size.height/2))  ){
                newCenterPoint.y = self.margin + selectedShape.frame.size.height/2;
            }

            selectedShape.center = newCenterPoint;
            viewShapeOutline.center = newCenterPoint;
            [self contentViewSizeToFit];
            //[self scrollRectToVisible:selectedShape.frame animated:NO];
            previousTouchPosition = location;
            break;
        default:
            if([self isOverlappingView:selectedShape]){
                [UIView animateWithDuration:0.5 animations:^{
                self->viewShapeOutline.alpha = 1.0;
                selectedShape.center = self->fromPosition;
                self->viewShapeOutline.center = self->fromPosition;
                CGRect rectToVisible = selectedShape.frame;
                rectToVisible.origin = self->fromPosition;
                [self contentViewSizeToFit];
                [self scrollRectToVisible:rectToVisible animated:YES];
                [self layoutIfNeeded];
                }];
            }else{
                self->viewShapeOutline.alpha = 1.0;
            }
            self.userInteractionEnabled = YES;
            break;
    }
}

- (void)setGestureOnButtons:(UIView *)view{
   // Adding gesture on the view for drag to move the object
    [viewShapeOutline addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
   // adding gesture for dragn left, top, right, bottom and digonaly.
    NSArray *arrTAGs = @[@10, @20, @30, @40, @50];
    for (NSNumber *tag in arrTAGs) {
        UIView *button = [view viewWithTag:tag.integerValue];
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForDragToResize:)];
        [button addGestureRecognizer:gesture];
    }
}
// GEsture
- (void)handlePanForDragToResize:(UIPanGestureRecognizer *)gesture
{
    if (arrSelectedItems.count == 0 || gesture.view == self) return;
    WMSpatialViewShape *selectedShape = arrSelectedItems.firstObject;
    
    CGPoint location = [gesture locationInView:self.contentView];
    UIButton *button = (UIButton *)gesture.view;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Begin");
            // Disable scroll view gesture to making focus on selected shape.
            self->viewShapeOutline.alpha = 0.0;
            self.userInteractionEnabled = NO;
            previousOutlineFrame = viewShapeOutline.frame;
            previousTouchPosition = location;
            previousShapeTransform = selectedShape.transform;
            
            switch (button.tag) {
                case Left:
                    NSLog(@"Left");
                    selectedShape.layer.position = CGPointMake(selectedShape.center.x + selectedShape.bounds.size.width/2, selectedShape.layer.position.y);
                    selectedShape.layer.anchorPoint = CGPointMake(1, .5);
                    break;
                case Right:
                    NSLog(@"Right");
                    selectedShape.layer.position = CGPointMake(selectedShape.center.x - selectedShape.bounds.size.width/2, selectedShape.layer.position.y);
                    selectedShape.layer.anchorPoint = CGPointMake(0, .5);
                    break;
                case Up:
                    NSLog(@"Up");
                   selectedShape.layer.anchorPoint = CGPointMake(.5, 1);
                    break;
                case Down:
                    // Updating frame of selected shape;
                    NSLog(@"Down");
                   selectedShape.layer.anchorPoint = CGPointMake(0.5, 0);
                    break;
                case Aspect:
                    // Updating frame of selected shape;
                    NSLog(@"ASPECT");
                   selectedShape.layer.anchorPoint = CGPointMake(0, 0);
                    break;
                default:
                    break;
            }
            
            
            break;
        case UIGestureRecognizerStateChanged:
            self.userInteractionEnabled = YES;
            float deltaX = location.x - previousTouchPosition.x;
            float deltaY = location.y - previousTouchPosition.y;
            NSLog(@"\nNew Rect to set Deltas %f:%f\n", deltaX, deltaY);
            CGRect newRect = selectedShape.bounds;
            switch (button.tag) {
                case Left:
                    NSLog(@"Left");
                    newRect.size.width -= deltaX;
                    break;
                case Right:
                    NSLog(@"Right");
                    
                    newRect.size.width += deltaX;
                    break;
                case Up:
                    NSLog(@"Up");
                    newRect.size.height -= deltaY;
                    break;
                case Down:
                    // Updating frame of selected shape;
                    NSLog(@"Down");
                    newRect.size.height += deltaY;
                    break;
                case Aspect:
                    // Updating frame of selected shape;
                    NSLog(@"ASPECT");
                    newRect.size.width += (deltaX+deltaY)/2;
                    newRect.size.height += (deltaX+deltaY)/2;
                    break;
                default:
                    break;
            }
            NSLog(@"\nNew Rect to set : %@\n", NSStringFromCGRect(newRect));
            newRect.size.width = MAX(MIN_WIDTH, newRect.size.width);
            newRect.size.height = MAX(MIN_HEIGHT, newRect.size.height);

//            CGRect frame = selectedShape.bounds;
//            frame.size.height += deltaY;
//            frame.size.width += deltaX;
            selectedShape.bounds = newRect;
            
            //selectedShape.transform = CGAffineTransformIdentity;
            // Updating frame of the outline view;
            [selectedShape setNeedsDisplay];
            //selectedShape.transform = t;
            //[self.contentView addSubview:selectedShape];
            [self contentViewSizeToFit];
            previousTouchPosition = location;
            break;
        default:
            if([self isOverlappingView:selectedShape]){
                [UIView animateWithDuration:0.5 animations:^{
                self->viewShapeOutline.alpha = 1.0;
//                    selectedShape.transform = self->previousShapeTransform;
//                    self->viewShapeOutline.transform = self->previousShapeTransform;
                }];
            }else{
                self->viewShapeOutline.alpha = 1.0;
                [self setOutlineViewOverShape:selectedShape];
            }
            self.userInteractionEnabled = YES;
            break;
    }
}

- (void)setOutlineViewOverShape:(WMSpatialViewShape *)shape{
//    viewShapeOutline.transform = CGAffineTransformIdentity;
//    CGRect rect = selectedShape.frame;
//    rect.size.width += 70;
//    rect.size.height += 70;
//    viewShapeOutline.frame = rect;
//    viewShapeOutline.center = selectedShape.center;
//    viewShapeOutline.transform = selectedShape.transform;
    
    CGRect shapeRect = CGRectZero;
    shapeRect.size = CGSizeMake(shape.frame.size.width+70, shape.frame.size.height+70);
    viewShapeOutline.frame = shapeRect;
    viewShapeOutline.transform = shape.transform;
    viewShapeOutline.center = shape.center;
}

@end
