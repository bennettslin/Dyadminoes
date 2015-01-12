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
  
  Chord noChord = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:@[]]];
  Chord monad = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:@[@0]]];
  Chord dyad = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:@[@0, @1]]];
  Chord illegal = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:@[@0, @1, @2, @3]]];
  
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
      
      Chord chordForTransposedChord = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithSet:transposedChord]];
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
      Chord chordFromIncompleteRootCSeventh = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:incompleteRootCSeventh]];
      
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
          
          Chord chordForTransposedChord = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:[NSSet setWithArray:transposedChord]];
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
    ChordType returnedChordType = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:illegalChord].chordType;
    
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
    ChordType returnedChordType = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:legalChord].chordType;
    
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
    ChordType returnedChordType = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:legalIncompleteSeventhChord].chordType;
    
    XCTAssertTrue(returnedChordType == kChordLegalIncompleteSeventh, @"Logic failed to detect that sonority is legal incomplete seventh for %@, saw it as %i instead.", legalIncompleteSeventhChord, returnedChordType);
  }
}

-(void)testSonorityIsSubsetOfSonorityMethod {
  
    // test 50 times
    // test when sonorities have no notes in common
  for (int i = 0; i < 50; i++) {
  
    NSSet *set1 = [self randomSonority];
    NSSet *set2 = [self randomSonorityThatIsNotSonority:set1];
  
    XCTAssertFalse([self.sonorityLogic sonority:set1 is:kSubset ofSonority:set2], @"Failed to see that sonorities have no notes in common.");
  }
  
    // test 50 times
  for (int i = 0; i < 50; i++) {
    
    NSSet *set1 = [self randomLegalChord];
    NSSet *set2 = [self randomSonorityThatIsSubsetOrSupersetOfRandomSonority:set1];
    
      // make set1 the smaller one no matter what
    if (set1.count > set2.count) {
      NSSet *tempSet = set2;
      set2 = set1;
      set1 = tempSet;
    }

    XCTAssertTrue([self.sonorityLogic sonority:set1 is:kSubset ofSonority:set2], @"Smaller sonority not recognised as subset of larger one.");

      // additionally, test when an extra note is added to the smaller sonority
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
    
    XCTAssertFalse([self.sonorityLogic sonority:set1 is:kSubset ofSonority:set2], @"Failed to see that sonority is not subset despite some notes in common, because it also has extra notes not found in other sonority.");
  }
  
    // test 50 times
    // test when sonorities are equal
  for (int i = 0; i < 50; i++){
    
    NSSet *set1 = [self randomSonority];
    NSSet *set2 = [NSSet setWithSet:set1];
    
    XCTAssertTrue([self.sonorityLogic sonority:set1 is:kSubset ofSonority:set2], @"Failed to see that sonorities are equal.");
  }
}

-(void)testEqualSonoritiesAreSubsetsOfEachOther {
  
    // test 50 times
  
  for (int i = 0; i < 50; i++) {
    NSSet *sonority1 = [self randomSonority];
    NSSet *sonority2 = [NSSet setWithSet:sonority1];
    
    XCTAssertTrue([self.sonorityLogic sonority:sonority1 is:kSubset ofSonority:sonority2], @"Sonority1 should be subset of sonority2.");
    XCTAssertTrue([self.sonorityLogic sonority:sonority2 is:kSubset ofSonority:sonority1], @"Sonority1 should be subset of sonority2.");
  }
}

