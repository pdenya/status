//
//  UserAvatarView.m
//  Status
//
//  Created by Paul Denya on 3/14/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "UserAvatarView.h"

@implementation UserAvatarView
@synthesize avatarView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
		[backButton addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
		
		UIView *headerView = [UIView headerView:nil leftButton:backButton rightButton:nil secondRightButton:nil thirdRightButton:nil];
		[self addSubview:headerView];
		
		self.avatarView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self.avatarView sety:[headerView bottomEdge]];
		[self.avatarView seth:[self h] - [self.avatarView y]];
		self.avatarView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:self.avatarView];
    }
    return self;
}

@end
