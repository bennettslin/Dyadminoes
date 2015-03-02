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

#pragma mark - validation methods

-(NSSet *)legalChordSonoritiesFromFormationOfSonorities:(NSSet *)sonorities {
    // returns all sonorities that are legal chords, with pc and dyadmino information
    // returns empty set if no legal chords
  
  NSMutableSet *tempChordSonorities = [NSMutableSet new];
  
  for (NSSet *sonority in sonorities) {
    
    NSSet *chordSonority = [self chordSonorityForSonority:sonority];
    Chord chord = [self chordFromSonorityPlusCheckIncompleteSeventh:chordSonority];
    
    if (chord.chordType <= kChordFrenchSixth) {
      [tempChordSonorities addObject:sonority];
    }
  }
  
  return tempChordSonorities;
}

-(IllegalPlacementResult)checkIllegalPlacementFromFormationOfSonorities:(NSSet *)sonorities {

  IllegalPlacementResult mostEgregiousError = kNotIllegal;
  
  for (NSSet *sonority in sonorities) {

      // ensures no chord exceeds maximum
    if (![self validateSonorityDoesNotExceedMaximum:sonority]) {
      mostEgregiousError = kExcessNotes > mostEgregiousError ? kExcessNotes : mostEgregiousError;
      
        // ensures chord does not have double pcs
    } else if (![self validateSonorityHasNoDoublePCs:sonority]) {
      mostEgregiousError = kDoublePCs > mostEgregiousError ? kDoublePCs : mostEgregiousError;
    }
    
    NSSet *chordSonority = [self chordSonorityForSonority:sonority];
    Chord chord = [self chordFromSonorityPlusCheckIncompleteSeventh:chordSonority];
    
      // ensures chord is not illegal
    if (chord.chordType == kChordIllegalChord) {
      mostEgregiousError = kIllegalSonority > mostEgregiousError ? kIllegalSonority : mostEgregiousError;
    }
  }

  return mostEgregiousError;
}

-(NSSet *)chordSonorityForSonority:(NSSet *)sonority {
  NSMutableSet *tempChordSonority = [NSMutableSet new];
  for (id note in sonority) {
    if ([note isKindOfClass:[NSDictionary class]]) {
      NSNumber *pc = note[@"pc"];
      [tempChordSonority addObject:pc];
    }
  }
  return [NSSet setWithSet:tempChordSonority];
}

-(NSSet *)chordSonoritiesForSonorities:(NSSet *)sonorities {
  NSMutableSet *tempChordSonorities = [NSMutableSet new];
  for (id sonority in sonorities) {
    if ([sonority isKindOfClass:[NSSet class]]) {
      NSSet *chordSonority = [self chordSonorityForSonority:(NSSet *)sonority];
      [tempChordSonorities addObject:chordSonority];
    }
  }
  return [NSSet setWithSet:tempChordSonorities];
}

-(BOOL)validateSonorityDoesNotExceedMaximum:(NSSet *)sonority {
  return (sonority.count <= 4);
}

-(BOOL)validateSonorityHasNoDoublePCs:(NSSet *)sonority {
  NSMutableSet *pcs = [NSMutableSet new];
  for (NSDictionary *note in sonority) {
    NSNumber *pc = note[@"pc"];
    if ([pcs containsObject:pc]) {
      return NO;
    }
    [pcs addObject:pc];
  }
  return YES;
}

-(BOOL)sonority:(NSSet *)set containsNote:(NSDictionary *)dictionary {
  
  for (NSDictionary *setNote in set) {
    
    if ([setNote[@"pc"] isEqual:dictionary[@"pc"]] && [setNote[@"dyadmino"] isEqual:dictionary[@"dyadmino"]]) {
      return YES;
    }
  }
  return NO;
}

