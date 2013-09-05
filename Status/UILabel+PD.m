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
	return [UILabel boldLabel:text size:round(13.0f * modifier)];
}

+ (UILabel *)boldLabel:(NSString *)text size:(CGFloat)size {
	UILabel *title = [[UILabel alloc] init];
	title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
	title.textColor = [UIColor colorWithHex:0x444444];
	title.text = text;
	[title sizeToFit];
	return title;
}

+ (UILabel *)label:(NSString *)text {
	return [self label:text modifier:1.0f];
}

+ (UILabel *)label:(NSString *)text modifier:(CGFloat)modifier {
	return [self label:text size:round(12.0f * modifier)];
}

+ (UILabel *)label:(NSString *)text size:(CGFloat)size {
	UILabel *title = [[UILabel alloc] init];
	title.font = [UIFont fontWithName:@"HelveticaNeue" size:size];
	title.textColor = [UIColor colorWithHex:0x444444];
	title.text = text;
	title.numberOfLines = 0;
	
	[title sizeToFit];
	return title;
}

+ (UILabel *)italicLabel:(NSString *)text {
	return [self italicLabel:text size:12.0f];
}

+ (UILabel *)italicLabel:(NSString *)text size:(CGFloat)size {
	UILabel *title = [[UILabel alloc] init];
	title.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:size];
	title.textColor = [UIColor colorWithHex:0x444444];
	title.text = text;
	[title sizeToFit];
	return title;
}


@end
