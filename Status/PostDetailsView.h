//
//  PostDetailsView.h
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostCreateView;

@interface PostDetailsView : UIView<UITableViewDataSource,UITableViewDelegate> {
	Post *post;
	User *user;
	
	UITableView *tableview;
	NSMutableArray *comments;
	NSMutableDictionary *user_data;
}

@property (assign) Post *post;
@property (assign) User *user;
@property (nonatomic, retain) UITableView *tableview;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) NSMutableDictionary *user_data;
@property (nonatomic, retain) PostCreateView *postcreate;

- (void)addedAsSubview;
- (void)userAvatarViewResized:(NSNumber *)height_difference;

@end
