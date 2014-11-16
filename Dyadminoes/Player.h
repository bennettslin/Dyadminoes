//
//  Player.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol PlayerDelegate;

@interface Player : NSManagedObject

  // permanent properties
@property (strong, nonatomic) NSString *uniqueID;
@property (strong, nonatomic) NSString *playerName;
@property (assign, nonatomic) NSUInteger playerOrder;

  // game state properties
@property (nonatomic) NSUInteger playerScore;
@property (strong, nonatomic) NSMutableArray *dataDyadminoesThisTurn;
@property (nonatomic) BOOL resigned;
@property (assign, nonatomic) BOOL won;

@property (weak, nonatomic) id <PlayerDelegate> delegate;

-(id)initWithUniqueID:(NSString *)uniqueID
        andPlayerName:(NSString *)playerName
     andPlayerPicture:(UIImage *)playerPicture;

@end

@protocol PlayerDelegate <NSObject>

@end