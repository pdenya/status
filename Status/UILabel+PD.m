//
//  UILabel+PD.m
//  Inspect
//
//  Created by Paul Denya on 11/21/12.
//
//

#import "UILabel+PD.h"
#import <QuartzCore/QuartzCore.h>

@implementation UILabel (PD)

+ (UILabel *)titleLabelWithText:(NSString *)labelText {
	UILabel *label = [[UILabel alloc] init];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:24.0f];
	label.textColor = [UIColor brandBlueColor];
//	label.shadowColor = [UIColor colorWithHex:0x89FFFD];
//	label.shadowOffset = CGSizeMake(0,-1);
	[label setText:labelText];
	[label sizeToFit];
	return label;
}

- (void) underline {
	CALayer *underline = [CALayer layer];
	underline.frame = CGRectMake(0, [self h] - 0.5f, [self w], 0.5f);
	underline.backgroundColor = self.textColor.CGColor;
	[self.layer addSublayer:underline];
}

+ (UILabel *)boldLabel:(NSString *)text {
	return [UILabel boldLabel:text modifier:1.0f];
}

+ (UILabel *)boldLabel:(NSString *)text modifier:(CGFloat)modifier {
	UILabel *title = [[UILabel alloc] init];
	title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f * modifier];
	title.textColor = [UIColor colorWithHex:0x444444];
	title.text = text;
	[title sizeToFit];
	return title;
}

+ (UILabel *)label:(NSString *)text {
	return [self label:text modifier:1.0f];
}

+ (UILabel *)label:(NSString *)text modifier:(CGFloat)modifier {
	UILabel *title = [[UILabel alloc] init];
	title.font = [UIFont fontWithName:@"HelveticaNeue" size:round(12.0f * modifier)];
	title.textColor = [UIColor colorWithHex:0x444444];
	title.text = text;
	title.numberOfLines = 0;
	
	[title sizeToFit];
	return title;
}

@end
