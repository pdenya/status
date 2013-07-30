//
//  FilteredUsersView.h
//  Status
//
//  Created by Paul Denya on 3/13/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineView.h"

@interface FilteredUsersView : UIView <UITableViewDataSource, UITableViewDelegate, TimelineContainer> {
	NSMutableDictionary *filter;
	UITableView *tableview;
	NSMutableArray *keys;
	NSMutableDictionary *user_data;
	TimelineView *timeline;
	NSMutableArray *feed;
}

@property (nonatomic, retain) NSMutableDictionary *filter;
@property (nonatomic, retain) NSMutableArray *keys;
@property (nonatomic, retain) UITableView *tableview;
@property (nonatomic, retain) NSMutableDictionary *user_data;
@property (nonatomic, retain) TimelineView *timeline;
@property (nonatomic, retain) NSMutableArray *feed;

- (void)refreshFeed;

@end
