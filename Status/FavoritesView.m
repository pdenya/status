//
//  FavoritesView.m
//  Status
//
//  Created by Paul on 3/26/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FavoritesView.h"
#import "ThumbView.h"
#import "UserAvatarView.h"
#import "PostDetailsView.h"

@implementation FavoritesView
@synthesize timeline, favorites, keys, feed;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.favorites = [FavoritesHelper instance].favorites;
		self.keys = [NSMutableArray arrayWithArray:[self.favorites allKeys]];
		self.feed = [[NSMutableArray alloc] init];
		
		self.backgroundColor = [UIColor whiteColor];

		[self refreshFeed];
		
		self.timeline = [[TimelineView alloc] initWithFrame:self.bounds];
		self.timeline.feed = self.feed;
		[self.timeline.tableview reloadData];
		[self.timeline setUpgradeHeader:@{
			@"title": @"Keep tabs on your favorite people",
			@"message": @"The last status each of your favorite people has posted.  See 5 favorites at once or upgrade to Pro to see them all.",
			@"icon": @"icon_favorite_large",
			@"icon_label": @"Favorites"
		}];
		[self addSubview:self.timeline];
    }
    return self;
}

- (void) refreshFeed {
	[self.feed removeAllObjects];
	
	[self.keys removeAllObjects];
	[self.keys addObjectsFromArray:[self.favorites allKeys]];
	
	for (NSString *key in self.keys) {
		NSDictionary *fav_data = [self.favorites objectForKey:key];
		User *user = [[UsersHelper instance].users objectForKey:[fav_data objectForKey:@"uid"]];
		Post *post = [self postFromUser:user];
		[self.feed addObject:post];
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

@end
