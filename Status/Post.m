//
//  Post.m
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "Post.h"

@implementation Post
@synthesize  message, status_id, time, uid, has_comments, images, last_comment_at, last_read;

+(Post *)postFromDictionary:(NSDictionary *)post_data {
	Post *post = [[[Post alloc] init] autorelease];
	
	post.message = [post_data valueForKey:@"message"];
	post.status_id = [[post_data valueForKey:@"status_id"] isKindOfClass:[NSString class]] ? [post_data valueForKey:@"status_id"] : [[post_data valueForKey:@"status_id"] stringValue];
	post.time = [post_data objectForKey:@"time"];
	post.uid = [[post_data valueForKey:@"uid"] isKindOfClass:[NSString class]] ? [post_data valueForKey:@"uid"] : [[post_data valueForKey:@"uid"] stringValue];
	post.has_comments = [post_data valueForKey:@"has_comments"] ? [(NSNumber *)[post_data valueForKey:@"has_comments"] boolValue] : NO;
	post.has_liked = [post_data valueForKey:@"has_liked"] ? [(NSNumber *)[post_data valueForKey:@"has_liked"] boolValue] : NO;
	
	if ([post_data valueForKey:@"images"]) {
		post.images = [NSMutableArray arrayWithArray:[post_data valueForKey:@"images"]];
	} else {
		post.images = [[NSMutableArray alloc] init];
	}
	
	if ([post_data valueForKey:@"location"]) {
		post.location = [post_data valueForKey:@"location"];
	}
	
	if ([post_data valueForKey:@"last_comment_at"]) {
		post.last_comment_at = [post_data valueForKey:@"last_comment_at"];
	}
	
	if ([post_data valueForKey:@"last_read"]) {
		post.last_read = [post_data valueForKey:@"last_read"];
	}
	
	return post;
}

