//
//  UIButton+PD.m
//  Status
//
//  Created by Paul Denya on 2/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "UIButton+PD.h"

@implementation UIButton (PD)

/* 
	I'd like to name these bootstrap style
	-primaryButtonWithText
 
	and have resizing methods
	-small
	-medium //default, called by primaryButtonWithText, etc
	-large
*/

+ (UIButton *)greyButtonWithText:(NSString *)buttonText {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:[[UIImage imageNamed:@"button_grey.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:30] forState:UIControlStateNormal];
	[button setTitle:buttonText forState:UIControlStateNormal];
	button.titleLabel.shadowColor = [UIColor colorWithHex:0x555555];
	button.titleLabel.shadowOffset = CGSizeMake(0,-1);
	button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
	
	//padding
	UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, -6.0f);
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
	
	//extra width required for title centering
	contentInsets.right += (titleInsets.left - titleInsets.right);
	
	[button setTitleEdgeInsets:titleInsets];
	[button setContentEdgeInsets:contentInsets];
	[button sizeToFit];
	
	[button seth:35];
	
	return button;
}

+ (UIButton *)blueButtonWithText:(NSString *)buttonText {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:[[UIImage imageNamed:@"button_blue.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:30] forState:UIControlStateNormal];
	[button setTitle:buttonText forState:UIControlStateNormal];
	button.titleLabel.shadowColor = [UIColor colorWithHex:0x555555];
	button.titleLabel.shadowOffset = CGSizeMake(0,-1);
	button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
	
	//padding
	UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, -6.0f);
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
	
	//extra width required for title centering
	contentInsets.right += (titleInsets.left - titleInsets.right);
	
	[button setTitleEdgeInsets:titleInsets];
	[button setContentEdgeInsets:contentInsets];
	[button sizeToFit];
	
	[button seth:35];
	
	return button;
}

+ (UIButton *)flatBlueButton:(NSString *)text modifier:(CGFloat)modifier {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	button.backgroundColor = [UIColor colorWithHex:0x3e9ed5];
	button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:round(modifier * 12.0f)];
	button.titleLabel.textAlignment = UITextAlignmentCenter;
	[button setTitle:text forState:UIControlStateNormal];
	
	CGFloat vpadding = modifier * 5.0f; //height
	CGFloat hpadding = modifier * 13.0f; //width
	[button setw:modifier * 500];
	[button seth:modifier * 100];
	[button sizeToFit];
	[button setw:[button w] + (hpadding * 2)];
	[button seth:[button h] + (vpadding * 2)];
	
	return button;
}

+ (UIButton *)flatBlueButton:(NSString *)text {
	return [UIButton flatBlueButton:text modifier:1];
}

@end
