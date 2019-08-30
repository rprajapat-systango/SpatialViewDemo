//
//  WMShape.m
//  SpatialViewDemo
//
//  Created by Systango on 17/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMShape.h"

@implementation WMShape

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict{
    WMShape *shape = [[WMShape alloc] init];
    return shape;
}

- (void)upateWithDict:(NSDictionary *)dict{
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{\"frame\": %@, \"title\": %@,\"shapeType\": %d,\"angle\": %f}",NSStringFromCGRect(_frame),self.title, self.shapeType,self.angle];
}

@end
