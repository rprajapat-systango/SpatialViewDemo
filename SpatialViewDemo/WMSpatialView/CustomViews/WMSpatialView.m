//
//  WMSpatialView.m
//  SpatialViewDemo
//
//  Created by Systango on 05/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMSpatialView.h"
#import "WMSpatialViewShape.h"

@interface WMSpatialView(){
    NSMutableArray *arrSelectedItems;
    UIView *viewShapeOutline;
    CGPoint fromPosition;
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
       [viewShapeOutline addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
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
            break;
        case UIGestureRecognizerStateChanged:
            self.userInteractionEnabled = YES;
            // Avoid to drag the shape outside of graph view
            NSLog(@"Location [%f, %f]",location.x, location.y);
            if ((location.x < (self.margin + selectedShape.frame.size.width/2))  ){
                location.x = self.margin + selectedShape.frame.size.width/2;
            }
            if ((location.y < (self.margin + selectedShape.frame.size.height/2))  ){
                location.y = self.margin + selectedShape.frame.size.height/2;
            }
            // set the new location of the shape via drag an drop
            selectedShape.center = location;
            viewShapeOutline.center = location;
            [self contentViewSizeToFit];
            [self scrollRectToVisible:selectedShape.frame animated:NO];
            break;
        default:
            viewShapeOutline.alpha = 1.0;
            if([self isOverlappingView:selectedShape]){
                [UIView animateWithDuration:0.5 animations:^{
                selectedShape.center = self->fromPosition;
                self->viewShapeOutline.center = self->fromPosition;
                CGRect rectToVisible = selectedShape.frame;
                rectToVisible.origin = self->fromPosition;
                [self contentViewSizeToFit];
                [self scrollRectToVisible:rectToVisible animated:YES];
                [self layoutIfNeeded];
                }];
            }
            self.userInteractionEnabled = YES;
            break;
    }
}


@end
