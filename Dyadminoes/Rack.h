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
@class SnapPoint;
@class Board;

@protocol FieldNodeDelegate <NSObject>

-(void)recordChangedDataForRackDyadminoes:(NSArray *)rackArray;
-(void)postSoundNotification:(NotificationName)whichNotification;

@end

@interface Rack : SKSpriteNode

@property (nonatomic) CGFloat xIncrementInRack;
@property (strong, nonatomic) NSMutableArray *rackNodes;
@property (weak, nonatomic) id <FieldNodeDelegate> delegate;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

#pragma mark - init and layout methods

-(id)initWithColour:(SKColor *)colour andSize:(CGSize)size andAnchorPoint:(CGPoint)anchorPoint andPosition:(CGPoint)position andZPosition:(CGFloat)zPosition;

-(void)layoutOrRefreshNodesWithCount:(NSUInteger)countNumber;

#pragma mark - reposition methods

-(void)repositionDyadminoes:(NSArray *)dyadminoesInArray fromUndo:(BOOL)undo withAnimation:(BOOL)animation;

-(NSArray *)handleRackExchangeOfTouchedDyadmino:(Dyadmino *)touchedDyadmino
                            withDyadminoes:(NSArray *)dyadminoesInArray
                        andClosestRackNode:(SnapPoint *)touchedDyadminoNewRackNode;

@end



