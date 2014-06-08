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

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    self.uniqueID = [aDecoder decodeObjectForKey:@"uniqueID"];
    self.playerName = [aDecoder decodeObjectForKey:@"playerName"];
    self.playerPicture = [aDecoder decodeObjectForKey:@"playerPicture"];
    self.playerScore = [[aDecoder decodeObjectForKey:@"playerScore"] unsignedIntegerValue];
    self.dataDyadminoesThisTurn = [aDecoder decodeObjectForKey:@"dataDyadsThisTurn"];
    self.resigned = [aDecoder decodeBoolForKey:@"resigned"];
    
//    self.tempBoard = [aDecoder decodeObjectForKey:@"tempBoard"];
//    self.tempRack = [aDecoder decodeObjectForKey:@"tempRack"];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.uniqueID forKey:@"uniqueID"];
  [aCoder encodeObject:self.playerName forKey:@"playerName"];
  [aCoder encodeObject:self.playerPicture forKey:@"playerPicture"];
  [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.playerScore] forKey:@"playerScore"];
  [aCoder encodeObject:self.dataDyadminoesThisTurn forKey:@"dataDyadsThisTurn"];
  [aCoder encodeBool:self.resigned forKey:@"resigned"];
  
//  [aCoder encodeObject:self.tempRack forKey:@"tempRack"];
//  [aCoder encodeObject:self.tempBoard forKey:@"tempBoard"];
}

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