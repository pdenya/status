//
//  HeaderView.m
//  Status
//
//  Created by Paul Denya on 7/16/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "HeaderView.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation HeaderView

- (id) init {
	self = [super initWithFrame:[UIScreen mainScreen].bounds];
	
	if (self) {
		[self seth:SYSTEM_VERSION_LESS_THAN(@"7.0") ? 35 : 50];
		self.backgroundColor = [UIColor colorWithHex:0xf1f0f0];
		
		//dark grey bottom border
		CALayer *bottomBorder = [CALayer layer];
		bottomBorder.frame = CGRectMake(0.0f, [self h] - 0.5f, [self w], 0.5f);
		bottomBorder.backgroundColor = [UIColor colorWithHex:0x5d5c5c].CGColor;
		[self.layer addSublayer:bottomBorder];	
	}
	
	return self;
}

- (int) header_adjust {
	return SYSTEM_VERSION_LESS_THAN(@"7.0") ? 0 : 20;
}

- (void) addCloseButton {
	// X button in the top left corner
	UILabel *close_btn = [[UILabel alloc] init];
	close_btn.backgroundColor = [UIColor clearColor];
	close_btn.text = @"×";
	close_btn.textColor = [UIColor colorWithHex:0x444444];
	close_btn.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30.0f];
	close_btn.userInteractionEnabled = YES;
	close_btn.textAlignment = NSTextAlignmentCenter;
	
	UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
	gr.numberOfTapsRequired = 1;
	gr.numberOfTouchesRequired = 1;
	[close_btn addGestureRecognizer:gr];
	
	[self addSubview:close_btn];
	[close_btn sizeToFit];
	[close_btn setx:0];
	[close_btn setw:[close_btn w] + 10];
	[close_btn centery];
	
	if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
		[close_btn sety:[close_btn y] - 2];
	}
	else {
		[close_btn sety:[close_btn y] + [self header_adjust] / 4];
	}
}

- (void)close:(id)sender {
	[[ViewController instance] closeModal:(self.superview && self.superview.tag == 50) ? self.superview : self];
}

- (void)addTitle:(NSString *)text {
	//the label in the header bar
	UILabel *title = [UILabel boldLabel:text];
	title.backgroundColor = [UIColor clearColor];
	[self addSubview:title];
	//TODO: add max width
	[title centery];
	[title sety:[title y] + [self header_adjust] / 2];
	[title centerx];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
