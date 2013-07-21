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
		[self.timeline.tableview reloadData];
		[self.timeline setUpgradeHeader:@{
		 @"title": @"Keep tabs on your favorite people",
		 @"message": @"The last status each of your favorite people has posted.  See 5 favorites at once or upgrade to Pro to see them all."
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
