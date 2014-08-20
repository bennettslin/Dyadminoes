//
//  NSObject+Helper.m
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "NSObject+Helper.h"
#import "Dyadmino.h"

@implementation NSObject (Helper)

#pragma mark - math methods

-(NSUInteger)randomIntegerUpTo:(NSUInteger)high {
  NSUInteger randInteger = ((int) arc4random() % high);
  return randInteger;
}

-(CGFloat)randomFloatUpTo:(CGFloat)high {
  CGFloat randFloat = arc4random() * high;
  return randFloat;
}

-(CGFloat)getDistanceFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2 {
  CGFloat xDistance = point1.x - point2.x;
  CGFloat yDistance = point1.y - point2.y;
  CGFloat distance = sqrtf((xDistance * xDistance) + (yDistance * yDistance));
  return distance;
}

-(CGPoint)addToThisPoint:(CGPoint)point1 thisPoint:(CGPoint)point2 {
  return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

-(CGPoint)subtractFromThisPoint:(CGPoint)point1 thisPoint:(CGPoint)point2 {
  return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

-(CGFloat)findAngleInDegreesFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2 {
  CGFloat angleDegrees = atan2f(point2.y - point1.y, point2.x - point1.x) * 180.f / M_PI + 180.f;
//  NSLog(@"angle is %f", angleDegrees);
  return angleDegrees;
}

-(CGFloat)getChangeFromThisAngle:(CGFloat)angle1 toThisAngle:(CGFloat)angle2 {
  CGFloat angle = 0.5f - ((angle1 - angle2) / 60);
  if (angle < 0.f) {
    angle += 12.f;
  }
  return angle;
}

-(CGFloat)getRadiansFromDegree:(CGFloat)degree {
  return (M_PI * degree) / 180;
}

-(HexCoord)hexCoordFromX:(NSInteger)x andY:(NSInteger)y {
  HexCoord newHexCoord;
  newHexCoord.x = x;
  newHexCoord.y = y;
  return newHexCoord;
}

#pragma mark - date stuff

-(NSString *)returnGameEndedDateStringFromDate:(NSDate *)date andTurn:(NSUInteger)turn {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  return [NSString stringWithFormat:@"Game ended %@.", [dateFormatter stringFromDate:date]];
}

-(NSString *)returnLastPlayedStringFromDate:(NSDate *)date andTurn:(NSUInteger)turn {
  NSDate *startDate = date;
  NSDate *endDate = [NSDate date];
  
  NSCalendar *gregorian = [[NSCalendar alloc]
                           initWithCalendarIdentifier:NSGregorianCalendar];
  
  NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit |
      NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
  
  NSDateComponents *components = [gregorian components:unitFlags
                                              fromDate:startDate
                                                toDate:endDate options:0];
  NSInteger years = [components year];
  NSInteger months = [components month];
//  NSInteger weeks = [components weekOfYear];
  NSInteger days = [components day];
  NSInteger hours = [components hour];
  NSInteger minutes = [components minute];
  
//  NSLog(@"years %i, months %i, weeks %i, days %i, hours %i", years, months, weeks, days, hours);
  
  NSInteger componentQuantity = 0;
  NSString *dateComponent;
  
  if (years > 0) {
    componentQuantity = years;
    dateComponent = years > 1 ? @"years" : @"year";
  } else if (months > 0) {
    componentQuantity = months;
    dateComponent = months > 1 ? @"months" : @"month";
  } else if (days / 7 > 0) { // workaround for weeks
    componentQuantity = days / 7;
    dateComponent = (days / 7) > 1 ? @"weeks" : @"week";
//  } else if (weeks > 0) {
//    componentQuantity = weeks;
//    dateComponent = weeks > 1 ? @"weeks" : @"week";
  } else if (days > 0) {
    componentQuantity = days;
    dateComponent = days > 1 ? @"days" : @"day";
  } else if (hours > 0) {
    componentQuantity = hours;
    dateComponent = hours > 1 ? @"hours" : @"hour";
  } else if (minutes > 0) {
    dateComponent = minutes > 1 ? @"minutes" : @"a minute";
  } else {
    dateComponent = @"seconds";
  }
  
  if (componentQuantity > 0) {
    NSString *componentString = [self wordForNumber:componentQuantity];
    dateComponent = [NSString stringWithFormat:@"%@ %@", componentString, dateComponent];
  }
  
  return (turn == 0) ?
      [NSString stringWithFormat:@"Started %@ ago.", dateComponent] :
      [NSString stringWithFormat:@"Turn %i played %@ ago.", turn, dateComponent];
}

-(NSString *)wordForNumber:(NSUInteger)number {
  NSArray *numberArray = @[@"zero", @"one", @"two", @"three", @"four",
                           @"five", @"six", @"seven", @"eight", @"nine",
                           @"ten", @"eleven", @"twelve", @"thirteen", @"fourteen",
                           @"fifteen", @"sixteen", @"seventeen", @"eighteen", @"nineteen",
                           @"twenty", @"twenty-one", @"twenty-two", @"twenty-three", @"twenty-four"];
  return numberArray[number];
}

#pragma mark - view stuff

-(void)addGradientToView:(UIView *)thisView WithColour:(UIColor *)colour andUpsideDown:(BOOL)upsideDown {
  
  CGFloat redValue, greenValue, blueValue, alpha;
  [colour getRed:&redValue green:&greenValue blue:&blueValue alpha:&alpha];
  
  CGFloat gradientRed;
  CGFloat gradientGreen;
  CGFloat gradientBlue;
  UIColor *topGradient;
  UIColor *bottomGradient;
  
    // no colour gradient lightens up, colour gradient darkens up

    gradientRed = redValue + ((1.f - redValue) / 5.f);
    gradientGreen = greenValue + ((1.f - greenValue) / 5.f);
    gradientBlue = blueValue + ((1.f - blueValue) / 5.f);

  if (!upsideDown) {
    topGradient = [UIColor colorWithRed:gradientRed green:gradientGreen blue:gradientBlue alpha:1.f];
    bottomGradient = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1.f];
  } else {
    topGradient = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1.f];
    bottomGradient = [UIColor colorWithRed:gradientRed green:gradientGreen blue:gradientBlue alpha:1.f];
  }

  
  CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  gradientLayer.frame = thisView.layer.bounds;
  gradientLayer.colors = @[(id)topGradient.CGColor, (id)bottomGradient.CGColor];
  gradientLayer.locations = @[@0.f, @1.f];
  
  [thisView.layer addSublayer:gradientLayer];
  gradientLayer.zPosition = -1;
}

