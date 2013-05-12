//
//  ThumbView.m
//  Status
//
//  Created by Paul Denya on 5/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "ThumbView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ThumbView
@synthesize image, user, post, imgview;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.layer.cornerRadius = 3.0f;
		self.layer.borderColor = [UIColor colorWithHex:0xa2caf1].CGColor;
		self.layer.borderWidth = 1.0f;
		self.layer.masksToBounds = YES;
		self.backgroundColor = [UIColor colorWithHex:0xa2caf1];
		
		self.imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment.png"]];
		self.imgview.frame = self.bounds;
    }
    return self;
}

- (void)setUser:(User *)new_user {
	user = new_user;

	if (user.image_square) {
		[self.imgview setImage:user.image_square];
	}
	else {
		
	}
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
