//
//  SnapNode.h
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
@class Dyadmino;

@interface SnapPoint : NSObject

@property (nonatomic) SnapPointType snapPointType;
@property (nonatomic) CGPoint position;
@property (strong, nonatomic) NSString *name;

-(id)initWithSnapPointType:(SnapPointType)snapPointType;
-(SnapPointType)isType;

@end
