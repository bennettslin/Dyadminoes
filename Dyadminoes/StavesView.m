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
  CGFloat lineWidth = 0.5f;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  for (int i = 0; i < 5; i++) {
    CGContextSetStrokeColorWithColor(context, [[UIColor brownColor] colorWithAlphaComponent:0.7f].CGColor);
    CGContextSetLineWidth(context, lineWidth);
    
    CGFloat yPosition = kStaveYHeight * (i + 3);
    CGContextMoveToPoint(context, kStaveXBuffer, yPosition); //start at this point
    
    CGFloat endXPoint = self.gameHasEnded ? kCellWidth - kStaveXBuffer - kStaveYHeight / 2 : kCellWidth - kStaveXBuffer;
    
    CGContextAddLineToPoint(context, endXPoint, yPosition); //draw to this point
    
      // and now draw the Path!
    CGContextStrokePath(context);
  }
  
    // filled rectangle of end symbol
  if (self.gameHasEnded) {
    
    CGContextRef endLineContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(endLineContext, lineWidth * 2);
    CGContextMoveToPoint(endLineContext, kCellWidth - kStaveXBuffer - kStaveYHeight * 0.9, kStaveYHeight * 3);
    CGContextAddLineToPoint(endLineContext, kCellWidth - kStaveXBuffer - kStaveYHeight * 0.9, kStaveYHeight * 7);
    CGContextStrokePath(endLineContext);
    
    CGContextRef endBoxContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(endBoxContext, [[UIColor brownColor] colorWithAlphaComponent:0.7f].CGColor);
    CGRect endRect = CGRectMake(kCellWidth - kStaveXBuffer - kStaveYHeight / 2, kStaveYHeight * 3 - lineWidth, kStaveYHeight / 2, kStaveYHeight * 4 + (lineWidth * 2));
    CGContextFillRect(endBoxContext, endRect);
  }
}

@end
