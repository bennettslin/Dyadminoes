//
//  StavesView.m
//  Dyadminoes
//
//  Created by Bennett Lin on 7/23/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "StavesView.h"
#import "NSObject+Helper.h"

@implementation StavesView

-(id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

  // draws staves
-(void)drawRect:(CGRect)rect {
  
  [super drawRect:rect];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  for (int i = 0; i < 5; i++) {
    CGContextSetStrokeColorWithColor(context, [[UIColor brownColor] colorWithAlphaComponent:0.7f].CGColor);
    CGContextSetLineWidth(context, 0.5f);
    
    CGFloat yPosition = kStaveYHeight * (i + 3);
    CGContextMoveToPoint(context, kStaveXBuffer, yPosition); //start at this point
    CGContextAddLineToPoint(context, kCellWidth - kStaveXBuffer, yPosition); //draw to this point
    
      // and now draw the Path!
    CGContextStrokePath(context);
  }
}

@end
