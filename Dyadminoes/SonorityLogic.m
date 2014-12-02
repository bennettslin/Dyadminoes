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

#pragma mark - chord logic methods

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

-(Chord)chordFromSonorityPlusCheckIncompleteSeventh:(NSArray *)sonority {
  
  Chord chord = [self chordFromSonority:sonority];
  
  if (chord.chordType == kChordIllegalChord) {
    if ([self sonorityIsIncompleteSeventh:sonority]) {
      return [self chordFromRoot:-1 andChordType:kChordLegaIncompleteSeventh];
    }
  }
  return chord;
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
      chordType = (ChordType)index;
      root = realRootPC;
    }
  }
  return [self chordFromRoot:root andChordType:chordType];
}

-(BOOL)sonorityIsIncompleteSeventh:(NSArray *)sonority {
  
    // cardinality must be 3
  if (sonority.count != 3) {
    return NO;
  }
  
    // sonority must be illegal as a triad
  Chord chordForSonority = [self chordFromSonority:sonority];
  if (chordForSonority.chordType != kChordIllegalChord) {
    return NO;
  }
  
  BOOL sonorityIsIncompleteSeventh = NO;
  
  for (NSUInteger i = 0; i < 12; i++) {
    NSNumber *missingNote = [NSNumber numberWithUnsignedInteger:i];
    if (![sonority containsObject:missingNote]) {
      NSMutableArray *tempSonority = [NSMutableArray arrayWithArray:sonority];
      [tempSonority addObject:missingNote];
      NSArray *newSonority = [NSArray arrayWithArray:tempSonority];
      Chord chordForNewSonority = [self chordFromSonority:newSonority];
      if (!chordForNewSonority.chordType != kChordIllegalChord) {
        sonorityIsIncompleteSeventh = YES;
      }
    }
  }
  
  return sonorityIsIncompleteSeventh;
}

#pragma mark - chord label methods

-(NSString *)stringForChordType:(ChordType)chordType {
  switch (chordType) {
    case kChordMinorTriad:
      return @"minor triad";
      break;
    case kChordMajorTriad:
      return @"major triad";
      break;
    case kChordHalfDiminishedSeventh:
      return @"half-diminished seventh";
      break;
    case kChordMinorSeventh:
      return @"minor seventh";
      break;
    case kChordDominantSeventh:
      return @"dominant seventh";
      break;
    case kChordDiminishedTriad:
      return @"diminished triad";
      break;
    case kChordAugmentedTriad:
      return @"augmented triad";
      break;
    case kChordFullyDiminishedSeventh:
      return @"fully diminished seventh";
      break;
    case kChordMinorMajorSeventh:
      return @"minor-major seventh";
      break;
    case kChordMajorSeventh:
      return @"major seventh";
      break;
    case kChordAugmentedMajorSeventh:
      return @"augmented major seventh";
      break;
    case kChordItalianSixth:
      return @"Italian sixth";
      break;
    case kChordFrenchSixth:
      return @"French sixth";
      break;
    case kChordNoChord:
    case kChordLegalMonad:
    case kChordLegalDyad:
    case kChordLegaIncompleteSeventh:
    case kChordIllegalChord:
      return nil;
      break;
  }
}

