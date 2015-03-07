//
//  SoloViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 7/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChildViewController.h"

@protocol LocalGameDelegate <NSObject>

-(void)startSelfOrPnPGameWithPlayerNames:(NSArray *)playerNames;
-(void)disableOverlay;
-(void)enableOverlay;

@end

@interface LocalGameViewController : ChildViewController

@property (weak, nonatomic) id<LocalGameDelegate> delegate;

  // parent needs this method when overlay is tapped with keyboard up
-(UITextField *)checkTextFieldFirstResponder;
-(void)resignTextField:(UITextField *)textField;

@end
