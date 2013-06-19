//
//  ViewController.h
//  Status
//
//  Created by Paul Denya on 1/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBHelper.h"
#import "TimelineView.h"
#import "PostDetailsView.h"
#import "FilteredUsersView.h"
#import "FavoritesView.h"


@interface ViewController : UIViewController <UITableViewDataSource,UITableViewDelegate> {
	TimelineView *timelineview;
	NSMutableArray *feed;
	NSMutableDictionary *user_data;
	NSMutableDictionary *filter;
	NSMutableDictionary *favorites;
	int total_failed;
}

@property (nonatomic, retain) TimelineView *timelineview;
@property (nonatomic, retain) NSMutableArray *feed;
@property (nonatomic, retain) NSMutableDictionary *user_data;
@property (nonatomic, retain) NSMutableDictionary *filter;
@property (nonatomic, retain) NSMutableDictionary *favorites;
@property (readwrite) int total_failed;

@end
