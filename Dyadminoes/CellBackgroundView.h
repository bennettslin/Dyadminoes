//
//  BackgroundView.h
//  Dyadminoes
//
//  Created by Bennett Lin on 7/21/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellBackgroundView : UIView

  // kludge way to ensure that view isn't made transparent
  // when table view cell is selected
@property (nonatomic) BOOL backgroundColourCanBeChanged;

@end
