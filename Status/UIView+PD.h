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

- (CGRect) roundedFrame;

-(UIView *)parents:(Class)class_name;

-(void)addRedBorder;
-(void)addSubtleShadow;
- (void)addTopBorder:(UIColor *)borderColor;
- (void)addBottomBorder:(UIColor *)borderColor;
- (void) addFlexibleBottomBorder:(UIColor *)borderColor;

-(void)setxp:(CGFloat)percent;
-(void)setyp:(CGFloat)percent;
-(void)setwp:(CGFloat)percent;
-(void)sethp:(CGFloat)percent;

- (void)setw:(CGFloat)width;
- (void)seth:(CGFloat)height;
- (void)setx:(CGFloat)x;
- (void)sety:(CGFloat)y;

- (void)centerx;
- (void)centery;


-(CGFloat)w;
-(CGFloat)h;
-(CGFloat)x;
-(CGFloat)y;

+ (UIView *) horizontalRule;
+ (UIView *) verticalRule;

- (void) shrinkAndRemove:(CGFloat)delay;
- (void) shrinkAndRemove;

- (void) addAndGrowSubview:(UIView *)view;
- (void) addAndGrowSubview:(UIView *)view fromPoint:(CGPoint)point;

//app specific
+ (UIView *) starView:(CGFloat)height;

@end
