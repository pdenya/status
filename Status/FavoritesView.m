//
//  FavoritesView.m
//  Status
//
//  Created by Paul on 3/26/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FavoritesView.h"

@implementation FavoritesView
@synthesize tableview, favorites, keys;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.favorites = [FavoritesHelper instance].favorites;
		self.keys = [NSMutableArray arrayWithArray:[self.favorites allKeys]];
		
		self.backgroundColor = [UIColor whiteColor];
		
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.favorites count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell configureForTimeline];
    }
	
	NSDictionary *fav_data = [self.favorites objectForKey:[self.keys objectAtIndex:[indexPath row]]];
	User *user = [[UsersHelper instance].users objectForKey:[fav_data objectForKey:@"uid"]];
	
	NSString *message = @"test";
	
	for (Post *post in [FeedHelper instance].feed) {
		NSString *post_uid = [NSString stringWithFormat:@"%@", post.uid];
		NSString *user_uid = [NSString stringWithFormat:@"%@", user.uid];
		if ([post_uid isEqualToString:user_uid]) {
			message = post.message;
			break;
		} else {
			NSLog(@"%@ %@", post.uid, user.uid);
		}
	}
	
	[cell setOptions:@{
	 @"message":		message,
     @"name":			[NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name],
     @"avatar":			user.image_square != nil ? user.image_square : [NSNumber numberWithInt:0] //stupid hack because nil can't exist in nsdictionary
	 }];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath	{
	NSDictionary *fav_data = [self.favorites objectForKey:[self.keys objectAtIndex:[indexPath row]]];
	User *user = [[UsersHelper instance].users objectForKey:[fav_data objectForKey:@"uid"]];
	
	NSLog(@"View Filter State for User %@ %@", user.first_name, user.last_name);
	
	EditFilterView *filterview = [[EditFilterView alloc] initWithFrame:self.bounds];
	filterview.user = user;
	
	[self addSubview:filterview];
	
}


@end
