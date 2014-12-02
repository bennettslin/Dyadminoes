//
//  SonorityLogicTests.m
//  Dyadminoes
//
//  Created by Bennett Lin on 8/12/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SonorityLogic.h"

@interface SonorityLogicTests : XCTestCase

@property (strong, nonatomic) SonorityLogic *sonorityLogic;

@end

@implementation SonorityLogicTests

-(void)setUp {
  [super setUp];
  self.sonorityLogic = [SonorityLogic sharedLogic];
}

-(void)tearDown {
  self.sonorityLogic = nil;
  [super tearDown];
}

#pragma mark - chord label tests

-(void)testRootInStringForAsymmetricChord {
  
  NSArray *rootsArray = @[@"C", @"C(#)/D(b)", @"D", @"D(#)/E(b)",
                          @"E", @"F", @"F(#)/G(b)", @"G",
                          @"G(#)/A(b)", @"A", @"A(#)/B(b)", @"B"];
  
  BOOL allAsymmetricRootsMatch = YES;
  
  for (int i = 0; i < 12; i++) {
    Chord myChord = [self chordFromRoot:i andChordType:kChordMajorTriad];
    NSString *myString = [self.sonorityLogic stringForChord:myChord];
    NSArray *myStringComponents = [myString componentsSeparatedByString:@" "];
    if (![myStringComponents[0] isEqualToString:rootsArray[i]]) {
      allAsymmetricRootsMatch = NO;
    }
  }
        
  XCTAssert(allAsymmetricRootsMatch, @"Not all asymmetric roots match.");
}

-(void)testRootInStringForSymmetricChords {
  
  NSArray *dimRootsArray = @[@"C$D(#)/E(b)$F(#)/G(b)$A", @"C(#)/D(b)$E$G$A(#)/B(b)", @"D$F$G(#)/A(b)$B"];
  NSArray *augRootsArray = @[@"C$E$G(#)/A(b)", @"C(#)/D(b)$F$A", @"D$F(#)/G(b)$A(#)/B(b)", @"D(#)/E(b)$G$B"];
  NSArray *frenchRootsArray = @[@"C$F(#)/G(b)", @"C(#)/D(b)$G", @"D$G(#)/A(b)",
                                @"D(#)/E(b)$A", @"E$A(#)/B(b)", @"F$B"];
  
  BOOL allSymmetricRootsMatch = YES;
  
    // diminished roots
  for (int i = 0; i < 12; i++) {
    Chord myChord = [self chordFromRoot:i andChordType:kChordFullyDiminishedSeventh];
    NSString *myString = [self.sonorityLogic stringForChord:myChord];
    NSArray *myStringComponents = [myString componentsSeparatedByString:@" "];
    if (![myStringComponents[0] isEqualToString:dimRootsArray[i % 3]]) {
      allSymmetricRootsMatch = NO;
    }
  }
  
    // augmented roots
  for (int i = 0; i < 12; i++) {
    Chord myChord = [self chordFromRoot:i andChordType:kChordAugmentedTriad];
    NSString *myString = [self.sonorityLogic stringForChord:myChord];
    NSArray *myStringComponents = [myString componentsSeparatedByString:@" "];
    if (![myStringComponents[0] isEqualToString:augRootsArray[i % 4]]) {
      allSymmetricRootsMatch = NO;
    }
  }

    // French roots
  for (int i = 0; i < 12; i++) {
    Chord myChord = [self chordFromRoot:i andChordType:kChordFrenchSixth];
    NSString *myString = [self.sonorityLogic stringForChord:myChord];
    NSArray *myStringComponents = [myString componentsSeparatedByString:@" "];
    if (![myStringComponents[0] isEqualToString:frenchRootsArray[i % 6]]) {
      allSymmetricRootsMatch = NO;
    }
  }
  
  XCTAssert(allSymmetricRootsMatch, @"Not all symmetric roots match.");
}

-(void)testChordTypeInStringForChord {
  
  NSArray *chordTypesArray = @[@"minor triad", @"major triad", @"half-diminished seventh", @"minor seventh", @"dominant seventh", @"diminished triad", @"augmented triad", @"fully diminished seventh", @"minor-major seventh", @"major seventh", @"augmented major seventh", @"Italian sixth", @"French sixth"];
  
  BOOL allChordTypesMatch = YES;
  
  for (ChordType i = 0; i < kChordNoChord; i++) {
    Chord myChord = [self chordFromRoot:0 andChordType:i];
    NSString *myString = [self.sonorityLogic stringForChord:myChord];
    NSArray *myStringComponents = [myString componentsSeparatedByString:@" "];
    NSMutableArray *mutableComponents = [NSMutableArray arrayWithArray:myStringComponents];
    [mutableComponents removeObjectAtIndex:0];
    NSString *chordTypeString = [mutableComponents componentsJoinedByString:@" "];
    
    if (![chordTypeString isEqualToString:chordTypesArray[i]]) {
      allChordTypesMatch = NO;
    }
  }
  
  XCTAssert(allChordTypesMatch, @"Not all chord types match.");
}

#pragma mark - chord logic tests

