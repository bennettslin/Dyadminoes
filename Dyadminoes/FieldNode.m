//
//  FieldNode.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/11/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "FieldNode.h"
#import "SnapNode.h"
#import "Dyadmino.h"

@implementation FieldNode {
  CGFloat _width;
  SnapNodeType _snapNodeType;
  
  BOOL _exchangeInProgress;
  
//  BOOL _tempNodeCount;
//  Dyadmino *_dyadminoOnBoard; // for node count purposes
}

#pragma mark - init and layout methods

-(id)initWithWidth:(CGFloat)width andFieldNodeType:(NSUInteger)fieldNodeType {
  self = [super init];
  if (self) {
    self.rackNodes = [NSMutableArray new];
    _width = width;
    _snapNodeType = fieldNodeType;    
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
    
      // if rack depleted, ensure rackNode count matches dyadminoesInRack count
    while (self.rackNodes.count > countNumber) {
      [_rackNodes removeObject:[_rackNodes lastObject]];
    }
    
      // then reposition the rackNodes
    for (SnapNode *rackNode in self.rackNodes) {
      NSUInteger index = [self.rackNodes indexOfObject:rackNode];
      
      rackNode.position = [self getNodePositionAtIndex:index withCountNumber:countNumber
                                        withStrayFloat:0.f andStrayIndex:0];
      rackNode.name = [NSString stringWithFormat:@"rackNode %i", index];
    }
  }
}

-(void)addRackNodeAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber {
  SnapNode *rackNode = [[SnapNode alloc] initWithSnapNodeType:_snapNodeType];
  rackNode.position = [self getNodePositionAtIndex:nodeIndex withCountNumber:countNumber
                                    withStrayFloat:0.f andStrayIndex:0];
  
  rackNode.name = [NSString stringWithFormat:@"rackNode %i", nodeIndex];
  [self.rackNodes addObject:rackNode];
}

#pragma mark - reposition methods

-(void)repositionOrShiftDyadminoes:(NSMutableArray *)dyadminoesInArray givenTouchedDyadmino:(Dyadmino *)touchedDyadmino {
    // dyadminoes are already in array, this method manages the sprite views
  
  for (NSUInteger index = 0; index < self.rackNodes.count; index++) {
    
    Dyadmino *dyadmino = [dyadminoesInArray objectAtIndex:index];
      // assign pointers
//    NSUInteger index = [dyadminoesInArray indexOfObject:dyadmino];
    
      // just in case dyadmino has no homeNode, such as in the beginning
//    if (!dyadmino.homeNode) {
    
      // this has to be reset after turn
      dyadmino.homeNode = self.rackNodes[index];
      dyadmino.tempBoardNode = nil;
      dyadmino.withinSection = kDyadminoWithinRack;
//    }
    
    //--------------------------------------------------------------------------
    
      // this if statement means that we're shifting
      // if there's a touched dyadmino, reposition others that are in rack without animation...
//    if (touchedDyadmino && dyadmino != touchedDyadmino && [dyadmino isInRack]) {
//      dyadmino.position = dyadmino.homeNode.position;
    
    //--------------------------------------------------------------------------
      
        // otherwise animate all
//    } else if (!touchedDyadmino) {
    
        // dyadmino is already on rack, just has to animate to new position if not already there
      if (dyadmino.parent == self) {
        if (!CGPointEqualToPoint(dyadmino.position, dyadmino.homeNode.position)) {
          [dyadmino animateConstantSpeedMoveDyadminoToPoint:dyadmino.homeNode.position];
        }
          // dyadmino is *not* already on rack, so add offscreen first and then animate
      } else {
        dyadmino.position = CGPointMake(_width + self.xIncrementInRack, dyadmino.homeNode.position.y);
        [self addChild:dyadmino];
        [dyadmino animateConstantSpeedMoveDyadminoToPoint:dyadmino.homeNode.position];
      }
//    }
  }
}

//-(void)repositionNodesGivenDyadminoes:(NSMutableArray *)dyadminoesInArray uponStrayDyadmino:(Dyadmino *)dyadmino {
//  
//    // do not shift if exchange in progress
//  if (!_exchangeInProgress) {
//    self.dyadminoShiftInProgress = YES;
//    
//      // just to ensure that stray dyadmino is in this array
//    if ([dyadminoesInArray containsObject:dyadmino]) {
//      
//        // get stray numbers
//      CGFloat strayFloat = [dyadmino getHeightFloatGivenGap:kGapForShiftingDyadminoes];
//      NSUInteger strayIndex = [dyadminoesInArray indexOfObject:dyadmino];
//      
//      
//      
//      for (SnapNode *rackNode in self.rackNodes) {
//        NSUInteger nodeIndex = [self.rackNodes indexOfObject:rackNode];
//        
//        rackNode.position = [self getNodePositionAtIndex:nodeIndex
//                                         withCountNumber:self.rackNodes.count
//                                          withStrayFloat:strayFloat andStrayIndex:strayIndex];
//      }
//    }
//  }
//  self.dyadminoShiftInProgress = NO;
//}

