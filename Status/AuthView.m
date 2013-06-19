//
//  AuthView.m
//  Status
//
//  Created by Paul Denya on 5/27/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "AuthView.h"

@implementation AuthView
@synthesize success;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
		
		UIImageView *imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"auth_header.jpg"]];
		[self addSubview:imgview];
		[imgview setw:[self w]];
		[imgview seth:[self h] / 2];
		
		UILabel *header = [UILabel titleLabelWithText:@"Welcome to Status"];
		[self addSubview:header];
		[header centerx];
		[header sety:([self h] / 2) + 30];
		
		UILabel *subhead = [[UILabel alloc] init];
		subhead.backgroundColor = [UIColor clearColor];
		subhead.font = [UIFont systemFontOfSize:13.0f];
		subhead.textColor = [UIColor colorWithHex:0x999999];
		subhead.numberOfLines = 0;
		subhead.textAlignment = UITextAlignmentCenter;
		[self addSubview:subhead];
		[subhead setwp:0.9f];
		[subhead setText:@"Status is a new view for your Facebook timeline. Find out what's happening with the people you care about."];
		[subhead sizeToFit];
		[subhead sety:[header bottomEdge] + 10];
		[subhead centerx];
		
		UIButton *fbButton = [UIButton blueButtonWithText:@"Connect to Facebook"];
		[fbButton addTarget:self action:@selector(connectToFacebookClicked:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:fbButton];
		[fbButton sety:[subhead bottomEdge] + 25];
		[fbButton centerx];

		UILabel *buttonhelp = [[UILabel alloc] init];
		buttonhelp.backgroundColor = [UIColor clearColor];
		buttonhelp.font = [UIFont systemFontOfSize:10.0f];
		buttonhelp.textColor = [UIColor colorWithHex:0xAAAAAA];
		buttonhelp.textAlignment = UITextAlignmentCenter;
		buttonhelp.text = @"We never post without your permission";
		[buttonhelp sizeToFit];
		[self addSubview:buttonhelp];
		[buttonhelp centerx];
		[buttonhelp sety:[fbButton bottomEdge] + 1];
    }
	
    return self;
}

- (void) connectToFacebookClicked:(id)sender {
	[[FBHelper instance] openSession:^{
		[self shrinkAndRemove];
		if (self.success) {
			self.success();
		}
	} allowLoginUI:YES onFail:^{
		
	}];
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
