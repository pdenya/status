//
//  PostCreateView.m
//  Status
//
//  Created by Paul Denya on 2/14/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "PostCreateView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostCreateView
@synthesize messageTextField, postClicked, focused;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor colorWithHex:0xEFEFEF];
    }
    return self;
}

- (void)addedAsSubview:(NSDictionary *)options {
	
	self.messageTextField = [[UITextView alloc] init];
	[self addSubview:self.messageTextField];
	[self.messageTextField seth:[self h] - 216 - 50];
	[self.messageTextField setw:[self w]];
	[self.messageTextField setx:0];
	[self.messageTextField sety:0];
	[self.messageTextField setContentInset:UIEdgeInsetsMake(5.0f, 20.0f, 10.0f, 0.0f)];
	self.messageTextField.font = [UIFont systemFontOfSize:20.0f];
	self.messageTextField.layer.cornerRadius = 2.0f;
	self.messageTextField.layer.borderWidth = 1.0f;
	self.messageTextField.layer.borderColor	= [UIColor colorWithHex:0xAAAAAA].CGColor;
	self.messageTextField.textColor = [UIColor colorWithHex:0x222222];
	
	UIButton *postButton = [UIButton blueButtonWithText:[options objectForKey:@"button_text"] ? [options objectForKey:@"button_text"] : @"Post to Facebook"];
	[self addSubview:postButton];
	[postButton sety:[messageTextField bottomEdge] + 7];
	[postButton setx:[messageTextField rightEdge] - [postButton w] - 7];
	[postButton addTarget:self action:@selector(postToFacebookClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *cancelButton = [UIButton greyButtonWithText:@"Cancel"];
	[self addSubview:cancelButton];
	[cancelButton sety:[postButton y]];
	[cancelButton setx:7];
	[cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	if ([[options objectForKey:@"autofocus"] boolValue]) {
		[self performSelector:@selector(focus) withObject:nil afterDelay:0.2f];
	}
}

- (void)focus {
	[self.messageTextField becomeFirstResponder];
}

- (void)postToFacebookClicked:(id)sender {
	NSLog(@"post to facebook clicked");
	[self postClicked]();
}

- (void)cancelClicked:(id)sender {
	[self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
