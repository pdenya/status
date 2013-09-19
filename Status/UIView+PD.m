//
//  UIView+PD.m
//  Inspect
//
//  Created by Paul Denya on 11/21/12.
//
//

#import "UIView+PD.h"
#import <QuartzCore/QuartzCore.h>



@implementation UIView (PD)

//getter shortcuts
-(CGFloat)rightEdge {
	return self.frame.origin.x + self.frame.size.width;
}

-(CGFloat)bottomEdge {
	return self.frame.origin.y + self.frame.size.height;
}

-(CGFloat)y {
	return self.frame.origin.y;
}

-(CGFloat)x {
	return self.frame.origin.x;
}

-(CGFloat)h {
	return self.frame.size.height;
}

-(CGFloat)w {
	return self.frame.size.width;
}

-(UIView *)parents:(Class)class_name {
	UIView *s = self.superview;
	while (![s isKindOfClass:class_name]) {
		if (s.superview) {
			s = s.superview;
		}
		else {
			return nil;
		}
	}
	
	return s;
}

//styling
- (void) addBottomBorder:(UIColor *)borderColor {
	UIView *border = [[UIView alloc] init];
	border.frame = CGRectMake(0, [self h] - (1/[[UIScreen mainScreen] scale]), [self w], 1/[[UIScreen mainScreen] scale]);
	border.backgroundColor = borderColor;
	border.tag = 102;
	[self addSubview:border];
	[border release];
}

- (void) addFlexibleBottomBorder:(UIColor *)borderColor {
	UIView *border = [[UIView alloc] init];
	border.tag = 101;
	border.frame = CGRectMake(0, [self h] - (1/[[UIScreen mainScreen] scale]), [self w], 1/[[UIScreen mainScreen] scale]);
	border.backgroundColor = borderColor;
	[self addSubview:border];
	[self bringSubviewToFront:border];
}

- (void) addTopBorder:(UIColor *)borderColor {
	CALayer *border = [CALayer layer];
	border.frame = CGRectMake(0, 0, [self w], 1.0f/[[UIScreen mainScreen] scale]);
	border.backgroundColor = borderColor.CGColor;
	[self.layer addSublayer:border];
}

-(void)addRedBorder {
	self.layer.borderColor = [UIColor redColor].CGColor;
	self.layer.borderWidth = 1.0f;
}

-(void)addSubtleShadow {
	CGFloat c = 0.2f;
	self.layer.shadowColor = [UIColor colorWithRed:c green:c blue:c alpha:0.5f].CGColor;
	self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f/[[UIScreen mainScreen] scale]);
	self.layer.shadowRadius = 1.0f/[[UIScreen mainScreen] scale];
	self.layer.shadowOpacity = 1;
}

//relative positioning
-(void)setyp:(CGFloat)percent {
	if (self.superview) {
		CGRect frame = [self roundedFrame];
		frame.origin.y = round((self.superview.frame.size.height * percent) - (frame.size.height / 2));
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD sety called but superview is nil");
	}
}

-(void)setxp:(CGFloat)percent {
	if (self.superview) {
		CGRect frame = [self roundedFrame];
		frame.origin.x = round((self.superview.frame.size.width * percent) - (frame.size.width / 2));
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD sety called but superview is nil");
	}
}

-(void)setwp:(CGFloat)percent {
	if (self.superview) {
		CGRect frame = [self roundedFrame];
		frame.size.width = round(self.superview.frame.size.width * percent);
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD setwp called but superview is nil");
	}
}

-(void)sethp:(CGFloat)percent {
	if (self.superview) {
		CGRect frame = [self roundedFrame];
		frame.size.height = round(self.superview.frame.size.height * percent);
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD sethp called but superview is nil");
	}
}


//positioning
- (void)sety:(CGFloat)y {
	CGRect frame = [self roundedFrame];
	frame.origin.y = y;
	self.frame = frame;
}

- (void)setx:(CGFloat)x {
	CGRect frame = [self roundedFrame];
	frame.origin.x = x;
	self.frame = frame;
}

- (void)setw:(CGFloat)width {
	CGRect frame = [self roundedFrame];
	frame.size.width = width;
	self.frame = frame;
}

- (void)seth:(CGFloat)height {
	CGRect frame = [self roundedFrame];
	frame.size.height = height;
	self.frame = frame;
}

