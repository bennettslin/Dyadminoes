//
//  GameEndedViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 8/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChildViewController.h"

@protocol GameEndedDelegate <NSObject>

-(NSString *)endGameResultsText;

@end

@interface GameEndedViewController : ChildViewController

@property (weak, nonatomic) id<GameEndedDelegate> delegate;

@end
