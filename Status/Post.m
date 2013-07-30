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
	post.status_id = [post_data valueForKey:@"status_id"];
	post.time = [post_data objectForKey:@"time"];
	post.uid = [post_data objectForKey:@"uid"];
	post.has_comments = NO;
	
	if ([post_data valueForKey:@"images"]) {
		post.images = [NSMutableArray arrayWithArray:[post_data valueForKey:@"images"]];
	} else {
		post.images = [[NSMutableArray alloc] init];
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
	CGFloat w = [self messageLabelWidth];
	
	CGFloat height = [self.message sizeWithFont:[Post getPostFont]
							  constrainedToSize:CGSizeMake(w, FLT_MAX)
								  lineBreakMode:UILineBreakModeWordWrap].height;
	
	height += 36;
	
	height = MAX([self minRowHeight], height);
	
	return height;
}

- (CGFloat) minRowHeight {
	return [[self user] is_filtered] ? 83 : 69; //[self hasImages] || [self has_comments] ? 60 : 33;
}

- (CGFloat)messageLabelWidth {
	return round([UIScreen mainScreen].bounds.size.width * ([self hasImages] ? 0.58 : .75));
}

- (NSDate *)date {
	return [NSDate dateWithTimeIntervalSince1970:[self.time integerValue]];
}

//NSCoding
	- (id)initWithCoder:(NSCoder *)coder {
		self = [super init];
		
		if (self) {
			self.message = [coder decodeObjectForKey:@"message"];
			self.status_id = [coder decodeObjectForKey:@"status_id"];
			self.time = [coder decodeObjectForKey:@"time"];
			self.uid = [coder decodeObjectForKey:@"uid"];
			self.has_comments = [coder decodeBoolForKey:@"has_comments"];
			self.images = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"images"]];
			
			if ([coder decodeObjectForKey:@"last_comment_at"]) {
				self.last_comment_at = [coder decodeObjectForKey:@"last_comment_at"];
			}
			
			if ([coder decodeObjectForKey:@"last_read"]) {
				self.last_read = [coder decodeObjectForKey:@"last_read"];
			}
		}
		
		return self;
	}

	- (void)encodeWithCoder:(NSCoder *)coder {
		[coder encodeObject:self.message forKey:@"message"];
		[coder encodeObject:self.status_id forKey:@"status_id"];
		[coder encodeObject:self.time forKey:@"time"];
		[coder encodeObject:self.uid forKey:@"uid"];
		[coder encodeBool:self.has_comments forKey:@"has_comments"];
		[coder encodeObject:self.images forKey:@"images"];
		
		if (self.last_comment_at) {
			[coder encodeObject:self.last_comment_at forKey:@"last_comment_at"];
		}
		
		if (self.last_read) {
			[coder encodeObject:self.last_read forKey:@"last_read"];
		}
	}

//Logging helper
	- (NSString *)description {
		return [NSString stringWithFormat:@"<Post Time='%@' UID='%@' StatusID='%@' Message='%@' />", self.time, self.uid, self.status_id, self.message];
	}

@end
