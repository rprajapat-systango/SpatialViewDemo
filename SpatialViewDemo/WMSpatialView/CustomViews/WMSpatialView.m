//
//  WMSpatialView.m
//  SpatialViewDemo
//
//  Created by Systango on 05/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMSpatialView.h"
#import "WMSpatialViewShape.h"

//#define MIN_WIDTH 100
//#define MIN_HEIGHT 100

@interface WMSpatialView(){
    NSMutableArray *arrSelectedItems;
    WMShapeOutlineView *viewShapeOutline;
    CGPoint fromPosition;
    CGPoint previousTouchPosition;
    CGRect previousFrame;
    CGAffineTransform previousShapeTransform;
    CGFloat touchMovingDistance;
    CGFloat rotation;
    CGPoint layerAnchorPosition;
}
@end

@implementation WMSpatialView

- (void)reloadShapes{
    self.delegate = self;
    [self contentViewSizeToFit];
    arrSelectedItems = [NSMutableArray new];
    // Clear spatial view if it's content alrady rendered.
    if (_contentView) {
        [_contentView removeFromSuperview];
    }else{
        self.contentView = [[WMGraphView alloc] init];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOutside:)]];
        
    }
    [self addSubview:_contentView];
    
    // Adding a all view shapes
    NSInteger totalItems;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInSpatialView:)]){
        totalItems = [self.dataSource numberOfItemsInSpatialView:self ];
    }else{
        NSLog(@"method numberOfItemsInSpatialView: not found in %@", self.dataSource.description);
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

- (void) tapOutside:(UITapGestureRecognizer *)gesture{
    [self clearSelection];
    // Sending message to receiver when tapping outside of the shape
    if ([self.actionDelegate respondsToSelector:@selector(spatialView:shouldDrawShapeOnPosition:)]){
        BOOL shouldDraw = [self.actionDelegate spatialView:self shouldDrawShapeOnPosition:[gesture locationInView:self.contentView]];
        if (shouldDraw){
            if ([self.actionDelegate respondsToSelector:@selector(spatialView:shapeToAddAt:)]){
                    WMSpatialViewShape *shapeToDraw = [self.actionDelegate spatialView:self shapeToAddAt:[gesture locationInView:self.contentView]];
                    shapeToDraw.delegate = self;
                    if (shapeToDraw) {
                        [_contentView addSubview:shapeToDraw];
                        [self didTapOnView:shapeToDraw];
                        [self contentViewSizeToFit];
                        if ([self.actionDelegate respondsToSelector:@selector(spatialView:didAddShape:)]){
                            [self.actionDelegate spatialView:self didAddShape:shapeToDraw];
                        }
                    }
            }
        }
    }
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

- (void) removeShape:(WMSpatialViewShape *)selectedShape{
    [self clearSelection];
    [selectedShape removeFromSuperview];
    [self contentViewSizeToFit];
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
            viewShapeOutline.selectedShape = shape;
            [self.contentView addSubview:viewShapeOutline];
            [self setGestureOnButtons:viewShapeOutline];
            [self setOutlineViewOverShape:shape];
        }
    }
}

- (void)setAspectRatio{
    CGSize desiredSize = self.bounds.size;
    CGSize size = [self getAspectFitSize:self.aspectRatio boundingSize:desiredSize];
    _contentView.frame = CGRectMake(0, 0, size.width*self.zoomScale, size.height*self.zoomScale);
}

- (void) contentViewSizeToFit{
    [self setAspectRatio];
    
    CGSize desiredSize = _contentView.bounds.size;
    desiredSize.width += 2 * CGRectGetMinX(_contentView.frame);
    desiredSize.height += 2 * CGRectGetMinX(_contentView.frame);
    
    self.contentSize = desiredSize;
    [self.contentView setNeedsDisplay];
    
  /*
    CGRect rect = CGRectZero;
    for (UIView *view in self.contentView.subviews) {
        if (view == viewShapeOutline) continue;
        rect = CGRectUnion(rect, view.frame);
    }
    CGSize contentSize = rect.size;
    contentSize.width += 2*self.margin;
    contentSize.height += 2*self.margin;
    
    CGSize desiredSize = self.bounds.size;
    desiredSize.height = MAX(contentSize.height, desiredSize.height);
    desiredSize.width = MAX(contentSize.width, desiredSize.width);
   
    _contentView.frame = CGRectMake(0, 0, desiredSize.width*self.zoomScale, desiredSize.height*self.zoomScale);

    self.contentSize = desiredSize;
    [self.contentView setNeedsDisplay];
  */
}

