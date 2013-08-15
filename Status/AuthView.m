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
		[imgview seth:([self w] / [imgview w]) * [imgview h]];
		[imgview setw:[self w]];
		[imgview setx:0];
		[imgview sety:0];
		imgview.contentMode = UIViewContentModeScaleAspectFill;
		imgview.clipsToBounds = YES;
		
		if ([self h] < 500) {
			[imgview seth:100];
		}
		
		[imgview addBottomBorder:[UIColor brandMediumGrey]];
		
		UILabel *header = [UILabel titleLabelWithText:@"Welcome to Status"];
		[self addSubview:header];
		[header setx:20];
		[header sety:[imgview bottomEdge] + 20];
		
		UILabel *subhead = [UILabel label:@"A fresh slice of your Facebook timeline." size:15.0f];
		subhead.textColor = [UIColor brandMediumGrey];
		[self addSubview:subhead];
		[subhead sety:[header bottomEdge] + 3];
		[subhead setx:[header x]];
		
		UILabel *focus = [UILabel boldLabel:@"Focus on friends" size:13.0f];
		focus.textColor = [UIColor brandDarkGrey];
		[self addSubview:focus];
		[focus setx:[header x]];
		[focus sety:[subhead bottomEdge] + 20.0f];
		
		UILabel *focus_description = [UILabel label:@"Status updates from friends. No links. No checkins. No brands." size:13.0f];
		focus_description.textColor = [UIColor brandMediumGrey];
		[self addSubview:focus_description];
		[focus_description sety:[focus bottomEdge] + 5.0f];
		[focus_description setx:[header x]];
		[focus_description setw:[self w] - ([header x] * 2)];
		[focus_description seth:30.0f];
		
		UILabel *conversations = [UILabel boldLabel:@"Track conversations" size:13.0f];
		conversations.textColor = [UIColor brandDarkGrey];
		[self addSubview:conversations];
		[conversations setx:[header x]];
		[conversations sety:[focus_description bottomEdge] + 20.0f];
		
		UILabel *conversations_description = [UILabel label:@"If there are unread comments on a status, we help you find them." size:13.0f];
		conversations_description.textColor = [UIColor brandMediumGrey];
		[self addSubview:conversations_description];
		[conversations_description sety:[conversations bottomEdge] + 5.0f];
		[conversations_description setx:[header x]];
		[conversations_description setw:[self w] - ([header x] * 2)];
		[conversations_description seth:30.0f];
		
		
		UIView *bottomView = [[UIView alloc] init];
		[self addSubview:bottomView];
		bottomView.backgroundColor = [UIColor brandGreyColor];
		[bottomView seth:100];
		[bottomView setw:[self w]];
		[bottomView setx:0];
		[bottomView sety:[self h] - [bottomView h]];
		[bottomView addTopBorder:[UIColor brandMediumGrey]];
		
		UIButton *fbButton = [UIButton blueButtonWithText:@"Connect to Facebook"];
		[fbButton addTarget:self action:@selector(connectToFacebookClicked:) forControlEvents:UIControlEventTouchUpInside];
		[bottomView addSubview:fbButton];
		[fbButton centery];
		[fbButton centerx];

		UILabel *buttonhelp = [[UILabel alloc] init];
		buttonhelp.backgroundColor = [UIColor clearColor];
		buttonhelp.font = [UIFont systemFontOfSize:10.0f];
		buttonhelp.textColor = [UIColor colorWithHex:0x666666];
		buttonhelp.textAlignment = UITextAlignmentCenter;
		buttonhelp.text = @"We never post without your permission";
		[buttonhelp sizeToFit];
		[bottomView addSubview:buttonhelp];
		[buttonhelp centerx];
		[buttonhelp sety:[fbButton bottomEdge] + 1];
		
		[bottomView release];

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
