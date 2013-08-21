//
//  FavoritesHelper.m
//  Status
//
//  Created by Paul on 3/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FavoritesHelper.h"

@implementation FavoritesHelper

+ (FavoritesHelper *)instance {
	static FavoritesHelper *favoriteshelper;
	
	if (!favoriteshelper) {
		favoriteshelper = [[FavoritesHelper alloc] init];
	}
	
	return favoriteshelper;
}

- (FavoritesHelper *)init {
    
    if (self = [super init]) {
        self.favorites = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (BOOL)isFavorited:(User *)user {
	if ([[self instance].favorites objectForKey:user.uid]) {
		return true;
	} else {
		return false;
	}
}

- (void) load {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData *favoritesData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/favorites",docDir]];
	NSDictionary *tmp = [NSKeyedUnarchiver unarchiveObjectWithData:favoritesData];
    
    if ([tmp count] > 0) {
        self.favorites = [NSMutableDictionary dictionaryWithDictionary:tmp];
        NSLog(@"Loaded Favorites Data: %@", [self.favorites description]);
    }
	
}

- (void) _save {
	static BOOL is_saving = NO;
	static BOOL is_dirty = NO;
	
	if (!is_saving) {
		is_saving = YES;
		NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSData *favoritesData = [NSKeyedArchiver archivedDataWithRootObject:self.favorites];
		[favoritesData writeToFile:[NSString stringWithFormat:@"%@/favorites",docDir] atomically:YES];
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
