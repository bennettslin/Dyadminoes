//
//  Dyadmino.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Dyadmino : SKSpriteNode

  /// pc1 does is the first pc
@property NSUInteger pc1;
@property NSUInteger pc2;
@property (strong, nonatomic) NSString *pcMode;
@property NSUInteger rackOrientation;
@property (strong, nonatomic) NSArray *rotationFrameArray;
@property (strong, nonatomic) SKSpriteNode *pc1LetterSprite;
@property (strong, nonatomic) SKSpriteNode *pc2LetterSprite;
@property (strong, nonatomic) SKSpriteNode *pc1NumberSprite;
@property (strong, nonatomic) SKSpriteNode *pc2NumberSprite;
@property (strong, nonatomic) SKSpriteNode *pc1Sprite;
@property (strong, nonatomic) SKSpriteNode *pc2Sprite;

/**
 initialises a dyadmino with pcs and orientation
 @see hello
 @param pc1, pc2, orientation
 @return itself
 **/
-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andPCMode:(NSString *)pcMode andRotationFrameArray:(NSArray *)rotationFrameArray andPC1LetterSprite:(SKSpriteNode *)pc1LetterSprite andPC2LetterSprite:(SKSpriteNode *)pc2LetterSprite andPC1NumberSprite:(SKSpriteNode *)pc1NumberSprite andPC2NumberSprite:(SKSpriteNode *)pc2NumberSprite;

-(void)selectAndPositionSprites;
-(void)randomiseRackOrientation;

@end
