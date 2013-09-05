//
//  UIImage+PD.m
//  Status
//
//  Created by Paul on 9/4/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "UIImage+PD.h"

@implementation UIImage (PD)

// http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/
- (UIImage *)resizeImageToHeight:(CGFloat)newHeight {
    UIImage *image = self;
    CGSize newSize = CGSizeMake(((image.size.width / image.size.height) * newHeight), newHeight);
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
