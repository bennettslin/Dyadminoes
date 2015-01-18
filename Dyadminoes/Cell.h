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
@class SnapPoint;

@protocol BoardCellDelegate <NSObject>

@property (strong, nonatomic) NSMutableSet *snapPointsTwelveOClock;
@property (strong, nonatomic) NSMutableSet *snapPointsTwoOClock;
@property (strong, nonatomic) NSMutableSet *snapPointsTenOClock;

@end

@interface Cell : SKSpriteNode

@property (weak, nonatomic) id<BoardCellDelegate> delegate;

@property (nonatomic) SKTexture *cellNodeTexture;
@property (nonatomic) CGPoint cellNodePosition;

@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) SnapPoint *boardSnapPointTwelveOClock;
@property (strong, nonatomic) SnapPoint *boardSnapPointTwoOClock;
@property (strong, nonatomic) SnapPoint *boardSnapPointTenOClock;

@property (strong, nonatomic) SKSpriteNode *cellNode;
@property (nonatomic) HexCoord hexCoord;
@property (strong, nonatomic) Dyadmino *myDyadmino;
@property (nonatomic) NSInteger myPC; // signed integer because myPC is -1 if no PC

@property (strong, nonatomic) SKLabelNode *hexCoordLabel;
@property (strong, nonatomic) SKLabelNode *pcLabel;

@property (assign, nonatomic) CGFloat myRed;
@property (assign, nonatomic) CGFloat myGreen;
@property (assign, nonatomic) CGFloat myBlue;
@property (assign, nonatomic) CGFloat myAlpha;

//@property (nonatomic) BOOL currentlyColouringNeighbouringCells;
//@property (nonatomic) NSInteger colouredByNeighbouringCells; // this is only used for fading cells during pinch zoom back in

  // called to instantiate new cell
-(id)initWithTexture:(SKTexture *)texture
         andHexCoord:(HexCoord)hexCoord
        andHexOrigin:(CGVector)hexOrigin
           andResize:(BOOL)resize
         andDelegate:(id)delegate;

-(void)reuseCellWithHexCoord:(HexCoord)hexCoord andHexOrigin:(CGVector)hexOrigin forResize:(BOOL)resize;
-(void)resetForReuse;
-(void)addColourValueForPC:(NSUInteger)pc atDistance:(NSUInteger)distance;
-(void)renderColour;

#pragma mark - snap point methods

-(void)addSnapPointsToBoardAndResize:(BOOL)resize;
-(void)removeSnapPointsFromBoard;

#pragma mark - cell view helper methods

+(CGSize)establishCellSizeForResize:(BOOL)resize;
+(CGPoint)positionCellAgnosticDyadminoGivenHexOrigin:(CGVector)hexOrigin andHexCoord:(HexCoord)hexCoord andOrientation:(DyadminoOrientation)orientation andResize:(BOOL)resize;

-(void)resizeAndRepositionCell:(BOOL)resize withHexOrigin:(CGVector)hexOrigin andSize:(CGSize)cellSize;
-(void)addColourWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

#pragma mark - testing methods

-(void)updatePCLabel;

@end
