//
//  TestHelper.h
//  FulcrumReceiptApp
//
//  Created by Bennett Lin on 11/12/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSManagedObjectContext;

@interface TestHelper : NSObject

+(NSManagedObjectContext *)managedObjectContextForTests;

@end
