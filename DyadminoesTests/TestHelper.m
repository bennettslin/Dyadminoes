//
//  TestHelper.m
//  FulcrumReceiptApp
//
//  Created by Bennett Lin on 11/12/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TestHelper.h"

@implementation TestHelper

+(NSManagedObjectContext *)managedObjectContextForTests {
  
    // retrieve model
  static NSManagedObjectModel *model = nil;
  if (!model) {
    model = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
  }
  
    // create mock coordinator and store
  NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
  [coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
  
  NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
  context.persistentStoreCoordinator = coordinator;
  
  return context;
}

@end
