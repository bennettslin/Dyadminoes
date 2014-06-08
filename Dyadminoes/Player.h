//
//  Player.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerDelegate;

@interface Player : NSObject <NSCoding>

  // permanent properties
@property (strong, nonatomic) NSString *uniqueID;
@property (strong, nonatomic) NSString *playerName;
@property (strong, nonatomic) UIImage *playerPicture;

  // player data dyadmino arrays to note orientation and order changes
  // that needn't be known by Game Center until turn has been completed
//@property (strong, nonatomic) NSMutableArray *tempRack;
//@property (strong, nonatomic) NSMutableSet *tempBoard;

  // game state properties
@property (nonatomic) NSUInteger playerScore;
@property (strong, nonatomic) NSMutableArray *dataDyadminoesThisTurn;
@property (nonatomic) BOOL resigned;

@property (weak, nonatomic) id <PlayerDelegate> delegate;

-(id)initWithUniqueID:(NSString *)uniqueID
        andPlayerName:(NSString *)playerName
     andPlayerPicture:(UIImage *)playerPicture;

@end

@protocol PlayerDelegate <NSObject>

//-(void)savePlayerTempStateData;

@end