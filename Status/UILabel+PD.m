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
	label.font = [UIFont systemFontOfSize:24.0f];
	label.textColor = [UIColor colorWithHex:0x0090FF];
//	label.shadowColor = [UIColor colorWithHex:0x89FFFD];
//	label.shadowOffset = CGSizeMake(0,-1);
	[label setText:labelText];
	[label sizeToFit];
	return label;
}

@end
