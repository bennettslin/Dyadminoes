//
//  Player.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

  // permanent properties
@property (nonatomic) NSUInteger uniqueID;
//@property (nonatomic) NSUInteger playerNumber;
@property (strong, nonatomic) NSString *playerName;
@property (strong, nonatomic) UIImage *playerPicture;

  // game state properties
@property (nonatomic) NSUInteger playerScore;
@property (strong, nonatomic) NSMutableArray *dyadminoesInRack;
@property (nonatomic) BOOL resigned;

-(id)initWithUniqueID:(NSUInteger)uniqueID
        andPlayerName:(NSString *)playerName
     andPlayerPicture:(UIImage *)playerPicture;

@end