-(void)testSonorityIsEqualToSonorityMethod {
    // same methods as subset test
  
    // test 50 times
    // test when sonorities have no notes in common
  for (int i = 0; i < 50; i++) {
    
    NSSet *set1 = [self randomSonority];
    NSSet *set2 = [self randomSonorityThatIsNotSonority:set1];
    
    XCTAssertFalse([self.sonorityLogic sonority:set1 is:kEqual ofSonority:set2], @"Failed to see that sonorities have no notes in common.");
  }
  
    // test 50 times
  for (int i = 0; i < 50; i++) {
    
    NSSet *set1 = [self randomLegalChord];
    NSSet *set2 = [self randomSonorityThatIsSubsetOrSupersetOfRandomSonority:set1];
    
    XCTAssertFalse([self.sonorityLogic sonority:set1 is:kEqual ofSonority:set2], @"One sonority that is a subset of another should not be equal.");
  }
  
    // test 50 times
    // test when sonorities are equal
  for (int i = 0; i < 50; i++){
    
    NSSet *set1 = [self randomSonority];
    NSSet *set2 = [NSSet setWithSet:set1];
    
    XCTAssertTrue([self.sonorityLogic sonority:set1 is:kEqual ofSonority:set2], @"Failed to see that sonorities are equal.");
  }
}

-(void)testSonoritiesIsSubsetOfSonoritiesMethod {

    // test 1000 times
  for (int i = 0; i < 1000; i++) {
    
    NSMutableSet *subsetSet = [NSMutableSet new];
    NSMutableSet *supersetSet = [NSMutableSet new];
    
      // varies from 1 to 5
    NSUInteger numberInSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberInSet; i++) {
        // first add equal sonorities

      BOOL addedSonority = NO;
      while (!addedSonority) {
        NSSet *randomSonority = [self randomSonority];
        if (![self sonorities:subsetSet containsSonority:randomSonority] &&
            ![self sonorities:supersetSet containsSonority:randomSonority]) {
          
          [subsetSet addObject:randomSonority];
          [supersetSet addObject:randomSonority];
          addedSonority = YES;
        }
      }
    }
    
    XCTAssertTrue([self.sonorityLogic sonorities:subsetSet is:kSubset ofSonorities:supersetSet], @"Failed to see that if sets are equal, then one is also subset of another.");
    
      // varies from 1 to 5
    NSUInteger randomNumberOfSubsets = (arc4random() % 5) + 1;
    for (int i = 0; i < randomNumberOfSubsets; i++) {
      // add at least one pair of subset and superset sonorities
      
      BOOL addedSonority = NO;
      while (!addedSonority) {
        NSSet *sonority = [self randomLegalChord];
        NSSet *otherSonority = [self randomSonorityThatIsSubsetOrSupersetOfRandomSonority:sonority];
        NSSet *smallerSonority = (sonority.count == 3) ? sonority : otherSonority;
        NSSet *largerSonority = (sonority.count == 3) ? otherSonority : sonority;
        
        if (![self sonorities:subsetSet containsSonority:smallerSonority] &&
            ![self sonorities:supersetSet containsSonority:largerSonority]) {
          
          [subsetSet addObject:smallerSonority];
          [supersetSet addObject:largerSonority];
          addedSonority = YES;
        }
      }
    }
    
    XCTAssertTrue([self.sonorityLogic sonorities:subsetSet is:kSubset ofSonorities:supersetSet], @"Failed to see that one set of sonorities is a subset of another, with a sonority in the one being a subset of a sonority in the other, and the rest being equal, with equal counts.");

    XCTAssertFalse([self.sonorityLogic sonorities:supersetSet is:kSubset ofSonorities:subsetSet], @"Failed to see that one set of sonorities is not a subset of another, with a sonority in the one being a superset of a sonority in the other, and the rest being equal, with equal counts.");
    
      // test adding extra sonority to superset
    NSMutableSet *tempSupersetSet = [NSMutableSet setWithSet:supersetSet];
    BOOL addedSonorityToSuperset = NO;
    while (!addedSonorityToSuperset) {
      NSSet *randomSonority = [self randomSonority];
      if (![self sonorities:supersetSet containsSonority:randomSonority] &&
          ![self sonorities:subsetSet containsSubsetOfSonority:randomSonority]) {

        [tempSupersetSet addObject:randomSonority];
        addedSonorityToSuperset = YES;
      }
    }
    
    XCTAssertTrue([self.sonorityLogic sonorities:subsetSet is:kSubset ofSonorities:tempSupersetSet], @"Failed to see that one set of sonorities is subset of another, with a sonority in the one being a subset of a sonority in the other, with the superset set having an extra sonority.");

      // test adding extra sonority to subset
    BOOL addedSonorityToSubset = NO;
    while (!addedSonorityToSubset) {
      NSSet *randomSonority = [self randomSonority];
      if (![self sonorities:subsetSet containsSonority:randomSonority] &&
          ![self sonorities:supersetSet containsSupersetOfSonority:randomSonority]) {
        
        [subsetSet addObject:randomSonority];
        addedSonorityToSubset = YES;
      }
    }
    
    XCTAssertFalse([self.sonorityLogic sonorities:subsetSet is:kSubset ofSonorities:supersetSet], @"Failed to see that the subset set is not a subset of the superset set, once it has an extra sonority.");
  }
}

