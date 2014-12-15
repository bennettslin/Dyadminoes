//
//  SonorityLogic+Helper.h
//  Dyadminoes
//
//  Created by Bennett Lin on 12/14/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SonorityLogic.h"

@interface SonorityLogic (Helper)

-(BOOL)validateSonorityDoesNotExceedMaximum:(NSSet *)sonority;
-(BOOL)validateSonorityHasNoDoublePCs:(NSSet *)sonority;

@end
