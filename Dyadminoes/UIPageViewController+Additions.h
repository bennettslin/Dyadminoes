//
//  UIPageViewController+Additions.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/7/15.
//  Copyright (c) 2015 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPageViewController (Additions)

-(void)setViewControllers:(NSArray *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction invalidateCache:(BOOL)invalidateCache animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end