-(void)testSonoritiesIsEqualToSonoritiesMethod {
  
    // test 1000 times
  for (int i = 0; i < 1000; i++) {
    
    NSMutableSet *subsetSet = [NSMutableSet new];
    NSMutableSet *supersetSet = [NSMutableSet new];
    
      // varies from 1 to 5
    NSUInteger numberInSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberInSet; i++) {
        // first add equal sonorities
      
      BOOL addedSonority = NO;
      while (!addedSonority) {
        NSSet *randomSonority = [self randomSonority];
        if (![self sonorities:subsetSet containsSonority:randomSonority] &&
            ![self sonorities:supersetSet containsSonority:randomSonority]) {
          
          [subsetSet addObject:randomSonority];
          [supersetSet addObject:randomSonority];
          addedSonority = YES;
        }
      }
    }
    
    XCTAssertTrue([self.sonorityLogic sonorities:subsetSet is:kEqual ofSonorities:supersetSet], @"Failed to see that sets are equal.");
    
      // varies from 1 to 5
    NSUInteger randomNumberOfSubsets = (arc4random() % 5) + 1;
    for (int i = 0; i < randomNumberOfSubsets; i++) {
        // add at least one pair of subset and superset sonorities
      
      BOOL addedSonority = NO;
      while (!addedSonority) {
        NSSet *sonority = [self randomLegalChord];
        NSSet *otherSonority = [self randomSonorityThatIsSubsetOrSupersetOfRandomSonority:sonority];
        NSSet *smallerSonority = (sonority.count == 3) ? sonority : otherSonority;
        NSSet *largerSonority = (sonority.count == 3) ? otherSonority : sonority;
        
        if (![self sonorities:subsetSet containsSonority:smallerSonority] &&
            ![self sonorities:supersetSet containsSonority:largerSonority]) {
          
          [subsetSet addObject:smallerSonority];
          [supersetSet addObject:largerSonority];
          addedSonority = YES;
        }
      }
    }
    
    XCTAssertFalse([self.sonorityLogic sonorities:subsetSet is:kEqual ofSonorities:supersetSet], @"Failed to see that one set of sonorities is not equal to another, with a sonority in the one being a subset of a sonority in the other, and the rest being equal, with equal counts.");
    
    XCTAssertFalse([self.sonorityLogic sonorities:supersetSet is:kEqual ofSonorities:subsetSet], @"Failed to see that one set of sonorities is not equal to another, with a sonority in the one being a superset of a sonority in the other, and the rest being equal, with equal counts.");
    
      // test adding extra sonority to superset
    NSMutableSet *tempSupersetSet = [NSMutableSet setWithSet:supersetSet];
    BOOL addedSonorityToSuperset = NO;
    while (!addedSonorityToSuperset) {
      NSSet *randomSonority = [self randomSonority];
      if (![self sonorities:supersetSet containsSonority:randomSonority] &&
          ![self sonorities:subsetSet containsSubsetOfSonority:randomSonority]) {
        
        [tempSupersetSet addObject:randomSonority];
        addedSonorityToSuperset = YES;
      }
    }
    
    XCTAssertFalse([self.sonorityLogic sonorities:subsetSet is:kEqual ofSonorities:tempSupersetSet], @"Failed to see that one set of sonorities is not equal to another, with a sonority in the one being a subset of a sonority in the other, with the superset set having an extra sonority.");
    
      // test adding extra sonority to subset
    BOOL addedSonorityToSubset = NO;
    while (!addedSonorityToSubset) {
      NSSet *randomSonority = [self randomSonority];
      if (![self sonorities:subsetSet containsSonority:randomSonority] &&
          ![self sonorities:supersetSet containsSupersetOfSonority:randomSonority]) {
        
        [subsetSet addObject:randomSonority];
        addedSonorityToSubset = YES;
      }
    }
    
    XCTAssertFalse([self.sonorityLogic sonorities:subsetSet is:kEqual ofSonorities:supersetSet], @"Failed to see that the subset set is not equal to the superset set, when it has an extra sonority.");
  }
}

