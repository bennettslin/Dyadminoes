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

  // sonority stuff
-(BOOL)sonority:(NSSet *)set containsNote:(NSDictionary *)dictionary;
-(BOOL)sonority:(NSSet *)smaller IsSubsetOfSonority:(NSSet *)larger;
-(NSSet *)chordSonorityForSonority:(NSSet *)sonority;
-(NSSet *)chordSonoritiesForSonorities:(NSSet *)sonorities;

#pragma mark - chord logic methods

-(Chord)chordFromSonorityPlusCheckIncompleteSeventh:(NSSet *)sonority;
-(BOOL)sonorityIsIncompleteSeventh:(NSSet *)sonority;

#pragma mark - chord label methods

//-(NSAttributedString *)stringWithAccidentals:(NSString *)myString fontSize:(CGFloat)size;
-(NSAttributedString *)stringForLegalChords:(NSSet *)chords;

#pragma mark - singleton method

+(id)sharedLogic;

@end