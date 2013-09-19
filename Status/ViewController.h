//
//  ViewController.h
//  Status
//
//  Created by Paul Denya on 1/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBHelper.h"
#import "NewsFeedView.h"
#import "PostDetailsView.h"
#import "FilteredUsersView.h"
#import "FavoritesView.h"
#import "UnreadPostsView.h"

@class PostCreateView;

@interface ViewController : UIViewController {
	NewsFeedView *newsfeed;
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

@property (nonatomic, retain) NewsFeedView *newsfeed;
@property (nonatomic, retain) FavoritesView *favoritesview;
@property (nonatomic, retain) FilteredUsersView *filteredview;
@property (nonatomic, retain) UnreadPostsView *unreadview;
@property (nonatomic, retain) NSMutableArray *feed;
@property (nonatomic, retain) NSMutableDictionary *user_data;
@property (nonatomic, retain) NSMutableDictionary *filter;
@property (nonatomic, retain) NSMutableDictionary *favorites;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) PostCreateView *postcreate;
@property (readwrite) int total_failed;
@property (assign) BOOL is_done_loading;

+ (ViewController *)instance;
- (id)init;
- (void) openModal:(UIView *)view;
- (void) openModal:(UIView *)view fromPoint:(CGPoint)point;
- (void) closeModal:(id)sender;
- (UIView *)headerContainer;
- (CGRect) contentFrame;
- (void) showLearnMoreView;
- (void)refreshFeeds:(NSArray *)added_row_indexes;
- (void) upgraded;

@end