-(void)testLegalChordsThatExtendALegalChordInLegalChordsMethod {
  
    // test 1000 times
  for (int i = 0; i < 1000; i++) {
    
    NSMutableSet *subsetSet = [NSMutableSet new];
    NSMutableSet *supersetSet = [NSMutableSet new];
    
      // varies from 1 to 5
      // equal sonorities in both sets
    NSUInteger numberOfEqualInSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberOfEqualInSet; i++) {
      
      BOOL addedLegalChord = NO;
      while (!addedLegalChord) {
        NSSet *randomLegalChord = [self randomLegalChord];
        if (![self sonorities:subsetSet containsSonority:randomLegalChord] &&
            ![self sonorities:supersetSet containsSonority:randomLegalChord]) {
          
          [subsetSet addObject:randomLegalChord];
          [supersetSet addObject:randomLegalChord];
          addedLegalChord = YES;
        }
      }
    }
    
      // varies from 1 to 5
      // add at least one pair of subset and superset sonorities
    NSMutableSet *expectedExtendingLegalChordsInSuperset = [NSMutableSet new];
    
    NSUInteger randomNumberOfSubsets = (arc4random() % 5) + 1;
    for (int i = 0; i < randomNumberOfSubsets; i++) {
      
      BOOL addedLegalChord = NO;
      while (!addedLegalChord) {
        NSSet *legalChord = [self randomLegalChord];
        NSSet *otherLegalChord = [self randomSonorityThatIsSubsetOrSupersetOfRandomSonority:legalChord];
        NSSet *smallerLegalChord = (legalChord.count == 3) ? legalChord : otherLegalChord;
        NSSet *largerLegalChord = (legalChord.count == 3) ? otherLegalChord : legalChord;
        
        if (![self sonorities:subsetSet containsSonority:smallerLegalChord] &&
            ![self sonorities:subsetSet containsSubsetOfSonority:largerLegalChord] &&
            ![self sonorities:supersetSet containsSupersetOfSonority:smallerLegalChord] &&
            ![self sonorities:supersetSet containsSonority:largerLegalChord]) {
          
          [subsetSet addObject:smallerLegalChord];
          [supersetSet addObject:largerLegalChord];
          
          [expectedExtendingLegalChordsInSuperset addObject:largerLegalChord];
          addedLegalChord = YES;
        }
      }
    }
    
    NSSet *returnedLegalChords = [self.sonorityLogic legalChords:supersetSet thatExtendALegalChordInLegalChords:subsetSet];
    
      // not sure why test breaks with large numbers such as 10,000
//    if (![self.sonorityLogic sonorities:expectedExtendingLegalChordsInSuperset is:kEqual ofSonorities:returnedLegalChords]) {
//      NSLog(@"superset set");
//      [self logSonorities:supersetSet];
//      NSLog(@"subset set");
//      [self logSonorities:subsetSet];
//      NSLog(@"expected set");
//      [self logSonorities:expectedExtendingLegalChordsInSuperset];
//      NSLog(@"returned set");
//      [self logSonorities:returnedLegalChords];
//    }
    
    XCTAssertTrue([self.sonorityLogic sonorities:expectedExtendingLegalChordsInSuperset is:kEqual ofSonorities:returnedLegalChords], @"Did not return all and only extending legal chords.");
  }
}

