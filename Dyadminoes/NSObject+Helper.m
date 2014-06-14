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

-(NSString *)returnGameEndedDateStringFromDate:(NSDate *)date {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//  [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
  return [NSString stringWithFormat:@"Game ended %@.", [dateFormatter stringFromDate:date]];
}

-(NSString *)returnLastPlayedStringFromDate:(NSDate *)date {
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
  NSInteger weeks = [components week];
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
    dateComponent = [NSString stringWithFormat:@"%i %@", componentQuantity, dateComponent];
  }
  
  return [NSString stringWithFormat:@"Last played %@ ago.", dateComponent];
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

    gradientRed = redValue + ((1.f - redValue) / 3.f);
    gradientGreen = greenValue + ((1.f - greenValue) / 3.f);
    gradientBlue = blueValue + ((1.f - blueValue) / 3.f);

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

@end
