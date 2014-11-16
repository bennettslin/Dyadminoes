//
//  SoloViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 7/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocalGameDelegate <NSObject>

-(void)startLocalGameWithPlayerNames:(NSArray *)playerNames;
-(void)disableOverlay;
-(void)enableOverlay;

@end

@interface LocalGameViewController : UIViewController

@property (weak, nonatomic) id<LocalGameDelegate> delegate;

-(void)resignTextField:(UITextField *)textField;

@end
