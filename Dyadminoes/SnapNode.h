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

@interface SnapNode : NSObject

@property (nonatomic) SnapNodeType snapNodeType;
@property (nonatomic) CGPoint position;
@property (strong, nonatomic) NSString *name;
-(id)initWithSnapNodeType:(SnapNodeType)snapNodeType;

-(SnapNodeType)isType;

@end
