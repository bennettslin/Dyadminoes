//
//  UIImage+colouredImage.m
//  Dyadminoes
//
//  Created by Bennett Lin on 8/3/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "UIImage+colouredImage.h"

@implementation UIImage (colouredImage)

+(UIImage *)colourImage:(UIImage *)image withColor:(UIColor *)color {
  
    // begin a new image context, to draw our colored image onto
  UIGraphicsBeginImageContext(image.size);
  
    // get a reference to that context we created
  CGContextRef context = UIGraphicsGetCurrentContext();
  
    // set the fill color
  [color setFill];
  
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
  CGContextTranslateCTM(context, 0, image.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  
    // set the blend mode to color burn, and the original image
  CGContextSetBlendMode(context, kCGBlendModeLighten); // assuming originals are black
  CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
  CGContextDrawImage(context, rect, image.CGImage);
  
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
  CGContextClipToMask(context, rect, image.CGImage);
  CGContextAddRect(context, rect);
  CGContextDrawPath(context,kCGPathFill);
  
    // generate a new UIImage from the graphics context we drew onto
  UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
    //return the color-burned image
  return coloredImage;
}

@end
