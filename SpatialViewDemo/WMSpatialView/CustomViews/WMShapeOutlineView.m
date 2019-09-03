//
//  WMShapeOutlineView.m
//  SpatialViewDemo
//
//  Created by Systango on 03/09/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMShapeOutlineView.h"

@implementation WMShapeOutlineView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)deleteShape:(UIButton *)sender {
    if (self.selectedShape){
        if([self.delegate respondsToSelector:@selector(removeShape:)]){
            [self.delegate removeShape:self.selectedShape];
        }
    }
}

- (IBAction)rotateShape:(UIButton *)sender {
    if (self.selectedShape){
        [self.selectedShape rotateByAngle:M_PI_2/2];
        [self.spatialView setOutlineViewOverShape:self.selectedShape];
        [self.spatialView contentViewSizeToFit];
    }
}

- (IBAction)copyShape:(UIButton *)sender {
    //[self perfomrActionOnShapeUsingMenuOption:sender.tag];
}

@end
