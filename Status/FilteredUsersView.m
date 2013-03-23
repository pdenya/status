//
//  FilteredUsersView.m
//  Status
//
//  Created by Paul Denya on 3/13/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FilteredUsersView.h"
#import "UserFilterView.h"

@implementation FilteredUsersView
@synthesize filter, tableview, keys, user_data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
		self.filter = [[NSMutableDictionary alloc] init];
		self.user_data = [[NSMutableDictionary alloc] init];
		
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
		[backButton addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];

		UIView *headerView = [UIView headerView:nil leftButton:backButton rightButton:nil secondRightButton:nil thirdRightButton:nil];
		[self addSubview:headerView];
		
		self.tableview = [[UITableView alloc] initWithFrame:self.bounds];
		[self.tableview seth:[self.tableview h] - [headerView h]];
		[self.tableview sety:[headerView bottomEdge]];
		self.tableview.delegate = self;
		self.tableview.dataSource = self;
		self.tableview.rowHeight = 83;
		[self addSubview:self.tableview];
    }
    return self;
}

- (void)setFilter:(NSMutableDictionary *)new_filter {
	filter = new_filter;
	self.keys = [NSMutableArray arrayWithArray:[new_filter allKeys]];
	NSLog(@"keys %@", [self.keys description]);
	
	if (self.tableview) {
		[self.tableview reloadData];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"rows in section: %i", [self.keys count]);
	return [self.keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell configureForTimeline];
    }
	
	NSNumber *uid = [NSNumber numberWithInteger:[[self.keys objectAtIndex:[indexPath row]] integerValue]];
	
	User *user = [self.user_data objectForKey:uid];
	
	[cell setOptions:@{
		 @"name":			[NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name],
		 @"avatar":			user.image_square != nil ? user.image_square : [NSNumber numberWithInt:0] //stupid hack because nil can't exist in nsdictionary
	 }];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath	{
	NSNumber *uid = [NSNumber numberWithInteger:[[self.keys objectAtIndex:[indexPath row]] integerValue]];
	User *user = [self.user_data objectForKey:uid];
	NSLog(@"View Filter State for User %@ %@", user.first_name, user.last_name);
	
	NSDictionary *filter_state = [self.filter objectForKey:[uid stringValue]];
	
	UserFilterView *filterview = [[UserFilterView alloc] initWithFrame:self.bounds];
	filterview.user = [self.user_data objectForKey:uid];
	
	[filterview setInitialFilterState:[filter_state objectForKey:@"state"]];
	[filterview setFilterStateChanged:^(NSDictionary *filter_update) {
		NSString *state = [filter_update objectForKey:@"state"];
		NSString *uid = [NSString stringWithFormat:@"%@", [filter_update objectForKey:@"uid"]];
		
		if ([state isEqualToString:@"visible"]) {
			[self.filter removeObjectForKey:uid];
		}
		else { //filtered, filtered_day, filtered_week
			[self.filter setObject:filter_update forKey:uid];
		}
		
		[self.tableview reloadData];
		
	}];
	[self addSubview:filterview];
	
}

@end
