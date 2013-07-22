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
#import "UnreadPostsView.h"

@interface ViewController : UIViewController {
	TimelineView *timelineview;
	FavoritesView *favoritesview;
	FilteredUsersView *filteredview;
	UnreadPostsView *unreadview;
	NSMutableArray *feed;
	NSMutableDictionary *user_data;
	NSMutableDictionary *filter;
	NSMutableDictionary *favorites;
	UIView *headerView;
	int total_failed;
}

@property (nonatomic, retain) TimelineView *timelineview;
@property (nonatomic, retain) FavoritesView *favoritesview;
@property (nonatomic, retain) FilteredUsersView *filteredview;
@property (nonatomic, retain) UnreadPostsView *unreadview;
@property (nonatomic, retain) NSMutableArray *feed;
@property (nonatomic, retain) NSMutableDictionary *user_data;
@property (nonatomic, retain) NSMutableDictionary *filter;
@property (nonatomic, retain) NSMutableDictionary *favorites;
@property (nonatomic, retain) UIView *headerView;
@property (readwrite) int total_failed;

+ (ViewController *)instance;
- (id)init;
- (void) openModal:(UIView *)view;
- (void) closeModal:(id)sender;
- (UIView *)headerContainer;
- (CGRect) contentFrame;
- (void) showLearnMoreView;

@end
