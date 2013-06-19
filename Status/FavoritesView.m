//
//  FavoritesView.m
//  Status
//
//  Created by Paul on 3/26/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FavoritesView.h"
#import "ThumbView.h"
#import "UserAvatarView.h"
#import "PostDetailsView.h"

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
		
		UILabel *headerLabel = [[UILabel alloc] init];
		[headerLabel setText:@"Favorites"];
		
		UIView *headerView = [UIView headerView:headerLabel leftButton:backButton rightButton:nil secondRightButton:nil thirdRightButton:nil];
		[self addSubview:headerView];
		
		self.tableview = [[UITableView alloc] initWithFrame:self.bounds];
		[self.tableview seth:[self.tableview h] - [headerView h]];
		[self.tableview sety:[headerView bottomEdge]];
		self.tableview.delegate = self;
		self.tableview.dataSource = self;
		[self addSubview:self.tableview];
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *fav_data = [self.favorites objectForKey:[self.keys objectAtIndex:[indexPath row]]];
	User *user = [[UsersHelper instance].users objectForKey:[fav_data objectForKey:@"uid"]];
	Post *post = [self postFromUser:user];
	CGFloat height = [post rowHeight];

	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.favorites count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    MCSwipeTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
	
	NSDictionary *fav_data = [self.favorites objectForKey:[self.keys objectAtIndex:[indexPath row]]];
	User *user = [[UsersHelper instance].users objectForKey:[fav_data objectForKey:@"uid"]];
	
	NSString *message = @"test";
	Post *post = [self postFromUser:user];
	
	message = post.message;
	
	[cell setOptions:@{
	 @"message":		message,
     @"name":			[NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name],
     @"user":			user,
	 @"has_comments":	[NSNumber numberWithBool:post.has_comments],
	 @"is_expanded":	[NSNumber numberWithBool:YES],
	 @"time":			post.time
	 }];
	
	[cell setDelegate:self];
	[cell setFirstStateIconName:@"comment_bubble.png"
                     firstColor:[UIColor colorWithHex:0x138dff]
            secondStateIconName:nil
                    secondColor:nil
                  thirdIconName:@"white_x.png"
                     thirdColor:[UIColor colorWithHex:0xCC0000]
                 fourthIconName:nil
                    fourthColor:nil];
	
	[cell setMode:MCSwipeTableViewCellModeExit];
	
	return cell;
}

- (Post *) postFromUser:(User *)user {
	Post *post;
	
	for (Post *p in [FeedHelper instance].feed) {
		NSString *post_uid = [NSString stringWithFormat:@"%@", p.uid];
		NSString *user_uid = [NSString stringWithFormat:@"%@", user.uid];
		if ([post_uid isEqualToString:user_uid]) {
			post = p;
			break;
		}
	}
	
	return post;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath	{
	
}

- (void)zoomAvatar:(id)sender {
	NSLog(@"zoomAvatar");
	
	UITapGestureRecognizer *gr = (UITapGestureRecognizer *)sender;
	UITableViewCell *cell = (UITableViewCell *)gr.view.superview.superview;
	NSIndexPath *index_path = [self.tableview indexPathForCell:cell];
	NSDictionary *fav_data = [self.favorites objectForKey:[self.keys objectAtIndex:[index_path row]]];
	User *user = [[UsersHelper instance].users objectForKey:[fav_data objectForKey:@"uid"]];
	
	UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:self.bounds];
	[avatarzoom setUser:user];
	[self addSubview:avatarzoom];
	[avatarzoom release];
}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode {
	if (state == MCSwipeTableViewCellState1) {
		NSLog(@"IndexPath : %@ - MCSwipeTableViewCellState : %d - MCSwipeTableViewCellMode : %d", [self.tableview indexPathForCell:cell], state, mode);
		NSIndexPath *index_path = [self.tableview indexPathForCell:cell];
		NSDictionary *fav_data = [self.favorites objectForKey:[self.keys objectAtIndex:[index_path row]]];
		User *user = [[UsersHelper instance].users objectForKey:[fav_data objectForKey:@"uid"]];
		
		PostDetailsView *details = [[PostDetailsView alloc] initWithFrame:self.bounds];
		details.post = [self postFromUser:user];
		details.user = user;
		
		[self addSubview:details];
		[details addedAsSubview];
		
		[self.tableview reloadRowsAtIndexPaths:@[[self.tableview indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
	}
	else if (state == MCSwipeTableViewCellState3) {
		NSIndexPath *index_path = [self.tableview indexPathForCell:cell];
		NSDictionary *fav_data = [self.favorites objectForKey:[self.keys objectAtIndex:[index_path row]]];
		
		EditFilterView *filterview = [[EditFilterView alloc] initWithFrame:self.bounds];
		filterview.user = [[UsersHelper instance].users objectForKey:[fav_data objectForKey:@"uid"]];;
		[self addSubview:filterview];
		
		[self.tableview reloadRowsAtIndexPaths:@[[self.tableview indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
	}
}

@end
