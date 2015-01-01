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

-(Chord)chordFromRoot:(NSInteger)root andChordType:(ChordType)chordType {
  Chord newChord;
  newChord.root = root;
  newChord.chordType = chordType;
  return newChord;
}

#pragma mark - dyadmino rack stuff

-(Dyadmino *)dyadminoInSet:(NSSet *)set withRackOrder:(NSUInteger)rackOrder {
  Dyadmino *returnedDyadmino;
  for (Dyadmino *dyadmino in set) {
    if (dyadmino.myRackOrder == rackOrder) {
      returnedDyadmino = dyadmino;
    }
  }
  return returnedDyadmino;
}

-(BOOL)validateUniqueRackOrdersInSet:(NSSet *)set {
  NSMutableSet *tempSet = [NSMutableSet new];
  
  for (Dyadmino *dyadmino in set) {
    if (dyadmino.myRackOrder >= set.count) {
      return NO;
    } else {
      [tempSet addObject:@(dyadmino.myRackOrder)];
    }
  }
  return (tempSet.count == set.count);
}

#pragma mark - date stuff

-(NSString *)returnGameEndedDateStringFromDate:(NSDate *)date {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  return [NSString stringWithFormat:@"Game ended %@.", [dateFormatter stringFromDate:date]];
}

-(NSString *)returnLastPlayedStringFromDate:(NSDate *)date andTurn:(NSUInteger)turn {
  NSDate *startDate = date;
  NSDate *endDate = [NSDate date];
  
  NSCalendar *gregorian = [[NSCalendar alloc]
                           initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  
  NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear |
      NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
  
  NSDateComponents *components = [gregorian components:unitFlags
                                              fromDate:startDate
                                                toDate:endDate options:0];
  NSInteger years = [components year];
  NSInteger months = [components month];
  NSInteger weeks = [components weekOfYear];
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
  } else if (weeks > 0) {
    componentQuantity = weeks;
    dateComponent = weeks > 1 ? @"weeks" : @"week";
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
      [NSString stringWithFormat:@"Turn %lu played %@ ago.", (unsigned long)turn, dateComponent];
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

@end
