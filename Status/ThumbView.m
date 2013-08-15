//
//  ThumbView.m
//  Status
//
//  Created by Paul Denya on 5/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "ThumbView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

@implementation ThumbView
@synthesize image, user, post, imgview;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.layer.masksToBounds = YES;
		
		//standard images on the right of the cell
		if ([self w] == [self h]) {
			self.layer.cornerRadius = 2.0f;
			self.layer.borderColor = [UIColor brandMediumGrey].CGColor;
			self.layer.borderWidth = 1/[[UIScreen mainScreen] scale];
		}

		self.backgroundColor = [UIColor colorWithHex:0xa2caf1];
		
		self.imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment.png"]];
		self.imgview.frame = CGRectMake([self w] - [self h], 0, [self h], [self h]);
		
		[self addSubview:imgview];
    }
    return self;
}

- (void)setUser:(User *)new_user {
	user = new_user;
	
	[self.imgview setImageWithURL:[NSURL URLWithString:[user picSquareUrl]] placeholderImage:nil];
}

- (void)setPost:(Post *)new_post {
	post = new_post;
	
	[self.imgview setImageWithURL:[NSURL URLWithString:[[post.images objectAtIndex:0] objectForKey:@"src"]] placeholderImage:nil];
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