-(void)handleRackExchangeOfTouchedDyadmino:(Dyadmino *)touchedDyadmino
                            withDyadminoes:(NSMutableArray *)dyadminoesInArray
                        andClosestRackNode:(SnapNode *)rackNode {
  
    // do not exchange if shift in progress
  if (touchedDyadmino.position.y < kRackHeight - (kGapForShiftingDyadminoes / 2) - kBufferUnderShiftingGapForExchangingDyadminoes) {
//    _exchangeInProgress = YES;
      // just a precaution
    if (rackNode != touchedDyadmino.homeNode) {
      NSUInteger rackNodesIndex = [self.rackNodes indexOfObject:rackNode];
      NSUInteger touchedDyadminoIndex = [dyadminoesInArray indexOfObject:touchedDyadmino];
      Dyadmino *exchangedDyadmino = [dyadminoesInArray objectAtIndex:rackNodesIndex];
      
        // just a precaution
      if (touchedDyadmino != exchangedDyadmino) {
        [dyadminoesInArray exchangeObjectAtIndex:touchedDyadminoIndex withObjectAtIndex:rackNodesIndex];
      }
        // dyadminoes exchange rack nodes, and vice versa
      exchangedDyadmino.homeNode = touchedDyadmino.homeNode;
      
        // take care of state change and animation of exchanged dyadmino, as long as it's not on the board
      if (!exchangedDyadmino.tempBoardNode) {
        
//          // if shift in progress, just reposition...
//        if (_strayDyadminoShiftInProgress) {
//          exchangedDyadmino.position = exchangedDyadmino.homeNode.position;
//          
//            // ...otherwise do animation
//        } else {
        exchangedDyadmino.zPosition = kZPositionRackMovedDyadmino;
        [exchangedDyadmino animateConstantSpeedMoveDyadminoToPoint:exchangedDyadmino.homeNode.position];
        exchangedDyadmino.zPosition = kZPositionRackRestingDyadmino;
//        }
        
      }
    }
      // continues exchange, or if just returning to its own rack node
    touchedDyadmino.homeNode = rackNode;
  }
//  _exchangeInProgress = NO;
}

#pragma mark - helper methods

-(CGPoint)getNodePositionAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber
    withStrayFloat:(CGFloat)strayFloat andStrayIndex:(NSUInteger)strayIndex {

    // margins will vary based on number of dyadminoes in rack
  CGFloat xEdgeMargin = 12.f + (16.f * (kNumDyadminoesInRack - countNumber));
  self.xIncrementInRack = (_width - (2 * xEdgeMargin)) / (countNumber * 2); // right now it's 24.666
  
  CGPoint nodePosition = CGPointMake(xEdgeMargin + self.xIncrementInRack + (2 * self.xIncrementInRack * nodeIndex), kRackHeight / 2);
  
    // if there is no stray dyadmino, then node position is straightforward
//  if (strayFloat == 0.f) {
    return nodePosition;
    
      // otherwise there is a stray index, so...
//  } else {
//
//      // margins for countNumber less one
//    NSUInteger destinationCount = countNumber - 1;
//    CGFloat destinationXEdgeMargin = 12.f + (16.f * (kNumDyadminoesInRack - destinationCount));
//    CGFloat destinationXIncrementInRack = (_width - (2 * destinationXEdgeMargin)) / (destinationCount * 2);
//    CGPoint destinationPosition;
//    
//      // this node is to the left of stray dyadmino
//    if (nodeIndex < strayIndex) {
//      destinationPosition = CGPointMake(destinationXEdgeMargin + destinationXIncrementInRack + (2 * destinationXIncrementInRack * nodeIndex), kRackHeight / 2);
//      
//        // this node is to the right of stray dyadmino
//    } else if (nodeIndex > strayIndex) {
//      destinationPosition = CGPointMake(destinationXEdgeMargin + destinationXIncrementInRack + (2 * destinationXIncrementInRack * (nodeIndex - 1)), kRackHeight / 2);
//    }
//    
//    CGFloat transitionalXPosition = nodePosition.x + (destinationPosition.x - nodePosition.x) * strayFloat;
//    return CGPointMake(transitionalXPosition, kRackHeight / 2);
//  }
}

//-(NSUInteger)getTempNodeCountGivenDyadminoes:(NSMutableArray *)dyadminoesInArray {
//  NSUInteger tempNodeCount = 0;
//  for (Dyadmino *dyadmino in dyadminoesInArray) {
//    
//      // do not add to count if dyadmino is on board
//    if (dyadmino.tempBoardNode) {
//        // do not add to count if dyadmino is touched
//    } else if (dyadmino.myTouch) {
//        //
//    } else {
//      tempNodeCount += 1;
//    }
//  }
//  return tempNodeCount;
//}

@end
