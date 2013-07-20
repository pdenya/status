//
//  FilteredUsersView.m
//  Status
//
//  Created by Paul Denya on 3/13/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FilteredUsersView.h"
#import "EditFilterView.h"
#import "ThumbView.h"
#import "UserAvatarView.h"

@implementation FilteredUsersView
@synthesize filter, tableview, keys, user_data, timeline, feed;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
		self.filter = [FilterHelper instance].filter;
		NSLog(@"Got Filter\n %@", [self.filter description]);
		self.keys = [NSMutableArray arrayWithArray:[self.filter allKeys]];
		self.user_data = [UsersHelper instance].users;
		
		self.tableview = [[UITableView alloc] initWithFrame:self.bounds];
		self.tableview.delegate = self;
		self.tableview.dataSource = self;
		self.tableview.rowHeight = 113;
		[self addSubview:self.tableview];
		
		/*
		self.timeline = [[TimelineView alloc] initWithFrame:self.bounds];
		self.timeline.feed = self.feed;
		[self.timeline.tableview reloadData];
		[self addSubview:self.timeline];
		 */
    }
    return self;
}

- (void) refreshFeed {
	
	
	[self.keys removeAllObjects];
	[self.keys addObjectsFromArray:[self.filter allKeys]];
	
	[self.feed removeAllObjects];
	
	for (NSString *key in self.keys) {
		NSDictionary *filter_data = [self.filter objectForKey:key];
		User *user = [self.user_data objectForKey:[filter_data objectForKey:@"uid"]];
		//Post *post = [self postFromUser:user];
		//[self.feed addObject:post];
	}
	
	[self.timeline.tableview reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"rows in section: %i", [self.filter count]);
	return [self.filter count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell configureForTimeline];
		
		ThumbView *avatarView = [cell avatarView];
		avatarView.userInteractionEnabled = YES;
		UITapGestureRecognizer *doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAvatar:)];
		doubletapgr.numberOfTouchesRequired = 1;
		doubletapgr.numberOfTapsRequired = 2;
		doubletapgr.cancelsTouchesInView = YES;
		doubletapgr.delaysTouchesBegan = YES;
		[avatarView addGestureRecognizer:doubletapgr];
		[doubletapgr release];
    }
		
	NSDictionary *filter_data = [self.filter objectForKey:[self.keys objectAtIndex:[indexPath row]]];
	User *user = [self.user_data objectForKey:[filter_data objectForKey:@"uid"]];
	
	[cell setOptions:@{
		 @"message":		[FilterHelper stringForState:[filter_data objectForKey:@"state"]],
		 @"name":			[NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name],
		 @"user":			user
	 }];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath	{
    
	NSDictionary *filter_data = [self.filter objectForKey:[self.keys objectAtIndex:[indexPath row]]];
	User *user = [self.user_data objectForKey:[filter_data objectForKey:@"uid"]];
	
	NSLog(@"View Filter State for User %@ %@", user.first_name, user.last_name);
		
	EditFilterView *filterview = [[EditFilterView alloc] initWithFrame:self.bounds];
	filterview.user = user;
	
	[filterview setFilterStateChanged:^(NSDictionary *filter_update) {
		self.keys = [NSMutableArray arrayWithArray:[self.filter allKeys]];
		[self.tableview reloadData];
	}];
	[self addSubview:filterview];
}

- (void)zoomAvatar:(id)sender {
	NSLog(@"zoomAvatar");
	
	UITapGestureRecognizer *gr = (UITapGestureRecognizer *)sender;
	UITableViewCell *cell = (UITableViewCell *)gr.view.superview.superview;
	NSIndexPath *index_path = [self.tableview indexPathForCell:cell];
	NSDictionary *filter_data = [self.filter objectForKey:[self.keys objectAtIndex:[index_path row]]];
	User *user = [self.user_data objectForKey:[filter_data objectForKey:@"uid"]];
	
	UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[avatarzoom setUser:user];
	[self addSubview:avatarzoom];
	[avatarzoom release];
}

@end
