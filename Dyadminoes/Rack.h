//
//  FieldNode.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/11/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
@class Dyadmino;
//@class SnapPoint;
@class Board;

@protocol FieldNodeDelegate <NSObject>

-(CGPoint)rackPositionForDyadmino:(Dyadmino *)dyadmino;
-(void)recordChangedDataForRackDyadminoes:(NSArray *)rackArray;
-(void)postSoundNotification:(NotificationName)whichNotification;
-(void)allowUndoButton;

@end

@interface Rack : SKSpriteNode

@property (nonatomic) CGFloat xIncrementInRack;
//@property (strong, nonatomic) NSMutableArray *rackNodes;
@property (weak, nonatomic) id <FieldNodeDelegate> delegate;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

#pragma mark - init and layout methods

-(id)initWithColour:(SKColor *)colour andSize:(CGSize)size andAnchorPoint:(CGPoint)anchorPoint andPosition:(CGPoint)position andZPosition:(CGFloat)zPosition;

//-(void)layoutOrRefreshNodesWithCount:(NSUInteger)countNumber;

#pragma mark - reposition methods

-(void)repositionDyadminoes:(NSArray *)dyadminoesInArray fromUndo:(BOOL)undo withAnimation:(BOOL)animation;
-(NSUInteger)findClosestRackIndexForDyadminoPosition:(CGPoint)dyadminoPosition withCount:(NSUInteger)countNumber;

-(NSArray *)handleRackExchangeOfTouchedDyadmino:(Dyadmino *)touchedDyadmino
                                 withDyadminoes:(NSArray *)dyadminoesInArray
                            andClosestRackIndex:(NSUInteger)closestRackIndex;

#pragma mark - helper methods

-(CGPoint)getNodePositionAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber;

@end



