//
//  EditFilterView.h
//  Status
//
//  Created by Paul Denya on 4/30/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditFilterView : UIView <UITableViewDelegate, UITableViewDataSource> {
	User *user;
	PDObjectBlock filterStateChanged;
	UITableView *tableview;
}

@property (nonatomic, retain) User *user;
@property (readwrite, copy) PDObjectBlock filterStateChanged;
@property (nonatomic, retain) UITableView *tableview;

- (void)setInitialFilterState:(NSString *)filter_state;

@end
