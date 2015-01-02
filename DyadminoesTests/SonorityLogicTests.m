//
//  SonorityLogicTests.m
//  Dyadminoes
//
//  Created by Bennett Lin on 8/12/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SonorityLogic+Helper.h"

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

-(void)testIsSingleton {
  SonorityLogic *logic1 = [SonorityLogic sharedLogic];
  SonorityLogic *logic2 = [SonorityLogic sharedLogic];
  XCTAssertEqualObjects(logic1, logic2, @"Sonority logic is not a singleton.");
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

-(void)testAttributedStringMethod {
  NSSet *sonority1 = [NSSet setWithArray:@[@0, @2, @6, @8]];
  NSSet *sonority2 = [NSSet setWithArray:@[@0, @4, @7, @11]];
  NSSet *sonority3 = [NSSet setWithArray:@[@0, @3, @6]];
  NSSet *sonority4 = [NSSet setWithArray:@[@0, @4, @7]];
  NSSet *sonorities = [NSSet setWithObjects:sonority1, sonority2, sonority3, sonority4, nil];
  
  NSAttributedString *attributedString = [self.sonorityLogic stringForLegalChords:sonorities];
  NSLog(@"attributed string is: %@", attributedString);
}

#pragma mark - chord logic tests

-(void)testRecognitionOfSpecificNonChords {
  
  Chord noChord = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:@[]]];
  Chord monad = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:@[@0]]];
  Chord dyad = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:@[@0, @1]]];
  Chord illegal = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:@[@0, @1, @2, @3]]];
  
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

      NSSet *transposedChord = [self transposeChord:rootCChord by:j];
      
      Chord chordForTransposedChord = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithSet:transposedChord]];
      if (chordForTransposedChord.chordType != (ChordType)i) {
        chordTypesAllCorrect = NO;
      }
    }
  }
  
  XCTAssert(chordTypesAllCorrect, @"Not all chord types are recognised correctly.");
}

-(void)testFailureCasesOfCheckingIncompleteSeventh {

  NSArray *legalTriad = @[@0, @4, @7];
  XCTAssertFalse([self.sonorityLogic sonorityIsIncompleteSeventh:[NSSet setWithArray:legalTriad]], @"legal triad should not be valid incomplete seventh.");

  NSArray *dyad = @[@0, @4];
  XCTAssertFalse([self.sonorityLogic sonorityIsIncompleteSeventh:[NSSet setWithArray:dyad]], @"dyad should not be valid incomplete seventh.");
  
  NSArray *seventh = @[@0, @1, @2, @3];
  XCTAssertFalse([self.sonorityLogic sonorityIsIncompleteSeventh:[NSSet setWithArray:seventh]], @"dyad should not be valid incomplete seventh.");
  
  NSArray *manualIncompleteSeventh = @[@0, @7, @10];
  XCTAssertTrue([self.sonorityLogic sonorityIsIncompleteSeventh:[NSSet setWithArray:manualIncompleteSeventh]], @"this *should* be a valid incomplete seventh.");
}

-(void)testCorrectChordTypesForAllTranspositionsOfAllIncompleteSevenths {
  
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
      Chord chordFromIncompleteRootCSeventh = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:incompleteRootCSeventh]];
      
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
          
          Chord chordForTransposedChord = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:transposedChord]];
          if (chordForTransposedChord.chordType != kChordLegalIncompleteSeventh) {
            
            incompleteSeventhTypesAllCorrect = NO;
          }
        }
      }
    }
  }
  
  XCTAssert(incompleteSeventhTypesAllCorrect, @"Not all illegal sevenths are recognised correctly.");
}

-(void)testDetectionOfExcessPCs {
  
    // test random sonority 100 times
  for (int i = 0; i < 100; i++) {
    NSSet *sonority = [self randomSonority];
    
    BOOL expectedSonorityToNotExceedMaximum = (sonority.count <= 4);
    BOOL returnedSonorityDoesNotExceedMaximum = [self.sonorityLogic validateSonorityDoesNotExceedMaximum:sonority];
    
    XCTAssertEqual(expectedSonorityToNotExceedMaximum, returnedSonorityDoesNotExceedMaximum, @"Logic failed at detecting whether sonority exceeds maximum.");
  }
  
    // test known excess sonority 50 times
  for (int i = 0; i < 50; i++) {
    NSSet *excessSonority = [self randomExcessSonority];
    XCTAssertFalse([self.sonorityLogic validateSonorityDoesNotExceedMaximum:excessSonority], @"Logic failed at detecting sonority with known excess.");
  }
}

