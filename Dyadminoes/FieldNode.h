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

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

#pragma mark - init and layout methods

-(id)initWithFieldNodeType:(NSUInteger)fieldNodeType andColour:(SKColor *)colour
                   andSize:(CGSize)size andAnchorPoint:(CGPoint)anchorPoint
               andPosition:(CGPoint)position andZPosition:(CGFloat)zPosition;

-(void)layoutOrRefreshNodesWithCount:(NSUInteger)countNumber;

#pragma mark - reposition methods

-(void)repositionDyadminoes:(NSMutableArray *)dyadminoesInArray;

-(void)handleRackExchangeOfTouchedDyadmino:(Dyadmino *)touchedDyadmino
                            withDyadminoes:(NSMutableArray *)dyadminoesInArray
                        andClosestRackNode:(SnapNode *)touchedDyadminoNewRackNode;

@end