-(void)testLegalChordsThatAreCompletelyNotFoundInLegalChordsMethod {
  
    // test 1000 times
  for (int i = 0; i < 1000; i++) {
    
    NSMutableSet *subsetSet = [NSMutableSet new];
    NSMutableSet *supersetSet = [NSMutableSet new];
    
      // varies from 1 to 5
      // equal sonorities in both sets
    NSUInteger numberOfEqualInSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberOfEqualInSet; i++) {
      
      BOOL addedLegalChord = NO;
      while (!addedLegalChord) {
        NSSet *randomLegalChord = [self randomLegalChord];
        if (![self sonorities:subsetSet containsSonority:randomLegalChord] &&
            ![self sonorities:supersetSet containsSonority:randomLegalChord]) {
          
          [subsetSet addObject:randomLegalChord];
          [supersetSet addObject:randomLegalChord];
          addedLegalChord = YES;
        }
      }
    }
    
      // varies from 1 to 5
      // random legal chords in subset set
    NSMutableSet *expectedNewLegalChordsInSuperset = [NSMutableSet new];
    
    NSUInteger numberOfRandomInSupersetSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberOfRandomInSupersetSet; i++) {
      
      BOOL addedLegalChord = NO;
      while (!addedLegalChord) {
        NSSet *randomLegalChord = [self randomLegalChord];
        if (![self sonorities:subsetSet containsSubsetOfSonority:randomLegalChord] &&
            ![self sonorities:supersetSet containsSonority:randomLegalChord]) {
          
          [supersetSet addObject:randomLegalChord];
          [expectedNewLegalChordsInSuperset addObject:randomLegalChord];
          addedLegalChord = YES;
        }
      }
    }
    
    NSSet *returnedLegalChords = [self.sonorityLogic legalChords:supersetSet thatAreCompletelyNotFoundInLegalChords:subsetSet];
    XCTAssertTrue([self.sonorityLogic sonorities:expectedNewLegalChordsInSuperset is:kEqual ofSonorities:returnedLegalChords], @"Did not return all and only completely new legal chords.");
  }
}

