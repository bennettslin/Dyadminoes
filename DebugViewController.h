//
//  DebugViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Match;

@protocol DebugDelegate;

@interface DebugViewController : UIViewController

@property (strong, nonatomic) Match *myMatch;
@property (weak, nonatomic) id <DebugDelegate> delegate;

@end

@protocol DebugDelegate <NSObject>

  //

@end