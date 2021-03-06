//
//  SKSpriteNode+Helper.h
//  Dyadminoes
//
//  Created by Bennett Lin on 12/26/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (Helper)

#pragma mark - animate methods

-(void)removeAnimationForKey:(NSString *)key withCompletion:(void(^)(void))completion;
-(void)toggleToYPosition:(CGFloat)toYPosition goOut:(BOOL)goOut completion:(void(^)(void))completion withKey:(NSString *)key;
-(void)toggleToXPosition:(CGFloat)toYPosition goOut:(BOOL)goOut completion:(void(^)(void))completion withKey:(NSString *)key;

@end
