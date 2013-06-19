//
//  FavoritesView.h
//  Status
//
//  Created by Paul on 3/26/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditFilterView.h"
#import "MCSwipeTableViewCell.h"

@interface FavoritesView : UIView <UITableViewDataSource, UITableViewDelegate, MCSwipeTableViewCellDelegate> {
    UITableView *tableview;
	NSMutableDictionary *favorites;
	NSMutableArray *keys;
}

@property (nonatomic, retain) UITableView *tableview;
@property (nonatomic, retain) NSMutableDictionary *favorites;
@property (nonatomic, retain) NSMutableArray *keys;

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode;

@end