+ (UIFont *)getPostFont {
	return [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
}

- (BOOL)hasImages {
	if (self.images) {
		return ([self.images count] > 0);
	}
	
	return NO;
}

- (BOOL)has_unread_comments {
	if (![self has_comments]) {
		return NO;
	}
	
	if (!self.last_read) {
		return YES;
	}
	
	if ([self.last_read compare:self.last_comment_at] == NSOrderedAscending) {
		return YES;
	}
	
	return NO;
}

- (NSString *)combined_id {
	return [NSString stringWithFormat:@"%@_%@",self.uid, self.status_id];
}

- (User *)user {
	return [[UsersHelper instance].users objectForKey:self.uid];
}

- (NSString *)image:(NSInteger)index size:(NSString *)size {
	if ([self hasImages] && [self.images objectAtIndex:index]) {
		return [[[self.images objectAtIndex:index] valueForKey:@"src"] stringByReplacingOccurrencesOfString:@"_s" withString:[NSString stringWithFormat:@"_%@", size]];
	}
	
	[NSException raise:@"Invalid index value" format:@"index %i for post %@ is invalid", index, self.status_id];
	
	return nil;
}

- (CGFloat)rowHeight {
	if (self.row_height && self.row_height > 0) return self.row_height;
	
	CGFloat w = [self messageLabelWidth];
	
	CGFloat height = [self.message sizeWithFont:[Post getPostFont]
							  constrainedToSize:CGSizeMake(w, FLT_MAX)
								  lineBreakMode:UILineBreakModeWordWrap].height;
	
	height += 36;
	
	height = MAX([self minRowHeight], height);
	
	//cache
	self.row_height = height;
	
	return height;
}

- (CGFloat) minRowHeight {
	return [[self user] is_filtered] ? 83 : 69; //[self hasImages] || [self has_comments] ? 60 : 33;
}

- (CGFloat)messageLabelWidth {
	return round([UIScreen mainScreen].bounds.size.width * ([self hasImages] ? 0.58 : .77));
}

- (NSDate *)date {
	return [NSDate dateWithTimeIntervalSince1970:[self.time integerValue]];
}

#pragma mark - actions
- (void)unlike {
	[[FBHelper instance] unlike:[self status_id] completed:^(BOOL success) {
		if (success) {
			self.has_liked = NO;
			[[FeedHelper instance] save];
		}
	}];
}

- (void)like {
	[[FBHelper instance] like:[self status_id] completed:^(BOOL success) {
		if (success) {
			self.has_liked = YES;
			[[FeedHelper instance] save];
		}
	}];
}

//NSCoding
	- (id)initWithCoder:(NSCoder *)coder {
		self = [super init];
		
		if (self) {
			self.message = [coder decodeObjectForKey:@"message"];
			self.status_id = [coder decodeObjectForKey:@"status_id"];
			self.time = [coder decodeObjectForKey:@"time"];
			self.uid = [coder decodeObjectForKey:@"uid"];
			self.has_comments = [coder decodeBoolForKey:@"has_comments"] ? [coder decodeBoolForKey:@"has_comments"] : NO;
			self.has_liked = [coder decodeBoolForKey:@"has_liked"] ? [coder decodeBoolForKey:@"has_comments"] : NO;
			
			if ([coder decodeObjectForKey:@"images"]) {
				self.images = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"images"]];
			}
			
			if ([coder decodeObjectForKey:@"last_comment_at"]) {
				self.last_comment_at = [coder decodeObjectForKey:@"last_comment_at"];
			}
			
			if ([coder decodeObjectForKey:@"last_read"]) {
				self.last_read = [coder decodeObjectForKey:@"last_read"];
			}
			
			if ([coder decodeObjectForKey:@"location"]) {
				self.location = [coder decodeObjectForKey:@"location"];
			}
		}
		
		return self;
	}

	- (void)encodeWithCoder:(NSCoder *)coder {
		[coder encodeObject:self.message forKey:@"message"];
		[coder encodeObject:self.status_id forKey:@"status_id"];
		[coder encodeObject:self.time forKey:@"time"];
		[coder encodeObject:self.uid forKey:@"uid"];
		
		//TODO: maybe use a loop and the kvc methods instead of all these ifs
		if (self.has_comments) {
			[coder encodeBool:self.has_comments forKey:@"has_comments"];
		}
		
		if ([self.images count] > 0) {
			[coder encodeObject:self.images forKey:@"images"];
		}
		
		if (self.has_liked) {
			[coder encodeBool:self.has_liked forKey:@"has_liked"];
		}
		
		if (self.last_comment_at) {
			[coder encodeObject:self.last_comment_at forKey:@"last_comment_at"];
		}
		
		if (self.last_read) {
			[coder encodeObject:self.last_read forKey:@"last_read"];
		}
		
		if (self.location) {
			[coder encodeObject:self.last_read forKey:@"location"];
		}
	}

- (NSDictionary *)toDict {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	[dict setObject:self.message forKey:@"message"];
	[dict setObject:self.status_id forKey:@"status_id"];
	[dict setObject:self.time forKey:@"time"];
	[dict setObject:self.uid forKey:@"uid"];
	
	//TODO: maybe use a loop and the kvc methods instead of all these ifs
	if (self.has_comments) {
		[dict setObject:[NSNumber numberWithBool:self.has_comments] forKey:@"has_comments"];
	}
	
	if ([self.images count] > 0) {
		[dict setObject:self.images forKey:@"images"];
	}
	
	if (self.has_liked) {
		[dict setObject:[NSNumber numberWithBool:self.has_liked] forKey:@"has_liked"];
	}
	
	if (self.last_comment_at) {
		[dict setObject:self.last_comment_at forKey:@"last_comment_at"];
	}
	
	if (self.last_read) {
		[dict setObject:self.last_read forKey:@"last_read"];
	}
	
	if (self.location) {
		[dict setObject:self.location forKey:@"location"];
	}
	
	return dict;
}

//Logging helper
	- (NSString *)description {
		return [NSString stringWithFormat:@"<Post Time='%@' UID='%@' StatusID='%@' Message='%@' />", self.time, self.uid, self.status_id, self.message];
	}

@end
