//
//  ViewController.m
//  Status
//
//  Created by Paul Denya on 1/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "ViewController.h"
#import "AuthView.h"
#import "LearnMoreView.h"
#import "PostCreateView.h"
#import "TimelineView.h"
#import "IAPHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize newsfeed, feed, user_data, total_failed, filter, favorites, headerView, favoritesview, filteredview, unreadview;

const int FAILED_THRESHOLD = 30;

+ (ViewController *)instance {
	static dispatch_once_t _singletonPredicate;
	static ViewController *_singleton = nil;
	
	dispatch_once(&_singletonPredicate, ^{
        _singleton = [[super allocWithZone:nil] init];
	});
	
	return _singleton;
}

- (id) init {
	self = [super init];
	
	if (self) {
		self.view.frame = [UIScreen mainScreen].bounds;
		self.is_done_loading = NO;
		
		//Auto Pro
		[PDUtils markAsPro];
	}

	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[AppHelper instance].vc = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
	
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	self.total_failed = 0;
	
	//[[FBHelper instance] logout];
	[self performSelectorInBackground:@selector(loadFeeds) withObject:nil];
	
	NSLog(@"viewWillAppear");
}

- (void) loadFeeds {
	[self load];
	//[self loadDemoData];
    
    self.filter = [FilterHelper instance].filter;
    self.user_data = [UsersHelper instance].users;
    self.favorites = [FavoritesHelper instance].favorites;
    self.feed = [FeedHelper instance].feed;
	
	[self filterFilter];
	
	self.is_done_loading = YES;
	
	[self performSelectorOnMainThread:@selector(auth) withObject:nil waitUntilDone:NO];
	
	if (![PDUtils isPro]) {
		[IAPHelper instance];
	}
}

- (void)auth {
	FBHelper *fb = [FBHelper instance];
	
	void (^fb_success)(void) = ^ {
		[self streamRefreshInterval];
		[self showNewsFeed];
	};
	
	if (FBSession.activeSession.isOpen) {
		NSLog(@"active session");
		fb_success();
    }
	else {
		[fb openSession:fb_success
		   allowLoginUI:NO
				 onFail:^{
					 NSLog(@"showAuth");
					 AuthView *authview = [[AuthView alloc] initWithFrame:self.view.bounds];
					 authview.success = fb_success;
					 [self.view addSubview:authview];
				 }
		 ];
	}
}

- (UIView<TimelineContainer> *) activeView {
	if (self.favoritesview && self.favoritesview.superview) {
		return self.favoritesview;
	}
	else if (self.filteredview && self.filteredview.superview) {
		return self.filteredview;
	}
	else if (self.newsfeed && self.newsfeed.superview) {
		return self.newsfeed;
	}
	else if (self.unreadview && self.unreadview.superview) {
		return self.unreadview;
	}
	
	return nil;
}

- (void) removeActiveView {
	if ([self activeView]) {
		[[self activeView] removeFromSuperview];
	}
}

- (void) updateNav {
	NSString *c = [[[self activeView] class] description];
	
	[(UIButton *)[self.headerView viewWithTag:70] setImage:[UIImage imageNamed:@"icon_home.png"] forState:UIControlStateNormal];
	[(UIButton *)[self.headerView viewWithTag:71] setImage:[UIImage imageNamed:@"icon_favorite.png"] forState:UIControlStateNormal];
	[(UIButton *)[self.headerView viewWithTag:72] setImage:[UIImage imageNamed:@"icon_filter.png"] forState:UIControlStateNormal];
	[(UIButton *)[self.headerView viewWithTag:73] setImage:[UIImage imageNamed:@"icon_unread.png"] forState:UIControlStateNormal];
	[(UIButton *)[self.headerView viewWithTag:74] setImage:[UIImage imageNamed:@"icon_new_post.png"] forState:UIControlStateNormal];
	
	if ([c isEqualToString:@"NewsFeedView"]) {
		[(UIButton *)[self.headerView viewWithTag:70] setImage:[UIImage imageNamed:@"icon_home_active.png"] forState:UIControlStateNormal];
	}
	else if ([c isEqualToString:@"FavoritesView"]) {
		[(UIButton *)[self.headerView viewWithTag:71] setImage:[UIImage imageNamed:@"icon_favorite_active.png"] forState:UIControlStateNormal];
	}
	else if ([c isEqualToString:@"FilteredUsersView"]) {
		[(UIButton *)[self.headerView viewWithTag:72] setImage:[UIImage imageNamed:@"icon_filter_active.png"] forState:UIControlStateNormal];
	}
	else if ([c isEqualToString:@"UnreadPostsView"]) {
		[(UIButton *)[self.headerView viewWithTag:73] setImage:[UIImage imageNamed:@"icon_unread_active.png"] forState:UIControlStateNormal];
	}
	
	NSLog(@"updateNav %@", c);
	
	[self.view bringSubviewToFront:self.headerView];
}

