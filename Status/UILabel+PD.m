//
//  UILabel+PD.m
//  Inspect
//
//  Created by Paul Denya on 11/21/12.
//
//

#import "UILabel+PD.h"

@implementation UILabel (PD)

+ (UILabel *)titleLabelWithText:(NSString *)labelText {
	UILabel *label = [[UILabel alloc] init];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:15.0f];
	label.textColor = [UIColor colorWithHex:0x2f2f2d];
	label.shadowColor = [UIColor colorWithHex:0x3086cc];
	label.shadowOffset = CGSizeMake(0,1);
	[label setText:labelText];
	[label sizeToFit];
	return label;
}

@end
