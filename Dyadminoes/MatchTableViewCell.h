//
//  MatchTableViewCell.h
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Match;

@protocol MatchCellDelegate;

@interface MatchTableViewCell : UITableViewCell

@property (strong, nonatomic) Match *myMatch;
@property (weak, nonatomic) id <MatchCellDelegate> delegate;

-(void)setProperties;

@end

@protocol MatchCellDelegate <NSObject>

@end