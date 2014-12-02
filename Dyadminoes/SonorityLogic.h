//
//  SonorityLogic.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Helper.h"

@interface SonorityLogic : NSObject

-(Chord)chordFromSonority:(NSArray *)sonority;
+(id)sharedLogic;

  // chord label stuff
-(NSString *)stringForChord:(Chord)chord;
-(NSAttributedString *)stringWithAccidentals:(NSString *)myString fontSize:(CGFloat)size;

@end