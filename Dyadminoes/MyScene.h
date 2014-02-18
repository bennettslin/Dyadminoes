//
//  MyScene.h
//  Dyadminoes
//

//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol KnowledgeOfPileDelegate <NSObject>

-(NSMutableArray *)returnPlayer1Rack;

@end

@interface MyScene : SKScene

@property (weak, nonatomic) id<KnowledgeOfPileDelegate> delegate;

@end