//todo: combine these show methods

- (void) showNewsFeed {
	if (!self.headerView) {
		self.headerView = [self makeHeader];
		[self.view addSubview:self.headerView];
	}
	
	if (!self.newsfeed) {
		self.newsfeed = [[NewsFeedView alloc] initWithFrame:[self contentFrame]];
	}
	else {
		[self.newsfeed refreshFeed];
	}
	
	[self removeActiveView];
	
	if (!self.newsfeed.superview) {
		[self.view addSubview:self.newsfeed];
	}
	
	[self updateNav];
}

- (void) showFavorites {
	if (!self.favoritesview) {
		self.favoritesview = [[FavoritesView alloc] initWithFrame:[self contentFrame]];
	}
	else {
		[self.favoritesview refreshFeed];
	}
	
	[self removeActiveView];
	
	if (!self.favoritesview.superview) {
		[self.view addSubview:self.favoritesview];
	}
	
	[self.view bringSubviewToFront:self.favoritesview];
	[self updateNav];
}

- (void) showFilter {
	if (!self.filteredview) {
		self.filteredview = [[FilteredUsersView alloc] initWithFrame:[self contentFrame]];
	}
	else {
		[self.filteredview refreshFeed];
	}
	
	[self removeActiveView];
	
	if (!self.filteredview.superview) {
		[self.view addSubview:self.filteredview];
	}
	
	[self.view bringSubviewToFront:self.filteredview];
	[self updateNav];
}

- (void) showUnread {
	if (!self.unreadview) {
		self.unreadview = [[UnreadPostsView alloc] initWithFrame:[self contentFrame]];
	}
	else {
		[self.unreadview refreshFeed];
	}
	
	[self removeActiveView];
	
	if (!self.unreadview.superview) {
		[self.view addSubview:self.unreadview];
	}
	
	[self.view bringSubviewToFront:self.unreadview];
	[self updateNav];
}

- (void) showLearnMoreView {
	LearnMoreView *learnmore = [[LearnMoreView alloc] initWithFrame:self.view.bounds];
	[self openModal:learnmore];
}