- (BOOL) isOverlappingView:(WMSpatialViewShape *)shape{
    // To avoid placing any shape outside of the graph view
    if (CGRectGetMaxX(shape.frame)*self.zoomScale > CGRectGetMaxX(_contentView.frame)  || CGRectGetMaxY(shape.frame)*self.zoomScale > CGRectGetMaxY(_contentView.frame)) {
        return YES;
    }
    
    if (self.allowOverlappingView){
        return NO;
    }
    //
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
    return _contentView;
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
            viewShapeOutline.alpha = 0.0;
            previousTouchPosition = location;
            fromPosition = CGPointMake(CGRectGetMidX(selectedShape.frame), CGRectGetMidY(selectedShape.frame));
            previousFrame = selectedShape.bounds;
            break;
        case UIGestureRecognizerStateChanged:
            self.userInteractionEnabled = YES;
            // Avoid to drag the shape outside of graph view
            NSLog(@"Location [%f, %f]",location.x, location.y);
            // set the new location of the shape via drag an drop
            float deltaX = location.x - previousTouchPosition.x;
            float deltaY = location.y - previousTouchPosition.y;
            
            CGPoint newCenterPoint = CGPointMake(selectedShape.center.x + deltaX, selectedShape.center.y + deltaY);

            if ((newCenterPoint.x < (self.margin + selectedShape.bounds.size.width/2))  ){
                newCenterPoint.x = self.margin + selectedShape.bounds.size.width/2;
            }
            if ((newCenterPoint.y < (self.margin + selectedShape.bounds.size.height/2))  ){
                newCenterPoint.y = self.margin + selectedShape.bounds.size.height/2;
            }

            selectedShape.center = newCenterPoint;
            [self contentViewSizeToFit];
            //[self scrollRectToVisible:selectedShape.frame animated:NO];
            previousTouchPosition = location;
            break;
        default:
            if([self isOverlappingView:selectedShape]){
                [UIView animateWithDuration:0.5 animations:^{
                    selectedShape.bounds = self->previousFrame;
                    selectedShape.center = self->fromPosition;
                    [self setOutlineViewOverShape:selectedShape];

                    CGRect rectToVisible = selectedShape.frame;
                    [self scrollRectToVisible:rectToVisible animated:YES];
                    [self contentViewSizeToFit];
                } completion:^(BOOL finished) {
                    self->viewShapeOutline.alpha = 1.0;
                }];
            }else{
                [self setOutlineViewOverShape:selectedShape];
                self->viewShapeOutline.alpha = 1.0;
            }
            self.userInteractionEnabled = YES;
            break;
    }
}

- (void)setGestureOnButtons:(UIView *)view{
   // Adding gesture on the view for drag to move the object
   // adding gesture for dragn left, top, right, bottom and digonaly.
    NSArray *arrTAGs = @[@10, @20, @30, @40, @50];
    for (NSNumber *tag in arrTAGs) {
        UIView *button = [view viewWithTag:tag.integerValue];
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForDragToResize:)];
        [self.panGestureRecognizer requireGestureRecognizerToFail:gesture];
        [button addGestureRecognizer:gesture];
    }
    
    UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.panGestureRecognizer requireGestureRecognizerToFail:dragGesture];
    [viewShapeOutline addGestureRecognizer:dragGesture];

}

- (void)gestureEndDragging:(WMSpatialViewShape *)selectedShape {
    selectedShape.layer.position = CGPointMake(CGRectGetMidX(selectedShape.frame), CGRectGetMidY(selectedShape.frame));
    selectedShape.layer.anchorPoint = CGPointMake(0.5, 0.5);
    if([self isOverlappingView:selectedShape]){
        [UIView animateWithDuration:0.5 animations:^{
            selectedShape.layer.position = CGPointMake(CGRectGetMidX(selectedShape.frame), CGRectGetMidY(selectedShape.frame));
            selectedShape.layer.anchorPoint = CGPointMake(0.5, 0.5);
            selectedShape.center = self->fromPosition;
            selectedShape.bounds = self->previousFrame;
            [self setOutlineViewOverShape:selectedShape];
        } completion:^(BOOL finished) {
            self->viewShapeOutline.alpha = 1.0;
        }];
    }else{
        [self setOutlineViewOverShape:selectedShape];
        self->viewShapeOutline.alpha = 1.0;
    }
    self.userInteractionEnabled = YES;
}

