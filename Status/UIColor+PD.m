//
//  UIColor+PD.m
//  Inspect
//
//  Created by Paul Denya on 11/21/12.
//
//

#import "UIColor+PD.h"

@implementation UIColor (PD)

+ (UIColor *)colorWithHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
	
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

+ (UIColor *)brandBlueColor {
	return [UIColor colorWithHex:0x105FA0];
}

@end
