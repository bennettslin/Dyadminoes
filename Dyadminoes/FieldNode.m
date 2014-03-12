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
}

-(id)initWithWidth:(CGFloat)width andSnapNodeType:(NSUInteger)snapNodeType {
  self = [super init];
  if (self) {
    self.rackNodes = [NSMutableArray new];
    _width = width;
    _snapNodeType = snapNodeType;    
  }
  return self;
}

-(void)layoutOrRefreshFieldWithCount:(NSUInteger)countNumber {
  
    // margins will vary based on number of dyadminoes in rack
  CGFloat xEdgeMargin = 12.f + (16.f * (6 - countNumber));
  self.xIncrementInRack = (_width - (2 * xEdgeMargin)) / (countNumber * 2); // right now it's 24.666
  
    // initial layout of rack nodes
  if (self.rackNodes.count == 0) {
    for (NSUInteger index = 0; index < countNumber; index++) {
      SnapNode *rackNode = [[SnapNode alloc] initWithSnapNodeType:_snapNodeType];
      rackNode.position = CGPointMake(xEdgeMargin + self.xIncrementInRack + (2 * _xIncrementInRack * index), kPlayerRackHeight / 2);
      
      if (_snapNodeType == kSnapNodeRack) {
        rackNode.zPosition = kZPositionRackNode;
      } else {
        rackNode.zPosition = kZPositionSwapNode;
      }
      
      rackNode.name = [NSString stringWithFormat:@"rackNode %i", index];
      [self addChild:rackNode];
      [self.rackNodes addObject:rackNode];
    }
      //--------------------------------------------------------------------------
    
      //layout after pile depletion
  } else {
      // ensure rackNode count matches dyadminoesInRack count
    while (self.rackNodes.count > countNumber) {
      [_rackNodes removeObject:[_rackNodes lastObject]];
    }
      // then reposition
    for (SnapNode *rackNode in self.rackNodes) {
      NSUInteger index = [self.rackNodes indexOfObject:rackNode];
      rackNode.position = CGPointMake(xEdgeMargin + self.xIncrementInRack + (2 * _xIncrementInRack * index), kPlayerRackHeight / 2);
      rackNode.name = [NSString stringWithFormat:@"rackNode %i", index];
    }
  }
}

-(void)populateOrRefreshWithDyadminoes:(NSMutableArray *)dyadminoesInArray {
    // dyadminoes are already in array, this method manages the sprite views
  
  for (int i = 0; i < dyadminoesInArray.count; i++) {
    Dyadmino *dyadmino = dyadminoesInArray[i];
    SnapNode *rackNode = self.rackNodes[i];
    
      // setup dyadmino and rackNode
    dyadmino.homeNode = rackNode;
    dyadmino.tempBoardNode = nil;
    dyadmino.withinSection = kDyadminoWithinRack;
    
    if (dyadmino.parent == self) {
        // dyadmino is already on rack, just has to animate to new position if not already there
      if (!CGPointEqualToPoint(dyadmino.position, dyadmino.homeNode.position)) {
        [dyadmino animateConstantSpeedMoveDyadminoToPoint:dyadmino.homeNode.position];
      }
    } else {
        // dyadmino is *not* already on rack, must add offscreen first, then animate
      dyadmino.position = CGPointMake(_width + self.xIncrementInRack, dyadmino.homeNode.position.y);
      [self addChild:dyadmino];
      [dyadmino animateConstantSpeedMoveDyadminoToPoint:dyadmino.homeNode.position];
    }
  }
}

@end
