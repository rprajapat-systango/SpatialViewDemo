//
//  WMGraphView.m
//  SpatialViewDemo
//
//  Created by Systango on 15/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMGraphView.h"

@implementation WMGraphView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawGraphLines:&rect];
    // Creating CGPathRef for drawing line around the shape
}

- (void)drawGraphLines:(const CGRect *)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    float W = rect->size.width;
    float H = rect->size.height;
    
    // Adding vertical lines
    int space = MIN(self.bounds.size.width/10, self.bounds.size.height/10);
    int x = space;
    while (x < W) {
        CGContextMoveToPoint(context, x, 0);
        CGContextAddLineToPoint(context, x, H);
        x += space;
    }

    // Adding horizontal lines
    int y = 0;
    while (y < H) {
        CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, W, y);
        y += space;
    }
    // Perform drawing paths
    CGContextStrokePath(context);
}


@end
