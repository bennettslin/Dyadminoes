//
//  FieldNode.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/11/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Rack.h"
#import "Dyadmino.h"
#import "Board.h"

@implementation Rack {
  BOOL _exchangeInProgress;
}

#pragma mark - init and layout methods

-(id)initWithColour:(SKColor *)colour andSize:(CGSize)size andAnchorPoint:(CGPoint)anchorPoint andPosition:(CGPoint)position andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    self.color = colour;
    self.size = size;
    self.anchorPoint = anchorPoint;
    self.position = position;
    self.zPosition = zPosition;
  }
  return self;
}

#pragma mark - reposition methods

-(void)repositionDyadminoes:(NSArray *)dyadminoesInArray fromUndo:(BOOL)undo withAnimation:(BOOL)animation {
    // dyadminoes are already in array, this method manages the sprite views
  
  __weak typeof(self) weakSelf = self;
  NSUInteger rackCount = dyadminoesInArray.count;
  for (NSUInteger index = 0; index < rackCount; index++) {
    
    // assign pointers
    Dyadmino *dyadmino = [dyadminoesInArray objectAtIndex:index];

    // this has to be reset after turn
    dyadmino.rackIndex = index;

    //--------------------------------------------------------------------------
  
    CGPoint shouldBePosition = [dyadmino addIfSwapToHomePosition:[self.delegate rackPositionForDyadmino:dyadmino]];
    
    SKAction *completeAction;
    
      // dyadmino is already on rack
    if (dyadmino.parent == self) {
      
        // no sound if dyadmino is already on rack
      completeAction = [SKAction runBlock:^{
      }];
      
        // undone dyadmino is popped in
      if (undo && index == dyadminoesInArray.count - 1) {
        dyadmino.position = shouldBePosition;
        
        [dyadmino animateGrowPopInWithCompletionBlock:^{
          [weakSelf.delegate allowUndoButton];
        }];
        return;
      }
        // dyadmino is *not* already on rack, so add offscreen first and then animate
    } else {
      
      completeAction = [SKAction runBlock:^{
        [weakSelf.delegate postSoundNotification:kNotificationEaseIntoNode];
      }];
      
      dyadmino.position = CGPointMake(self.size.width + self.xIncrementInRack, shouldBePosition.y);
      dyadmino.zPosition = kZPositionRackRestingDyadmino;
      [self addChild:dyadmino];
      [dyadmino orientWithAnimation:animation];
    }
    
    if (animation) {
      SKAction *waitAction = [SKAction waitForDuration:(undo ? 0 : index * kWaitTimeForRackDyadminoPopulate)];
      SKAction *moveAction = [SKAction runBlock:^{
        [dyadmino animateMoveToPointCalledFromRack:shouldBePosition];
      }];
      SKAction *sequenceAction = [SKAction sequence:@[waitAction, moveAction, completeAction]];
      [dyadmino runAction:sequenceAction withKey:@"repositionDyadmino"];
    } else {
      dyadmino.position = shouldBePosition;
    }
  }
}

-(NSUInteger)findClosestRackIndexForDyadminoPosition:(CGPoint)dyadminoPosition withCount:(NSUInteger)countNumber {
  
  NSUInteger minDistanceIndex;
  CGFloat minDistance = CGFLOAT_MAX;
  
  for (int i = 0; i < countNumber; i++) {
    CGPoint nodePositionToCheck = [self getRackPositionAtIndex:i withCountNumber:countNumber];
    CGFloat thisDistance = fabsf([self getDistanceFromThisPoint:nodePositionToCheck toThisPoint:dyadminoPosition]);
    
    if (thisDistance < minDistance) {
      minDistance = thisDistance;
      minDistanceIndex = i;
    }
  }
  
  return minDistanceIndex;
}


