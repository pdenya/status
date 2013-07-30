//
//  LearnMoreView.m
//  Status
//
//  Created by Paul Denya on 7/16/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "LearnMoreView.h"
#import "HeaderView.h"

@implementation LearnMoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor whiteColor];
		
		int padding = SYSTEM_VERSION_LESS_THAN(@"7.0") ? 10 : 15;
		
        // Initialization code
		HeaderView *header_view = [[HeaderView alloc] init];
		[header_view addCloseButton];
		[header_view addTitle:@"Upgrade to Pro"];
		[self addSubview:header_view];
		
		UIView *unreadsection = [self getSection:@{
		   @"title": @"Unlimited Unread Messages",
		   @"content":	@"A list of all the posts that have comments you haven’t read yet.  As you tap "
						@"through to read the comments the post is removed from the stream until someone else responds."
	   }];
		
		[unreadsection sety:[header_view bottomEdge] + padding];
		[self addSubview:unreadsection];
		
		UIView *filtersection = [self getSection:@{
		   @"title": @"Unlimited Filters",
		   @"content":	@"Hide posts from friends for different intervals: a day (ideal for people posting about sports games you don’t follow), a week or forever. "
						@"Your friends are only hidden within this app, your Facebook timeline will not be affected."
						@"\n\n"
						@"Browse the full list of people you’ve blocked along with their most recent posts (to help you judge whether or not they’re worth unblocking)."
	   }];
		
		
		[filtersection sety:[unreadsection bottomEdge] + padding];
		[self addSubview:filtersection];
		
		UIView *favoritesection = [self getSection:@{
		   @"title": @"Unlimited Favorites",
		   @"content": @"Mark as many people as your favorites as you want and you’ll see the last status each of them posted in your favorites timeline."
	   }];
		
		
		[favoritesection sety:[filtersection bottomEdge] + padding];
		[self addSubview:favoritesection];
		
		
		UIView *bottomview = [[UIView alloc] initWithFrame:self.bounds];
		bottomview.backgroundColor = [UIColor colorWithHex:0xf7f6f6];
		[self addSubview:bottomview];
		[bottomview sethp:(SYSTEM_VERSION_LESS_THAN(@"7.0") ? 0.1f : 0.2f)];
		[bottomview sety:[self h] - [bottomview h]];
		[bottomview addTopBorder:[UIColor colorWithHex:0xa7a6a6]];
		
		UIButton *upgradeBtn = [UIButton flatBlueButton:@"Upgrade to Pro - $1.99" modifier:1.5f];
		[bottomview addSubview:upgradeBtn];
		[upgradeBtn centerx];
		[upgradeBtn centery];
		
    }
    return self;
}

- (UIView *)getSection:(NSDictionary *)options {
	UIView *section = [[UIView alloc] init];
	
	UILabel *titleLabel = [UILabel boldLabel:[options objectForKey:@"title"]];
	[titleLabel setx:76];
	[titleLabel setw:230];
	[titleLabel seth:30];
	[titleLabel sizeToFit];
	[section addSubview:titleLabel];

	UILabel *contentLabel = [UILabel label:[options objectForKey:@"content"]];
	[contentLabel setx:76];
	[contentLabel setw:230];
	[contentLabel seth:300];
	[contentLabel sety:[titleLabel bottomEdge] + 3];
	[contentLabel sizeToFit];
	[section addSubview:contentLabel];
	
	[section seth:[contentLabel bottomEdge]];
	return section;
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