// Gesture
- (void)handlePanForDragToResize:(UIPanGestureRecognizer *)gesture
{
    if (arrSelectedItems.count == 0 || gesture.view == self) return;
    WMSpatialViewShape *selectedShape = arrSelectedItems.firstObject;
    
    CGPoint location = [gesture locationInView:self.contentView];
    UIButton *button = (UIButton *)gesture.view;
    
    UIView *anchorView;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Begin");
            touchMovingDistance = 0.0;
            anchorView = [self->viewShapeOutline viewWithTag:button.tag/10];
            // Disable scroll view gesture to making focus on selected shape.
            self->viewShapeOutline.alpha = 0.0;
            self.userInteractionEnabled = NO;
            fromPosition = CGPointMake(CGRectGetMidX(selectedShape.frame), CGRectGetMidY(selectedShape.frame));
            previousFrame = selectedShape.bounds;
            previousTouchPosition = location;
            previousShapeTransform = selectedShape.transform;
            rotation = [selectedShape getAngleFromTransform];
            CGPoint scaledPosition = CGPointMake(anchorView.layer.position.x,  anchorView.layer.position.y);
            
            NSLog(@"Change Size From [ %@ to %@]", NSStringFromCGPoint(anchorView.layer.position), NSStringFromCGPoint(scaledPosition));
            
            float theScale = 1.0 / self.zoomScale;
            CGPoint globalPosition = [viewShapeOutline convertPoint:scaledPosition toView:self];
            CGPoint point = CGPointMake(globalPosition.x - CGRectGetMinX(_contentView.frame), globalPosition.y - CGRectGetMinY(_contentView.frame));
            CGPoint anchorPosition = CGPointMake(point.x * theScale,  point.y * theScale);
            selectedShape.layer.position = anchorPosition;
            layerAnchorPosition = anchorPosition;
            switch (button.tag) {
                case Up:
                    selectedShape.layer.anchorPoint = CGPointMake(.5, 1);
                    break;
                case Right:
                    NSLog(@"Right");
                    selectedShape.layer.anchorPoint = CGPointMake(0, .5);
                    break;
                case Down:
                    NSLog(@"Down");
                    selectedShape.layer.anchorPoint = CGPointMake(0.5, 0);
                    break;
                case Left:
                    selectedShape.layer.anchorPoint = CGPointMake(1, .5);
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
            
            // TAG: 10 Up, 20 Right, 30 Bottom, 40 Left, 50 Aspect
            
            NSInteger newTag = button.tag;
            int multiplier = 0;
            if (button.tag != Aspect && (rotation >= M_PI_2 || rotation < 0)){
                if (rotation < 0){
                    float angle =  2* M_PI + rotation;
                    multiplier = angle/M_PI_2;
                }else{
                    multiplier = rotation/M_PI_2;
                }
                newTag = newTag+10*multiplier;
                newTag = newTag%40 == 0 ? 40 : newTag%40;
            }
            
            float newDistance = [self getDistanceBetweenPoint:layerAnchorPosition andPoint:location];
            NSLog(@"New Distance = %f",newDistance);
            
            // After rotation is belongs to 90 to 180 or 270 to 360 degree then height and width will be exchange to each other
            BOOL shouldExchange = (multiplier == 1 || multiplier == 3);
            
            switch (newTag) {
                case Left:
                    NSLog(@"Left");
                    if (shouldExchange){
                        newRect.size.height -= deltaX;
                    }else{
                        newRect.size.width -= deltaX;
                    }
                    break;
                case Right:
                    NSLog(@"Right");
                    if (shouldExchange){
                        newRect.size.height += deltaX;
                    }else{
                        newRect.size.width += deltaX;
                    }
                    break;
                case Up:
                    NSLog(@"Up");
                    if (shouldExchange){
                        newRect.size.width -= deltaY;
                    }else{
                        newRect.size.height -= deltaY;
                    }
                    break;
                case Down:
                    // Updating frame of selected shape;
                    NSLog(@"Down");
                    if (shouldExchange){
                        newRect.size.width += deltaY;
                    }else{
                        newRect.size.height += deltaY;
                    }
                    break;
                case Aspect:
                    // Updating frame of selected shape;
                    NSLog(@"ASPECT");
                    float aspectDetla = ABS(deltaX)+ABS(deltaY)/2;
                    if (newDistance >= touchMovingDistance){
                        newRect.size.width += aspectDetla;
                        newRect.size.height += aspectDetla;
                    }else{
                        newRect.size.width -= aspectDetla;
                        newRect.size.height -= aspectDetla;
                    }
                    break;
                default:
                    break;
            }
            CGSize minSize = [self getMinSize];
            newRect.size.width = MAX(minSize.width, newRect.size.width);
            newRect.size.height = MAX(minSize.height, newRect.size.height);
            if (newRect.size.width <= minSize.width && newRect.size.height <= minSize.height){
                // Disabling gesture, when the shap size is reaches to the minimum allowed size.
                [gesture setEnabled:NO];
                [gesture setEnabled:YES];
                selectedShape.bounds = newRect;
                [selectedShape setNeedsDisplay];
                [self contentViewSizeToFit];
                previousTouchPosition = location;
                touchMovingDistance = newDistance;
                [self gestureEndDragging:selectedShape];
                NSLog(@"Disabling gesture, when the shap size is reaches to the minimum allowed size");
            }
            else{
                // Set new frame to the shape after darg gesture.
                selectedShape.bounds = newRect;
                [selectedShape setNeedsDisplay];
                [self contentViewSizeToFit];
                previousTouchPosition = location;
                touchMovingDistance = newDistance;
            }
            break;
        default:
            [self gestureEndDragging:selectedShape];
            break;
    }
}