-(BOOL)sonority:(NSSet *)sonority1 is:(Condition)condition ofSonority:(NSSet *)sonority2 {

  switch (condition) {
    case kSubset:
      for (NSDictionary *note in sonority1) {
        if (![self sonority:sonority2 containsNote:note]) {
          return NO;
        }
      }
      return YES;
      break;
      
    case kEqual:
        // if counts aren't equal, return no right away
      if (sonority1.count != sonority2.count) {
        return NO;
      }
      
      for (NSDictionary *note in sonority1) {
        if (![self sonority:sonority2 containsNote:note]) {
          return NO;
        }
      }
      return YES;
      break;
  }
  return NO;
}

-(BOOL)sonorities:(NSSet *)sonorities1 is:(Condition)condition ofSonorities:(NSSet *)sonorities2 {
  
          BOOL returnValue = YES;
          BOOL conditionSatisfied;
  
  switch (condition) {
    case kSubset:
      returnValue = YES;
      
        // for every sonority in sonorities1,
        // there is a sonority in sonorities2 that is equal to or a superset of it
      for (NSSet *sonority1 in sonorities1) {
        
        conditionSatisfied = NO;
        for (NSSet *sonority2 in sonorities2) {
          if ([self sonority:sonority1 is:kSubset ofSonority:sonority2]) {
            conditionSatisfied = YES;
          }
        }
        
        if (!conditionSatisfied) {
          returnValue = NO;
        }
      }
      
      return returnValue;
      break;
      
    case kEqual:
        // if counts aren't equal, return no right away
      if (sonorities1.count != sonorities2.count) {
        return NO;
      }
      
      returnValue = YES;
      
        // for every sonority in sonorities1,
        // there is a sonority in sonorities2 that is equal to it
      for (NSSet *sonority1 in sonorities1) {
        
        conditionSatisfied = NO;
        for (NSSet *sonority2 in sonorities2) {
          if ([self sonority:sonority1 is:kEqual ofSonority:sonority2]) {
            conditionSatisfied = YES;
          }
        }
        
        if (!conditionSatisfied) {
          returnValue = NO;
        }
      }
      
      return returnValue;
      break;
  }
  
  return NO;
}

-(NSSet *)legalChords:(NSSet *)legalChords1 thatExtendALegalChordInLegalChords:(NSSet *)legalChords2 {
  
  NSMutableSet *returnedLegalChords = [NSMutableSet new];
  
  for (NSSet *legalChord2 in legalChords2) {
    for (NSSet *legalChord1 in legalChords1) {
      
        // subset and not equal
      if ([self sonority:legalChord2 is:kSubset ofSonority:legalChord1] &&
          ![self sonority:legalChord2 is:kEqual ofSonority:legalChord1]) {
        
        [returnedLegalChords addObject:legalChord1];
      }
    }
  }
  return [NSSet setWithSet:returnedLegalChords];
}

-(NSSet *)legalChords:(NSSet *)legalChords1 thatAreCompletelyNotFoundInLegalChords:(NSSet *)legalChords2 {
  
  NSMutableSet *returnedLegalChords = [NSMutableSet new];
  
  for (NSSet *legalChord1 in legalChords1) {
    
    BOOL thereIsAnEqualOrSubsetLegalChord = NO;
    for (NSSet *legalChord2 in legalChords2) {
      if ([self sonority:legalChord1 is:kEqual ofSonority:legalChord2] ||
          [self sonority:legalChord2 is:kSubset ofSonority:legalChord1]) {
        thereIsAnEqualOrSubsetLegalChord = YES;
      }
    }
    
    if (!thereIsAnEqualOrSubsetLegalChord) {
      [returnedLegalChords addObject:legalChord1];
    }
  }
  return [NSSet setWithSet:returnedLegalChords];
}

