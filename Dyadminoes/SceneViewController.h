//
//  ViewController.h
//  Dyadminoes
//

//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
@class Match;
@class Player;

@interface SceneViewController : UIViewController

@property (strong, nonatomic) Match *myMatch;
@property (strong, nonatomic) Player *myPlayer;

@end
