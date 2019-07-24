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
}

@end

@implementation WMSpatialView

- (void)reloadShapes{
    arrSelectedItems = [NSMutableArray new];
    // Clear spatial view if alrady have contents.
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
    
    if ([self.delegate respondsToSelector:@selector(spatialView:viewForItem:)]){
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
}

- (void)didTapOnView:(WMSpatialViewShape *)shape{
    
/*
    CGRect oldRect = shape.frame;
    UIView *superView = shape.superview;
    oldRect.size = CGSizeMake(oldRect.size.width+20, oldRect.size.height+20);
    shape.frame = oldRect;
*/
    /*
 Transform using angle
    CGAffineTransform transform = shape.transform;
    transform = CGAffineTransformConcat(CGAffineTransformScale(transform,  1.1, 1.1),
                                        CGAffineTransformRotate(transform, 10));
    shape.transform = transform;
    */
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
}

- (void) contentViewSizeToFit{
    CGRect rect = CGRectZero;
    for (UIView *view in self.contentView.subviews) {
        rect = CGRectUnion(rect, view.frame);
    }
    CGSize contentSize = rect.size;
    contentSize.width += 2*self.margin;
    contentSize.height += 2*self.margin;
    
    _contentView.frame = CGRectMake(0, 0, contentSize.width*self.zoomScale, contentSize.height*self.zoomScale);
    self.contentSize = _contentView.frame.size;
}

@end
