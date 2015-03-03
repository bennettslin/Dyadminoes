//
//  Button.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/17/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"

@protocol ButtonDelegate;

@interface Button : SKSpriteNode

@property (weak, nonatomic) id<ButtonDelegate> delegate;

-(id)initWithName:(NSString *)name
         andColor:(UIColor *)color
          andSize:(CGSize)size
      andPosition:(CGPoint)position
     andZPosition:(CGFloat)zPosition;

-(void)changeName;
-(SwapCancelOrUndoButton)confirmSwapCancelOrUndo;
-(PassPlayOrDoneButton)confirmPassPlayOrDone;

-(BOOL)isEnabled;
-(void)enable:(BOOL)isEnabled;

@end

@protocol ButtonDelegate <NSObject>

-(void)postSoundNotification:(NotificationName)whichNotification;
-(void)handleButtonPressed:(Button *)button;

  // return to games
-(void)goBackToMainViewController;

@end
