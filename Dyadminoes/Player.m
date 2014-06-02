//
//  Player.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Player.h"
#import "NSObject+Helper.h"

@interface Player ()

@end

@implementation Player

-(id)initWithUniqueID:(NSString *)uniqueID
        andPlayerName:(NSString *)playerName
     andPlayerPicture:(UIImage *)playerPicture  {
  
  self = [super init];
  
  if (self) {
    self.uniqueID = uniqueID;
    self.playerName = playerName;
    self.playerPicture = playerPicture;
    
      // game state
    self.dataDyadminoesThisTurn = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
    self.resigned = NO;
  }
  
  return self;
}

@end