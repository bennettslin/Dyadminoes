//
//  DyadminoesTests.m
//  DyadminoesTests
//
//  Created by Bennett Lin on 1/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SceneEngine.h"

@interface DyadminoesTests : XCTestCase

@end

@implementation DyadminoesTests

-(void)setUp {
  [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

-(void)testPileCountAfterInstantiation {
  SceneEngine *pile = [[SceneEngine alloc] init];
  XCTAssertTrue([pile.allDyadminoes count] == 66, @"Pile count should be 66");
}

@end
