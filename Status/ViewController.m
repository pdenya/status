//
//  ViewController.m
//  Status
//
//  Created by Paul Denya on 1/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "ViewController.h"
#import "AuthView.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize timelineview, feed, user_data, total_failed, filter, favorites;

const int FAILED_THRESHOLD = 30;

- (void)viewDidLoad {
    [super viewDidLoad];
	[AppHelper instance].vc = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
	
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	self.total_failed = 0;
	
	[self load];
	//[self loadDemoData];
    
    self.filter = [FilterHelper instance].filter;
    self.user_data = [UsersHelper instance].users;
    self.favorites = [FavoritesHelper instance].favorites;
    self.feed = [FeedHelper instance].feed;
	
	[self filterFilter];
	
	//[[FBHelper instance] logout];
	
	[self auth];
	
	NSLog(@"viewWillAppear");
}

- (void)auth {
	FBHelper *fb = [FBHelper instance];
	
	void (^fb_success)(void) = ^ {
		[self streamRefreshInterval];
		[self showTimeline];
	};
	
	if (FBSession.activeSession.isOpen) {
		NSLog(@"active session");
		fb_success();
    }
	else {
		[fb openSession:fb_success
		   allowLoginUI:NO
				 onFail:^{
					 NSLog(@"showAuth");
					 AuthView *authview = [[AuthView alloc] initWithFrame:self.view.bounds];
					 authview.success = fb_success;
					 [self.view addSubview:authview];
				 }
		 ];
	}
}

- (void) showTimeline {
	if (!self.timelineview) {
		self.timelineview = [[TimelineView alloc] initWithFrame:self.view.bounds];
		self.timelineview.filterButtonClicked = ^{
			FilteredUsersView *filteredview = [[FilteredUsersView alloc] initWithFrame:self.view.bounds];
			[self.view addSubview:filteredview];
			[self.view bringSubviewToFront:filteredview];
			[filteredview release];
		};
		
		self.timelineview.favoriteButtonClicked = ^{
			FavoritesView *favview = [[FavoritesView alloc] initWithFrame:self.view.bounds];
			[self.view addSubview:favview];
			[self.view bringSubviewToFront:favview];
			[favview release];
		};
	}
	
	if (!self.timelineview.superview) {
		[self.view addSubview:self.timelineview];
	}
}

//once called, this method polls fb
-(void)streamRefreshInterval {
	[self fetchFeed];
	[self performSelector:@selector(streamRefreshInterval) withObject:nil afterDelay:30.0f];
}

- (void)filterFilter {
	NSMutableArray *to_remove = [[NSMutableArray alloc] init];
	
	for (NSString *user_key in self.filter) {
		NSDictionary *f = [self.filter objectForKey:user_key];
		
		NSDate *cutoff = nil;
		NSDate *start = [f objectForKey:@"start"];
		
		if ([[f objectForKey:@"state"]  isEqualToString:FILTER_STATE_FILTERED_WEEK]) {
			//edge cases where this fails exist but who cares stackoverflow.com/questions/10209427/subtract-7-days-from-current-date
			cutoff = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
		}
		else if ([[f objectForKey:@"state"]  isEqualToString:FILTER_STATE_FILTERED_DAY]) {
			//edge cases where this fails exist but who cares stackoverflow.com/questions/10209427/subtract-7-days-from-current-date
			cutoff = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];
		}
		
		if (cutoff != nil && (![start isKindOfClass:[NSDate class]] || [start compare:cutoff] == NSOrderedAscending)) {
			[to_remove addObject:user_key];
		}
	}
	
	[self.filter removeObjectsForKeys:to_remove];
}

- (void)fetchFeed {
	NSLog(@"FetchFeed");
	FBHelper *fb = [FBHelper instance];
	
	FBDictionaryBlock completed = ^(NSDictionary *data) {
		//add to feed and sort reverse chronologically
		[self.feed addObjectsFromArray:[data objectForKey:@"feed"]];
		[self.feed sortUsingComparator:[User timeComparator]];
		
		//todo: check overwrite policy on this
		[self.user_data addEntriesFromDictionary:[data objectForKey:@"users"]];
		
		[self save];
		[self.timelineview.tableview reloadData];	
	};
	
	int max_time = 0;
	if ([self.feed count] > 0) {
		for (int i = 0; i < [self.feed count]; i++) {
			max_time = MAX(max_time, [[[self.feed objectAtIndex:i] valueForKey:@"time"] integerValue]);
		}
	}
	
	[fb getStream:completed options:@{ @"max_time": @(max_time), @"filtered_uids": [self.filter allKeys] }];
}

- (void)save {
    [[FeedHelper    instance] save];
    [[FavoritesHelper instance] save];
    [[UsersHelper   instance] save];
    [[FilterHelper  instance] save];
}

- (void)load {
	[[FeedHelper    instance] load];
    [[FavoritesHelper instance] load];
    [[UsersHelper   instance] load];
    [[FilterHelper  instance] load];
}

@end