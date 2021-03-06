//
//  UserAvatarView.m
//  Status
//
//  Created by Paul Denya on 3/14/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "UserAvatarView.h"
#import "ViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDImageCache.h>

@implementation UserAvatarView
@synthesize avatarView, urls, photos, headerView, headerLabel, should_resize;

- (id)init {
	return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.urls = [[[NSMutableArray alloc] init] autorelease];
		self.photos = [[[NSMutableArray alloc] init] autorelease];
		self.backgroundColor = [UIColor blackColor];
		self.should_resize = NO;
		
		self.headerView = [[[HeaderView alloc] init] autorelease];
		[self.headerView addCloseButton];
		[self addSubview:self.headerView];
		
		self.avatarView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
		[self.avatarView sety:[self.headerView bottomEdge]];
		[self.avatarView seth:[self h] - [self.avatarView y]];
		self.avatarView.contentMode = UIViewContentModeScaleAspectFit;
		
		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.avatarView.frame];
		scrollView.contentSize = scrollView.bounds.size;
		scrollView.minimumZoomScale = 1.0;
		scrollView.maximumZoomScale = 4.0;
		scrollView.delegate = self;
		[self addSubview:scrollView];
		
		self.avatarView.frame = scrollView.bounds;
		[scrollView addSubview:self.avatarView];
    }
    return self;
}

- (void) hideHeader {
	self.headerView.hidden = YES;
    self.avatarView.superview.frame = self.bounds;
    self.avatarView.frame = self.bounds;
}

- (void) resizeTo:(CGFloat)new_h {
	
	[self.avatarView seth:new_h];
	UIScrollView *sv = ((UIScrollView *)self.avatarView.superview);
	[sv seth:new_h];
	sv.contentSize = sv.bounds.size;
	
	CGFloat h = [self h];
	[self seth:self.headerView.hidden ? new_h : new_h + [self.headerView h]];
	
	NSNumber *difference = [NSNumber numberWithFloat:(h - [self h])];
	
	if (self.superview && difference > 0) {
		UIView *sv = self.superview;
		
		while (![sv respondsToSelector:@selector(userAvatarViewResized:)] && sv.superview) {
			sv = sv.superview;
		}
		
		if ([sv respondsToSelector:@selector(userAvatarViewResized:)]) {
			[sv performSelector:@selector(userAvatarViewResized:) withObject:difference];
		}
	}
}

- (void) setUser:(User *)new_user {
	[self.avatarView setImageWithURL:[NSURL URLWithString:[new_user picBigUrl]]
					placeholderImage:[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[new_user picSquareUrl]]
						   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
							   if (!image) {
								   image = self.avatarView.image;
							   }
							   
							   if (self.should_resize && image) {
								   //Multiply the original image size by the given scale, and you'll get your actual displayed image size.
								   [self autosize];
							   }
							}];
	
	if (self.should_resize) {
		[self autosize];
	}
	
	if (self.headerLabel) [self.headerLabel setText:[new_user full_name]];
}

- (void) setPost:(Post *)new_post {
	[self setPost:new_post index:0];
}

- (void) autosize {
	if (!self.avatarView.image) return;
	
	CGFloat sx = [self.avatarView w] / self.avatarView.image.size.width;
	CGFloat sy = [[ViewController instance] contentFrame].size.height / self.avatarView.image.size.height;
	CGFloat s = fminf(sx, sy);
	[self resizeTo:(s * self.avatarView.image.size.height)];
}

- (void) setPost:(Post *)new_post index:(int)index {
	if ([new_post hasImages]) {
		NSLog(@"Setting Image to %@", [new_post image:0 size:@"n"]);
		[self.avatarView setImageWithURL:[NSURL URLWithString:[new_post image:index size:@"n"]]
						placeholderImage:[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[new_post image:index size:@"n"]]
							   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
								   if (!image) {
									   image = self.avatarView.image;
								   }
								   
								   if (self.should_resize && image) {
									   //Multiply the original image size by the given scale, and you'll get your actual displayed image size.
									   [self autosize];
								   }
							   }];
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.avatarView;
}

@end
