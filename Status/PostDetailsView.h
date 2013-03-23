//
//  PostDetailsView.h
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostDetailsView : UIView<UITableViewDataSource,UITableViewDelegate> {
	Post *post;
	User *user;
	
	UITableView *tableview;
	NSMutableArray *comments;
	NSMutableDictionary *user_data;
}

@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) UITableView *tableview;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) NSMutableDictionary *user_data;

- (void)addedAsSubview;

@end
