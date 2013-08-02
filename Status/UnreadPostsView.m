//
//  UnreadPostsView.m
//  Status
//
//  Created by Paul Denya on 7/20/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "UnreadPostsView.h"


@implementation UnreadPostsView
@synthesize feed, timeline;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.feed = [[NSMutableArray alloc] init];
		self.backgroundColor = [UIColor whiteColor];
		
		[self refreshFeed];
		
		self.timeline = [[TimelineView alloc] initWithFrame:self.bounds];
		self.timeline.feed = self.feed;
		self.timeline.max_free_rows = 5;
		[self.timeline.tableview reloadData];
		[self.timeline setUpgradeHeader:@{
		 @"title": @"Join the conversation",
		 @"message": @"View the posts from your timeline which have comments you haven’t read yet. View the 5 most recent unread posts for free or upgrade to Pro to browse them all.",
		 @"message_pro": @"All the posts from your timeline which have comments you haven’t read yet. Posted are marked as unread again whenever new comments are added.",
		 @"icon": @"icon_unread_large",
		 @"icon_label": @"Unread"
		 }];
		[self addSubview:self.timeline];
    }
    return self;
}

- (void) refreshFeed {
	[self.feed removeAllObjects];
	
	for (Post *post in [FeedHelper instance].feed) {
		if ([post has_unread_comments]) {
			[self.feed addObject:post];
		}
	}
	
	[self.timeline.tableview reloadData];
}

- (Post *) postFromUser:(User *)user {
	Post *post;
	
	for (Post *p in [FeedHelper instance].feed) {
		NSString *post_uid = [NSString stringWithFormat:@"%@", p.uid];
		NSString *user_uid = [NSString stringWithFormat:@"%@", user.uid];
		if ([post_uid isEqualToString:user_uid]) {
			post = p;
			break;
		}
	}
	
	return post;
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
