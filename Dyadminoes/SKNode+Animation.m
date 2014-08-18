//
//  SKNode+Animation.m
//  Dyadminoes
//
//  Created by Bennett Lin on 8/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SKNode+Animation.h"

@implementation SKNode (Animation)

-(void)moveToYPosition:(CGFloat)yPosition withBounce:(BOOL)bounce duration:(CGFloat)duration key:(NSString *)key {
  
  SKAction *moveAction = [SKAction moveToY:yPosition duration:duration];
  [self runAction:moveAction withKey:key];
}

@end
