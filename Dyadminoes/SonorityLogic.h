//
//  SonorityLogic.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Helper.h"

@interface SonorityLogic : NSObject

#pragma mark - chord logic methods

-(Chord)chordFromSonorityPlusCheckIncompleteSeventh:(NSArray *)sonority;
-(BOOL)sonorityIsIncompleteSeventh:(NSArray *)sonority;

#pragma mark - chord label methods

-(NSString *)stringForChord:(Chord)chord;
-(NSAttributedString *)stringWithAccidentals:(NSString *)myString fontSize:(CGFloat)size;

#pragma mark - singleton method

+(id)sharedLogic;

@end