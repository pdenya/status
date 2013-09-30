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
		BOOL istall = [self h] > 500;
		BOOL isios7 = !SYSTEM_VERSION_LESS_THAN(@"7.0");
        // Initialization code
		self.backgroundColor = [UIColor brandGreyColor];
		
		UIView *bluebg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self w], 80)];
		bluebg.backgroundColor = [UIColor brandBlueColor];
		[self addSubview:bluebg];
		
		if (istall && isios7) {
			[bluebg seth:100];
		}
		else if (isios7 && !istall) {
			[bluebg seth:85];
		}
		else if (istall && !isios7) {
			
		}
		
		
		[bluebg addBottomBorder:[UIColor brandMediumGrey]];
		
		UILabel *header = [UILabel label:@"Welcome to Status" size:28.0f];
		header.backgroundColor = [UIColor brandBlueColor];
		header.textColor = [UIColor whiteColor];
		[bluebg addSubview:header];
		[header centerx];
		[header centery];
		
		if (isios7 && !istall) {
			[header sety:[header y] - 5.0f];
		}
		else if (!isios7) {
			[header sety:[header y] - 10.0f];
		}
		
		
		UILabel *subhead = [UILabel italicLabel:@"A fresh slice of your Facebook timeline." size:12.0f];
		subhead.backgroundColor = [UIColor brandBlueColor];
		subhead.textColor = [UIColor whiteColor];
		[bluebg addSubview:subhead];
		[subhead sety:[header bottomEdge] + 3];
		[subhead centerx];
		
        CGFloat imgview_padding = 19.0f;
		CGFloat section_padding = 15.0f;
		
		UIView *focusview = ({
			UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self w], 100)];
			
			UIImageView *imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_friends.png"]];
			[imgview setx:imgview_padding];
            [imgview sety:7];
			[view addSubview:imgview];
			
			UILabel *focus = [UILabel boldLabel:@"Focus on friends" size:13.0f];
            focus.backgroundColor = self.backgroundColor;
			focus.textColor = [UIColor brandDarkGrey];
			[view addSubview:focus];
			[focus setx:[imgview rightEdge] + imgview_padding];
			[focus sety:0.0f];
			
			UILabel *focus_description = [UILabel label:@"Status updates from friends. No links. No checkins. No brands." size:13.0f];
            focus_description.backgroundColor = self.backgroundColor;
			focus_description.textColor = [UIColor brandMediumGrey];
			[view addSubview:focus_description];
			[focus_description sety:[focus bottomEdge] + 0.0f];
			[focus_description setx:[focus x]];
			[focus_description setw:[view w] - ([focus x] + imgview_padding)];
			[focus_description seth:40.0f];
			
			[view seth:MAX([focus_description bottomEdge], [imgview bottomEdge])];
			[view sety:[bluebg bottomEdge] + section_padding];
			
			[imgview release];
			
			view;
		});
		
		[self addSubview:focusview];
		
		
		UIView *trackview = ({
			UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self w], 100)];
			
			UIImageView *imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_conversation.png"]];
			[imgview setx:imgview_padding];
            [imgview sety:7];
			[view addSubview:imgview];
			
			UILabel *track = [UILabel boldLabel:@"Track conversations" size:13.0f];
            track.backgroundColor = self.backgroundColor;
			track.textColor = [UIColor brandDarkGrey];
			[view addSubview:track];
			[track setx:[imgview rightEdge] + imgview_padding];
			[track sety:0.0f];
			
			UILabel *track_description = [UILabel label:@"If there are unread comments on a status, we help you find them." size:13.0f];
            track_description.backgroundColor = self.backgroundColor;
			track_description.textColor = [UIColor brandMediumGrey];
			[view addSubview:track_description];
			[track_description sety:[track bottomEdge] + 0.0f];
			[track_description setx:[track x]];
			[track_description setw:[view w] - ([track x] + imgview_padding)];
			[track_description seth:40.0f];
			
			[view seth:MAX([track_description bottomEdge], [imgview bottomEdge])];
			[view sety:[focusview bottomEdge] + section_padding];
			
			[imgview release];
			
			view;
		});
		
		
		[self addSubview:trackview];
		
		UIView *bottomView = [[UIView alloc] init];
		[self addSubview:bottomView];
		bottomView.backgroundColor = [UIColor brandGreyColor];
		[bottomView seth:80];
		
		if (istall) {
			//[bottomView seth:100];
		}
		
		[bottomView setw:[self w]];
		[bottomView setx:0];
		[bottomView sety:[self h] - [bottomView h]];
		[bottomView addTopBorder:[UIColor brandMediumGrey]];
		
		UIButton *fbButton = [UIButton blueButtonWithText:@"Connect to Facebook"];
		[fbButton addTarget:self action:@selector(connectToFacebookClicked:) forControlEvents:UIControlEventTouchUpInside];
		[bottomView addSubview:fbButton];
		[fbButton centery];
		[fbButton centerx];
		
		UILabel *buttonhelp = [UILabel label:@"We never post without your permission" size:9.0f];
		buttonhelp.textColor = [UIColor colorWithHex:0x777777];
		buttonhelp.textAlignment = UITextAlignmentCenter;
		[bottomView addSubview:buttonhelp];
		[buttonhelp centerx];
		[buttonhelp sety:[fbButton bottomEdge] + 1];
		
		
		//this is visually above bottom view but it's easier to have the height while initing it and h is dependent on bottomView sort of
		UIScrollView *scrollview = ({
			UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [trackview bottomEdge] + section_padding, [self w], 100)];
			[scrollview seth:[bottomView y] - [scrollview y]];

			scrollview.backgroundColor = [UIColor brandMediumGrey];
            
            CGFloat ss_padding = 7.0f;
            CGFloat new_height = ([scrollview h] - (ss_padding * 2));
            
            UIImage *ss_img = [UIImage imageNamed:@"screenshot_timeline.png"];
            UIImageView *ss_1 = [[UIImageView alloc] initWithImage:[ss_img resizeImageToHeight:new_height]];
            ss_1.frame = CGRectMake(ss_padding, ss_padding, (ss_img.size.width/ss_img.size.height) * new_height, new_height);
			
			[scrollview addSubview:ss_1];
            
			ss_1.tag = 40;
			
			UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
			[ss_1 addGestureRecognizer:tapgr];
			ss_1.userInteractionEnabled = YES;
			[tapgr release];
			
			
            UIImageView *ss_2 = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"screenshot_fav.png"] resizeImageToHeight:new_height]];
            ss_2.frame = ss_1.frame;
            [ss_2 setx:[ss_1 rightEdge] + ss_padding];
            [scrollview addSubview:ss_2];
			ss_2.tag = 41;
			
			UITapGestureRecognizer *tapgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
			[ss_2 addGestureRecognizer:tapgr2];
			ss_2.userInteractionEnabled = YES;
			[tapgr2 release];
			
            UIImageView *ss_3 = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"screenshot_conversation.png"] resizeImageToHeight:new_height]];
            ss_3.frame = ss_1.frame;
            [ss_3 setx:[ss_2 rightEdge] + ss_padding];
            [scrollview addSubview:ss_3];
			ss_3.tag = 42;
			
			UITapGestureRecognizer *tapgr3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
			[ss_3 addGestureRecognizer:tapgr3];
			ss_3.userInteractionEnabled = YES;
			[tapgr3 release];
            
            UIImageView *ss_4 = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"screenshot_post.png"] resizeImageToHeight:new_height]];
            ss_4.frame = ss_1.frame;
            [ss_4 setx:[ss_3 rightEdge] + ss_padding];
            [scrollview addSubview:ss_4];
			ss_4.tag = 43;
			
			UITapGestureRecognizer *tapgr4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
			[ss_4 addGestureRecognizer:tapgr4];
			ss_4.userInteractionEnabled = YES;
			[tapgr4 release];
            
			UIImageView *ss_5 = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"screenshot_filter.png"] resizeImageToHeight:new_height]];
            ss_5.frame = ss_1.frame;
            [ss_5 setx:[ss_4 rightEdge] + ss_padding];
            [scrollview addSubview:ss_5];
			ss_5.tag = 44;
			
			UITapGestureRecognizer *tapgr5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
			[ss_5 addGestureRecognizer:tapgr5];
			ss_5.userInteractionEnabled = YES;
			[tapgr5 release];
			
            [ss_1 release];
            [ss_2 release];
            [ss_3 release];
            [ss_4 release];
			[ss_5 release];
			
            scrollview.contentSize = CGSizeMake([ss_5 rightEdge] + ss_padding, [scrollview h]);
			
			[scrollview scrollRectToVisible:CGRectMake(scrollview.contentSize.width - 10.0f, 0, 10.0f, [scrollview h]) animated:NO];
            
			scrollview;
		});
		
		[self addSubview:scrollview];
		self.tourview = scrollview;
		[scrollview release];
		[self performSelector:@selector(scrollToBeginning) withObject:nil afterDelay:0.5f];
		
		[focusview release];
		[trackview release];
		[bluebg release];
		[bottomView release];
    }
	
    return self;
}