-(void)testLegalChordsThatAreEitherNewOrExtendingRelativeToLegalChordsMethod {
  
    // test 1000 times
  for (int i = 0; i < 1000; i++) {
    
    NSMutableSet *subsetSet = [NSMutableSet new];
    NSMutableSet *supersetSet = [NSMutableSet new];
    
      // varies from 1 to 5
      // equal sonorities in both sets
    NSUInteger numberOfEqualInSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberOfEqualInSet; i++) {
      
      BOOL addedLegalChord = NO;
      while (!addedLegalChord) {
        NSSet *randomLegalChord = [self randomLegalChord];
        if (![self sonorities:subsetSet containsSonority:randomLegalChord] &&
            ![self sonorities:supersetSet containsSonority:randomLegalChord]) {
          
          [subsetSet addObject:randomLegalChord];
          [supersetSet addObject:randomLegalChord];
          addedLegalChord = YES;
        }
      }
    }
    
      // varies from 1 to 5
      // random legal chords in subset set
    NSMutableSet *expectedNewOrExtendingLegalChordsInSuperset = [NSMutableSet new];
    
    NSUInteger numberOfRandomInSupersetSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberOfRandomInSupersetSet; i++) {
      
      BOOL addedLegalChord = NO;
      while (!addedLegalChord) {
        NSSet *randomLegalChord = [self randomLegalChord];
        if (![self sonorities:subsetSet containsSubsetOfSonority:randomLegalChord] &&
            ![self sonorities:supersetSet containsSonority:randomLegalChord]) {
          
          [supersetSet addObject:randomLegalChord];
          [expectedNewOrExtendingLegalChordsInSuperset addObject:randomLegalChord];
          addedLegalChord = YES;
        }
      }
    }
    
      // varies from 1 to 5
      // add at least one pair of subset and superset sonorities
    NSUInteger randomNumberOfSubsets = (arc4random() % 5) + 1;
    for (int i = 0; i < randomNumberOfSubsets; i++) {
      
      BOOL addedLegalChord = NO;
      while (!addedLegalChord) {
        NSSet *legalChord = [self randomLegalChord];
        NSSet *otherLegalChord = [self randomSonorityThatIsSubsetOrSupersetOfRandomSonority:legalChord];
        NSSet *smallerLegalChord = (legalChord.count == 3) ? legalChord : otherLegalChord;
        NSSet *largerLegalChord = (legalChord.count == 3) ? otherLegalChord : legalChord;
        
        if (![self sonorities:subsetSet containsSonority:smallerLegalChord] &&
            ![self sonorities:subsetSet containsSubsetOfSonority:largerLegalChord] &&
            ![self sonorities:supersetSet containsSupersetOfSonority:smallerLegalChord] &&
            ![self sonorities:supersetSet containsSonority:largerLegalChord]) {
          
          [subsetSet addObject:smallerLegalChord];
          [supersetSet addObject:largerLegalChord];
          
          [expectedNewOrExtendingLegalChordsInSuperset addObject:largerLegalChord];
          addedLegalChord = YES;
        }
      }
    }
    
    NSSet *returnedLegalChords = [self.sonorityLogic legalChords:supersetSet thatAreEitherNewOrExtendingRelativeToLegalChords:subsetSet];
    XCTAssertTrue([self.sonorityLogic sonorities:expectedNewOrExtendingLegalChordsInSuperset is:kEqual ofSonorities:returnedLegalChords], @"Did not return all and only completely new or extending legal chords.");
  }
}

-(void)testLegalChordSonoritiesFromFormationOfSonoritiesMethod {
  
    // test 1000 times
  for (int i = 0; i < 1000; i++) {
    NSMutableSet *tempFormationsSet = [NSMutableSet new];
    NSMutableSet *expectedLegalChords = [NSMutableSet new];
    NSUInteger numberInFormationsSet = (arc4random() % 5) + 1;
    
    for (int i = 0; i < numberInFormationsSet; i++) {
      
      BOOL illegalChordAdded = NO;
      while (!illegalChordAdded) {
        NSSet *randomIllegalChord = [self randomIllegalChord];
        if (![self sonorities:tempFormationsSet containsSonority:randomIllegalChord]) {
          [tempFormationsSet addObject:randomIllegalChord];
          illegalChordAdded = YES;
        }
      }

      BOOL legalChordAdded = NO;
      while (!legalChordAdded) {
        NSSet *randomLegalChord = [self randomLegalChord];
        if (![self sonorities:tempFormationsSet containsSonority:randomLegalChord]) {
          [tempFormationsSet addObject:randomLegalChord];
          [expectedLegalChords addObject:randomLegalChord];
          legalChordAdded = YES;
        }
      }
    }

    NSSet *formationsSet = [NSSet setWithSet:tempFormationsSet];
    NSSet *returnedLegalChords = [self.sonorityLogic legalChordSonoritiesFromFormationOfSonorities:formationsSet];
    
    XCTAssertTrue([self.sonorityLogic sonorities:expectedLegalChords is:kEqual ofSonorities:returnedLegalChords], @"Failed to detech all and only legal chords in formation of sonorities.");
    
  }
}

