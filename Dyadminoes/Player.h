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

@end