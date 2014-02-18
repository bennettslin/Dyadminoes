//
//  SonorityLogic.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SonorityLogic : NSObject

@property (strong, nonatomic) NSArray *icPrimeForm;

@property BOOL legalChord;
@property (strong, nonatomic) NSString *rootPCLetter;
@property (strong, nonatomic) NSString *chordType;

-(id)initWithPCs:(NSArray *)pcs;

@end