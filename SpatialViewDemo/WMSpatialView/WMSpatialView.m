//
//  WMSpatialView.m
//  SpatialViewDemo
//
//  Created by SGVVN on 05/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMSpatialView.h"
#import "WMShapeView.h"

@implementation WMSpatialView


- (void)loadViewsOnCanvas {
    // Clear spatial view if alrady have contents.
    if (_contentView) {
        [_contentView removeFromSuperview];
    }else{
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    [self addSubview:_contentView];
    // Adding a view as circle
    WMShapeView *circle = [[WMShapeView alloc] initWithFrame:CGRectMake(50, 50, 200, 200) type:ELLIPSE title:@"One" andColor:[UIColor redColor]];
    [self.contentView addSubview:circle];
    
    // Adding another view as Ellipse
    WMShapeView *ellipse = [[WMShapeView alloc] initWithFrame:CGRectMake(300, 50, 300, 200) type:ELLIPSE title:@"Two" andColor:[UIColor blueColor]];
    [self.contentView addSubview:ellipse];
    
    // Adding another view as Rectangle
    WMShapeView *longRectangle = [[WMShapeView alloc] initWithFrame:CGRectMake(630, 50, 120, 570) type:RECTANGLE title:@"Family" andColor:[UIColor greenColor]];
    [self.contentView addSubview:longRectangle];
    
    // Adding another view as Rectangle
    WMShapeView *rectangle = [[WMShapeView alloc] initWithFrame:CGRectMake(50, 300, 200, 300) type:RECTANGLE title:@"Three" andColor:[UIColor greenColor]];
    [self.contentView addSubview:rectangle];
    
    // Adding another view as Square
    WMShapeView *square = [[WMShapeView alloc] initWithFrame:CGRectMake(300, 300, 140, 140) type:DIAMOND title:@"Four" andColor:[UIColor yellowColor]];
    [self.contentView addSubview:square];
    
    WMShapeView *square2 = [[WMShapeView alloc] initWithFrame:CGRectMake(460, 300, 140, 140) type:DIAMOND title:@"Five" andColor:[UIColor yellowColor]];
    [self.contentView addSubview:square2];
    
    WMShapeView *square3 = [[WMShapeView alloc] initWithFrame:CGRectMake(300, 460, 140, 140) type:DIAMOND title:@"SIX" andColor:[UIColor yellowColor]];
    [self.contentView addSubview:square3];
    
    WMShapeView *square4 = [[WMShapeView alloc] initWithFrame:CGRectMake(460, 460, 140, 140) type:DIAMOND title:@"SEVENSEVEN" andColor:[UIColor yellowColor]];
    [self.contentView addSubview:square4];
    
    WMShapeView *largeDiomond = [[WMShapeView alloc] initWithFrame:CGRectMake(300, 700, 300, 400) type:DIAMOND title:@"Five" andColor:[UIColor yellowColor]];
    [self.contentView addSubview:largeDiomond];
    
    WMShapeView *largeDiomond1 = [[WMShapeView alloc] initWithFrame:CGRectMake(900, 500, 200, 400) type:DIAMOND title:@"Five" andColor:[UIColor yellowColor]];
    [self.contentView addSubview:largeDiomond1];
    
    [self setContentViewRect];
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
