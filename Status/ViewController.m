//
//  ViewController.m
//  Status
//
//  Created by Paul Denya on 1/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize timelineview, feed, user_data, total_failed, filter, favorites;

const int FAILED_THRESHOLD = 30;

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
	
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	self.total_failed = 0;
	
	[self load];
	//[self loadDemoData];
	
	[self filterFilter];
	
	FBHelper *fb = [FBHelper instance];
	
	if (FBSession.activeSession.isOpen) {
		NSLog(@"active session");
		[self streamRefreshInterval];
    }
	else {
		[fb openSession:^(NSArray *data) {
			[self streamRefreshInterval];
		}];
	}
	
	self.timelineview = [[TimelineView alloc] initWithFrame:self.view.bounds];
	self.timelineview.filterButtonClicked = ^{
		FilteredUsersView *filteredview = [[FilteredUsersView alloc] initWithFrame:self.view.bounds];
		[self.view addSubview:filteredview];
		[self.view bringSubviewToFront:filteredview];
		[filteredview release];
	};
	
	[self.view addSubview:self.timelineview];
	
	NSLog(@"viewWillAppear");
}

//once called, this method polls fb every 5 minutes
-(void)streamRefreshInterval {
	[self fetchFeed];
	[self performSelector:@selector(streamRefreshInterval) withObject:nil afterDelay:30.0f];
}

- (void)filterFilter {
	NSMutableArray *to_remove = [[NSMutableArray alloc] init];
	
	for (NSString *user_key in self.filter) {
		NSDictionary *f = [self.filter objectForKey:user_key];
		
		NSDate *cutoff = nil;
		NSDate *start = [f objectForKey:@"state"];
		
		if ([[f objectForKey:@"state"]  isEqualToString:FILTER_STATE_FILTERED_WEEK]) {
			//edge cases where this fails exist but who cares stackoverflow.com/questions/10209427/subtract-7-days-from-current-date
			cutoff = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
		}
		else if ([[f objectForKey:@"state"]  isEqualToString:FILTER_STATE_FILTERED_DAY]) {
			//edge cases where this fails exist but who cares stackoverflow.com/questions/10209427/subtract-7-days-from-current-date
			cutoff = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];
		}
		
		if (cutoff != nil) {
			if (![start isKindOfClass:[NSDate class]] || start < cutoff) {
				[to_remove addObject:user_key];
			}
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
		
		//preload the rest of the profile pics that we need
		for (NSString *user_key in self.user_data) {
			[[self.user_data objectForKey:user_key] loadPicSquare];
		}
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

- (void)loadDemoData {
	Post *post = [Post postFromDictionary:@{
					@"message": @"This is a pretty short post.",
				    @"time": @"1340723958",
					@"uid": @"12312424",
					@"status_id": @"23981241"
				  }];
	
	Post *post2 = [Post postFromDictionary:@{
				  @"message": @"This one is much longer.  Like the ones that robby writes that are like pages long.  Who writes that much at a time on facebook of all things.  It's crazy.  It's also pretty funny that I'm doing a facebook client instead of a twitter client....but the opportunity is there, i might as well take it.  Joel and Caroline both see what I see.  Maybe this will be big.  Buuuuut it probably won't be.  You know how it is.  The biggest things are the ones made by other people.",
				  @"time": @"1340723998",
				  @"uid": @"12312424",
				  @"status_id": @"239812414"
				  }];
	self.feed = [NSMutableArray arrayWithArray:@[post, post2]];
	self.timelineview.feed = self.feed;
}

// UITABLEVIEW id<UITableViewDelegate> *delegate;
//id<UITableViewDelegate> *delegate;

@end