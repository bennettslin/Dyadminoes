//
//  Button.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/17/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"

@interface Button : SKSpriteNode

-(id)initWithName:(NSString *)name
         andColor:(UIColor *)color
          andSize:(CGSize)size
      andPosition:(CGPoint)position
     andZPosition:(CGFloat)zPosition;

-(void)changeName;
-(SwapCancelOrUndoButton)confirmSwapCancelOrUndo;
-(PassPlayOrDoneButton)confirmPassPlayOrDone;

@end
