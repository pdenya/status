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
	self.filter = [NSMutableDictionary dictionaryWithDictionary:tmp];
	NSLog(@"Loaded Filter Data: %@", [self.filter description]);
}

- (void)save {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSData *filterData = [NSKeyedArchiver archivedDataWithRootObject:self.filter];
	[filterData writeToFile:[NSString stringWithFormat:@"%@/filter",docDir] atomically:YES];
}

@end
