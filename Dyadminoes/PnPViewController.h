//
//  PnPViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 5/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PnPDelegate <NSObject>

-(void)startPnPGame;

@end

@interface PnPViewController : UIViewController

@property (weak, nonatomic) id<PnPDelegate> delegate;

@end