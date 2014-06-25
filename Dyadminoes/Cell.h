//
//  Cell.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/16/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
@class Board;
@class Dyadmino;

@interface Cell : NSObject

@property (nonatomic) CGPoint cellNodePosition;
@property (nonatomic) CGSize cellNodeSize;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) SKSpriteNode *cellNode;
@property (strong, nonatomic) Board *board;
@property (nonatomic) HexCoord hexCoord;
@property (strong, nonatomic) Dyadmino *myDyadmino;
@property (nonatomic) NSInteger myPC; // signed integer because myPC is -1 if no PC

@property (strong, nonatomic) SKLabelNode *hexCoordLabel;
@property (strong, nonatomic) SKLabelNode *pcLabel;

-(id)initWithBoard:(Board *)board
        andTexture:(SKTexture *)texture
       andHexCoord:(HexCoord)hexCoord
      andVectorOrigin:(CGVector)vectorOrigin;

-(void)addSnapPointsToBoard;
-(void)removeSnapPointsFromBoard;

#pragma mark - testing methods

-(void)updatePCLabel;

@end