-(void)testDetectionOfDoublePCs {
  
    // test random sonority 100 times
  for (int i = 0; i < 100; i++) {
    
    BOOL expectedNoDoublePCs = YES;
    
    NSSet *sonority = [self randomSonority];
    NSMutableSet *pcs = [NSMutableSet new];

    for (NSDictionary *note in sonority) {
      NSNumber *pc = note[@"pc"];
      if ([pcs containsObject:pc]) {
        expectedNoDoublePCs = NO;
      } else {
        [pcs addObject:pc];
      }
    }
    
    BOOL returnedNoDoublePCs = [self.sonorityLogic validateSonorityHasNoDoublePCs:sonority];
    XCTAssertEqual(expectedNoDoublePCs, returnedNoDoublePCs, @"Logic failed at detecting whether sonority has double pcs.");
  }
  
    // test known sonority with doubles 50 times
  for (int i = 0; i < 50; i++) {
    
    NSSet *doublePCSonority = [self randomSonorityWithDoublePCs];

    XCTAssertFalse([self.sonorityLogic validateSonorityHasNoDoublePCs:doublePCSonority], @"Logic failed at detecting sonority with known double pcs.");
  }
}

-(void)testDetectionOfIllegalChords {
  
    // test known legal chords 100 times
  for (int i = 0; i < 100; i++) {
    
    NSSet *illegalSonority = [self randomIllegalChord];
  
    NSMutableSet *tempIllegalChord = [NSMutableSet new];
    for (NSDictionary *note in illegalSonority) {
      
      [tempIllegalChord addObject:note[@"pc"]];
    }
    
    NSSet *illegalChord = [NSSet setWithSet:tempIllegalChord];
    ChordType returnedChordType = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:illegalChord].chordType;
    
    XCTAssertTrue(returnedChordType == kChordIllegalChord, @"Logic failed to detect that sonority is illegal chord.");
  }
  
}

-(void)testDetectionOfLegalChords {
  
    // test known legal chords 100 times
  for (int i = 0; i < 100; i++) {
    
    NSSet *legalSonority = [self randomLegalChord];
    
    NSMutableSet *tempLegalChord = [NSMutableSet new];
    for (NSDictionary *note in legalSonority) {
      
      [tempLegalChord addObject:note[@"pc"]];
    }
    
    NSSet *legalChord = [NSSet setWithSet:tempLegalChord];
    ChordType returnedChordType = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:legalChord].chordType;
    
    BOOL chordIsLegal = YES;
    
    if (returnedChordType == kChordIllegalChord || returnedChordType == kChordLegalMonad || returnedChordType == kChordLegalDyad || returnedChordType == kChordLegalIncompleteSeventh) {
      
      chordIsLegal = NO;
    }
    
    XCTAssertTrue(chordIsLegal, @"Logic failed to detect that sonority is legal chord.");
  }
}

-(void)testDetectionOfLegalIncompleteSevenths {
  
    // test known legal incomplete sevenths 100 times
  for (int i = 0; i < 100; i++) {
    
    NSSet *legalIncompleteSeventhSonority = [self randomLegalIncompleteSeventh];
    
    NSMutableSet *tempLegalIncompleteSeventhChord = [NSMutableSet new];
    for (NSDictionary *note in legalIncompleteSeventhSonority) {
      
      [tempLegalIncompleteSeventhChord addObject:note[@"pc"]];
    }
    
    NSSet *legalIncompleteSeventhChord = [NSSet setWithSet:tempLegalIncompleteSeventhChord];
    ChordType returnedChordType = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:legalIncompleteSeventhChord].chordType;
    
    XCTAssertTrue(returnedChordType == kChordLegalIncompleteSeventh, @"Logic failed to detect that sonority is legal incomplete seventh for %@, saw it as %i instead.", legalIncompleteSeventhChord, returnedChordType);
  }
}