-(void)addShadowToView:(UIView *)thisView upsideDown:(BOOL)upsideDown {
  thisView.layer.shadowColor = [UIColor blackColor].CGColor;
  thisView.layer.shadowOffset = CGSizeMake(0, upsideDown ? -10.f : 10.f);
  thisView.layer.shadowOpacity = .35f;
}

-(NSString *)stringForMusicSymbol:(MusicSymbol)symbol {
  NSUInteger charIndex = 0;

  switch (symbol) {
    case kSymbolTrebleClef:
      charIndex = 38;
      break;
    case kSymbolAltoClef:
      charIndex = 66;
      break;
    case kSymbolTenorClef:
      charIndex = 66;
      break;
    case kSymbolBassClef:
      charIndex = 63;
      break;
    case kSymbolFermata:
      charIndex = 85;
      break;
    case kSymbolEndBarline:
      charIndex = 211;
      break;
    case kSymbolQuarterRest:
      charIndex = 206;
      break;
    case kSymbolHalfRest:
      charIndex = 238;
      break;
    case kSymbolFlat:
      charIndex = 98;
      break;
    case kSymbolSharp:
      charIndex = 35;
      break;
    case kSymbolBullet:
      charIndex = 183;
      break;
  }
  unichar myChar[1] = {(unichar)charIndex};
  return [NSString stringWithCharacters:myChar length:1];
}

-(MusicSymbol)musicSymbolForMatchType:(GameType)type {
  switch (type) {
    case kSelfGame:
      return kSymbolTrebleClef;
      break;
    case kPnPGame:
      return kSymbolAltoClef;
      break;
    case kGCFriendGame:
      return kSymbolTenorClef;
      break;
    case kGCRandomGame:
      return kSymbolBassClef;
      break;
    default:
      return -1;
      break;
  }
}

#pragma mark - chord label methods

-(NSString *)stringForChord:(ChordType)chordType {
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
      return nil;
      break;
  }
}

-(NSString *)stringForRoot:(NSUInteger)root andChordType:(ChordType)chordType {
  if (chordType == kChordFullyDiminishedSeventh) {
    switch (root) {
      case 0:
      case 3:
      case 6:
      case 9:
        return @"C-D\u266f/E\u266d-F\u266f/G\u266d-A";
        break;
      case 1:
      case 4:
      case 7:
      case 10:
        return @"C\u266f/D\u266d-E-G-A\u266f/B\u266d";
        break;
      case 2:
      case 5:
      case 8:
      case 11:
        return @"D-F-G\u266f/A\u266d-B";
        break;
    }
    
  } else if (chordType == kChordAugmentedTriad) {
    switch (root) {
      case 0:
      case 4:
      case 8:
        return @"C-E-G\u266f/A\u266d";
        break;
      case 1:
      case 5:
      case 9:
        return @"C\u266f/D\u266d-F-A";
        break;
      case 2:
      case 6:
      case 10:
        return @"D-F\u266f/G\u266d-A\u266f/B\u266d";
        break;
      case 3:
      case 7:
      case 11:
        return @"D\u266f/E\u266d-G-B";
        break;
    }
    
  } else if (chordType == kChordFrenchSixth) {
    switch (root) {
      case 0:
      case 6:
        return @"C-F\u266f/G\u266d";
        break;
      case 1:
      case 7:
        return @"C\u266f/D\u266d-G";
        break;
      case 2:
      case 8:
        return @"D-G\u266f/A\u266d";
        break;
      case 3:
      case 9:
        return @"D\u266f/E\u266d-A";
        break;
      case 4:
      case 10:
        return @"E-A\u266f/B\u266d";
        break;
      case 5:
      case 11:
        return @"F-B";
        break;
    }
  } else if (chordType != kChordNoChord) {
    switch (root) {
      case 0:
        return @"C";
        break;
      case 1:
        return @"C\u266f/D\u266d";
        break;
      case 2:
        return @"D";
        break;
      case 3:
        return @"D\u266f/E\u266d";
        break;
      case 4:
        return @"E";
        break;
      case 5:
        return @"F";
        break;
      case 6:
        return @"F\u266f/G\u266d";
        break;
      case 7:
        return @"G";
        break;
      case 8:
        return @"G\u266f/A\u266d";
        break;
      case 9:
        return @"A";
        break;
      case 10:
        return @"A\u266f/B\u266d";
        break;
      case 11:
        return @"B";
        break;
    }
  }
  return nil;
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
      
    } else if (myChar == (unichar)45) { // hyphen turns into bullet
      [attString replaceCharactersInRange:NSMakeRange(i, 1) withString:[self stringForMusicSymbol:kSymbolBullet]];
      [attString addAttribute:NSKernAttributeName value:@(-size * .05) range:NSMakeRange(i, 1)];
    }
  }
  
  return attString;
}

@end
