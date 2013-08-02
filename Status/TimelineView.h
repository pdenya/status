//
//  TimelineView.h
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"
#import "ZKRevealingTableViewCell.h"
#import "RevealedView.h"

@protocol TimelineContainer
-(void)refreshFeed;
@end

@interface TimelineView : UIView <UITableViewDataSource, UITableViewDelegate, ZKRevealingTableViewCellDelegate> {
	NSMutableDictionary *user_data;
	NSMutableArray *feed;
	UITableView *tableview;
	NSMutableDictionary *filter;
	PDBlock filterButtonClicked;
    PDBlock favoriteButtonClicked;
}

@property (nonatomic, retain) NSMutableDictionary *user_data;
@property (nonatomic, retain) NSMutableArray *feed;
@property (nonatomic, retain) UITableView *tableview;
@property (nonatomic, retain) NSMutableDictionary *filter;
@property (readwrite, copy) PDBlock filterButtonClicked;
@property (readwrite, copy) PDBlock favoriteButtonClicked;
@property (nonatomic, strong) ZKRevealingTableViewCell *currentlyRevealedCell;
@property (assign) BOOL isSnappingBack;
@property (assign) int max_free_rows;

- (void) setUpgradeHeader:(NSDictionary *)options;

@end
