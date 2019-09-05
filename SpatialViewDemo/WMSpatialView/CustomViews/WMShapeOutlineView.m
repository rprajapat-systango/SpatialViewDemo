//
//  WMShapeOutlineView.m
//  SpatialViewDemo
//
//  Created by Systango on 03/09/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMShapeOutlineView.h"
@implementation WMShapeOutlineView

- (void)setTransform:(CGAffineTransform)transform{
    [super setTransform:transform];
}


- (CGFloat)getAngleFromTransform{
    CGFloat angle = [(NSNumber *)[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    NSLog(@"\nView Rotation is : %f\n", angle); // 0.020000
    return angle;
}

- (IBAction)copyShape:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(copyShape:)]){
        [self.delegate copyShape:self.selectedShape];
    }
}

- (IBAction)rotateShape:(UIButton *)sender {
    if (self.selectedShape){
        if([self.delegate respondsToSelector:@selector(rotateShape:)]){
            [self.delegate rotateShape:self.selectedShape];
        }
    }
}

- (IBAction)deleteShape:(UIButton *)sender {
    if (self.selectedShape){
        if([self.delegate respondsToSelector:@selector(removeShape:)]){
            [self.delegate removeShape:self.selectedShape];
            
        }
    }
}

@end
