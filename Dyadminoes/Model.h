//
//  Model.h
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Helper.h"
@class Match;

@interface Model : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableArray *myMatches;

+(void)saveMyModel:(Model *)myModel;
+(Model *)getMyModel;

-(Match *)instantiateNewLocalMatchWithNames:(NSMutableArray *)playerNames andRules:(GameRules)rules andSkill:(GameSkill)skill;
-(void)sortMyMatches;

@end