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
-(IllegalPlacementResult)checkIllegalPlacementFromFormationOfSonorities:(NSSet *)sonorities;

-(BOOL)sonority:(NSSet *)set containsNote:(NSDictionary *)dictionary;
-(BOOL)sonority:(NSSet *)sonority1 is:(Condition)condition ofSonority:(NSSet *)sonority2;
-(BOOL)sonorities:(NSSet *)sonorities1 is:(Condition)condition ofSonorities:(NSSet *)sonorities2;

-(NSSet *)legalChords:(NSSet *)legalChords1 thatExtendALegalChordInLegalChords:(NSSet *)legalChords2;
-(NSSet *)legalChords:(NSSet *)legalChords1 thatAreCompletelyNotFoundInLegalChords:(NSSet *)legalChords2;
-(NSSet *)legalChords:(NSSet *)legalChords1 thatAreEitherNewOrExtendingRelativeToLegalChords:(NSSet *)legalChords2;

#pragma mark - chord label methods

-(NSString *)stringForSonorities:(NSSet *)sonorities
               withInitialString:(NSString *)initialString
                 andEndingString:(NSString *)endingString;

  // only used for logging and testing purposes
-(Chord)testChordFromSonorityPlusCheckIncompleteSeventh:(NSSet *)sonority;
-(NSString *)testStringForLegalChordSonoritiesWithSonorities:(NSSet *)sonorities;

#pragma mark - singleton method

+(id)sharedLogic;

@end