//
//  UIImage+PD.h
//  Status
//
//  Created by Paul on 9/4/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PD)

- (UIImage *)resizeImageToHeight:(CGFloat)newHeight;

// by allen brunson  march 29 2009 - http://www.platinumball.net/blog/2010/01/31/iphone-uiimage-rotation-and-scaling/
// rotate UIImage to any angle
-(UIImage*)rotate:(UIImageOrientation)orient;

// rotate and scale image from iphone camera
-(UIImage*)rotateAndScaleFromCameraWithMaxSize:(CGFloat)maxSize;

// scale this image to a given maximum width and height
-(UIImage*)scaleWithMaxSize:(CGFloat)maxSize;
-(UIImage*)scaleWithMaxSize:(CGFloat)maxSize
					quality:(CGInterpolationQuality)quality;



@end
