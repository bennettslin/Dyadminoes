//
//  FieldNode.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/11/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class Dyadmino;

@protocol FieldNodeDelegate <NSObject>

@end

@interface FieldNode : SKSpriteNode

@property (nonatomic) CGFloat xIncrementInRack;
@property (strong, nonatomic) NSMutableArray *rackNodes;
@property (weak, nonatomic) id <FieldNodeDelegate> delegate;

-(id)initWithWidth:(CGFloat)width andFieldNodeType:(NSUInteger)fieldNodeType;
-(void)layoutOrRefreshFieldWithCount:(NSUInteger)countNumber;
-(void)populateOrRefreshWithDyadminoes:(NSMutableArray *)dyadminoesInArray;

@end

