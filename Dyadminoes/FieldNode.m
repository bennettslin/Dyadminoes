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
  CGFloat _nodeYPosition;
  SnapNodeType _snapNodeType;
  
  BOOL _exchangeInProgress;
}

#pragma mark - init and layout methods

-(id)initWithFieldNodeType:(NSUInteger)fieldNodeType andColour:(UIColor *)colour
                   andSize:(CGSize)size andAnchorPoint:(CGPoint)anchorPoint
               andPosition:(CGPoint)position andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    self.rackNodes = [NSMutableArray new];
    self.color = colour;
    self.size = size;
    self.anchorPoint = anchorPoint;
    self.position = position;
    self.zPosition = zPosition;
    _snapNodeType = fieldNodeType;
    
    if (_snapNodeType == kFieldNodeRack) {
      self.name = @"rack";
      _nodeYPosition = 0.f;
    } else if (_snapNodeType == kFieldNodeSwap) {
      self.name = @"swap";
      _nodeYPosition = kRackHeight;
    }

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
    for (SnapNode *rackNode in self.rackNodes) {
      NSUInteger index = [self.rackNodes indexOfObject:rackNode];
      rackNode.position = [self getNodePositionAtIndex:index withCountNumber:countNumber];
    }
  }
}

#pragma mark - reposition methods

-(void)repositionDyadminoes:(NSMutableArray *)dyadminoesInArray {
    // dyadminoes are already in array, this method manages the sprite views
    
  for (NSUInteger index = 0; index < dyadminoesInArray.count; index++) {
    
    // assign pointers
    Dyadmino *dyadmino = [dyadminoesInArray objectAtIndex:index];

    // this has to be reset after turn
    dyadmino.homeNode = self.rackNodes[index];
    dyadmino.tempBoardNode = nil;
    dyadmino.withinSection = kWithinRack;

    //--------------------------------------------------------------------------
  
      // to ensure position if swapped
    CGPoint shouldBePosition = [dyadmino getHomeNodePosition];
    
      // dyadmino is already on rack, just has to animate to new position if not already there
    if (dyadmino.parent == self) {
      if (!CGPointEqualToPoint(dyadmino.position, shouldBePosition)) {
        [dyadmino animateConstantSpeedMoveDyadminoToPoint:shouldBePosition];
      }
      
        // dyadmino is *not* already on rack, so add offscreen first and then animate
    } else {
      dyadmino.position = CGPointMake(self.size.width + self.xIncrementInRack, shouldBePosition.y);
      [self addChild:dyadmino];
      [dyadmino animateConstantSpeedMoveDyadminoToPoint:shouldBePosition];
    }
  }
}

-(void)handleRackExchangeOfTouchedDyadmino:(Dyadmino *)touchedDyadmino
                            withDyadminoes:(NSMutableArray *)dyadminoesInArray
                        andClosestRackNode:(SnapNode *)touchedDyadminoNewRackNode {
  
    // touchedDyadmino is in the rack, eligible for exchange
  if ([touchedDyadmino isInRack] || [touchedDyadmino isInSwap]) {

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
      }
      
      Dyadmino *scootedDyadmino = [dyadminoesInArray objectAtIndex:newRackNodeIndex];

      while (scootedDyadmino.homeNode != touchedDyadmino.homeNode) {
        
        NSUInteger scootedIndex = [dyadminoesInArray indexOfObject:scootedDyadmino];
        NSUInteger displacedIndex = (scootedIndex + iterator) % 6;
    
        Dyadmino *displacedDyadmino = [dyadminoesInArray objectAtIndex:displacedIndex];
        
          // dyadminoes exchange rack nodes, and vice versa
        scootedDyadmino.homeNode = displacedDyadmino.homeNode;
        
          // take care of state change and animation of exchanged dyadmino, as long as it's not on the board
        if (!scootedDyadmino.tempBoardNode) {
          scootedDyadmino.zPosition = kZPositionRackMovedDyadmino;
          [scootedDyadmino animateConstantSpeedMoveDyadminoToPoint:[scootedDyadmino getHomeNodePosition]];
          scootedDyadmino.zPosition = kZPositionRackRestingDyadmino;
        }
          // make the displacedDyadmino the new scootedDyadmino
        displacedDyadmino.homeNode = scootedDyadmino.homeNode;
        scootedDyadmino = displacedDyadmino;
      }
      
        // everything scooted, now do it for the touched dyadmino
      touchedDyadmino.homeNode = touchedDyadminoNewRackNode;
      [dyadminoesInArray removeObject:touchedDyadmino];
      [dyadminoesInArray insertObject:touchedDyadmino atIndex:newRackNodeIndex];
    }
  }
}

-(void)addRackNodeAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber {
  SnapNode *rackNode = [[SnapNode alloc] initWithSnapNodeType:_snapNodeType];
  rackNode.position = [self getNodePositionAtIndex:nodeIndex withCountNumber:countNumber];
  
  rackNode.name = [NSString stringWithFormat:@"%@ node %lu", self.name, (unsigned long)nodeIndex];
  [self.rackNodes addObject:rackNode];
}

#pragma mark - helper methods

-(CGPoint)getNodePositionAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber {

    // margins will vary based on number of dyadminoes in rack
  CGFloat xEdgeMargin = 12.f + (16.f * (kNumDyadminoesInRack - countNumber));
  self.xIncrementInRack = (self.size.width - (2 * xEdgeMargin)) / (countNumber * 2); // right now it's 24.666
  
  return CGPointMake(xEdgeMargin + self.xIncrementInRack + (2 * self.xIncrementInRack * nodeIndex),
                     _nodeYPosition + (self.size.height) / 2);
}

@end
