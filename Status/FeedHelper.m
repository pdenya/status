//
//  FeedHelper.m
//  Status
//
//  Created by Paul on 3/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FeedHelper.h"
#import "ViewController.h"

@implementation FeedHelper

+ (FeedHelper *)instance {
	static FeedHelper *feedhelper;
	
	if (!feedhelper) {
		feedhelper = [[FeedHelper alloc] init];
	}
	
	return feedhelper;
}

- (FeedHelper *)init {
    
    if (self = [super init]) {
        self.feed = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) refresh {
	NSLog(@"FetchFeed");
	FBHelper *fb = [FBHelper instance];
	
	FBDictionaryBlock completed = ^(NSDictionary *data) {
		//grab a reference to this for use belo
		Post *first_post = (self.feed && [self.feed count] > 0) ? (Post *)[self.feed objectAtIndex:0] : nil;
		
		//add to feed and sort reverse chronologically
		[self.feed addObjectsFromArray:[data objectForKey:@"feed"]];
		[self.feed sortUsingComparator:[User timeComparator]];
		
		//todo: check overwrite policy on this
		[[UsersHelper instance].users addEntriesFromDictionary:[data objectForKey:@"users"]];
		
		//save changes
		[self save];
		[[UsersHelper instance] save];
		
		//get an array of the index paths of rows we added
		int index = first_post ? [self.feed indexOfObject:first_post] : [self.feed count];
		NSMutableArray *added_rows = [[NSMutableArray alloc] init];
		for (int i = 0; i < index; i++) {
			[added_rows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
		}
		
		if ([added_rows count] > 0) {
			//if we added any rows notify the tableviews
			[[ViewController instance] refreshFeeds:added_rows];
		}
		else {
			[[ViewController instance] refreshFeeds:nil];
		}
	};
	
	/*
	
	if ([self.feed count] > 0) {
		for (int i = 0; i < [self.feed count]; i++) {
			max_time = MAX(max_time, [[[self.feed objectAtIndex:i] valueForKey:@"time"] integerValue]);
		}
	}
	 */
	int max_time = 0;
	
	//TODO: make this block less naive about time, switch to calendar methods for diff calculation, etc
	if ([self.feed count] > 0) {
		//assuming for now that the newest post is first in line since we sort
		Post *newest_post = [self.feed objectAtIndex:0];
		max_time = [[newest_post date] timeIntervalSinceNow];
		
		//no older than 5 days ago
		int cutoff = (60 * 60 * 24 * -5);
		
		if (max_time < cutoff) {
			//naive but it doesn't matter for now
			max_time = [[NSDate date] timeIntervalSince1970] + cutoff; //cutoff is negative
		}
		else {
			max_time = [[newest_post date] timeIntervalSince1970];
		}
	}
		
	[fb getStream:completed options:@{ @"max_time": @(max_time) }];
}

- (void) load {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSData *feedData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/feed",docDir]];
	self.feed = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:feedData]];
	NSLog(@"Loaded Feed Data: %@", [self.feed description]);
}

- (void) _save {
	static BOOL is_saving = NO;
	static BOOL is_dirty = NO;
	
	if (!is_saving) {
		is_saving = YES;
        NSArray *save_feed = [self.feed copy];
		NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSData *feedData = [NSKeyedArchiver archivedDataWithRootObject:save_feed];
		[feedData writeToFile:[NSString stringWithFormat:@"%@/feed",docDir] atomically:YES];
		is_saving = NO;
		
		if (is_dirty) {
			is_dirty = NO;
			[self _save];
		}
	}
	else {
		is_dirty = YES;
	}
}

- (void) save {
	[self performSelectorInBackground:@selector(_save) withObject:nil];
}

@end
