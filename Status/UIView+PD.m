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
	CALayer *border = [CALayer layer];
	border.frame = CGRectMake(0, [self h] - 0.5f, [self w], 0.5f);
	border.backgroundColor = borderColor.CGColor;
	[self.layer addSublayer:border];
}

- (void) addFlexibleBottomBorder:(UIColor *)borderColor {
	UIView *border = [[UIView alloc] init];
	NSLog(@"content view frame %@", NSStringFromCGRect(self.frame));
	border.frame = CGRectMake(0, 10, [self w], 1/[[UIScreen mainScreen] scale]);
	NSLog(@"content view frame %@", NSStringFromCGRect(border.frame));
	border.backgroundColor = borderColor;
	border.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;// | UIViewAutoresizingFlexibleWidth;
	[self addSubview:border];
	[self bringSubviewToFront:border];
}

- (void) addTopBorder:(UIColor *)borderColor {
	CALayer *border = [CALayer layer];
	border.frame = CGRectMake(0, 0, [self w], 0.5f);
	border.backgroundColor = borderColor.CGColor;
	[self.layer addSublayer:border];
}

-(void)addBlueBackground {
	self.backgroundColor = [UIColor blackColor];
 	
	UIImageView *bgview = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bg_blue.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:240]];
	bgview.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	if (![self respondsToSelector:@selector(setBackgroundView:)]) {
		[self addSubview:bgview];
		[self sendSubviewToBack:bgview];
	}
	else {
		[self performSelector:@selector(setBackgroundView:) withObject:bgview];
	}
	
	[bgview release];
}

-(void)addBlueTableCellBackground {
	self.backgroundColor = [UIColor clearColor];
 	
	UIImageView *bgview = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bg_tablecell.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:28]];
	bgview.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	[self addSubview:bgview];
	[self sendSubviewToBack:bgview];
	[bgview release];
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
		CGRect frame = CGRectIntegral(self.frame);
		frame.origin.y = round((self.superview.frame.size.height * percent) - (frame.size.height / 2));
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD sety called but superview is nil");
	}
}

-(void)setxp:(CGFloat)percent {
	if (self.superview) {
		CGRect frame = CGRectIntegral(self.frame);
		frame.origin.x = round((self.superview.frame.size.width * percent) - (frame.size.width / 2));
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD sety called but superview is nil");
	}
}

-(void)setwp:(CGFloat)percent {
	if (self.superview) {
		CGRect frame = CGRectIntegral(self.frame);
		frame.size.width = round(self.superview.frame.size.width * percent);
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD setwp called but superview is nil");
	}
}

-(void)sethp:(CGFloat)percent {
	if (self.superview) {
		CGRect frame = CGRectIntegral(self.frame);
		frame.size.height = round(self.superview.frame.size.height * percent);
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD sethp called but superview is nil");
	}
}


//positioning
- (void)sety:(int)y {
	CGRect frame = CGRectIntegral(self.frame);
	frame.origin.y = y;
	self.frame = frame;
}

- (void)setx:(int)x {
	CGRect frame = CGRectIntegral(self.frame);
	frame.origin.x = x;
	self.frame = frame;
}


- (void)setw:(int)width {
	CGRect frame = CGRectIntegral(self.frame);
	frame.size.width = width;
	self.frame = frame;
}

- (void)seth:(int)height {
	CGRect frame = CGRectIntegral(self.frame);
	frame.size.height = height;
	self.frame = frame;
}

- (void)centerx {
	if (self.superview) {
		CGRect frame = CGRectIntegral(self.frame);
		frame.origin.x = round((self.superview.frame.size.width * 0.5f) - (frame.size.width / 2));
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD centerx called but superview is nil");
	}
}
- (void)centery {
	if (self.superview) {
		CGRect frame = CGRectIntegral(self.frame);
		frame.origin.y = round((self.superview.frame.size.height * 0.5f) - (frame.size.height / 2));
		self.frame = frame;
	}
	else {
		NSLog(@"ERROR: UIView+PD centery called but superview is nil");
	}
}

+ (UIView *) horizontalRule {
	UIView *hr = [[UIView alloc] init];
	[hr setw:200];
	[hr seth:1];
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
	view.transform = CGAffineTransformMakeScale(0.95, 0.95);
	view.alpha = 0.4f;
	[self addSubview:view];

	[UIView animateWithDuration:0.1f
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 view.transform = CGAffineTransformIdentity;
						 view.alpha = 1.0f;
					 }
					 completion:^(BOOL finished){ }];
	
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
