//
//  WMShapeOutlineView.m
//  SpatialViewDemo
//
//  Created by Systango on 03/09/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMShapeOutlineView.h"

@implementation WMShapeOutlineView

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
