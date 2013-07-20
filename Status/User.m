//
//  User.m
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize first_name, last_name, pic_big, pic_square, uid, image_square, image_big, callbacks;

static int total_failed = 0;
const int max_failed = 30;

+ (User *)userFromDictionary:(NSDictionary *)user_data {
	User *user = [[[User alloc] init] autorelease];
	
	user.first_name = [user_data valueForKey:@"first_name"];
	user.last_name = [user_data valueForKey:@"last_name"];
	user.pic_big = [user_data valueForKey:@"pic_big"];
	user.pic_square = [user_data valueForKey:@"pic_square"];
	user.uid = [user_data objectForKey:@"uid"];
	
	return user;
}

+ (NSComparisonResult(^)(id a, id b))timeComparator {
	return ^NSComparisonResult(id a, id b) {
		return [((Post *)a).time integerValue] > [((Post *)b).time integerValue] ? NSOrderedAscending : NSOrderedDescending;
	};
}


- (User *)init {
	self = [super init];
	
	if (self) {
		self.callbacks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

+ (int)reachedFailureThreshold {
	return total_failed >= max_failed;
}

//NSCoding
	- (id)initWithCoder:(NSCoder *)coder {
		self = [super init];
		
		self.first_name = [coder decodeObjectForKey:@"first_name"];
		self.last_name = [coder decodeObjectForKey:@"last_name"];
		self.pic_big = [coder decodeObjectForKey:@"pic_big"];
		self.pic_square = [coder decodeObjectForKey:@"pic_square"];
		self.uid = [coder decodeObjectForKey:@"uid"];
			
		return self;
	}

	- (void)encodeWithCoder:(NSCoder *)coder {
		[coder encodeObject:self.first_name forKey:@"first_name"];
		[coder encodeObject:self.last_name forKey:@"last_name"];
		[coder encodeObject:self.pic_big forKey:@"pic_big"];
		[coder encodeObject:self.pic_square forKey:@"pic_square"];
		[coder encodeObject:self.uid forKey:@"uid"];
	}

//public methods
	- (void)loadPicSquare {
		[self loadPicSquare:nil];
	}

	- (NSString *)picSquareUrl {
		return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=150&height=150", self.uid];
	}

	- (NSString *)picBigUrl {
		return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=640", self.uid];
	}

	- (void)loadPicSquare:(PDBlock)completed {
		NSLog(@"Don't use loadPicSquare, use SDWebImage with picSquareUrl instead unless you have a good reason!");
		return;
		
		if(is_fetching_square_image) {
			if (completed) {
				[self.callbacks addObject:[[completed copy] autorelease]];
			}
			return;
		}
		if (total_failed > max_failed) return;
		if (self.image_square != nil) {
			if (completed) completed();
			return;
		}
		
		is_fetching_square_image = YES;
		
		//fetch profile image
		NSLog(@"Loading Pic Square %@", self.uid);
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			// do your background tasks here
			
			NSString *url_string = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=150&height=150", self.uid];
			UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_string]]];
			
			if (image != nil) {
				self.image_square = image;
				if (completed) {
					completed();
				}
				
				if ([self.callbacks count] > 0) {
					for (int j = 0; j < [self.callbacks count]; j++) {
						PDBlock c = [self.callbacks objectAtIndex:j];
						if (c) {
							c();
						}
					}
					
					[self.callbacks removeAllObjects];
				}
			} else {
				total_failed++;
			}
			
			is_fetching_square_image = NO;
		});
	}

	- (void)loadPicBig:(PDBlock)loaded {
		if(is_fetching_big_image) return;
		if (total_failed > max_failed) return;
		if (self.image_big != nil) {
			loaded();
			return;
		}
		
		is_fetching_big_image = YES;
		
		//fetch profile image
		NSLog(@"Loading Pic Big %@", self.uid);
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			// do your background tasks here
			NSString *url_string = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=640", self.uid];
			NSLog(@"URL STRIN %@", url_string);
			UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url_string]]];
			
			if (image != nil) {
				self.image_big = image;
				loaded();
			} else {
				total_failed++;
			}
			
			is_fetching_big_image = NO;
		});
	}

- (NSString *)full_name {
	return [NSString stringWithFormat:@"%@ %@", self.first_name, self.last_name];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<User Name='%@ %@' PicBig='%@' PicSquare='%@' UID='%@' />", self.first_name, self.last_name, self.pic_big, self.pic_square, self.uid];
}

- (BOOL) is_favorite {
	return (BOOL)[[FavoritesHelper instance].favorites objectForKey:self.uid];
}

- (void) favorite {
	if (![self is_favorite]) {
		//update user favorites
		[[FavoritesHelper instance].favorites setObject:@{
		  @"state": FAVORITE_STATE_FAVORITED,
		  @"start": [NSDate date],
		  @"uid": self.uid
		} forKey:self.uid];
	}
}

- (void) unfavorite {
	if ([self is_favorite]) {
		//update user favorites
		[[FavoritesHelper instance].favorites removeObjectForKey:self.uid];
	}
}


@end
