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
		self.timeline.max_free_rows = 5;
		
		[self.timeline createTutorial:@{
			@"header": @"0 Favorites",
			@"stepone": @"To mark someone as a favorite, swipe left on your timeline.",
			@"steptwo": @"After tapping to favorite, the last status your friend posted will show up on this list."
		}];
		
		[self.timeline.tableview reloadData];
		[self addUpgradeHeader];
		[self addSubview:self.timeline];
    }
    return self;
}

- (void) addUpgradeHeader {
	[self.timeline setUpgradeHeader:@{
	 @"title": @"Keep tabs on your favorite people",
	 @"message": @"The last status each of your favorite people has posted.  See 5 favorites at once or upgrade to Pro to see them all.",
	 @"message_pro": @"The last status each of your favorite people has posted.  Keep tabs on your friends.",
	 @"icon": @"icon_favorite_large",
	 @"icon_label": @"Favorites"
	 }];
}

- (void) refreshFeed {
	
	NSArray *new_keys = [self.favorites allKeys];
    NSMutableArray *new_feed = [[NSMutableArray alloc] init];
	
	for (NSString *key in new_keys) {
		NSDictionary *fav_data = [self.favorites objectForKey:key];
		User *user = [[UsersHelper instance].users objectForKey:[fav_data objectForKey:@"uid"]];
		Post *post = [user most_recent_post];
		[new_feed addObject:post];
	}
	
	[self.feed removeAllObjects];
	[self.feed addObjectsFromArray:new_feed];
	
	[self.keys removeAllObjects];
	[self.keys addObjectsFromArray:new_keys];
	
	[new_feed release];
	
	[self.timeline.tableview reloadData];
}

@end
