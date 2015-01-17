//
//  NSObjectTests.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/12/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+Helper.h"

@interface NSObjectTests : XCTestCase

@property (strong, nonatomic) NSObject *myObject;

@end

@implementation NSObjectTests

-(void)setUp {
  [super setUp];
  
  self.myObject = [NSObject new];
}

-(void)tearDown {
  
  self.myObject = nil;
  [super tearDown];
}

-(void)testCorrectGameEndedText {
  NSString *gameEndedString = [self.myObject returnGameEndedDateStringFromDate:[NSDate date]];
  NSArray *gameEndedArray = [gameEndedString componentsSeparatedByString:@" "];
  
  BOOL correctGameEndedText = [gameEndedArray[0] isEqualToString:@"Game"] && [gameEndedArray[1] isEqualToString:@"ended"];
  XCTAssertTrue(correctGameEndedText, @"Game ended text is incorrect.");
}

-(void)testCorrectGameEndedDate {

    // test for next five years
  for (int year = 2015; year < 2020; year++) {
    for (int month = 1; month <= 12; month++) {
      for (int day = 1; day <= (month == 2 ? 28 : 30); day++) { // just test 30 days for each month other than February
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:day];
        [components setMonth:month];
        [components setYear:year];
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components];
        NSString *returnString = [self.myObject returnGameEndedDateStringFromDate:date];
        NSArray *stringComponents = [returnString componentsSeparatedByString:@" "];
        
          // get date at end
        NSString *dateString = [stringComponents lastObject];
        
          // remove period at end
        dateString = [dateString substringToIndex:dateString.length - 1];
        
        NSArray *dateStringComponents = [dateString componentsSeparatedByString:@"/"];
        
        NSString *dayString = (NSString *)dateStringComponents[1];
        NSString *monthString = (NSString *)dateStringComponents[0];
        NSString *yearString = (NSString *)dateStringComponents[2];;

        XCTAssertEqual([monthString integerValue], month, @"Month is not correct for game ended string.");
        XCTAssertEqual([dayString integerValue], day, @"Day is not correct for game ended string.");
        XCTAssertEqual([yearString integerValue], year % 2000, @"Year is not correct for game ended string.");
      }
    }
  }
}

-(void)testCorrectLastPlayedDateText {
  
  NSString *justStartedString = [self.myObject returnLastPlayedStringFromDate:[NSDate date] andTurn:0];
  NSArray *justStartedArray = [justStartedString componentsSeparatedByString:@" "];
  
  BOOL correctJustStartedString = [justStartedArray[0] isEqualToString:@"Started"] && [justStartedArray[2] isEqualToString:@"ago."];
  XCTAssertTrue(correctJustStartedString, @"Last played text is incorrect for turn 0.");
  
  NSString *lastPlayedString = [self.myObject returnLastPlayedStringFromDate:[NSDate date] andTurn:1];
  NSArray *lastPlayedArray = [lastPlayedString componentsSeparatedByString:@" "];
  
  BOOL correctLastPlayedText = [lastPlayedArray[0] isEqualToString:@"Turn"] &&
                                 [lastPlayedArray[2] isEqualToString:@"played"] &&
                                 [lastPlayedArray[4] isEqualToString:@"ago."];
  XCTAssertTrue(correctLastPlayedText, @"Last played text is incorrect for all other turns.");
}

-(void)testCorrectLastPlayedDateComponents {

    // test once for half, whole, double
  NSArray *minuteNumbers = @[@0, @1, @2, // minutes
                             @30, @60, @120, // hours
                             @720, @1440, @2880, // days
                             @5040, @10080, @20160, // weeks
                             @22320, @44640, @89280, // months
                             @262980, @525960, @1051920]; // years
  
  NSArray *returnedText = @[@"seconds", @"minute", @"minutes",
                            @"minutes", @"hour", @"hours",
                            @"hours", @"day", @"days",
                            @"days", @"week", @"weeks",
                            @"weeks", @"month", @"months",
                            @"months", @"year", @"years"];
  
  NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
  
  for (int i = 0; i < minuteNumbers.count; i++) { // was 1051200
      // Get the components of the current date
    
      // Create last played date
    NSDateComponents *lastPlayedComponents = [[NSDateComponents alloc] init];
    lastPlayedComponents.minute = -[minuteNumbers[i] unsignedIntegerValue];
    
    NSDate *pastDate = [calendar dateByAddingComponents:lastPlayedComponents toDate:[NSDate date] options:0];
    NSString *lastPlayedString = [self.myObject returnLastPlayedStringFromDate:pastDate andTurn:1];
    NSArray *lastPlayedArray = [lastPlayedString componentsSeparatedByString:@" "];

    NSString *lastPlayedDate;
    switch (i) {
      case 0:
      case 2:
      case 3:
        lastPlayedDate = lastPlayedArray[3];
        break;
      default:
        lastPlayedDate = lastPlayedArray[4];
        break;
    }
    
    XCTAssertEqualObjects(lastPlayedDate, returnedText[i], @"Expected last played date text to be %@, was %@", lastPlayedDate, returnedText[i]);
  }
}

#pragma mark - hex coordinate methods

-(void)testDistanceBasedOnHexXAndHexYMethod {
  XCTFail();
}

#pragma mark - cell helper methods

-(void)testTopHexCellForBottomHexCellMethod {

  const int radius = 5;
  for (int x = -radius; x <= radius; x++ ) {
    for (int y = -radius; y <= radius; y++) {
      for (DyadminoOrientation orientation = kPC1atTwelveOClock; orientation <= kPC1atTenOClock; orientation++) {

        HexCoord bottomHexCoord = [self.myObject hexCoordFromX:x andY:y];
        HexCoord returnedTopHexCoord = [self.myObject retrieveTopHexCoordForBottomHexCoord:bottomHexCoord
                                                                            andOrientation:orientation];
        
        HexCoord expectedTopHexCoord;
        switch (orientation) {
          case kPC1atTwelveOClock:
          case kPC1atSixOClock:
            expectedTopHexCoord = [self.myObject hexCoordFromX:x andY:y + 1];
            break;
          case kPC1atTwoOClock:
          case kPC1atEightOClock:
            expectedTopHexCoord = [self.myObject hexCoordFromX:x + 1 andY:y];
            break;
          case kPC1atFourOClock:
          case kPC1atTenOClock:
            expectedTopHexCoord = [self.myObject hexCoordFromX:x - 1 andY:y + 1];
            break;
        }
        
        BOOL returnedAsExpected = (returnedTopHexCoord.x == expectedTopHexCoord.x &&
                                   returnedTopHexCoord.y == expectedTopHexCoord.y);        
        XCTAssertTrue(returnedAsExpected, @"Did not return expected top hex coord for bottom hex coord.");
      }
    }
  }
}

#pragma mark - dyadmino helper methods

-(void)testPCsForIndexMethod {
  
  NSUInteger index = 0;
  for (int pc1 = 0; pc1 < 12; pc1++) {
    for (int pc2 = pc1 + 1; pc2 < 12; pc2++) {
      if (pc1 < pc2) {
        XCTAssertEqual(pc1, [self.myObject pcForDyadminoIndex:index isPC1:YES], @"Incorrect pc1 for dyadmino index %lu", (unsigned long)index);
        XCTAssertEqual(pc2, [self.myObject pcForDyadminoIndex:index isPC1:NO], @"Incorrect pc2 for dyadmino index %lu", (unsigned long)index);
        index++;
      }
    }
  }
  
  XCTAssertEqual(index, kPileCount, @"Index was not equal to pile count.");
}

@end
