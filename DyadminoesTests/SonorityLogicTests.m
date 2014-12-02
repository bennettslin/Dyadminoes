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
  
  NSArray *dimRootsArray = @[@"C-D(#)/E(b)-F(#)/G(b)-A", @"C(#)/D(b)-E-G-A(#)/B(b)", @"D-F-G(#)/A(b)-B"];
  NSArray *augRootsArray = @[@"C-E-G(#)/A(b)", @"C(#)/D(b)-F-A", @"D-F(#)/G(b)-A(#)/B(b)", @"D(#)/E(b)-G-B"];
  NSArray *frenchRootsArray = @[@"C-F(#)/G(b)", @"C(#)/D(b)-G", @"D-G(#)/A(b)",
                                @"D(#)/E(b)-A", @"E-A(#)/B(b)", @"F-B"];
  
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



//-(void)testChord {
//  Chord chord = [self.sonorityLogic chordFromSonority:@[@0, @4, @7]];
//}

@end
