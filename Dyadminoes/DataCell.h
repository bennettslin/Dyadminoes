//
//  DataCell.h
//  Dyadminoes
//
//  Created by Bennett Lin on 12/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Helper.h"

@interface DataCell : NSObject

@property (readonly, nonatomic) NSUInteger myPC;
@property (readonly, nonatomic) NSUInteger myDyadminoID;
@property (readonly, nonatomic) NSInteger hexX;
@property (readonly, nonatomic) NSInteger hexY;

-(instancetype)initWithPC:(NSUInteger)pc dyadminoID:(NSUInteger)dyadminoID hexCoord:(HexCoord)hexCoord;
-(BOOL)isOccupiedByDyadminoID:(NSInteger)dyadminoIndex;
-(HexCoord)hexCoord;

@end
