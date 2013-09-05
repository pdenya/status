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
		BOOL isios7 = [self h] < 500;
        // Initialization code
		self.backgroundColor = [UIColor brandGreyColor];
		
		UIView *bluebg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self w], 120)];
		bluebg.backgroundColor = [UIColor brandBlueColor];
		[self addSubview:bluebg];
		
		if (isios7) {
			[bluebg seth:100];
		}
		
		[bluebg addBottomBorder:[UIColor brandMediumGrey]];
		
		UILabel *header = [UILabel label:@"Welcome to Status" size:28.0f];
		header.backgroundColor = [UIColor brandBlueColor];
		header.textColor = [UIColor whiteColor];
		[bluebg addSubview:header];
		[header centerx];
		[header centery];
		[header sety:[header y] - ([header h] / 3)];
		
		if (isios7) {
			[header centery];
		}
		
		UILabel *subhead = [UILabel label:@"A fresh slice of your Facebook timeline." size:13.0f];
		subhead.backgroundColor = [UIColor brandBlueColor];
		subhead.textColor = [UIColor whiteColor];
		[bluebg addSubview:subhead];
		[subhead sety:[header bottomEdge] + 3];
		[subhead centerx];
		

		UIView *focusview = ({
			UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self w], 100)];
			
			UIImageView *imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_friends.png"]];
			[imgview setx:5];
			[view addSubview:imgview];
			
			UILabel *focus = [UILabel boldLabel:@"Focus on friends" size:13.0f];
			focus.textColor = [UIColor brandDarkGrey];
			[view addSubview:focus];
			[focus setx:[imgview rightEdge] + 5.0f];
			[focus sety:0.0f];
			
			UILabel *focus_description = [UILabel label:@"Status updates from friends. No links. No checkins. No brands." size:13.0f];
			focus_description.textColor = [UIColor brandMediumGrey];
			[view addSubview:focus_description];
			[focus_description sety:[focus bottomEdge] + 0.0f];
			[focus_description setx:[focus x]];
			[focus_description setw:[view w] - ([focus x] + 5.0f)];
			[focus_description seth:40.0f];
			
			[view seth:[focus_description bottomEdge]];
			[view sety:[bluebg bottomEdge] + 20.0f];
			
			view;
		});
		
		[self addSubview:focusview];
		
		
		UIView *trackview = ({
			UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self w], 100)];
			
			UIImageView *imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_friends.png"]];
			[imgview setx:5];
			[view addSubview:imgview];
			
			UILabel *track = [UILabel boldLabel:@"Track conversations" size:13.0f];
			track.textColor = [UIColor brandDarkGrey];
			[view addSubview:track];
			[track setx:[imgview rightEdge] + 5.0f];
			[track sety:0.0f];
			
			UILabel *track_description = [UILabel label:@"If there are unread comments on a status, we help you find them." size:13.0f];
			track_description.textColor = [UIColor brandMediumGrey];
			[view addSubview:track_description];
			[track_description sety:[track bottomEdge] + 0.0f];
			[track_description setx:[track x]];
			[track_description setw:[view w] - ([track x] + 5.0f)];
			[track_description seth:40.0f];
			
			[view seth:[track_description bottomEdge]];
			[view sety:[focusview bottomEdge] + 20.0f];
			
			view;
		});
		
		
		[self addSubview:trackview];
		
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
		
		
		//this is visually above bottom view but it's easier to have the height while initing it and h is dependent on bottomView sort of
		UIScrollView *tourview = ({
			UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [trackview bottomEdge] + 20.0f, [self w], 100)];
			[scrollview seth:[bottomView y] - [scrollview y]];

			scrollview.backgroundColor = [UIColor brandMediumGrey];
			
			scrollview;
		});
		
		[self addSubview:tourview];
		
		
		
		
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
