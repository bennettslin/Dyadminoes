//
//  Button.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/17/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"

@protocol ReturnToGamesButtonDelegate;

@interface Button : SKSpriteNode

@property (weak, nonatomic) id<ReturnToGamesButtonDelegate> delegate;

-(id)initWithName:(NSString *)name
         andColor:(UIColor *)color
          andSize:(CGSize)size
      andPosition:(CGPoint)position
     andZPosition:(CGFloat)zPosition;

-(void)changeName;
-(SwapCancelOrUndoButton)confirmSwapCancelOrUndo;
-(PassPlayOrDoneButton)confirmPassPlayOrDone;
-(void)sinkInWithAnimation:(BOOL)animation;
-(void)liftWithAnimation:(BOOL)animation andCompletion:(void (^)(void))completion;

-(BOOL)isEnabled;
-(void)enable:(BOOL)isEnabled;

@end

@protocol ReturnToGamesButtonDelegate <NSObject>

-(void)goBackToMainViewController;

@end