-(void)testCheckIllegalPlacementFromFormationOfSnoritiesMethod {

    // test 100 times
  for (int i = 0; i < 100; i++) {
    
      // just legal chords
    NSMutableSet *justLegalChordsSet = [NSMutableSet new];
    NSUInteger numberInJustLegalChordsSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberInJustLegalChordsSet; i++) {
      [justLegalChordsSet addObject:[self randomLegalChord]];
    }
    XCTAssertTrue([self.sonorityLogic checkIllegalPlacementFromFormationOfSonorities:justLegalChordsSet] == kNotIllegal, @"Should return not illegal.");

      // plus excess notes
    NSMutableSet *excessNotesSet = [NSMutableSet new];
    NSUInteger numberInExcessNotesSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberInExcessNotesSet; i++) {
      [excessNotesSet addObject:[self randomExcessSonority]];
      [excessNotesSet addObject:[self randomLegalChord]];
    }
    XCTAssertTrue([self.sonorityLogic checkIllegalPlacementFromFormationOfSonorities:excessNotesSet] == kExcessNotes, @"Should return excess notes error.");
    
      // plus double PCs
    NSMutableSet *doublesSet = [NSMutableSet new];
    NSUInteger numberInDoublesSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberInDoublesSet; i++) {
      [doublesSet addObject:[self randomSonorityWithDoublePCs]];
      [doublesSet addObject:[self randomLegalChord]];
    }
    XCTAssertTrue([self.sonorityLogic checkIllegalPlacementFromFormationOfSonorities:doublesSet] == kDoublePCs, @"Should return double PCs error.");

      // plus illegal sonorities
    NSMutableSet *illegalsSet = [NSMutableSet new];
    NSUInteger numberInIllegalsSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberInIllegalsSet; i++) {
      [illegalsSet addObject:[self randomIllegalChord]];
      [illegalsSet addObject:[self randomLegalChord]];
    }
    XCTAssertTrue([self.sonorityLogic checkIllegalPlacementFromFormationOfSonorities:illegalsSet] == kIllegalSonority, @"Should return illegal sonority error.");
    
      // excess plus doubles
    NSMutableSet *excessPlusDoublesSet = [NSMutableSet new];
    NSUInteger numberInExcessPlusDoublesSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberInExcessPlusDoublesSet; i++) {
      [excessPlusDoublesSet addObject:[self randomExcessSonority]];
      [excessPlusDoublesSet addObject:[self randomSonorityWithDoublePCs]];
      [excessPlusDoublesSet addObject:[self randomLegalChord]];
    }
    XCTAssertTrue([self.sonorityLogic checkIllegalPlacementFromFormationOfSonorities:excessPlusDoublesSet] == kExcessNotes, @"Should return excess notes error, not double PCs error.");
    
      // excess plus illegals
    NSMutableSet *excessPlusIllegalsSet = [NSMutableSet new];
    NSUInteger numberInExcessPlusIllegalsSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberInExcessPlusIllegalsSet; i++) {
      [excessPlusIllegalsSet addObject:[self randomExcessSonority]];
      [excessPlusIllegalsSet addObject:[self randomIllegalChord]];
      [excessPlusIllegalsSet addObject:[self randomLegalChord]];
    }
    XCTAssertTrue([self.sonorityLogic checkIllegalPlacementFromFormationOfSonorities:excessPlusIllegalsSet] == kExcessNotes, @"Should return excess notes error, not illegal sonority error.");
    
      // doubles plus illegals
    NSMutableSet *doublesPlusIllegalsSet = [NSMutableSet new];
    NSUInteger numberInDoublesPlusIllegalsSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberInDoublesPlusIllegalsSet; i++) {
      [doublesPlusIllegalsSet addObject:[self randomSonorityWithDoublePCs]];
      [doublesPlusIllegalsSet addObject:[self randomIllegalChord]];
      [doublesPlusIllegalsSet addObject:[self randomLegalChord]];
    }
    XCTAssertTrue([self.sonorityLogic checkIllegalPlacementFromFormationOfSonorities:doublesPlusIllegalsSet] == kDoublePCs, @"Should return double PCs error, not illegal sonority error.");
    
      // the whole shebang
    NSMutableSet *everythingSet = [NSMutableSet new];
    NSUInteger numberInEverythingSet = (arc4random() % 5) + 1;
    for (int i = 0; i < numberInEverythingSet; i++) {
      [everythingSet addObject:[self randomExcessSonority]];
      [everythingSet addObject:[self randomSonorityWithDoublePCs]];
      [everythingSet addObject:[self randomIllegalChord]];
      [everythingSet addObject:[self randomLegalChord]];
    }
    XCTAssertTrue([self.sonorityLogic checkIllegalPlacementFromFormationOfSonorities:everythingSet] == kExcessNotes, @"Should return excess notes error, since it is the most egregious violation.");
  }
}

