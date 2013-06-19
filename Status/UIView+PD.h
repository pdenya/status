//
//  UIView+PD.h
//  Inspect
//
//  Created by Paul Denya on 11/21/12.
//
//

#import <UIKit/UIKit.h>

//maybe move this to a globals file at some point
typedef void (^PDBlock)(void);
typedef void (^PDObjectBlock)(id);

@interface UIView (PD)

-(CGFloat)rightEdge;
-(CGFloat)bottomEdge;

-(void)addBlueBackground;
-(void)addBlueTableCellBackground;
-(void)addRedBorder;

-(void)setxp:(CGFloat)percent;
-(void)setyp:(CGFloat)percent;
-(void)setwp:(CGFloat)percent;
-(void)sethp:(CGFloat)percent;

- (void)setw:(int)width;
- (void)seth:(int)height;
- (void)setx:(int)x;
- (void)sety:(int)y;

- (void)centerx;
- (void)centery;

-(CGFloat)w;
-(CGFloat)h;
-(CGFloat)x;
-(CGFloat)y;

+ (UIView *) horizontalRule;
+ (UIView *) verticalRule;
+ (UIView *) headerView:(UILabel *)label leftButton:(UIButton *)leftButton rightButton:(UIButton *)rightButton secondRightButton:(UIButton *)secondRightButton thirdRightButton:(UIButton *)thirdRightButton;

- (void) shrinkAndRemove:(CGFloat)delay;
- (void) shrinkAndRemove;

- (void) addAndGrowSubview:(UIView *)view;

@end
