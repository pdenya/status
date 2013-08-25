//
//  FavoritesView.m
//  Status
//
//  Created by Paul on 3/26/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "NewsFeedView.h"
#import "ThumbView.h"
#import "UserAvatarView.h"
#import "PostDetailsView.h"

@implementation NewsFeedView
@synthesize timeline, feed;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.feed = [[NSMutableArray alloc] init];
		self.backgroundColor = [UIColor whiteColor];
		
		[self refreshFeed];
		
		self.timeline = [[TimelineView alloc] initWithFrame:self.bounds];
		self.timeline.feed = self.feed;
		self.timeline.removeWhenFiltered = YES;
		[self.timeline.tableview reloadData];
		/*
		[self.timeline setUpgradeHeader:@{
		 @"title": @"Keep tabs on your favorite people",
		 @"message": @"The last status each of your favorite people has posted.  See 5 favorites at once or upgrade to Pro to see them all.",
		 @"icon": @"icon_favorite_large",
		 @"icon_label": @"Favorites"
		 }];
		 */
		[self addSubview:self.timeline];
    }
    return self;
}

- (void) refreshFeed {
	[self.feed removeAllObjects];
    NSMutableArray *new_feed = [[NSMutableArray alloc] init];
	
	for (Post *p in [FeedHelper instance].feed) {
		if (![[p user] is_filtered]) {
			[new_feed addObject:p];
		}
	}
	
    [self.feed removeAllObjects];
    [self.feed addObjectsFromArray:new_feed];
    [new_feed release];
        
	[self.timeline.tableview reloadData];
}

@end
