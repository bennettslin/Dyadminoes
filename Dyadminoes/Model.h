//
//  Model.h
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableArray *myMatches;

+(void)saveMyModel:(Model *)myModel;
+(Model *)getMyModel;
-(void)instantiateHardCodedMatchesForDebugPurposes;
-(void)sortMyMatches;

@end
