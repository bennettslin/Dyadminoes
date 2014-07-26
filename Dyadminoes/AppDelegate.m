//
//  AppDelegate.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "AppDelegate.h"
#import <SpriteKit/SpriteKit.h>

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSLog(@"application did finish launching with options");
  
  self.myAtlas = [SKTextureAtlas atlasNamed:@"DyadminoImages"];
  [self.myAtlas preloadWithCompletionHandler:^{
//    NSLog(@"texture atlas loaded");
  }];
  
  UIPageControl *pageControl = [UIPageControl appearance];
  pageControl.pageIndicatorTintColor = [UIColor yellowColor];
  pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
  pageControl.backgroundColor = [UIColor orangeColor];
  return YES;
}
							
-(void)applicationWillResignActive:(UIApplication *)application {
  NSLog(@"application will resign active");
  
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
  NSLog(@"application did enter background");
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
  NSLog(@"application will enter foreground");
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
  NSLog(@"application did become active");
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

-(void)applicationWillTerminate:(UIApplication *)application {
  NSLog(@"application will terminate");
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
