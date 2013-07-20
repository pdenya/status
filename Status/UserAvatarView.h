//
//  UserAvatarView.h
//  Status
//
//  Created by Paul Denya on 3/14/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface UserAvatarView : UIView <UIScrollViewDelegate> {
	UIImageView *avatarView;
	NSMutableArray *urls;
	NSMutableArray *photos;
	HeaderView *headerView;
	UILabel *headerLabel;
}

@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) NSMutableArray *urls;
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) HeaderView *headerView;
@property (nonatomic, retain) UILabel *headerLabel;
@property (readwrite) BOOL should_resize;


- (void) setUser:(User *)new_user;
- (void) setPost:(Post *)new_post;
- (void) hideHeader;
@end
