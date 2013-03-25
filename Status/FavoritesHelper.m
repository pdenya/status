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

- (void) load {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData *favoritesData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/favoites",docDir]];
	NSDictionary *tmp = [NSKeyedUnarchiver unarchiveObjectWithData:favoritesData];
	self.favorites = [NSMutableDictionary dictionaryWithDictionary:tmp];
	NSLog(@"Loaded Favorites Data: %@", [self.favorites description]);
}

- (void) save {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData *favoritesData = [NSKeyedArchiver archivedDataWithRootObject:self.favorites];
	[favoritesData writeToFile:[NSString stringWithFormat:@"%@/favorites",docDir] atomically:YES];
}

@end
