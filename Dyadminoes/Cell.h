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

@interface Cell : SKSpriteNode

@property (strong, nonatomic) SKTexture *cellNodeTexture;
@property (strong, nonatomic) NSString *name;

//@property (strong, nonatomic) SKSpriteNode *cellNode;
@property (strong, nonatomic) Dyadmino *myDyadmino;
@property (assign, nonatomic) HexCoord hexCoord;
@property (assign, nonatomic) NSInteger myPC; // signed integer because myPC is -1 if no PC

@property (strong, nonatomic) SKLabelNode *hexCoordLabel;
@property (strong, nonatomic) SKLabelNode *pcLabel;

@property (assign, nonatomic) CGFloat myRed;
@property (assign, nonatomic) CGFloat myGreen;
@property (assign, nonatomic) CGFloat myBlue;
@property (assign, nonatomic) CGFloat myAlpha;

@property (readonly, nonatomic) NSUInteger minDistance;

  // called to instantiate new cell
-(id)initWithTexture:(SKTexture *)texture
         andHexCoord:(HexCoord)hexCoord
        andHexOrigin:(CGVector)hexOrigin
           andResize:(BOOL)resize;

-(void)reuseCellWithHexCoord:(HexCoord)hexCoord andHexOrigin:(CGVector)hexOrigin forResize:(BOOL)resize;
-(void)resetForReuse;
-(void)addColourValueForPC:(NSUInteger)pc atDistance:(NSUInteger)distance;
-(void)resetColour;
-(void)renderColour;

#pragma mark - cell view helper methods

+(CGSize)cellSizeForResize:(BOOL)resize;
+(CGPoint)snapPositionForHexCoord:(HexCoord)hexCoord
                      orientation:(DyadminoOrientation)orientation
                        andResize:(BOOL)resize
                   givenHexOrigin:(CGVector)hexOrigin;

-(void)animateResizeAndRepositionOfCell:(BOOL)resize withHexOrigin:(CGVector)hexOrigin andSize:(CGSize)cellSize;

#pragma mark - testing methods

-(void)updatePCLabel;

@end
