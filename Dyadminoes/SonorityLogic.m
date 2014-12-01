//
//  SonorityLogic.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SonorityLogic.h"

@interface SonorityLogic ()

@end

@implementation SonorityLogic

-(Chord)chordFromSonority:(NSArray *)sonority {
  
    // root is -1 if not a chord
  
  
  NSUInteger cardinality = [sonority count];
  
    // return if legal sonority
  if (cardinality == 0) {
    return [self chordFromRoot:-1 andChordType:kChordNoChord];
  } else if (cardinality == 1) {
    return [self chordFromRoot:-1 andChordType:kChordLegalMonad];
  } else if (cardinality == 2) {
    return [self chordFromRoot:-1 andChordType:kChordLegalDyad];
  }
  
    // puts in pc normal form
  NSMutableArray *pcNormalForm = [NSMutableArray arrayWithArray:sonority];
  [pcNormalForm sortUsingSelector:@selector(compare:)];
  
    // puts in ic normal form
  NSMutableArray *icNormalForm = [[NSMutableArray alloc] initWithCapacity:cardinality];
  NSMutableArray *arrayOfSmallestICIndexes = [[NSMutableArray alloc] initWithCapacity:cardinality];
  NSUInteger smallestKnownIC = 12; // start out with the maximum
  
  for (int i = 0; i < cardinality; i++) {
    NSInteger higherNumber = [[pcNormalForm objectAtIndex:(i + 1) % cardinality] integerValue];
    NSInteger lowerNumber = [[pcNormalForm objectAtIndex:i] integerValue];
    NSInteger interval = higherNumber - lowerNumber;
    if (interval < 0) {
      interval += 12;
    }
    
    [icNormalForm addObject:[NSNumber numberWithInteger:interval]];
      // this will later help to determine ic prime form
    if (interval < smallestKnownIC) {
      smallestKnownIC = interval;
      [arrayOfSmallestICIndexes removeAllObjects];
      [arrayOfSmallestICIndexes addObject:[NSNumber numberWithInt:i]];
    } else if (interval == smallestKnownIC) {
      [arrayOfSmallestICIndexes addObject:[NSNumber numberWithInt:i]];
    }
  }

    // converts ic normal form to ic prime form
    // if there are two smallest known ICs, then find the one that has the largest known gap
  NSUInteger largestKnownGap = 0; // start out with the minimum
  int firstICIndex = 0;
  for (NSNumber *indexObject in arrayOfSmallestICIndexes) {
    int index = [indexObject intValue];
      // ensures no division by zero
    NSUInteger thisGap = (NSUInteger)icNormalForm[((index - 1) + cardinality) % cardinality];
    if (thisGap > largestKnownGap) {
      largestKnownGap = thisGap;
      firstICIndex = index;
    }
  }
  NSMutableArray *tempICPrimeForm = [[NSMutableArray alloc] initWithCapacity:cardinality];
  for (int i = 0; i < cardinality; i++) {
    uint thisIC = [icNormalForm[(i + firstICIndex) % cardinality] unsignedIntValue];
    [tempICPrimeForm addObject:[NSNumber numberWithUnsignedInt:thisIC]];
  }

  NSNumber *_fakeRootPC = pcNormalForm[firstICIndex];
  NSArray *icPrimeForm = [NSArray arrayWithArray:tempICPrimeForm];
  return [self chordFromFakeRootPC:_fakeRootPC andICPrimeForm:icPrimeForm];
}

-(Chord)chordFromFakeRootPC:(NSNumber *)fakeRootPC andICPrimeForm:(NSArray *)icPrimeForm {
  
  NSArray *legalICPrimeForms = @[@[@3, @4, @5], @[@3, @5, @4], @[@2, @3, @3, @4],
                                 @[@2, @3, @4, @3], @[@2, @4, @3, @3], @[@3, @3, @6],
                                 @[@4, @4, @4], @[@3, @3, @3, @3], @[@1, @3, @4, @4],
                                 @[@1, @4, @3, @4], @[@1, @4, @4, @3],
                                 @[@2, @4, @6], @[@2, @4, @2, @4]];
  
  NSArray *fakeRootOffsets = @[@0, @8, @2, @2, @2, @0, @0, @0, @1, @1, @1, @2, @2];

    // establish default
  BOOL isLegalChord = NO;
  ChordType chordType = kChordIllegalChord;
  NSInteger root = -1;
  
  for (NSArray *legalICPrimeForm in legalICPrimeForms) {
    if ([icPrimeForm isEqualToArray:legalICPrimeForm]) {
      isLegalChord = YES;
      NSUInteger index = [legalICPrimeForms indexOfObject:legalICPrimeForm];
      NSUInteger realRootPC = [fakeRootPC unsignedIntegerValue] +
                      [fakeRootOffsets[index] unsignedIntegerValue];
      if (realRootPC >= 12) {
        realRootPC -= 12;
      }
      chordType = index;
      root = realRootPC;
    }
  }
  return [self chordFromRoot:root andChordType:chordType];
}

#pragma mark - singleton method

+(id)sharedLogic {
  static SonorityLogic *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[self alloc] init];
  });
  return shared;
}

@end