-(void)testRecognitionOfNonChords {
  
  Chord noChord = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:@[]];
  Chord monad = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:@[@0]];
  Chord dyad = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:@[@0, @1]];
  Chord illegal = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:@[@0, @1, @2, @3]];
  
  XCTAssert(noChord.chordType == kChordNoChord);
  XCTAssert(monad.chordType == kChordLegalMonad);
  XCTAssert(dyad.chordType == kChordLegalDyad);
  XCTAssert(illegal.chordType == kChordIllegalChord);
}

-(void)testCorrectChordTypesForAllTranspositionsOfAllLegalChords {
  
  NSArray *rootCChords = @[@[@0, @3, @7], @[@0, @4, @7], @[@0, @3, @6, @10],
  @[@0, @3, @7, @10], @[@0, @4, @7, @10], @[@0, @3, @6], @[@0, @4, @8], @[@0, @3, @6, @9],
  @[@0, @3, @7, @11], @[@0, @4, @7, @11], @[@0, @4, @8, @11], @[@0, @6, @8], @[@0, @2, @6, @8]];
  
  BOOL chordTypesAllCorrect = YES;
  
    // iterate through all chord types
  for (int i = 0; i < rootCChords.count; i++) {
    NSArray *rootCChord = rootCChords[i];
    
      // transpose up semitone from C to B
    for (int j = 0; j < 12; j++) {
      NSMutableArray *mutableTransposedChord = [NSMutableArray new];
      
        // transpose each note in chord
      for (NSNumber *pcObject in rootCChord) {
        NSUInteger pc = [pcObject unsignedIntegerValue];
        pc = (pc + j) % 12;
        [mutableTransposedChord addObject:[NSNumber numberWithUnsignedInteger:pc]];
      }
      NSArray *transposedChord = [NSArray arrayWithArray:mutableTransposedChord];
      
      Chord chordForTransposedChord = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:transposedChord];
      if (chordForTransposedChord.chordType != (ChordType)i) {
        chordTypesAllCorrect = NO;
      }
    }
  }
  
  XCTAssert(chordTypesAllCorrect, @"Not all chord types are recognised correctly.");
}

-(void)testFailureCasesOfCheckingIncompleteSeventh {

  NSArray *legalTriad = @[@0, @4, @7];
  XCTAssertFalse([self.sonorityLogic sonorityIsIncompleteSeventh:legalTriad], @"legal triad should not be valid incomplete seventh.");

  NSArray *dyad = @[@0, @4];
  XCTAssertFalse([self.sonorityLogic sonorityIsIncompleteSeventh:dyad], @"dyad should not be valid incomplete seventh.");
  
  NSArray *seventh = @[@0, @1, @2, @3];
  XCTAssertFalse([self.sonorityLogic sonorityIsIncompleteSeventh:seventh], @"dyad should not be valid incomplete seventh.");
  
  NSArray *manualIncompleteSeventh = @[@0, @7, @10];
  XCTAssertTrue([self.sonorityLogic sonorityIsIncompleteSeventh:manualIncompleteSeventh], @"this *should* be a valid incomplete seventh.");
}

-(void)testCorrectChordTypesForAllTranspositionsOfIncompleteSevenths {
  
  NSArray *rootCSevenths = @[@[@0, @3, @6, @10], @[@0, @3, @7, @10], @[@0, @4, @7, @10], @[@0, @3, @6, @9],
                           @[@0, @3, @7, @11], @[@0, @4, @7, @11], @[@0, @4, @8, @11], @[@0, @2, @6, @8]];
  
  BOOL incompleteSeventhTypesAllCorrect = YES;
  
    // iterate through all chord types
  for (int i = 0; i < rootCSevenths.count; i++) {
    NSArray *rootCSeventh = rootCSevenths[i];
    
      // remove each note once
    for (int j = 0; j < rootCSeventh.count; j++) {
    
      NSMutableArray *tempIncompleteRootCSeventh = [NSMutableArray arrayWithArray:rootCSeventh];
      [tempIncompleteRootCSeventh removeObjectAtIndex:j];
      NSArray *incompleteRootCSeventh = [NSArray arrayWithArray:tempIncompleteRootCSeventh];
      Chord chordFromIncompleteRootCSeventh = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:incompleteRootCSeventh];
      
        // only checks triads that are not legal triads
      if (chordFromIncompleteRootCSeventh.chordType == kChordIllegalChord) {
      
          // transpose up semitone from C to B
        for (int k = 0; k < 12; k++) {
          NSMutableArray *mutableTransposedChord = [NSMutableArray new];
          
            // transpose each note in chord
          for (NSNumber *pcObject in incompleteRootCSeventh) {
            NSUInteger pc = [pcObject unsignedIntegerValue];
            pc = (pc + k) % 12;
            [mutableTransposedChord addObject:[NSNumber numberWithUnsignedInteger:pc]];
          }
          NSArray *transposedChord = [NSArray arrayWithArray:mutableTransposedChord];
          
          Chord chordForTransposedChord = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:transposedChord];
          if (chordForTransposedChord.chordType != kChordLegaIncompleteSeventh) {
            
            incompleteSeventhTypesAllCorrect = NO;
          }
        }
      }
    }
  }
  
  XCTAssert(incompleteSeventhTypesAllCorrect, @"Not all illegal sevenths are recognised correctly.");
}

@end
