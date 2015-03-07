//
//  ChildViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 12/26/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+Helper.h"

#define kChildVCButtonSize (kIsIPhone ? 44.f : 80.f)

#define kCancelButtonEdge 48.f
#define kChildVCTopMargin (kCancelButtonEdge * 2.f)
#define kChildVCSideMargin (kChildVCTopMargin * 0.5f)
#define kChildVCBottomMargin (kChildVCTopMargin * 0.75f)

@protocol ChildViewControllerDelegate <NSObject>

-(void)backToParentViewWithAnimateRemoveVC:(BOOL)animateRemoveVC;

@end

@interface ChildViewController : UIViewController

@property (assign, nonatomic) StartingQuadrant startingQuadrant;
@property (weak, nonatomic) id<ChildViewControllerDelegate> parentDelegate;

-(void)positionCancelButtonBasedOnWidth:(CGFloat)width;
-(void)fadeTitleLabel;
-(void)centreTitleLabelWithText:(NSString *)text colour:(UIColor *)colour textAnimation:(BOOL)animate;

@end
