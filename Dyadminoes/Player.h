//
//  Player.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject <NSCoding>

  // permanent properties
@property (strong, nonatomic) NSString *uniqueID;
@property (strong, nonatomic) NSString *playerName;
@property (strong, nonatomic) UIImage *playerPicture;

  // game state properties
@property (nonatomic) NSUInteger playerScore;
@property (strong, nonatomic) NSMutableArray *dataDyadminoesThisTurn;
@property (nonatomic) BOOL resigned;

-(id)initWithUniqueID:(NSString *)uniqueID
        andPlayerName:(NSString *)playerName
     andPlayerPicture:(UIImage *)playerPicture;

@end
