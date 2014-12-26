//
//  ChildViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 12/26/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChildViewControllerDelegate <NSObject>

-(void)backToParentViewWithAnimateRemoveVC:(BOOL)animateRemoveVC;

@end

@interface ChildViewController : UIViewController

@property (weak, nonatomic) id<ChildViewControllerDelegate> parentDelegate;

-(void)positionCancelButtonBasedOnWidth:(CGFloat)width;

@end
