//
//  FieldNode.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/11/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class Dyadmino;
@class SnapNode;

@protocol FieldNodeDelegate <NSObject>

@end

@interface FieldNode : SKSpriteNode

@property (nonatomic) CGFloat xIncrementInRack;
@property (strong, nonatomic) NSMutableArray *rackNodes;
@property (weak, nonatomic) id <FieldNodeDelegate> delegate;

@property (nonatomic) BOOL dyadminoShiftInProgress;

#pragma mark - init and layout methods

-(id)initWithWidth:(CGFloat)width andFieldNodeType:(NSUInteger)fieldNodeType;
-(void)layoutOrRefreshNodesWithCount:(NSUInteger)countNumber;

#pragma mark - reposition methods

-(void)repositionDyadminoes:(NSMutableArray *)dyadminoesInArray;

-(void)handleRackExchangeOfTouchedDyadmino:(Dyadmino *)touchedDyadmino
                            withDyadminoes:(NSMutableArray *)dyadminoesInArray
                        andClosestRackNode:(SnapNode *)rackNode;

@end