-(NSArray *)handleRackExchangeOfTouchedDyadmino:(Dyadmino *)touchedDyadmino
                                 withDyadminoes:(NSArray *)dyadminoesInArray
                            andClosestRackIndex:(NSUInteger)closestRackIndex {
  
    // touchedDyadmino is in the rack, eligible for exchange
  if ([touchedDyadmino isInRack] || touchedDyadmino.belongsInSwap) {
    
      // touchedDyadmino is closer to another dyadmino's rackNode
    if (closestRackIndex != touchedDyadmino.rackIndex) {
      
        // assign pointers
      NSUInteger newRackNodeIndex = closestRackIndex;
      NSUInteger touchedDyadminoIndex = [dyadminoesInArray indexOfObject:touchedDyadmino];
      NSUInteger iterator;
      
        // decide which direction to scoot dyadminoes
      if (touchedDyadminoIndex > newRackNodeIndex) {
        iterator = 1; // scoot right
      } else if (touchedDyadminoIndex < newRackNodeIndex) {
        iterator = -1; // scoot left
      } else {
        iterator = 0;
      }
      
      Dyadmino *scootedDyadmino = [dyadminoesInArray objectAtIndex:newRackNodeIndex];

        // displaces intermediary dyadminoes one by one until scooted dyadmino is in right node
      while (scootedDyadmino.rackIndex != touchedDyadmino.rackIndex) {
        
        NSUInteger scootedIndex = [dyadminoesInArray indexOfObject:scootedDyadmino];
        NSUInteger displacedIndex = (scootedIndex + iterator) % 6;
    
        Dyadmino *displacedDyadmino = [dyadminoesInArray objectAtIndex:displacedIndex];
        
          // dyadminoes exchange rack indexes, and vice versa
        displacedDyadmino.rackIndex = newRackNodeIndex;
        scootedDyadmino.rackIndex = displacedIndex;
        
          // take care of state change and animation of exchanged dyadmino, as long as it's not on the board
        if (![scootedDyadmino isOnBoard]) {
          scootedDyadmino.zPosition = kZPositionRackMovedDyadmino;
          [scootedDyadmino animateMoveToPointCalledFromRack:[scootedDyadmino addIfSwapToHomePosition:[self.delegate rackPositionForDyadmino:scootedDyadmino]]];
          scootedDyadmino.zPosition = kZPositionRackRestingDyadmino;
          
            // sound it
          [self.delegate postSoundNotification:kNotificationRackExchangeClick];
        }
          // make the displacedDyadmino the new scootedDyadmino
        scootedDyadmino = displacedDyadmino;
      }
      
        // everything scooted, now do it for the touched dyadmino
      touchedDyadmino.rackIndex = closestRackIndex;
      
      NSMutableArray *tempArray = [NSMutableArray arrayWithArray:dyadminoesInArray];
      [tempArray removeObject:touchedDyadmino];
      [tempArray insertObject:touchedDyadmino atIndex:newRackNodeIndex];
      
        // delegate method makes it easier to call only if there was indeed a rack exchange
      NSArray *immutableArray = [NSArray arrayWithArray:tempArray];
      [self.delegate recordChangedDataForRackDyadminoes:immutableArray];

      return immutableArray;
    }
  }
  return dyadminoesInArray;
}

#pragma mark - helper methods

-(CGPoint)getRackPositionAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber {
  
  CGFloat screenEdgeMarginFactor = kIsIPhone ? 0.125f : 2.25f;
  CGFloat dyadminoesLeftFactor = .875f * (kNumDyadminoesInRack - countNumber);

    // margins will vary based on number of dyadminoes in rack
  CGFloat xEdgeMargin = kDyadminoFaceRadius * (screenEdgeMarginFactor + dyadminoesLeftFactor);
  self.xIncrementInRack = (self.size.width / 2.f - xEdgeMargin) / countNumber;
  
  return CGPointMake(xEdgeMargin + self.xIncrementInRack + (2 * self.xIncrementInRack * nodeIndex),
                     (self.size.height) * 0.5);
}

@end