-(NSSet *)legalChords:(NSSet *)legalChords1 thatAreEitherNewOrExtendingRelativeToLegalChords:(NSSet *)legalChords2 {
  NSSet *newLegalChords = [self legalChords:legalChords1 thatAreCompletelyNotFoundInLegalChords:legalChords2];
  NSSet *extendingLegalChords = [self legalChords:legalChords1 thatExtendALegalChordInLegalChords:legalChords2];
  NSMutableSet *tempReturnedSet = [NSMutableSet setWithSet:newLegalChords];
  [tempReturnedSet addObjectsFromArray:extendingLegalChords.allObjects];
  return [NSSet setWithSet:tempReturnedSet];
}

#pragma mark - chord logic methods

-(Chord)chordFromChordSonority:(NSSet *)sonority {
  
    // root is -1 if not a chord
  NSUInteger cardinality = [sonority count];
  
    // return if legal sonority
  if (cardinality == 0) {
    return [self chordFromRoot:-1 andChordType:kChordNoChord];
  } else if (cardinality == 1) {
    return [self chordFromRoot:-1 andChordType:kChordLegalMonad];
  } else if (cardinality == 2) {
    return [self chordFromRoot:-1 andChordType:kChordLegalDyad];
  } else if (cardinality > 4) {
    return [self chordFromRoot:-1 andChordType:kChordIllegalChord];
  }
  
    // puts in pc normal form
  NSMutableArray *pcNormalForm = [NSMutableArray arrayWithArray:sonority.allObjects];
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

-(Chord)chordFromSonorityPlusCheckIncompleteSeventh:(NSSet *)sonority {
  
  Chord chord = [self chordFromChordSonority:sonority];
  
  if (chord.chordType == kChordIllegalChord) {
    if ([self sonorityIsIncompleteSeventh:sonority]) {
      return [self chordFromRoot:-1 andChordType:kChordLegalIncompleteSeventh];
    }
  }
  return chord;
}

-(Chord)chordFromFakeRootPC:(NSNumber *)fakeRootPC andICPrimeForm:(NSArray *)icPrimeForm {
  
    // ensures that diminished triad is in right order
  if ([icPrimeForm isEqualToArray:@[@3, @6, @3]]) {
    fakeRootPC = @(([fakeRootPC unsignedIntegerValue] + 9) % 12);
    icPrimeForm = @[@3, @3, @6];
  }
  
  NSArray *legalICPrimeForms = @[@[@3, @4, @5], @[@3, @5, @4], @[@2, @3, @3, @4],
                                 @[@2, @3, @4, @3], @[@2, @4, @3, @3], @[@3, @3, @6],
                                 @[@4, @4, @4], @[@3, @3, @3, @3], @[@1, @3, @4, @4],
                                 @[@1, @4, @3, @4], @[@1, @4, @4, @3],
                                 @[@2, @4, @6], @[@2, @4, @2, @4]];
  
  NSArray *fakeRootOffsets = @[@0, @8, @2, @2, @2, @0, @0, @0, @1, @1, @1, @2, @2];

    // establish default
  ChordType chordType = kChordIllegalChord;
  NSInteger root = -1;
  
  for (NSArray *legalICPrimeForm in legalICPrimeForms) {
    if ([icPrimeForm isEqualToArray:legalICPrimeForm]) {
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

-(BOOL)sonorityIsIncompleteSeventh:(NSSet *)sonority {
  
    // cardinality must be 3
  if (sonority.count != 3) {
    return NO;
  }
  
    // sonority must be illegal as a triad
  Chord chordForSonority = [self chordFromChordSonority:sonority];
  if (chordForSonority.chordType != kChordIllegalChord) {
    return NO;
  }
  
  BOOL sonorityIsIncompleteSeventh = NO;
  
  for (NSUInteger i = 0; i < 12; i++) {
    NSNumber *missingNote = [NSNumber numberWithUnsignedInteger:i];
    if (![sonority containsObject:missingNote]) {
      NSMutableSet *tempSonority = [NSMutableSet setWithSet:sonority];
      [tempSonority addObject:missingNote];
      NSSet *newSonority = [NSSet setWithSet:tempSonority];
      Chord chordForNewSonority = [self chordFromChordSonority:newSonority];
      if (chordForNewSonority.chordType != kChordIllegalChord) {
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
    case kChordLegalIncompleteSeventh:
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
  
    // nonbreaking line space
  return [NSString stringWithFormat:@"%@\u00a0%@", rootString, [self stringForChordType:chordType]];
}

-(NSString *)stringForSonorities:(NSSet *)sonorities
               withInitialString:(NSString *)initialString
                 andEndingString:(NSString *)endingString {
  
//  NSMutableAttributedString *initialText = [[NSMutableAttributedString alloc] initWithString:initialString];
  
  NSSet *chords = [self chordSonoritiesForSonorities:sonorities];
  NSString *chordsText = [self stringForLegalChords:chords];
//  
//  NSAttributedString *attributedChordsText = [self stringWithAccidentals:chordsText fontSize:kChordMessageLabelFontSize];
  
//  NSMutableAttributedString *endingText = [[NSMutableAttributedString alloc] initWithString:endingString];
  
//  [initialText appendAttributedString:attributedChordsText];
//  [initialText appendAttributedString:endingText];
  
  return [NSString stringWithFormat:@"%@%@%@", initialString, chordsText, endingString];
}

-(NSString *)stringForLegalChords:(NSSet *)chords {
  
    // sort chords based on chord type
  NSMutableArray *tempDictionaryArray = [NSMutableArray new];
  for (NSSet *chordSonority in chords) {
    Chord chord = [self chordFromSonorityPlusCheckIncompleteSeventh:chordSonority];
    NSNumber *chordTypeNumber = @(chord.chordType);
    NSDictionary *chordDictionary = @{@"chordSonority":chordSonority, @"chordType":chordTypeNumber};
    [tempDictionaryArray addObject:chordDictionary];
  }
  NSArray *dictionaryArray = [NSArray arrayWithArray:tempDictionaryArray];
  NSSortDescriptor *chordTypeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"chordType" ascending:YES];
  NSArray *sortedArray = [dictionaryArray sortedArrayUsingDescriptors:@[chordTypeDescriptor]];
  
  NSMutableArray *tempStringArray = [NSMutableArray new];
  for (int i = 0; i < sortedArray.count; i++) {
    NSDictionary *chordDictionary = sortedArray[i];
    if ([chordDictionary[@"chordType"] unsignedIntegerValue] <= kChordFrenchSixth) {
      NSSet *chordSonority = chordDictionary[@"chordSonority"];
      Chord chord = [self chordFromSonorityPlusCheckIncompleteSeventh:chordSonority];
      NSString *string = [self stringForChord:chord];
      NSString *finalString;
      
        // _____
        // _____ and _____
        // _____, _____, and _____
      
        // last string in list
      if (i == 0 && sortedArray.count == 1) {
        finalString = string;
      } else if (i == 0 && sortedArray.count == 2) {
        finalString = [NSString stringWithFormat:@"%@ ", string];
      } else if ((i == sortedArray.count - 1) && sortedArray.count > 1) {
        finalString = [NSString stringWithFormat:@"and %@", string];
      } else {
        finalString = [NSString stringWithFormat:@"%@, ", string];
      }
      
      [tempStringArray addObject:finalString];
    }
  }
  
  NSMutableString *mutableString = [[NSMutableString alloc] initWithString:@""];
  for (int i = 0; i < tempStringArray.count; i++) {
    [mutableString appendString:tempStringArray[i]];
  }
  
  NSString *string = [NSString stringWithString:mutableString];
  
  return string;
}

#pragma mark - test methods

-(Chord)testChordFromSonorityPlusCheckIncompleteSeventh:(NSSet *)sonority {
  return [self chordFromSonorityPlusCheckIncompleteSeventh:(NSSet *)sonority];
}

-(NSString *)testStringForLegalChordSonoritiesWithSonorities:(NSSet *)sonorities {
  
  NSSet *chords = [self chordSonoritiesForSonorities:sonorities];
  return [self stringForLegalChords:chords];
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
