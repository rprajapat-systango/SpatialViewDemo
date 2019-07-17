//
//  WMSpatialView.m
//  SpatialViewDemo
//
//  Created by SGVVN on 05/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMSpatialView.h"
#import "WMShapeView.h"

@interface WMSpatialView(){
    NSMutableArray *arrSelectedItems;
}

@end

@implementation WMSpatialView

- (NSArray *)getShapesArray {
    NSMutableArray *shapes = [NSMutableArray new];
    WMShapeView *circle = [[WMShapeView alloc] initWithFrame:CGRectMake(50, 50, 200, 200) type:ELLIPSE title:@"100" andColor:[UIColor redColor] withDelegate:self];
    [shapes addObject:circle];
    // Adding another view as Ellipse
    WMShapeView *ellipse = [[WMShapeView alloc] initWithFrame:CGRectMake(300, 50, 300, 200) type:ELLIPSE title:@"102" andColor:[UIColor blueColor] withDelegate:self];
    [shapes addObject:ellipse];
    // Adding another view as Rectangle
    WMShapeView *longRectangle = [[WMShapeView alloc] initWithFrame:CGRectMake(650, 50, 120, 570) type:RECTANGLE title:@"103" andColor:[UIColor greenColor] withDelegate:self];
    [shapes addObject:longRectangle];
    // Adding another view as Rectangle
    WMShapeView *rectangle = [[WMShapeView alloc] initWithFrame:CGRectMake(50, 300, 200, 300) type:RECTANGLE title:@"104" andColor:[UIColor greenColor] withDelegate:self];
    [shapes addObject:rectangle];
    // Adding another view as Square
    WMShapeView *square = [[WMShapeView alloc] initWithFrame:CGRectMake(300, 300, 140, 140) type:DIAMOND title:@"106" andColor:[UIColor yellowColor] withDelegate:self];
    [shapes addObject:square];
    WMShapeView *square2 = [[WMShapeView alloc] initWithFrame:CGRectMake(460, 300, 140, 140) type:DIAMOND title:@"109" andColor:[UIColor yellowColor] withDelegate:self];
    [shapes addObject:square2];
    WMShapeView *square3 = [[WMShapeView alloc] initWithFrame:CGRectMake(300, 460, 140, 140) type:DIAMOND title:@"201" andColor:[UIColor yellowColor] withDelegate:self];
    [shapes addObject:square3];
    WMShapeView *square4 = [[WMShapeView alloc] initWithFrame:CGRectMake(460, 460, 140, 140) type:DIAMOND title:@"202" andColor:[UIColor yellowColor] withDelegate:self];
    [shapes addObject:square4];
    
    return [shapes copy];
}

- (void)loadShapes:(NSArray *)shapes {
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
    for (WMShapeView *view in [self getShapesArray]) {
        [_contentView addSubview:view];
    }
    
    [self setContentViewRect];
}

- (void)didTapOnView:(WMShapeView *)shape{
//    CGRect oldRect = shape.frame;
//    UIView *superView = shape.superview;
//    oldRect.size = CGSizeMake(oldRect.size.width+20, oldRect.size.height+20);
//    shape.frame = oldRect;

// Transform using angle
//    CGAffineTransform transform = shape.transform;
//    transform = CGAffineTransformConcat(CGAffineTransformScale(transform,  1.1, 1.1),
//                                        CGAffineTransformRotate(transform, 10));
//    shape.transform = transform;
    
    if (arrSelectedItems.count){
        WMShapeView *oldSelection = (WMShapeView *)arrSelectedItems.firstObject;
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
}

- (void) setContentViewRect{
    CGRect rect = CGRectZero;
    for (UIView *view in self.contentView.subviews) {
        rect = CGRectUnion(rect, view.frame);
    }
    CGSize contentSize = rect.size;
    contentSize.width += 2*self.margin;
    contentSize.height += 2*self.margin;
    _contentView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    self.contentSize = _contentView.frame.size;
}

@end