-(NSString *)stringForChord:(Chord)chord {
  
  NSInteger root = chord.root;
  ChordType chordType = chord.chordType;
  
  NSString *rootString;
  
  if (chordType == kChordFullyDiminishedSeventh) {
    switch (root) {
      case 0:
      case 3:
      case 6:
      case 9:
        rootString = @"C$D(#)/E(b)$F(#)/G(b)$A";
        break;
      case 1:
      case 4:
      case 7:
      case 10:
        rootString = @"C(#)/D(b)$E$G$A(#)/B(b)";
        break;
      case 2:
      case 5:
      case 8:
      case 11:
        rootString = @"D$F$G(#)/A(b)$B";
        break;
    }
    
  } else if (chordType == kChordAugmentedTriad) {
    switch (root) {
      case 0:
      case 4:
      case 8:
        rootString = @"C$E$G(#)/A(b)";
        break;
      case 1:
      case 5:
      case 9:
        rootString = @"C(#)/D(b)$F$A";
        break;
      case 2:
      case 6:
      case 10:
        rootString = @"D$F(#)/G(b)$A(#)/B(b)";
        break;
      case 3:
      case 7:
      case 11:
        rootString = @"D(#)/E(b)$G$B";
        break;
    }
    
  } else if (chordType == kChordFrenchSixth) {
    switch (root) {
      case 0:
      case 6:
        rootString = @"C$F(#)/G(b)";
        break;
      case 1:
      case 7:
        rootString = @"C(#)/D(b)$G";
        break;
      case 2:
      case 8:
        rootString = @"D$G(#)/A(b)";
        break;
      case 3:
      case 9:
        rootString = @"D(#)/E(b)$A";
        break;
      case 4:
      case 10:
        rootString = @"E$A(#)/B(b)";
        break;
      case 5:
      case 11:
        rootString = @"F$B";
        break;
    }
    
  } else if (chordType < kChordNoChord) {
    switch (root) {
      case 0:
        rootString = @"C";
        break;
      case 1:
        rootString = @"C(#)/D(b)";
        break;
      case 2:
        rootString = @"D";
        break;
      case 3:
        rootString = @"D(#)/E(b)";
        break;
      case 4:
        rootString = @"E";
        break;
      case 5:
        rootString = @"F";
        break;
      case 6:
        rootString = @"F(#)/G(b)";
        break;
      case 7:
        rootString = @"G";
        break;
      case 8:
        rootString = @"G(#)/A(b)";
        break;
      case 9:
        rootString = @"A";
        break;
      case 10:
        rootString = @"A(#)/B(b)";
        break;
      case 11:
        rootString = @"B";
        break;
    }
  }
  return [NSString stringWithFormat:@"%@ %@", rootString, [self stringForChordType:chordType]];
}

-(NSAttributedString *)stringWithAccidentals:(NSString *)myString fontSize:(CGFloat)size {
  
    // first replace all instances of (#) and (b) with pound and yen characters
  unichar pound[1] = {(unichar)163};
  unichar yen[1] = {(unichar)165};
  
  myString = [myString stringByReplacingOccurrencesOfString:@"(#)" withString:[NSString stringWithCharacters:pound length:1]];
  myString = [myString stringByReplacingOccurrencesOfString:@"(b)" withString:[NSString stringWithCharacters:yen length:1]];
  
  NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:myString];
  
  for (int i = 0; i < myString.length; i++) {
    unichar myChar = [myString characterAtIndex:i];
    
    if (myChar == (unichar)163) {
      [attString replaceCharactersInRange:NSMakeRange(i, 1) withString:[self stringForMusicSymbol:kSymbolSharp]];
      [attString addAttribute:NSBaselineOffsetAttributeName value:@(size / 2.75) range:NSMakeRange(i, 1)];
      [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSonata size:size * 0.85] range:NSMakeRange(i, 1)];
      
    } else if (myChar == (unichar)165) {
      [attString replaceCharactersInRange:NSMakeRange(i, 1) withString:[self stringForMusicSymbol:kSymbolFlat]];
      [attString addAttribute:NSBaselineOffsetAttributeName value:@(size / 4.8) range:NSMakeRange(i, 1)];
      [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSonata size:size * 0.95] range:NSMakeRange(i, 1)];
      
    } else if (myChar == (unichar)36) { // dollar sign turns into bullet
      [attString replaceCharactersInRange:NSMakeRange(i, 1) withString:[self stringForMusicSymbol:kSymbolBullet]];
      [attString addAttribute:NSKernAttributeName value:@(-size * .05) range:NSMakeRange(i, 1)];
    }
  }
  
  return attString;
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
