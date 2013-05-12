//
//  Post.m
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "Post.h"

@implementation Post
@synthesize  message, status_id, time, uid, has_comments, images;

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


- (BOOL)hasImages {
	if (self.images) {
		return ([self.images count] > 0);
	}
	
	return NO;
}

- (CGFloat)rowHeight {
	CGFloat w = [self messageLabelWidth];
	
	CGFloat height = [self.message sizeWithFont:[UIFont systemFontOfSize:15.0f]
							  constrainedToSize:CGSizeMake(w, FLT_MAX)
								  lineBreakMode:UILineBreakModeWordWrap].height;
	
	CGFloat min_height = [self hasImages] ? 53 : 43;
	
	height = MAX(min_height, height) + 40;
	
	return height;
}

- (CGFloat)messageLabelWidth {
	return round([UIScreen mainScreen].bounds.size.width * ([self hasImages] ? 0.58 : .75));
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
	}

//Logging helper
	- (NSString *)description {
		return [NSString stringWithFormat:@"<Post Time='%@' UID='%@' StatusID='%@' Message='%@' />", self.time, self.uid, self.status_id, self.message];
	}

@end
