//
//  UserAvatarView.h
//  Status
//
//  Created by Paul Denya on 3/14/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserAvatarView : UIView <UIScrollViewDelegate> {
	UIImageView *avatarView;
	NSMutableArray *urls;
	NSMutableArray *photos;
	UIView *headerView;
	UILabel *headerLabel;
}

@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) NSMutableArray *urls;
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UILabel *headerLabel;

- (void) setUser:(User *)new_user;
- (void) setPost:(Post *)new_post;
@end
