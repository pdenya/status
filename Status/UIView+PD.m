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

//styling
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
	self.layer.borderWidth = 2.0f;
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
	
	/*
	hr.layer.shadowColor = [UIColor colorWithHex:0x3586b4].CGColor;
	hr.layer.shadowOffset = CGSizeMake(1.0f, 0.0f);
	hr.layer.shadowOpacity = 1.0f;
	hr.layer.shadowRadius = 0.0f;
	*/
	
	hr.alpha = 0.6f;
	
	[hr setw:1];
	[hr seth:40];
	
	return hr;
}

+ (UIView *) headerView:(UILabel *)label leftButton:(UIButton *)leftButton
			rightButton:(UIButton *)rightButton secondRightButton:(UIButton *)secondRightButton thirdRightButton:(UIButton *)thirdRightButton  {
	
	UIView *headerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[headerView seth:50];
	headerView.backgroundColor = [UIColor colorWithHex:0x3e9ed5];
	
	//do something with leftbutton
	UIView *leftvr;
	
	if (leftButton) {
		[leftButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
		[headerView addSubview:leftButton];
		[leftButton seth:50];
		[leftButton setw:50];
		[leftButton setyp:0.5f];
		[leftButton setx:5];
		
		leftvr = [UIView verticalRule];
		[headerView addSubview:leftvr];
		[leftvr seth:35];
		[leftvr setyp:0.5f];
		[leftvr setx:[leftButton rightEdge] + [leftvr w] + 0];
	}
	
	UIView *vr;
	UIView *secondvr;
	UIView *thirdvr;
	
	if (rightButton) {
		[rightButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
		[headerView addSubview:rightButton];
		[rightButton seth:50];
		[rightButton setw:50];
		[rightButton setyp:0.5f];
		[rightButton sety:[rightButton y] + 1];
		[rightButton setx:[headerView w] - [rightButton w] - 5];
		
		vr = [UIView verticalRule];
		[headerView addSubview:vr];
		[vr seth:35];
		[vr setyp:0.5f];
		[vr setx:[rightButton x] - [vr w] - 10];
		
		if (secondRightButton) {
			[secondRightButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
			[headerView addSubview:secondRightButton];
			[secondRightButton seth:50];
			[secondRightButton setw:50];
			[secondRightButton setx:[vr x] - [secondRightButton w] - 7];
			[secondRightButton setyp:0.5f];
			
			secondvr = [UIView verticalRule];
			[headerView addSubview:secondvr];
			[secondvr seth:35];
			[secondvr setyp:0.5f];
			[secondvr setx:[secondRightButton x] - [secondvr w] - 10];
			
			if (thirdRightButton) {
				[thirdRightButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
				[headerView addSubview:thirdRightButton];
				[thirdRightButton seth:50];
				[thirdRightButton setw:50];
				[thirdRightButton setx:[secondvr x] - [thirdRightButton w] - 7];
				[thirdRightButton setyp:0.5f];
				
				thirdvr = [UIView verticalRule];
				[headerView addSubview:thirdvr];
				[thirdvr seth:35];
				[thirdvr setyp:0.5f];
				[thirdvr setx:[thirdRightButton x] - [thirdvr w] - 10];

			}
		}
	}
	
	//do something with label
	if (label) {
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:20.0f];
		label.textColor = [UIColor colorWithHex:0xFFFFFF];
		
		[label setx:(leftButton ? [leftvr rightEdge] : 0) + 15];
		
		[label setw:[headerView w] - [label x]];
		
		if (secondRightButton) {
			[label setw:[label w] - ([headerView w] - [secondvr x])];
		}
		else if (rightButton) {
			[label setw:[label w] - ([headerView w] - [vr x])];
		}
		
		[headerView addSubview:label];
		[label sethp:0.8f];
		[label setyp:0.5f];
	}
	
	return headerView;
}

@end