-(void)testSonorityIsSubsetOfSonorityMethod {
    // see if method can be simplified with isEqual
  
    // test 50 times
    // test when sonorities have no notes in common
  for (int i = 0; i < 50; i++){
  
    NSSet *set1 = [self randomSonority];
    NSSet *set2;

    while (!set2) {
      NSSet *trialSet2 = [self randomSonority];
      
      BOOL noCommonNote = YES;
      for (NSDictionary *note in trialSet2) {
        if ([set1 containsObject:note]) {
          noCommonNote = NO;
        }
      }
      
      set2 = noCommonNote ? trialSet2 : nil;
    }
  
    XCTAssertFalse([self.sonorityLogic sonority:set1 isSubsetOfSonority:set2], @"Failed to see that sonorities have no notes in common.");
  }
  
    // test 50 times
  for (int i = 0; i < 50; i++) {
    
    NSSet *set1 = [self randomLegalChord];
    NSSet *set2;
    
      // set1 is triad, add note
    if (set1.count == 3) {
      NSMutableSet *tempSet = [NSMutableSet setWithSet:set1];
      
      while (!set2 || set2.count < 4) {
        NSUInteger pc = arc4random() % 12;
        NSUInteger dyadmino = arc4random() % 10; // ten dyadminoes, to make it easier
        NSDictionary *note = @{@"pc":@(pc), @"dyadmino": @(dyadmino)};
        [tempSet addObject:note];
        set2 = [NSSet setWithSet:tempSet];
      }
      
        // set1 is seventh, subtract note
    } else {
      NSMutableSet *tempSet = [NSMutableSet setWithSet:set1];
      [tempSet removeObject:[tempSet anyObject]];
      set2 = [NSSet setWithSet:tempSet];
    }
    
      // make set1 the smaller one no matter what
    if (set1.count > set2.count) {
      NSSet *tempSet = set2;
      set2 = set1;
      set1 = tempSet;
    }

    XCTAssertTrue([self.sonorityLogic sonority:set1 isSubsetOfSonority:set2], @"Smaller sonority not recognised as subset of larger one.");

    NSMutableSet *tempSet1 = [NSMutableSet setWithSet:set1];
    while (set1.count < set2.count) {
    
      NSUInteger pc = arc4random() % 12;
      NSUInteger dyadmino = arc4random() % 10; // ten dyadminoes, to make it easier
      NSDictionary *note = @{@"pc":@(pc), @"dyadmino": @(dyadmino)};
      if (![self.sonorityLogic sonority:set2 containsNote:note]) {
        
        [tempSet1 addObject:note];
        set1 = [NSSet setWithSet:tempSet1];
      }
    }
    
//    NSLog(@"set1 is %@, set2 is %@", set1, set2);
    XCTAssertFalse([self.sonorityLogic sonority:set1 isSubsetOfSonority:set2], @"Failed to see that sonority is not subset despite some notes in common, because it also has extra notes not found in other sonority.");
  }
}

-(void)testEqualSonoritiesAreSubsetsOfEachOther {
  
    // test 50 times
  
  for (int i = 0; i < 50; i++) {
    NSSet *sonority1 = [self randomSonority];
    NSSet *sonority2 = [NSSet setWithSet:sonority1];
    
    XCTAssertTrue([self.sonorityLogic sonority:sonority1 isSubsetOfSonority:sonority2], @"Sonority1 should be subset of sonority2.");
    XCTAssertTrue([self.sonorityLogic sonority:sonority2 isSubsetOfSonority:sonority1], @"Sonority1 should be subset of sonority2.");
  }
}

-(void)testChordForPersonalPurposes {
  NSSet *chordSonority = [NSSet setWithArray:@[@1, @4, @7]];
  Chord chord = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:chordSonority];
  NSLog(@"chord type is %i", chord.chordType);
  XCTAssertTrue(chord.chordType == kChordDiminishedTriad, @"This chord should be diminished triad!");
}

  // FIXME: test supersets method
  // FIXME: test legal chord sonorities from sonorities method