- (void) dealloc {
	[_tourview release];
	[super dealloc];
}

- (void) scrollToBeginning {
	BOOL isios7 = !SYSTEM_VERSION_LESS_THAN(@"7.0");
	if (isios7) {
		[UIView animateWithDuration:1.3f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.0f options:nil animations:^{
			[self.tourview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
		} completion:^(BOOL finished) {}];
	}
	else {
		[UIView animateWithDuration:1.0f animations:^{
			[self.tourview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
		}];
	}
}

- (void) zoomImage:(id)sender {
	UIImageView *imgview = (UIImageView *)((UITapGestureRecognizer *)sender).view;
	UIImageView *zoomedview = [[UIImageView alloc] init];
	
	switch(imgview.tag) {
		case 40:
			[imgview setx:[imgview x] + 40.0f];
			[zoomedview setImage:[UIImage imageNamed:@"screenshot_timeline.png"]];
			break;
		case 41:
			[zoomedview setImage:[UIImage imageNamed:@"screenshot_fav.png"]];
			break;
		case 42:
			[zoomedview setImage:[UIImage imageNamed:@"screenshot_conversation.png"]];
			break;
		case 43:
			[zoomedview setImage:[UIImage imageNamed:@"screenshot_post.png"]];
			break;
		case 44:
			[zoomedview setImage:[UIImage imageNamed:@"screenshot_filter.png"]];
			break;
	}
	
	zoomedview.frame = [self bounds];
	zoomedview.userInteractionEnabled = YES;
	zoomedview.contentMode = UIViewContentModeTop;
	[self addAndGrowSubview:zoomedview];
	
	UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:zoomedview action:@selector(shrinkAndRemove)];
	[zoomedview addGestureRecognizer:tapgr];
	[tapgr release];
	
	[zoomedview release];
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
