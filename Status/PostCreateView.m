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
@synthesize messageTextField, postClicked, focused;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
		
		int padding = 4;
		self.messageTextField = [[UITextView alloc] init];
		[self addSubview:self.messageTextField];
		[self.messageTextField seth:[self h] - 216 - 50 + 5];
		[self.messageTextField setw:[self w] - (padding * 2)];
		[self.messageTextField setx:padding];
		[self.messageTextField sety:padding];
		self.messageTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
		self.messageTextField.textColor = [UIColor colorWithHex:0x333333];
		
		UIButton *postButton = [UIButton flatBlueButton:@"Post to Facebook" modifier:1.2];
		[self addSubview:postButton];
		[postButton sety:[messageTextField bottomEdge] + padding];
		[postButton setx:[messageTextField rightEdge] - [postButton w] - padding];
		[postButton addTarget:self action:@selector(postToFacebookClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		UILabel *close_btn = [[UILabel alloc] init];
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
		[close_btn sety:[postButton y] - 14];
    }
    return self;
}

- (void)addedAsSubview:(NSDictionary *)options {
	[self performSelector:@selector(focus) withObject:nil afterDelay:0.2f];
}

- (void)focus {
	[self.messageTextField becomeFirstResponder];
}

- (void)postToFacebookClicked:(id)sender {
	NSLog(@"post to facebook clicked");
	
	FBHelper *fb = [FBHelper instance];
	[fb postStatus:self.messageTextField.text completed:^(NSArray *response) {
		//todo: make this happen immediately rather than waiting for this response
		[[ViewController instance] closeModal:self];
		
		if ([self postClicked]) {
			[self postClicked]();
		}
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