#pragma mark - test helper methods

-(NSSet *)randomFormationOfSonorities {
  
  NSMutableSet *tempSonorities = [NSMutableSet new];
  NSUInteger numberOfSonorities = arc4random() % 5 + 1;
  for (int i = 0; i < numberOfSonorities; i++) {
    [tempSonorities addObject:[self randomSonority]];
  }
  
  return [NSSet setWithSet:tempSonorities];
}

-(NSSet *)randomSonority {
  NSMutableSet *tempSonority = [NSMutableSet new];
  NSUInteger numberOfNotesInSonority = arc4random() % 5 + 1;
  for (int j = 0; j < numberOfNotesInSonority; j++) {
    
    NSUInteger pc = arc4random() % 12;
    NSUInteger dyadmino = arc4random() % 10; // ten dyadminoes, to make it easier
    
    NSNumber *pcNumber = [NSNumber numberWithUnsignedInteger:pc];
    NSNumber *dyadminoNumber = [NSNumber numberWithUnsignedInteger:dyadmino];
    
    NSDictionary *note = @{@"pc":pcNumber, @"dyadmino": dyadminoNumber};
    [tempSonority addObject:note];
  }
  return [NSSet setWithSet:tempSonority];
}

-(NSSet *)randomExcessSonority {
  NSMutableSet *tempSonority = [NSMutableSet new];
  NSUInteger numberOfNotesInSonority = 5 + arc4random() % 5 + 1;
  while (tempSonority.count < numberOfNotesInSonority) {
    
    NSUInteger pc = arc4random() % 12;
    NSUInteger dyadmino = arc4random() % 10; // ten dyadminoes, to make it easier
    
    NSNumber *pcNumber = [NSNumber numberWithUnsignedInteger:pc];
    NSNumber *dyadminoNumber = [NSNumber numberWithUnsignedInteger:dyadmino];
    
    NSDictionary *note = @{@"pc":pcNumber, @"dyadmino": dyadminoNumber};
    [tempSonority addObject:note];
  }
  return [NSSet setWithSet:tempSonority];
}

-(NSSet *)randomSonorityWithDoublePCs {
  NSMutableSet *tempSonority = [NSMutableSet new];
  NSUInteger numberOfNotesInSonority = arc4random() % 4 + 1;
  while (tempSonority.count < numberOfNotesInSonority) {
    
    NSUInteger pc = arc4random() % 12;
    NSUInteger dyadmino = arc4random() % 10; // ten dyadminoes, to make it easier
    
    NSNumber *pcNumber = [NSNumber numberWithUnsignedInteger:pc];
    NSNumber *dyadminoNumber = [NSNumber numberWithUnsignedInteger:dyadmino];
    
    NSDictionary *note = @{@"pc":pcNumber, @"dyadmino": dyadminoNumber};
    [tempSonority addObject:note];
    
      // double of existing pc
    if (tempSonority.count == 1) {
      dyadminoNumber = [NSNumber numberWithUnsignedInteger:dyadmino + 1];
      
      NSDictionary *doubleNote = @{@"pc":pcNumber, @"dyadmino": dyadminoNumber};
      [tempSonority addObject:doubleNote];
    }
  }
  return [NSSet setWithSet:tempSonority];
}

-(NSSet *)randomIllegalChord {
    // not ideal, since it uses the same method to find an illegal chord as the one being tested
  
  NSSet *illegalChord;
  while (!illegalChord) {
    
    NSMutableSet *tempSonority = [NSMutableSet new];
    
    NSUInteger cardinality = arc4random() % 2 + 3; // will return 3 or 4
    
      // while loop ensures no double pc
    while (tempSonority.count < cardinality) {
      
      NSUInteger pc = arc4random() % 12;
      [tempSonority addObject:@(pc)];
    }

    Chord trialChord = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:tempSonority];
    if (trialChord.chordType == kChordIllegalChord) {
      illegalChord = [NSSet setWithSet:tempSonority];
    }
  }
  
  NSMutableSet *tempReturnedChord = [NSMutableSet new];
  
  for (NSNumber *pc in illegalChord) {
    NSUInteger dyadmino = arc4random() % 10; // ten dyadminoes, to make it easier
    NSDictionary *illegalChordNote = @{@"pc":pc, @"dyadmino": @(dyadmino)};
    [tempReturnedChord addObject:illegalChordNote];
  }

  return [NSSet setWithSet:tempReturnedChord];
}

