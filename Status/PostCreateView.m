//
//  PostCreateView.m
//  Status
//
//  Created by Paul Denya on 2/14/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "PostCreateView.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostCreateView
@synthesize messageTextField, postClicked, focused, post;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
		
		int padding = 4;
		self.messageTextField = [[UITextView alloc] init];
		[self addSubview:self.messageTextField];
		NSLog(@"self h %f", [self h]);
		
		[self.messageTextField seth:[self h] - (216 + 65)];
		
		if (!SYSTEM_VERSION_LESS_THAN(@"7.0")) {
			[self.messageTextField seth:[self.messageTextField h] - 8];
		}
		
		[self.messageTextField setw:[self w] - (padding * 2)];
		[self.messageTextField sety:SYSTEM_VERSION_LESS_THAN(@"7.0") ? padding : 20];
		[self.messageTextField setx:padding];
		self.messageTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
		self.messageTextField.textColor = [UIColor brandDarkGrey];
    }
    return self;
}

- (void)addedAsSubview:(NSDictionary *)options {
	[self performSelector:@selector(focus) withObject:nil afterDelay:0.0f];
	[self performSelector:@selector(addControls) withObject:nil afterDelay:0.3f];
}


- (void)addControls {
	int padding = 4;
	
	UIButton *postButton = (UIButton *)[self viewWithTag:60];
	if (postButton) {
		//already initialized
		return;
	}
	
	postButton = [UIButton flatBlueButton:@"Post to Facebook" modifier:1.2];
	postButton.hidden = YES;
	postButton.alpha = 0;
	[self addSubview:postButton];
	[postButton sety:[self.messageTextField bottomEdge] + padding];
	[postButton setx:[self.messageTextField rightEdge] - [postButton w] - padding];
	[postButton addTarget:self action:@selector(postToFacebookClicked:) forControlEvents:UIControlEventTouchUpInside];
	postButton.tag = 60;
	
	UILabel *close_btn = [[UILabel alloc] init];
	close_btn.hidden = YES;
	close_btn.alpha = 0;
	close_btn.backgroundColor = [UIColor clearColor];
	close_btn.text = @"×";
	close_btn.textColor = [UIColor colorWithHex:0x444444];
	close_btn.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40.0f];
	close_btn.userInteractionEnabled = YES;
	close_btn.textAlignment = NSTextAlignmentCenter;
	
	UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelClicked:)];
	gr.numberOfTapsRequired = 1;
	gr.numberOfTouchesRequired = 1;
	[close_btn addGestureRecognizer:gr];
	
	[self addSubview:close_btn];
	[close_btn sizeToFit];
	[close_btn setx:padding];
	[close_btn setw:[close_btn w] + 10];
	[close_btn sety:[postButton y] - (SYSTEM_VERSION_LESS_THAN(@"7.0") ? 14 : 7)];
	
	if (self.post) {
		[self switchToComment:self.post];
	}
	
	[UIView animateWithDuration:0.2f animations:^{
		postButton.alpha = 1;
		postButton.hidden = NO;
		close_btn.alpha = 1;
		close_btn.hidden = NO;
	} completion:^(BOOL finished) {
		[close_btn release];
	}];
}


- (void)focus {
	[self.messageTextField becomeFirstResponder];
}

- (void) switchToComment:(Post *)p {
	self.post = p;
	UIButton *postbtn = (UIButton *)[self viewWithTag:60];
	[postbtn setTitle:@"Post comment" forState:UIControlStateNormal];
	[postbtn removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
	[postbtn addTarget:self action:@selector(postCommentClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	//todo: build post display view and add to the top
	
	UIView *responding_to = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self w], SYSTEM_VERSION_LESS_THAN(@"7.0") ? 50 : 60)];
	responding_to.backgroundColor = [UIColor brandGreyColor];
	[responding_to addFlexibleBottomBorder:[UIColor brandMediumGrey]];
	[self addSubview:responding_to];
	
	UILabel *r_message = [UILabel label:self.post.message];
	[r_message setw:[self w] - 20];
	[r_message seth:[responding_to h] - (SYSTEM_VERSION_LESS_THAN(@"7.0") ? 10 : 20)];
	[r_message setx:10];
	[r_message sety:SYSTEM_VERSION_LESS_THAN(@"7.0") ? 5 : 15];
	r_message.backgroundColor = responding_to.backgroundColor;
	[responding_to addSubview:r_message];
	
	[self.messageTextField sety:[responding_to bottomEdge]];
}

- (void)postCommentClicked:(id)sender {
	FBHelper *fb = [FBHelper instance];
	
	[fb postComment:self.messageTextField.text onStatus:[self.post combined_id] completed:
	 ^(NSArray *response) {
		 if ([self postClicked]) {
			 [self postClicked]();
		 }
		 
	  	 //todo: make this happen immediately rather than waiting for this response
		 [[ViewController instance] closeModal:self];
	 }];
}

- (void)postToFacebookClicked:(id)sender {
	NSLog(@"post to facebook clicked");
	
	if ([PDUtils processCommand:self.messageTextField]) {
		return;
	}
	
	FBHelper *fb = [FBHelper instance];
	[fb postStatus:self.messageTextField.text completed:^(NSArray *response) {
		if ([self postClicked]) {
			[self postClicked]();
		}
		
		//todo: make this happen immediately rather than waiting for this response
		[[ViewController instance] closeModal:self];
	}];
}

- (void)cancelClicked:(id)sender {
	[[ViewController instance] closeModal:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
