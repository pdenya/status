//
//  FavoritesView.h
//  Status
//
//  Created by Paul on 3/26/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditFilterView.h"

@interface FavoritesView : UIView <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tableview;
	NSMutableDictionary *favorites;
	NSMutableArray *keys;
}

@property (nonatomic, retain) UITableView *tableview;
@property (nonatomic, retain) NSMutableDictionary *favorites;
@property (nonatomic, retain) NSMutableArray *keys;

@end
