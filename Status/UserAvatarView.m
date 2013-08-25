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

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.urls = [[NSMutableArray alloc] init];
		self.photos = [[NSMutableArray alloc] init];
		self.backgroundColor = [UIColor blackColor];
		self.should_resize = NO;
		
		self.headerView = [[HeaderView alloc] init];
		[self.headerView addCloseButton];
		[self addSubview:self.headerView];
		
		self.avatarView = [[UIImageView alloc] initWithFrame:self.bounds];
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
								   CGFloat sx = [self.avatarView w] / image.size.width;
								   CGFloat sy = [self.avatarView h] / image.size.height;
								   CGFloat s = fminf(sx, sy);
								   [self resizeTo:(s * image.size.height)];
							   }
							}];
	
	if (self.headerLabel) [self.headerLabel setText:[new_user full_name]];
}

- (void) setPost:(Post *)new_post {
	if ([new_post hasImages]) {
		NSLog(@"Setting Image to %@", [new_post image:0 size:@"o"]);
		[self.avatarView setImageWithURL:[NSURL URLWithString:[new_post image:0 size:@"o"]]
						placeholderImage:[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[new_post image:0 size:@"s"]]
							   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
								   if (!image) {
									   image = self.avatarView.image;
								   }
								   
								   if (self.should_resize && image) {
									   //Multiply the original image size by the given scale, and you'll get your actual displayed image size.
									   CGFloat sx = [self.avatarView w] / image.size.width;
									   CGFloat sy = [self.avatarView h] / image.size.height;
									   CGFloat s = fminf(sx, sy);
									   [self resizeTo:(s * image.size.height)];
								   }
							   }];
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.avatarView;
}

@end
