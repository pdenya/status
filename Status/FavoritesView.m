//
//  FavoritesView.m
//  Status
//
//  Created by Paul on 3/26/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FavoritesView.h"

@implementation FavoritesView
@synthesize tableview;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.tableview = [[UITableView alloc] initWithFrame:self.bounds];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[FavoritesHelper instance].favorites count];
}

/*
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
*/

@end
