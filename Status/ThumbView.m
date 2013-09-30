//
//  ThumbView.m
//  Status
//
//  Created by Paul Denya on 5/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "ThumbView.h"
#import "ViewController.h"
#import "UserAvatarView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

@implementation ThumbView
@synthesize image, user, post, imgview;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		//self.layer.masksToBounds = YES;

		self.backgroundColor = [UIColor colorWithHex:0xa2caf1];
		
		self.imgview = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment.png"]] autorelease];
		self.imgview.frame = self.bounds;
		self.imgview.contentMode = UIViewContentModeScaleAspectFill;
		
		//standard images on the right of the cell
		if ([self w] == [self h]) {
			self.layer.cornerRadius = 2.0f;
			self.clipsToBounds = YES;
		}
		
		[self addSubview:imgview];
    }
    return self;
}

- (void)setUser:(User *)new_user {
	user = new_user;
	
	[self.imgview setImageWithURL:[NSURL URLWithString:[user picSquareUrl]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
		self.imgview.frame = self.bounds;
	}];
}

- (void)setPost:(Post *)new_post {
    [self setPost:new_post index:0];
}

- (void)setPost:(Post *)new_post index:(int)index {
    post = new_post;
	self.index = index;
    
    [self.imgview setImageWithURL:[NSURL URLWithString:[post image:index size:@"n"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
		self.imgview.frame = self.bounds;
	}];
}

- (void) makeTappable {
	self.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAvatar:)];
	doubletapgr.numberOfTouchesRequired = 1;
	doubletapgr.numberOfTapsRequired = 1;
	doubletapgr.cancelsTouchesInView = YES;
	doubletapgr.delaysTouchesBegan = NO;
	[self addGestureRecognizer:doubletapgr];
	[doubletapgr release];
}

- (void)zoomAvatar:(UITapGestureRecognizer *)gr {
	UserAvatarView *imgzoom = [[UserAvatarView alloc] init];
	[imgzoom setPost:self.post index:self.index];
	[[ViewController instance] openModal:imgzoom fromPoint:[gr locationOfTouch:0 inView:[ViewController instance].view]];
	[imgzoom release];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
