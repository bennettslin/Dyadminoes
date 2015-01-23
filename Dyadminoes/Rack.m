//
//  FieldNode.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/11/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Rack.h"
#import "SnapPoint.h"
#import "Dyadmino.h"
#import "Board.h"

@implementation Rack {
  SnapPointType _snapNodeType;
  BOOL _exchangeInProgress;
}

#pragma mark - init and layout methods

-(id)initWithColour:(SKColor *)colour andSize:(CGSize)size andAnchorPoint:(CGPoint)anchorPoint andPosition:(CGPoint)position andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    self.rackNodes = [NSMutableArray new];
    self.color = colour;
    self.size = size;
    self.anchorPoint = anchorPoint;
    self.position = position;
    self.zPosition = zPosition;
  }
  return self;
}

-(void)layoutOrRefreshNodesWithCount:(NSUInteger)countNumber {
    // this only gets called when initially laying out, or after turn
  
    // initial layout of rack nodes...
  if (self.rackNodes.count == 0) {
    for (NSUInteger index = 0; index < countNumber; index++) {
      [self addRackNodeAtIndex:index withCountNumber:countNumber];
    }
    //--------------------------------------------------------------------------
    
      // or else refreshing dyadminoes
  } else {
    
      // ensure rackNode count matches dyadminoesInRack count
    while (self.rackNodes.count != countNumber) {
      if (self.rackNodes.count > countNumber) {
        [self.rackNodes removeObject:[self.rackNodes lastObject]];
      } else if (self.rackNodes.count < countNumber) {
        [self addRackNodeAtIndex:self.rackNodes.count withCountNumber:countNumber];
      }
    }
    
      // then reposition the rackNodes
    for (SnapPoint *rackNode in self.rackNodes) {
      NSUInteger index = [self.rackNodes indexOfObject:rackNode];
      rackNode.position = [self getNodePositionAtIndex:index withCountNumber:countNumber];
    }
  }
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
    dyadmino.homeNode = self.rackNodes[index];
    dyadmino.tempBoardNode = nil;

    //--------------------------------------------------------------------------
  
    CGPoint shouldBePosition = [dyadmino getHomeNodePositionConsideringSwap];
    
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
      [dyadmino orientBySnapNode:dyadmino.homeNode animate:animation];
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
    CGPoint nodePositionToCheck = [self getNodePositionAtIndex:i withCountNumber:countNumber];
    CGFloat thisDistance = fabsf([self getDistanceFromThisPoint:nodePositionToCheck toThisPoint:dyadminoPosition]);
    
    if (thisDistance < minDistance) {
      minDistance = thisDistance;
      minDistanceIndex = i;
    }
  }
  
  NSLog(@"closest rack index is %i", minDistanceIndex);
  return minDistanceIndex;
}


-(NSArray *)handleRackExchangeOfTouchedDyadmino:(Dyadmino *)touchedDyadmino
                                 withDyadminoes:(NSArray *)dyadminoesInArray
                             andClosestRackNode:(SnapPoint *)touchedDyadminoNewRackNode {
  
    // touchedDyadmino is in the rack, eligible for exchange
  if ([touchedDyadmino isInRack] || touchedDyadmino.belongsInSwap) {
    
      // touchedDyadmino is closer to another dyadmino's rackNode
    if (touchedDyadminoNewRackNode != touchedDyadmino.homeNode) {
      
        // assign pointers
      NSUInteger newRackNodeIndex = [self.rackNodes indexOfObject:touchedDyadminoNewRackNode];
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
      while (scootedDyadmino.homeNode != touchedDyadmino.homeNode) {
        
        NSUInteger scootedIndex = [dyadminoesInArray indexOfObject:scootedDyadmino];
        NSUInteger displacedIndex = (scootedIndex + iterator) % 6;
    
        Dyadmino *displacedDyadmino = [dyadminoesInArray objectAtIndex:displacedIndex];
        
          // dyadminoes exchange rack nodes, and vice versa
        scootedDyadmino.homeNode = displacedDyadmino.homeNode;
        
        displacedDyadmino.myRackOrder = newRackNodeIndex;
        scootedDyadmino.myRackOrder = displacedIndex;
        
          // take care of state change and animation of exchanged dyadmino, as long as it's not on the board
        if (!scootedDyadmino.tempBoardNode) {
          scootedDyadmino.zPosition = kZPositionRackMovedDyadmino;
          [scootedDyadmino animateMoveToPointCalledFromRack:[scootedDyadmino getHomeNodePositionConsideringSwap]];
          scootedDyadmino.zPosition = kZPositionRackRestingDyadmino;
          
            // sound it
          [self.delegate postSoundNotification:kNotificationRackExchangeClick];
        }
          // make the displacedDyadmino the new scootedDyadmino
        displacedDyadmino.homeNode = scootedDyadmino.homeNode;
        scootedDyadmino = displacedDyadmino;
      }
      
        // everything scooted, now do it for the touched dyadmino
      touchedDyadmino.homeNode = touchedDyadminoNewRackNode;
      
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

-(void)addRackNodeAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber {
  
  SnapPoint *rackNode = [[SnapPoint alloc] initWithSnapPointType:_snapNodeType];
  rackNode.position = [self getNodePositionAtIndex:nodeIndex withCountNumber:countNumber];
  
  rackNode.name = [NSString stringWithFormat:@"%@ node %lu", self.name, (unsigned long)nodeIndex];
  [self.rackNodes addObject:rackNode];
}

#pragma mark - helper methods

-(CGPoint)getNodePositionAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber {
  
  CGFloat screenEdgeMarginFactor = kIsIPhone ? 0.125f : 2.25f;
  CGFloat dyadminoesLeftFactor = .875f * (kNumDyadminoesInRack - countNumber);

    // margins will vary based on number of dyadminoes in rack
  CGFloat xEdgeMargin = kDyadminoFaceRadius * (screenEdgeMarginFactor + dyadminoesLeftFactor);
  self.xIncrementInRack = (self.size.width / 2.f - xEdgeMargin) / countNumber;
  
  return CGPointMake(xEdgeMargin + self.xIncrementInRack + (2 * self.xIncrementInRack * nodeIndex),
                     (self.size.height) * 0.5);
}

@end
