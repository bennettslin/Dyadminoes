//
//  SKNode+Animation.h
//  Dyadminoes
//
//  Created by Bennett Lin on 8/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"

@interface SKNode (Animation)

-(void)moveToYPosition:(CGFloat)yPosition withBounce:(BOOL)bounce duration:(CGFloat)duration key:(NSString *)key completionAction:(SKAction *)completionAction;

@end
