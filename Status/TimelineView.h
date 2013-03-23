//
//  TimelineView.h
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@interface TimelineView : UIView <UITableViewDataSource, UITableViewDelegate, MCSwipeTableViewCellDelegate> {
	NSMutableDictionary *user_data;
	NSMutableArray *feed;
	UITableView *tableview;
	NSMutableArray *expanded;
	NSMutableDictionary *filter;
	PDBlock filterButtonClicked;
    PDObjectBlock favoriteButtonClicked;
}

@property (nonatomic, retain) NSMutableDictionary *user_data;
@property (nonatomic, retain) NSMutableArray *feed;
@property (nonatomic, retain) UITableView *tableview;
@property (nonatomic, retain) NSMutableArray *expanded;
@property (nonatomic, retain) NSMutableDictionary *filter;
@property (readwrite, copy) PDBlock filterButtonClicked;
@property (readwrite, copy) PDObjectBlock favoriteButtonClicked;

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode;

@end