- (void) showNewPost {
	if (!self.postcreate) {
		self.postcreate = [[PostCreateView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	}
	
	[self openModal:self.postcreate];
	[self.postcreate addedAsSubview:@{}];
	//[self.postcreate release];
}

- (void) upgraded {
	if (self.favoritesview) {
		[self.favoritesview addUpgradeHeader];
		[self.favoritesview.timeline.tableview reloadData];
	}
	
	if (self.filteredview) {
		[self.filteredview addUpgradeHeader];
		[self.filteredview.timeline.tableview reloadData];
	}
	
	if (self.unreadview) {
		[self.unreadview addUpgradeHeader];
		[self.unreadview.timeline.tableview reloadData];
	}
}

- (CGRect) contentFrame {
	return CGRectMake(0, [self.headerView bottomEdge], [self.view w], [self.view h] - [self.headerView bottomEdge]);
}

- (UIView *)headerContainer {
	//TODO update this to use HeaderView class
	UIView *header_view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[header_view seth:SYSTEM_VERSION_LESS_THAN(@"7.0") ? 35 : 50];
	header_view.backgroundColor = [UIColor colorWithHex:0xf1f0f0];
	
	CALayer *bottomBorder = [CALayer layer];
	bottomBorder.frame = CGRectMake(0.0f, [header_view h] - 0.5f, [header_view w], 0.5f);
	bottomBorder.backgroundColor = [UIColor brandMediumGrey].CGColor;
	[header_view.layer addSublayer:bottomBorder];
	
	return header_view;
}

- (UIView *)makeHeader {
	UIView *header_view = [self headerContainer];
	
	int btn_height = 42;

	int header_adjust = SYSTEM_VERSION_LESS_THAN(@"7.0") ? 0 : 19;
	int btn_y = ((([header_view h] - header_adjust) / 2)  - (btn_height / 2)) + header_adjust;
	int btn_offset = 0;
	int btn_inset = 1;
	UIEdgeInsets insets = UIEdgeInsetsMake(btn_inset, btn_inset, btn_inset, btn_inset); //top left bottom right
	
	UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[homeButton setImageEdgeInsets:insets];
	[header_view addSubview:homeButton];
	homeButton.frame = CGRectMake(btn_offset, btn_y, btn_height, btn_height);
	[homeButton addTarget:self action:@selector(showNewsFeed) forControlEvents:UIControlEventTouchUpInside];
	homeButton.tag = 70;
	
	UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[favoriteButton setImageEdgeInsets:insets];
	[header_view addSubview:favoriteButton];
	favoriteButton.frame = CGRectMake([homeButton rightEdge] + btn_offset, btn_y, btn_height, btn_height);
	[favoriteButton addTarget:self action:@selector(showFavorites) forControlEvents:UIControlEventTouchUpInside];
	favoriteButton.tag = 71;
	
	UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[filterButton setImageEdgeInsets:insets];
	[header_view addSubview:filterButton];
	filterButton.frame = CGRectMake([favoriteButton rightEdge] + btn_offset, btn_y, btn_height, btn_height);
	[filterButton addTarget:self action:@selector(showFilter) forControlEvents:UIControlEventTouchUpInside];
	filterButton.tag = 72;
	
	UIButton *unreadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[unreadButton setImageEdgeInsets:insets];
	[header_view addSubview:unreadButton];
	unreadButton.frame = CGRectMake([filterButton rightEdge] + btn_offset, btn_y + (1.0f/[[UIScreen mainScreen] scale]), btn_height, btn_height);
	[unreadButton addTarget:self action:@selector(showUnread) forControlEvents:UIControlEventTouchUpInside];
	unreadButton.tag = 73;
	
	UIButton *newPostButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[newPostButton setImageEdgeInsets:insets];
	[header_view addSubview:newPostButton];
	newPostButton.frame = CGRectMake([header_view w] - (btn_height + btn_offset), btn_y + (1.0f/[[UIScreen mainScreen] scale]), btn_height, btn_height);
	[newPostButton addTarget:self action:@selector(showNewPost) forControlEvents:UIControlEventTouchUpInside];
	newPostButton.tag = 74;
	
	return header_view;
}

//once called, this method polls fb
-(void)streamRefreshInterval {
	if (self.is_done_loading) {
		[[FeedHelper instance] refresh];
		[self performSelector:@selector(streamRefreshInterval) withObject:nil afterDelay:30.0f];
	}
	else {
		[self performSelector:@selector(streamRefreshInterval) withObject:nil afterDelay:1.0f];
	}
}

- (void)filterFilter {
	NSMutableArray *to_remove = [[NSMutableArray alloc] init];
	
	for (NSString *user_key in self.filter) {
		NSDictionary *f = [self.filter objectForKey:user_key];
		
		NSDate *cutoff = nil;
		NSDate *start = [f objectForKey:@"start"];
		
		if ([[f objectForKey:@"state"]  isEqualToString:FILTER_STATE_FILTERED_WEEK]) {
			//edge cases where this fails exist but who cares stackoverflow.com/questions/10209427/subtract-7-days-from-current-date
			cutoff = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
		}
		else if ([[f objectForKey:@"state"]  isEqualToString:FILTER_STATE_FILTERED_DAY]) {
			//edge cases where this fails exist but who cares stackoverflow.com/questions/10209427/subtract-7-days-from-current-date
			cutoff = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];
		}
		
		if (cutoff != nil && (![start isKindOfClass:[NSDate class]] || [start compare:cutoff] == NSOrderedAscending)) {
			[to_remove addObject:user_key];
		}
	}
	
	[self.filter removeObjectsForKeys:to_remove];
}

- (void)refreshFeeds:(NSArray *)added_row_indexes {
	//TODO: pass added_row_index to the tableviews for better handling
	//[self.timelineview.tableview beginUpdates];
	//[self.timelineview.tableview insertRowsAtIndexPaths:added_rows withRowAnimation:UITableViewRowAnimationAutomatic];
	//[self.timelineview.tableview endUpdates];
	
	[[self activeView] refreshFeed];
}

- (void) openModal:(UIView *)view {
	view.tag = 50;
	[self.view addAndGrowSubview:view];
	[self.view bringSubviewToFront:view];
}

- (void) closeModal:(id)sender {
	//sender or viewWithTag:50
	NSLog(@"sender tag %i", ((UIView *)sender).tag);
	UIView *view = [sender isKindOfClass:[UIView class]] && ((UIView *)sender).tag == 50 ? (UIView *)sender : [self.view viewWithTag:50];
	[view shrinkAndRemove];
	
	if (self.favoritesview && self.favoritesview.superview) {
		[self.favoritesview refreshFeed];
	}
}


- (void)save {
    [[FeedHelper    instance] save];
    [[FavoritesHelper instance] save];
    [[UsersHelper   instance] save];
    [[FilterHelper  instance] save];
}

- (void)load {
	[[UsersHelper   instance] load];
    [[FilterHelper  instance] load];
	[[FeedHelper    instance] load];
    [[FavoritesHelper instance] load];
}

@end