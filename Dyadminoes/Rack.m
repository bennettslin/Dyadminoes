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
  CGFloat _nodeYPosition;
  SnapPointType _snapNodeType;
  Board *_board;
  BOOL _exchangeInProgress;
}

#pragma mark - init and layout methods

  // FIXME: does rackNode need to know board?
-(id)initWithBoard:(Board *)board andColour:(SKColor *)colour
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
    _board = board;
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

-(void)repositionDyadminoes:(NSMutableArray *)dyadminoesInArray {
    // dyadminoes are already in array, this method manages the sprite views
    
  for (NSUInteger index = 0; index < dyadminoesInArray.count; index++) {
    
    // assign pointers
    Dyadmino *dyadmino = [dyadminoesInArray objectAtIndex:index];

    // this has to be reset after turn
    dyadmino.homeNode = self.rackNodes[index];
    dyadmino.tempBoardNode = nil;
//    dyadmino.withinSection = kWithinRack;

    //--------------------------------------------------------------------------
  
      // to ensure position if swapped
    CGPoint shouldBePosition = [dyadmino getHomeNodePosition];
    
      // dyadmino is already on rack, just has to animate to new position if not already there
    if (dyadmino.parent == self) {
      if (!CGPointEqualToPoint(dyadmino.position, shouldBePosition)) {
        [dyadmino animateMoveDyadminoInRackToPoint:shouldBePosition];
      }
      
        // dyadmino is *not* already on rack, so add offscreen first and then animate
    } else {
      dyadmino.position = CGPointMake(self.size.width + self.xIncrementInRack, shouldBePosition.y);
      dyadmino.zPosition = kZPositionRackRestingDyadmino;
      [self addChild:dyadmino];
      [dyadmino animateMoveDyadminoInRackToPoint:shouldBePosition];
    }
  }
}

-(void)handleRackExchangeOfTouchedDyadmino:(Dyadmino *)touchedDyadmino
                            withDyadminoes:(NSMutableArray *)dyadminoesInArray
                        andClosestRackNode:(SnapPoint *)touchedDyadminoNewRackNode {
  
    // touchedDyadmino is in the rack, eligible for exchange
  if ([touchedDyadmino isInRack] || [touchedDyadmino isOrBelongsInSwap]) {

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
          [scootedDyadmino animateMoveDyadminoInRackToPoint:[scootedDyadmino getHomeNodePosition]];
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
  
  SnapPoint *rackNode = [[SnapPoint alloc] initWithSnapPointType:_snapNodeType];
  rackNode.position = [self getNodePositionAtIndex:nodeIndex withCountNumber:countNumber];
  
  rackNode.name = [NSString stringWithFormat:@"%@ node %lu", self.name, (unsigned long)nodeIndex];
  [self.rackNodes addObject:rackNode];
}

#pragma mark - helper methods

-(CGPoint)getNodePositionAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber {
  
  CGFloat screenEdgeMarginFactor = 0.125f;
  CGFloat dyadminoesLeftFactor = .875f * (kNumDyadminoesInRack - countNumber);
  
    // margins will vary based on number of dyadminoes in rack
  CGFloat xEdgeMargin = kDyadminoFaceRadius * (screenEdgeMarginFactor + dyadminoesLeftFactor);
  self.xIncrementInRack = (self.size.width / 2.f - xEdgeMargin) / countNumber;
  
  return CGPointMake(xEdgeMargin + self.xIncrementInRack + (2.f * self.xIncrementInRack * nodeIndex),
                     _nodeYPosition + (self.size.height) / 2.f);
}

@end