- (void)setOutlineViewOverShape:(WMSpatialViewShape *)shape{
    viewShapeOutline.transform = CGAffineTransformIdentity;
    CGRect shapeRect = CGRectZero;
    shapeRect.size = CGSizeMake(shape.bounds.size.width+70, shape.bounds.size.height+70);
    viewShapeOutline.frame = shapeRect;
    viewShapeOutline.transform = shape.transform;
    viewShapeOutline.center = CGPointMake(CGRectGetMidX(shape.frame), CGRectGetMidY(shape.frame));
}

- (CGFloat) getDistanceBetweenPoint:(CGPoint )a andPoint:(CGPoint)b {
    float xDist = a.x - b.x;
    float yDist = a.y - b.y;
    return sqrt(xDist * xDist + yDist * yDist);
}

- (void)clearAll{
    [self setZoomScale:1.0];
    for (UIView* b in self.contentView.subviews)
    {
        [b removeFromSuperview];
    }
}

- (CGSize) getAspectFitSize:(CGSize)aspectRatio boundingSize:(CGSize) boundingSize{
    float mW = boundingSize.width / aspectRatio.width;
    float mH = boundingSize.height / aspectRatio.height;
    
    if( mH < mW ) {
        boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
    }
    else if( mW < mH ) {
        boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
    }
    return boundingSize;
}


- (NSArray *)saveAllShapes{
    NSMutableArray *shapeItems = [NSMutableArray new];
    CGSize contentSize =  _contentView.bounds.size;
    for (UIView *view in [_contentView subviews]){
        if([view isKindOfClass:[WMSpatialViewShape class]]){
            WMSpatialViewShape *shape = (WMSpatialViewShape *)view;
            shape.shapeModel.angle = [shape getAngleFromTransform];
            CGAffineTransform oldTran = shape.transform;
            shape.transform = CGAffineTransformIdentity;
            CGRect frame = shape.frame;
            shape.transform = oldTran;
            CGPoint scaledOrigin = CGPointMake(frame.origin.x/contentSize.width, frame.origin.y/contentSize.height);
            CGSize scaledSize = CGSizeMake(frame.size.width/contentSize.width, frame.size.height/contentSize.height);
            // Scalling the shape size relatively to room size.
            shape.shapeModel.frame = CGRectMake(scaledOrigin.x, scaledOrigin.y, scaledSize.width, scaledSize.height);
            [shapeItems addObject:shape.shapeModel];
        }
    }
    return [shapeItems copy];
}

- (void)setMinMaxZoomScale{
    self.minimumZoomScale = 0.1;
    self.maximumZoomScale = 5.5;
}

- (CGSize) getMinSize{
    int min = MIN(self.contentView.bounds.size.width/7, self.contentView.bounds.size.height/7);
    return CGSizeMake(min, min);
}

+ (BOOL)isDeviceTypeIpad{
    return  [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}


@end