-(void)testChordForPersonalPurposes {
  NSSet *chordSonority = [NSSet setWithArray:@[@1, @4, @7]];
  Chord chord = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:chordSonority];
  NSLog(@"chord type is %i", chord.chordType);
  XCTAssertTrue(chord.chordType == kChordDiminishedTriad, @"This chord should be diminished triad!");
}

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

-(NSSet *)randomSonorityThatIsNotSonority:(NSSet *)notSonority {
  NSSet *returnSonority;
  
  while (!returnSonority) {
    NSSet *trialSet2 = [self randomSonority];
    
    BOOL noCommonNote = YES;
    for (NSDictionary *note in trialSet2) {
      if ([notSonority containsObject:note]) {
        noCommonNote = NO;
      }
    }
    
    returnSonority = noCommonNote ? trialSet2 : nil;
  }
  
  return returnSonority;
}

-(NSSet *)randomSonorityThatIsSubsetOrSupersetOfRandomSonority:(NSSet *)originalSonority {
    // this method was originally written for legal chords
    // but it works with any sonorities of three and four
  
  NSSet *returnSonority;
  
    // if original sonority is triad, then add note
  if (originalSonority.count == 3) {
    NSMutableSet *tempSet = [NSMutableSet setWithSet:originalSonority];
    
    while (!returnSonority || returnSonority.count < 4) {
      NSUInteger pc = arc4random() % 12;
      NSUInteger dyadmino = arc4random() % 10; // ten dyadminoes, to make it easier
      NSDictionary *note = @{@"pc":@(pc), @"dyadmino": @(dyadmino)};
      [tempSet addObject:note];
      returnSonority = [NSSet setWithSet:tempSet];
    }
    
      // if original sonority is seventh, then subtract note
  } else {
    NSMutableSet *tempSet = [NSMutableSet setWithSet:originalSonority];
    [tempSet removeObject:[tempSet anyObject]];
    returnSonority = [NSSet setWithSet:tempSet];
  }
  
  return returnSonority;
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

    Chord trialChord = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:tempSonority];
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
    ChordType chordType = [self.sonorityLogic testChordFromSonorityPlusCheckIncompleteSeventh:trialChord].chordType;
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

-(BOOL)sonorities:(NSSet *)sonorities containsSonority:(NSSet *)sonority {
  for (NSSet *setSonority in sonorities) {
    if ([self.sonorityLogic sonority:setSonority is:kEqual ofSonority:sonority]) {
      return YES;
    }
  }
  return NO;
}

-(BOOL)sonorities:(NSSet *)sonorities containsSubsetOfSonority:(NSSet *)sonority {
  for (NSSet *setSonority in sonorities) {
    if ([self.sonorityLogic sonority:setSonority is:kSubset ofSonority:sonority]) {
      return YES;
    }
  }
  return NO;
}

-(BOOL)sonorities:(NSSet *)sonorities containsSupersetOfSonority:(NSSet *)sonority {
  for (NSSet *setSonority in sonorities) {
    if ([self.sonorityLogic sonority:sonority is:kSubset ofSonority:setSonority]) {
      return YES;
    }
  }
  return NO;
}

@end