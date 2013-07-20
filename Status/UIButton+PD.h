//
//  UIButton+PD.h
//  Status
//
//  Created by Paul Denya on 2/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (PD)

+ (UIButton *)greyButtonWithText:(NSString *)buttonText;
+ (UIButton *)blueButtonWithText:(NSString *)buttonText;
+ (UIButton *)flatBlueButton:(NSString *)text;
+ (UIButton *)flatBlueButton:(NSString *)text modifier:(CGFloat)modifier;

@end
