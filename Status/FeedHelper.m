//
//  FeedHelper.m
//  Status
//
//  Created by Paul on 3/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FeedHelper.h"

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
		NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSData *feedData = [NSKeyedArchiver archivedDataWithRootObject:self.feed];
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
