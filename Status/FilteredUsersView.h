//
//  FilteredUsersView.h
//  Status
//
//  Created by Paul Denya on 3/13/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilteredUsersView : UIView <UITableViewDataSource, UITableViewDelegate> {
	NSMutableDictionary *filter;
	UITableView *tableview;
	NSMutableArray *keys;
	NSMutableDictionary *user_data;
}

@property (nonatomic, retain) NSMutableDictionary *filter;
@property (nonatomic, retain) NSMutableArray *keys;
@property (nonatomic, retain) UITableView *tableview;
@property (nonatomic, retain) NSMutableDictionary *user_data;

@end
