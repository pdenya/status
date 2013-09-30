//
//  UserProfileView.m
//  Status
//
//  Created by Paul Denya on 8/21/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "UserProfileView.h"
#import "HeaderView.h"
#import "UserAvatarView.h"
#import "ViewController.h"

@implementation UserProfileView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithUser:(User *)user {
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if (self) {
		self.user = user;
		self.feed = [[[NSMutableArray alloc] init] autorelease];
		
		HeaderView *header_view = [[HeaderView alloc] init];
		[header_view addCloseButton];
		[header_view addTitle:[self.user full_name]];
		
		//add header view
		[self addSubview:header_view];
		[self bringSubviewToFront:header_view];
		
		UIView *topview = [[UIView alloc] initWithFrame:self.frame];
		
        [self refreshFeed];
        
        //embed image view
		UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:[[ViewController instance] contentFrame]];
		avatarzoom.should_resize = [self.feed count] > 0 ? YES : NO;
		[avatarzoom hideHeader];
		[avatarzoom setUser:self.user];
		
        if ([self.feed count] > 0) {
            [avatarzoom sety:0];
            [topview seth:[avatarzoom h]];
            [topview addSubview:avatarzoom];
            
            self.timeline = [[[TimelineView alloc] initWithFrame:[[ViewController instance] contentFrame]] autorelease];
            [self.timeline.tableview setTableHeaderView:topview];
            self.timeline.feed = self.feed;
            [self.timeline.tableview reloadData];
            [self addSubview:self.timeline];
        } else {
            [avatarzoom sety:[header_view h]];
            [self addSubview:avatarzoom];
        }
        
		[header_view release];
		[topview release];
		[avatarzoom release];
	}
	
	return self;
}

- (void) dealloc {
	[self.feed removeAllObjects];
	[_feed release];
	[_timeline release];
	
	[super dealloc];
}

- (void)userAvatarViewResized:(NSNumber *)height_difference {
	UIView *topView = self.timeline.tableview.tableHeaderView;
	[topView seth:[topView h] - [height_difference floatValue]];
	[self.timeline.tableview setTableHeaderView:topView];
}


- (void) refreshFeed {
    NSMutableArray *new_feed = [[NSMutableArray alloc] init];
    User *u = self.user;
	
	for (Post *post in [FeedHelper instance].feed) {
		if (post.user == u) {
			[new_feed addObject:post];
		}
	}
	
    [self.feed removeAllObjects];
    [self.feed addObjectsFromArray:new_feed];
    [new_feed release];
    
	[self.timeline.tableview reloadData];
}

@end
