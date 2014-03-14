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
      
      rackNode.position = [self getNodePositionAtIndex:index withCountNumber:countNumber];
      rackNode.name = [NSString stringWithFormat:@"rackNode %i", index];
    }
  }
}

-(void)addRackNodeAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber {
  SnapNode *rackNode = [[SnapNode alloc] initWithSnapNodeType:_snapNodeType];
  rackNode.position = [self getNodePositionAtIndex:nodeIndex withCountNumber:countNumber];
  
  rackNode.name = [NSString stringWithFormat:@"rackNode %i", nodeIndex];
  [self.rackNodes addObject:rackNode];
}

#pragma mark - reposition methods

-(void)repositionDyadminoes:(NSMutableArray *)dyadminoesInArray {
    // dyadminoes are already in array, this method manages the sprite views
  
  for (NSUInteger index = 0; index < self.rackNodes.count; index++) {
    
    // assign pointers
    Dyadmino *dyadmino = [dyadminoesInArray objectAtIndex:index];

    // this has to be reset after turn
    dyadmino.homeNode = self.rackNodes[index];
    dyadmino.tempBoardNode = nil;
    dyadmino.withinSection = kDyadminoWithinRack;

    //--------------------------------------------------------------------------
  
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
  }
}

-(void)handleRackExchangeOfTouchedDyadmino:(Dyadmino *)touchedDyadmino
                            withDyadminoes:(NSMutableArray *)dyadminoesInArray
                        andClosestRackNode:(SnapNode *)rackNode {
  
  if (touchedDyadmino.position.y < kRackHeight) {

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
        exchangedDyadmino.zPosition = kZPositionRackMovedDyadmino;
        [exchangedDyadmino animateConstantSpeedMoveDyadminoToPoint:exchangedDyadmino.homeNode.position];
        exchangedDyadmino.zPosition = kZPositionRackRestingDyadmino;
      }
    }
      // continues exchange, or if just returning to its own rack node
    touchedDyadmino.homeNode = rackNode;
  }
}

#pragma mark - helper methods

-(CGPoint)getNodePositionAtIndex:(NSUInteger)nodeIndex withCountNumber:(NSUInteger)countNumber {

    // margins will vary based on number of dyadminoes in rack
  CGFloat xEdgeMargin = 12.f + (16.f * (kNumDyadminoesInRack - countNumber));
  self.xIncrementInRack = (_width - (2 * xEdgeMargin)) / (countNumber * 2); // right now it's 24.666
  
  return CGPointMake(xEdgeMargin + self.xIncrementInRack + (2 * self.xIncrementInRack * nodeIndex), kRackHeight / 2);
}

@end
