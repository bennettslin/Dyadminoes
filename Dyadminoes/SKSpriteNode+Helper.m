//
//  SKSpriteNode+Helper.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/26/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SKSpriteNode+Helper.h"
#import "NSObject+Helper.h"

@implementation SKSpriteNode (Helper)

#pragma mark - animate methods

-(void)toggleToYPosition:(CGFloat)toYPosition goOut:(BOOL)goOut completion:(void(^)(void))completion withKey:(NSString *)key {
  
  CGFloat originalYPosition = self.position.y;
  CGFloat excessYPosition = ((toYPosition - originalYPosition) / 15.f) + toYPosition;
  
  SKAction *excessAction = [SKAction moveToY:excessYPosition duration:kConstantTime * 0.7];
  excessAction.timingMode = SKActionTimingEaseOut;
  SKAction *bounceBackAction = [SKAction moveToY:toYPosition duration:kConstantTime * 0.3];
  bounceBackAction.timingMode = SKActionTimingEaseIn;
  SKAction *completionAction = [SKAction runBlock:completion];
  SKAction *sequence = [SKAction sequence:@[excessAction, bounceBackAction, completionAction]];
  [self runAction:sequence withKey:key];
}

@end