- (void)centerx {
	if (self.superview) {
		CGRect frame = [self roundedFrame];
		frame.origin.x = round((self.superview.frame.size.width * 0.5f) - (frame.size.width / 2));
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD centerx called but superview is nil");
	}
}
- (void)centery {
	if (self.superview) {
		CGRect frame = [self roundedFrame];
		frame.origin.y = round((self.superview.frame.size.height * 0.5f) - (frame.size.height / 2));
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD centery called but superview is nil");
	}
}

- (CGRect) roundedFrame {
	return CGRectMake(
		  round(self.frame.origin.x * [[UIScreen mainScreen] scale]) / [[UIScreen mainScreen] scale],
		  round(self.frame.origin.y * [[UIScreen mainScreen] scale]) / [[UIScreen mainScreen] scale],
		  round(self.frame.size.width * [[UIScreen mainScreen] scale]) / [[UIScreen mainScreen] scale],
		  round(self.frame.size.height * [[UIScreen mainScreen] scale]) / [[UIScreen mainScreen] scale]
	  );
}

+ (UIView *) horizontalRule {
	UIView *hr = [[UIView alloc] init];
	[hr setw:200];
	[hr seth:(1/[[UIScreen mainScreen] scale])];
	hr.backgroundColor = [UIColor colorWithHex:0x317ca7];
	
	return hr;
}

+ (UIView *) verticalRule {
	UIView *hr = [[[UIView alloc] init] autorelease];
	hr.backgroundColor = [UIColor colorWithHex:0x317ca7];
	hr.alpha = 0.6f;
	
	[hr setw:1];
	[hr seth:40];
	
	return hr;
}

//removal effects
- (void) shrinkAndRemove:(CGFloat)delay {
	[UIView animateWithDuration:0.2
						  delay:delay
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.transform = CGAffineTransformMakeScale(0.4, 0.4);
						 self.alpha = 0.0f;
					 }
					 completion:^(BOOL finished){ [self removeFromSuperview]; }];
}

- (void) addAndGrowSubview:(UIView *)view {
	void (^animations)() = ^ {
		view.transform = CGAffineTransformIdentity;
		view.alpha = 1.0f;
	};
 	
	BOOL isios7 = !SYSTEM_VERSION_LESS_THAN(@"7.0");
	if (isios7) {
		view.transform = CGAffineTransformMakeScale(0.5, 0.5);
		view.alpha = 0.4f;
		[self addSubview:view];
		
		[UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.0f options:nil animations:animations completion:^(BOOL finished) {}];
	}
	else {
		view.transform = CGAffineTransformMakeScale(0.95, 0.95);
		view.alpha = 0.4f;
		[self addSubview:view];
		
		[UIView animateWithDuration:0.1f
							  delay:0.0f
							options:UIViewAnimationOptionCurveEaseOut
						 animations:animations
						 completion:^(BOOL finished){ }];
	}
}

- (void) addAndGrowSubview:(UIView *)view fromPoint:(CGPoint)point	{
	void (^animations)() = ^ {
		view.transform = CGAffineTransformIdentity;
		view.alpha = 1.0f;
		view.frame = [[UIScreen mainScreen] bounds];
	};
 	
	BOOL isios7 = !SYSTEM_VERSION_LESS_THAN(@"7.0");
	if (isios7) {
		view.transform = CGAffineTransformMakeScale(0.05, 0.05);
		view.alpha = 0.1f;
		view.center = point;
		
		[self addSubview:view];
		
		[UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.0f options:nil animations:animations completion:^(BOOL finished) {}];
	}
	else {
		view.transform = CGAffineTransformMakeScale(0.95, 0.95);
		view.alpha = 0.4f;
		[self addSubview:view];
		
		[UIView animateWithDuration:0.1f
							  delay:0.0f
							options:UIViewAnimationOptionCurveEaseOut
						 animations:animations
						 completion:^(BOOL finished){ }];
	}
}

- (void) shrinkAndRemove {
	[self shrinkAndRemove:0.0f];
}

+ (UIView *) starView:(CGFloat)height {
	UIView *v = [[UIView alloc] init];
	[v seth:height];
	[v setw:height];
	
	
	
	return v;
}

@end
