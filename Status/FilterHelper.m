//
//  FilterHelper.m
//  Status
//
//  Created by Paul on 3/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FilterHelper.h"

@implementation FilterHelper

+ (FilterHelper *)instance {
	static FilterHelper *filterhelper;
	
	if (!filterhelper) {
		filterhelper = [[FilterHelper alloc] init];
	}
	
	return filterhelper;
}

+ (NSString *) stringForState:(NSString *)state {
	if ([state isEqualToString:FILTER_STATE_FILTERED]) {
		return @"Filtered";
	}
	else if ([state isEqualToString:FILTER_STATE_FILTERED_DAY]) {
		return @"Filtered for a day";
	}
	else if ([state isEqualToString:FILTER_STATE_FILTERED_WEEK]) {
		return @"Filtered for a week";
	}
	else {
		return @"Visible";
	}
}

- (FilterHelper *)init {
    
    if (self = [super init]) {
        self.filter = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)load {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData *filterData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/filter",docDir]];
	NSDictionary *tmp = [NSKeyedUnarchiver unarchiveObjectWithData:filterData];
	if ([tmp isKindOfClass:[NSDictionary class]]) {
		self.filter = [NSMutableDictionary dictionaryWithDictionary:tmp];
	}
	else {
		self.filter = [[NSMutableDictionary alloc] init];
		[self save];
	}

	NSLog(@"Loaded Filter Data: %@", [self.filter description]);
}

- (void) _save {
	static BOOL is_saving = NO;
	static BOOL is_dirty = NO;
	
	if (!is_saving) {
		is_saving = YES;
		NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSData *filterData = [NSKeyedArchiver archivedDataWithRootObject:self.filter];
		[filterData writeToFile:[NSString stringWithFormat:@"%@/filter",docDir] atomically:YES];
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
