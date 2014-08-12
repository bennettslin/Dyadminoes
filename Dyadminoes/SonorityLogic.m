//
//  SonorityLogic.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SonorityLogic.h"

@implementation SonorityLogic {
  NSUInteger _cardinality;
  NSNumber *_fakeRootPC;
}

-(id)initWithPCs:(NSArray *)pcs {
  self = [super init];
  if (self) {
    [self findFakeRootAndICPrimeFormFromSonority:pcs];
    [self findRootPCLetterAndChordTypeIfLegal];
  }
  return self;
}

-(void)findFakeRootAndICPrimeFormFromSonority:(NSArray *)sonority {
  _cardinality = [sonority count];
  
    // puts in pc normal form
  NSMutableArray *pcNormalForm = [NSMutableArray arrayWithArray:sonority];
  [pcNormalForm sortUsingSelector:@selector(compare:)];
//  NSLog(@"pc normal form is %@", pcNormalForm);
  
    // puts in ic normal form
  NSMutableArray *icNormalForm = [[NSMutableArray alloc] initWithCapacity:_cardinality];
  NSMutableArray *arrayOfSmallestICIndexes = [[NSMutableArray alloc] initWithCapacity:_cardinality];
  NSUInteger smallestKnownIC = 12; // start out with the maximum
  
  for (int i = 0; i < _cardinality; i++) {
    NSInteger higherNumber = [[pcNormalForm objectAtIndex:(i + 1) % _cardinality] integerValue];
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
//  NSLog(@"ic normal form is %@", icNormalForm);
  
    // converts ic normal form to ic prime form
    // if there are two smallest known ICs, then find the one that has the largest known gap
  NSUInteger largestKnownGap = 0; // start out with the minimum
  int firstICIndex = 0;
  for (NSNumber *indexObject in arrayOfSmallestICIndexes) {
    int index = [indexObject integerValue];
      // ensures no division by zero
    NSUInteger thisGap = (NSUInteger)icNormalForm[((index - 1) + _cardinality) % _cardinality];
    if (thisGap > largestKnownGap) {
      largestKnownGap = thisGap;
      firstICIndex = index;
    }
  }
  NSMutableArray *tempICPrimeForm = [[NSMutableArray alloc] initWithCapacity:_cardinality];
  for (int i = 0; i < _cardinality; i++) {
    NSUInteger thisIC = [icNormalForm[(i + firstICIndex) % _cardinality] unsignedIntegerValue];
    [tempICPrimeForm addObject:[NSNumber numberWithUnsignedInt:thisIC]];
  }
//  NSLog(@"ic prime form is %@", tempICPrimeForm);
  
  _fakeRootPC = pcNormalForm[firstICIndex];
//    NSLog(@"fake root is %@", _fakeRootPC);
  self.icPrimeForm = [NSArray arrayWithArray:tempICPrimeForm];
}

-(void)findRootPCLetterAndChordTypeIfLegal {
  NSArray *legalICPrimeForms = @[@[@3, @4, @5], @[@3, @5, @4], @[@2, @3, @3, @4],
                                 @[@2, @3, @4, @3], @[@2, @4, @3, @3], @[@3, @3, @6],
                                 @[@4, @4, @4], @[@3, @3, @3, @3], @[@1, @3, @4, @4],
                                 @[@1, @4, @3, @4], @[@1, @4, @4, @3],
                                 @[@2, @4, @6], @[@2, @4, @2, @4]];
  NSArray *legalChordTypes = @[@"minor triad", @"major triad", @"half-diminished seventh",
                               @"minor seventh", @"dominant seventh", @"diminished triad",
                               @"augmented triad", @"fully diminished seventh", @"minor-major seventh",
                               @"major seventh", @"augmented major seventh",
                               @"Italian sixth", @"French sixth"];
    // will eventually use real accidentals, of course
  NSArray *pcLetters = @[@"C", @"C#/Db", @"D", @"D#/Eb", @"E", @"F",
                         @"F#/Gb", @"G", @"G#/Ab", @"A", @"A#/Bb", @"B"];
  NSArray *fakeRootOffsets = @[@0, @8, @2, @2, @2, @0, @0, @0, @1, @1, @1, @2, @2];
  
  for (NSArray *legalICPrimeForm in legalICPrimeForms) {
    if ([self.icPrimeForm isEqualToArray:legalICPrimeForm]) {
      self.legalChord = YES;
      int index = [legalICPrimeForms indexOfObject:legalICPrimeForm];
      NSUInteger realRootPC = [_fakeRootPC unsignedIntegerValue] +
                      [fakeRootOffsets[index] unsignedIntegerValue];
      if (realRootPC >= 12) {
        realRootPC -= 12;
      }
      self.chordType = legalChordTypes[index];
      
        // if symmetric chord
      NSUInteger symmetricModulus;
      switch (index) {
        case 6: // augmented triad
          symmetricModulus = 4;
          break;
        case 7: // diminished seventh
          symmetricModulus = 3;
          break;
        case 12: // French sixth
          symmetricModulus = 6;
          break;
        default: // asymmetrical
          symmetricModulus = 0;
          break;
      }
      
      if (symmetricModulus != 0) {
        self.rootPCLetter = pcLetters[realRootPC];
        for (int i = 1; i < (12 / symmetricModulus); i++) {
          self.rootPCLetter = [self.rootPCLetter stringByAppendingString:
            [NSString stringWithFormat:@",%@", pcLetters[realRootPC + (i * symmetricModulus)]]];
        }
      } else { // not a symmetric chord
        self.rootPCLetter = pcLetters[realRootPC];
      }
    }
  }
}

@end
