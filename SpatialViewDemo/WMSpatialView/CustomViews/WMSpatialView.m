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
    
//    CGRect previousShapeFrame;
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
        if(shape == oldSelection){
            // Matching with existing one.
            [arrSelectedItems removeObject: oldSelection];
        }else{
            [arrSelectedItems removeObject: oldSelection];
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
       [self.contentView addSubview:viewShapeOutline];
       [self setGestureOnButtons:viewShapeOutline];
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
    [self.contentView setNeedsDisplay];
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
            self.userInteractionEnabled = NO;
            previousShapeTransform = selectedShape.transform;
            //previousShapeFrame = selectedShape.frame;
            previousOutlineFrame = viewShapeOutline.frame;
            previousTouchPosition = location;
            self->viewShapeOutline.alpha = 0.0;
            break;
        case UIGestureRecognizerStateChanged:
            self.userInteractionEnabled = YES;
            
            float deltaX = location.x - previousTouchPosition.x;;
            float deltaY = location.y - previousTouchPosition.y;;
            
            CGRect previousRect = selectedShape.frame;
            CGRect outlineFrame = viewShapeOutline.frame;
            
            switch (button.tag) {
                case Left:
                    NSLog(@"Left");
                    previousRect.origin.x += deltaX;
                    outlineFrame.origin.x += deltaX;
                    previousRect.size.width -= deltaX;
                    outlineFrame.size.width -= deltaX;
                    [selectedShape.layer setAnchorPoint:CGPointMake(1.0, 0.5)];
                    selectedShape.transform = CGAffineTransformScale(selectedShape.transform, (1+deltaX/selectedShape.frame.size.width), 1.0);
                   // viewShapeOutline.transform = CGAffineTransformScale(viewShapeOutline.transform, (1+deltaX/viewShapeOutline.frame.size.width+70), 1.0);
                    
                    break;
                case Right:
                    previousRect.size.width += deltaX;
                    outlineFrame.size.width += deltaX;
                    [selectedShape.layer setAnchorPoint:CGPointMake(0.0, 0.5)];
                    selectedShape.transform = CGAffineTransformScale(selectedShape.transform, (1+deltaX/selectedShape.frame.size.width), 1.0);
                    //viewShapeOutline.transform = CGAffineTransformScale(viewShapeOutline.transform, (1+deltaX/viewShapeOutline.frame.size.width+70), 1.0);
                    
                    NSLog(@"Right");
                    break;
                case Up:
                    NSLog(@"Up");
                    previousRect.origin.y += deltaY;
                    outlineFrame.origin.y += deltaY;
                    previousRect.size.height -= deltaY;
                    outlineFrame.size.height -= deltaY;
                    
                    selectedShape.transform = CGAffineTransformScale(selectedShape.transform, (1+deltaX/selectedShape.frame.size.width), (1+deltaY/selectedShape.frame.size.height));
                    //viewShapeOutline.transform = CGAffineTransformScale(viewShapeOutline.transform, (1+deltaX/viewShapeOutline.frame.size.width+70), (1+deltaY/viewShapeOutline.frame.size.height+70));
                    break;
                case Down:
                    // Updating frame of selected shape;
                    previousRect.size.height += deltaY;
                    outlineFrame.size.height += deltaY;
                    
                    selectedShape.transform = CGAffineTransformScale(selectedShape.transform, (1+deltaX/selectedShape.frame.size.width), (1+deltaY/selectedShape.frame.size.height));
                   // viewShapeOutline.transform = CGAffineTransformScale(viewShapeOutline.transform, (1+deltaX/viewShapeOutline.frame.size.width+70), (1+deltaY/viewShapeOutline.frame.size.height+70));
                    NSLog(@"Down");
                    break;
                case Aspect:
                    // Updating frame of selected shape;
                    previousRect.size.width += (deltaX+deltaY)/2;
                    previousRect.size.height += (deltaX+deltaY)/2;
                    outlineFrame.size.width += deltaX;
                    outlineFrame.size.height += deltaY;
                    
                    selectedShape.transform = CGAffineTransformScale(selectedShape.transform, (1+deltaX/selectedShape.frame.size.width), (1+deltaY/selectedShape.frame.size.height));
                    //viewShapeOutline.transform = CGAffineTransformScale(viewShapeOutline.transform, (1+deltaX/viewShapeOutline.frame.size.width+70), (1+deltaY/viewShapeOutline.frame.size.height+70));
                    NSLog(@"Down");
                    break;
                default:
                    break;
            }
            
//            previousRect.size.width = MAX(MIN_WIDTH, previousRect.size.width);
//            previousRect.size.height = MAX(MIN_HEIGHT, previousRect.size.height);
            outlineFrame.size.width = MAX(MIN_WIDTH+70, outlineFrame.size.width);
            outlineFrame.size.height = MAX(MIN_HEIGHT+70, outlineFrame.size.height);

            
            
//            selectedShape.frame = previousRect;
            // Updating frame of the outline view;
            viewShapeOutline.frame = outlineFrame;
            [selectedShape setNeedsDisplay];
            
            [self contentViewSizeToFit];
            previousTouchPosition = location;
            break;
        default:
            if([self isOverlappingView:selectedShape]){
                [UIView animateWithDuration:0.5 animations:^{
                self->viewShapeOutline.alpha = 1.0;
                selectedShape.transform = self->previousShapeTransform;
                //selectedShape.frame = self->previousShapeFrame;
                self->viewShapeOutline.transform = self->previousShapeTransform;
                    //self->viewShapeOutline.frame = self->previousOutlineFrame;
                }];
            }else{
                self->viewShapeOutline.alpha = 1.0;
            }
            self.userInteractionEnabled = YES;
            break;
    }
}

@end
