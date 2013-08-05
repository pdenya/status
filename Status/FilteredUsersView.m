//
//  FilteredUsersView.m
//  Status
//
//  Created by Paul Denya on 3/13/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FilteredUsersView.h"
#import "ThumbView.h"
#import "UserAvatarView.h"

@implementation FilteredUsersView
@synthesize filter, tableview, keys, user_data, timeline, feed;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];	
		
		self.filter = [FilterHelper instance].filter;
		self.keys = [NSMutableArray arrayWithArray:[self.filter allKeys]];
		self.user_data = [UsersHelper instance].users;
		self.feed = [NSMutableArray new];
		
		[self refreshFeed];
		
		self.timeline = [[TimelineView alloc] initWithFrame:self.bounds];
		self.timeline.feed = self.feed;
		self.timeline.max_free_rows = 5;
		[self.timeline.tableview reloadData];
		[self addUpgradeHeader];
		[self addSubview:self.timeline];
		
    }
    return self;
}

- (void) refreshFeed {
	[self.keys removeAllObjects];
	[self.keys addObjectsFromArray:[self.filter allKeys]];
	
	[self.feed removeAllObjects];
	
	for (NSString *key in self.keys) {
		NSDictionary *filter_data = [self.filter objectForKey:key];
		User *user = [self.user_data objectForKey:[filter_data objectForKey:@"uid"]];
		Post *post = [user most_recent_post];
		post.row_height = 0;
		[self.feed addObject:post];
	}
	
	[self.timeline.tableview reloadData];
}

- (void) addUpgradeHeader {
	[self.timeline setUpgradeHeader:@{
	 @"title": @"Read what you want to read",
	 @"message": @"Filter your friends so their statuses don't show up in your timeline for a day, a week, or forever. Hide 5 people for free or upgrade to pro to take back your timeline.",
	 @"message_pro": @"Filter your friends so their statuses don't show up in your timeline for a day, a week or forever. The most recent update from each user you've filtered is listed here.",
	 @"icon": @"icon_filter_large",
	 @"icon_label": @"Filtered"
	 }];
}

- (void)zoomAvatar:(id)sender {
	NSLog(@"zoomAvatar");
	
	UITapGestureRecognizer *gr = (UITapGestureRecognizer *)sender;
	UITableViewCell *cell = (UITableViewCell *)gr.view.superview.superview;
	NSIndexPath *index_path = [self.tableview indexPathForCell:cell];
	NSDictionary *filter_data = [self.filter objectForKey:[self.keys objectAtIndex:[index_path row]]];
	User *user = [self.user_data objectForKey:[filter_data objectForKey:@"uid"]];
	
	UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[avatarzoom setUser:user];
	[self addSubview:avatarzoom];
	[avatarzoom release];
}

@end
