//
//  UILabel+PD.h
//  Inspect
//
//  Created by Paul Denya on 11/21/12.
//
//

#import <UIKit/UIKit.h>

@interface UILabel (PD)

+ (UILabel *)titleLabelWithText:(NSString *)labelText;
+ (UILabel *)boldLabel:(NSString *)text;
+ (UILabel *)boldLabel:(NSString *)text modifier:(CGFloat)modifier;
+ (UILabel *)boldLabel:(NSString *)text size:(CGFloat)size;
+ (UILabel *)label:(NSString *)text;
+ (UILabel *)label:(NSString *)text modifier:(CGFloat)modifier;
+ (UILabel *)label:(NSString *)text size:(CGFloat)size;
- (void) underline;


@end
