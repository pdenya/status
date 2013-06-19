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
@synthesize avatarView, urls, photos, headerView, headerLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.urls = [[NSMutableArray alloc] init];
		self.photos = [[NSMutableArray alloc] init];
		self.backgroundColor = [UIColor blackColor];
		
        // Initialization code
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
		[backButton addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
		
		self.headerLabel = [[UILabel alloc] init];
		self.headerLabel.text = @"";
		
		self.headerView = [UIView headerView:self.headerLabel leftButton:backButton rightButton:nil secondRightButton:nil thirdRightButton:nil];
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

- (void) setUser:(User *)new_user {
	[self.avatarView setImageWithURL:[NSURL URLWithString:[new_user picBigUrl]] placeholderImage:[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[new_user picSquareUrl]]];
	[self.headerLabel setText:[new_user full_name]];
}

- (void) setPost:(Post *)new_post {
	if ([new_post hasImages]) {
		[self.avatarView setImageWithURL:[NSURL URLWithString:[new_post image:0 size:@"o"]]
						placeholderImage:[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[new_post image:0 size:@"s"]]];
		//[self.headerLabel setText:[new_user full_name]];
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.avatarView;
}

@end
