//
//  Dyadmino.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dyadmino : NSObject

@property NSUInteger pc1;
@property NSUInteger pc2;
@property NSUInteger rackOrientation;

-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andOrientation:(NSUInteger)orientation;

@end