-(NSSet *)randomLegalChord {
  
  NSArray *rootCChords = @[@[@0, @3, @7], @[@0, @4, @7], @[@0, @3, @6, @10],
                           @[@0, @3, @7, @10], @[@0, @4, @7, @10], @[@0, @3, @6], @[@0, @4, @8], @[@0, @3, @6, @9],
                           @[@0, @3, @7, @11], @[@0, @4, @7, @11], @[@0, @4, @8, @11], @[@0, @6, @8], @[@0, @2, @6, @8]];
  
  NSUInteger randomIndex = arc4random() % rootCChords.count;
  NSArray *randomChord = rootCChords[randomIndex];
  NSUInteger randomTransposition = arc4random() % 12;
  
  NSSet *randomChordSet = [self transposeChord:randomChord by:randomTransposition];
  
  NSMutableSet *tempReturnedChord = [NSMutableSet new];
  
  for (NSNumber *pc in randomChordSet) {
    NSUInteger dyadmino = arc4random() % 10; // ten dyadminoes, to make it easier
    NSDictionary *legalChordNote = @{@"pc":pc, @"dyadmino": @(dyadmino)};
    [tempReturnedChord addObject:legalChordNote];
  }
  
  return [NSSet setWithSet:tempReturnedChord];
}

-(NSSet *)randomLegalIncompleteSeventh {
  NSArray *rootCSevenths = @[@[@0, @3, @6, @10], @[@0, @3, @7, @10], @[@0, @4, @7, @10], @[@0, @3, @6, @9],
                             @[@0, @3, @7, @11], @[@0, @4, @7, @11], @[@0, @4, @8, @11], @[@0, @2, @6, @8]];
  
  NSSet *incompleteSeventh;
  while (!incompleteSeventh) {
    NSUInteger randomIndex = arc4random() % rootCSevenths.count;
    NSArray *randomSeventhArray = rootCSevenths[randomIndex];
    NSUInteger randomTransposition = arc4random() % 12;
    
    NSSet *randomSeventh = [self transposeChord:randomSeventhArray by:randomTransposition];
    NSMutableSet *tempIncompleteSeventh = [NSMutableSet setWithSet:randomSeventh];
    [tempIncompleteSeventh removeObject:[tempIncompleteSeventh anyObject]];
    
      // this ensures that a legal triad is not returned
    NSSet *trialChord = [NSSet setWithSet:tempIncompleteSeventh];
    ChordType chordType = [self.sonorityLogic chordFromSonorityPlusCheckIncompleteSeventh:trialChord].chordType;
    if (chordType > kChordFrenchSixth) {
      incompleteSeventh = trialChord;
    }
  }
  
  NSMutableSet *tempReturnedChord = [NSMutableSet new];
  
  for (NSNumber *pc in incompleteSeventh) {
    NSUInteger dyadmino = arc4random() % 10; // ten dyadminoes, to make it easier
    NSDictionary *legalIncompleteSeventhNote = @{@"pc":pc, @"dyadmino": @(dyadmino)};
    [tempReturnedChord addObject:legalIncompleteSeventhNote];
  }
  
  return [NSSet setWithSet:tempReturnedChord];
}

-(NSSet *)transposeChord:(NSArray *)chordAsArray by:(NSUInteger)transposition {
  NSMutableSet *mutableTransposedChord = [NSMutableSet new];
  
    // transpose each note in chord
  for (NSNumber *pcObject in chordAsArray) {
    NSUInteger pc = [pcObject unsignedIntegerValue];
    pc = (pc + transposition) % 12;
    [mutableTransposedChord addObject:[NSNumber numberWithUnsignedInteger:pc]];
  }
  return [NSSet setWithSet:mutableTransposedChord];
}

@end