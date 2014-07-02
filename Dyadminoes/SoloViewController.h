//
//  SoloViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 7/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SoloDelegate <NSObject>

-(void)startSoloGame;

@end

@interface SoloViewController : UIViewController

@property (weak, nonatomic) id<SoloDelegate> delegate;

@end
