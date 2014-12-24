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

#pragma mark - validation methods

-(NSSet *)legalChordSonoritiesFromFormationOfSonorities:(NSSet *)sonorities;

-(BOOL)setOfLegalChords:(NSSet *)setofLegalChords1 isSubsetOfSetOfLegalChords:(NSSet *)setOfLegalChords2;

-(BOOL)sonority:(NSSet *)set containsNote:(NSDictionary *)dictionary;

-(NSSet *)sonoritiesInSonorities:(NSSet *)larger thatAreSupersetsOfSonoritiesInSonorities:(NSSet *)smaller;

#pragma mark - point methods

-(NSUInteger)pointsForSonority:(NSSet *)sonority fromExtension:(BOOL)fromExtension;

#pragma mark - chord logic methods

-(Chord)chordFromSonorityPlusCheckIncompleteSeventh:(NSSet *)sonority;

#pragma mark - chord label methods

-(NSAttributedString *)stringForSonorities:(NSSet *)sonorities
                         withInitialString:(NSString *)initialString
                           andEndingString:(NSString *)endingString;

#pragma mark - singleton method

+(id)sharedLogic;

@end