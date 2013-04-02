//
//  TimelineView.m
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "PostCreateView.h"
#import "PostDetailsView.h"
#import "UserFilterView.h"
#import "TimelineView.h"
#import "UserAvatarView.h"
#import <QuartzCore/QuartzCore.h>


@implementation TimelineView
@synthesize feed, user_data, tableview, expanded, filter, filterButtonClicked, favoriteButtonClicked;

const int NUM_LINES_BEFORE_CLIP = 5;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.tableview = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
		self.tableview.delegate = self;
		self.tableview.dataSource = self;
		self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
		[self.tableview seth:[self h] - 50];
		[self.tableview sety:50];
		[self addSubview:self.tableview];
		
		self.feed = [FeedHelper instance].feed;
		self.user_data = [UsersHelper instance].users;
		self.expanded = [[NSMutableArray alloc] init];
		self.filter = [FilterHelper instance].filter;
		
		UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[postButton setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
		[postButton addTarget:self action:@selector(showPostCreateView) forControlEvents:UIControlEventTouchUpInside];
		
		UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[filterButton setImage:[UIImage imageNamed:@"filter.png"] forState:UIControlStateNormal];
		[filterButton addTarget:self action:@selector(didClickFilterButton) forControlEvents:UIControlEventTouchUpInside];
		
		UIButton *favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[favoritesButton setImage:[UIImage imageNamed:@"favorites.png"] forState:UIControlStateNormal];
		[favoritesButton addTarget:self action:@selector(didClickFavoritesButton) forControlEvents:UIControlEventTouchUpInside];
		
		UIView *headerView = [UIView headerView:nil leftButton:nil rightButton:postButton secondRightButton:filterButton thirdRightButton:favoritesButton];
		
		//tableview.tableHeaderView = headerView; //can scroll offscreen
		[self addSubview:headerView]; //fixed top position, does not scroll offscreen
    }
    return self;
}


- (NSString *)stringFromIndexPath:(NSIndexPath *)indexPath {
	return [NSString stringWithFormat:@"%i", indexPath.row];
}


-(void)didClickFilterButton {
	if (self.filterButtonClicked) {
		self.filterButtonClicked();
	}
}

-(void)didClickFavoritesButton {
	NSLog(@"Favorite Button Clicked");
}

- (void)showPostCreateView {
	PostCreateView *postcreateview = [[[PostCreateView alloc] initWithFrame:self.bounds] autorelease];
	[self addSubview:postcreateview];
	[self bringSubviewToFront:postcreateview];
	[postcreateview addedAsSubview:@{ @"autofocus": [NSNumber numberWithBool:YES] }];
	postcreateview.postClicked = ^{
		FBHelper *fb = [FBHelper instance];
		[fb postStatus:postcreateview.messageTextField.text completed:^(NSArray *response) {
			//nothing
			[postcreateview removeFromSuperview];
		}];
	};
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self clipHeight] < [self heightForRow:[indexPath row]] ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"didSelectRowAtIndexPath start expanded: %@", [self.expanded description]);
	
	if ([self.expanded containsObject:[self stringFromIndexPath:indexPath]]) {
		[self.expanded removeObject:[self stringFromIndexPath:indexPath]];
		[self reloadRows:@[indexPath]];
	}
	else {
		//for now I guess
		NSMutableArray *to_reload = [[NSMutableArray alloc] init];
		for (int i = 0; i < [self.expanded count]; i++) {
			//split the nsindexpath format back into a row int
			NSInteger row = [[self.expanded objectAtIndex:i] integerValue];
			[to_reload addObject:[NSIndexPath indexPathForRow:row inSection:0]];
		}
		
		[self.expanded removeAllObjects];
		[self.expanded addObject:[self stringFromIndexPath:indexPath]];
		[to_reload addObject:indexPath];
		[self reloadRows:to_reload];
	}
}

- (void)reloadRows:(NSArray *)to_reload {
	[tableview beginUpdates];
	[self.tableview reloadRowsAtIndexPaths:to_reload withRowAnimation:UITableViewRowAnimationFade];
	[tableview endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = [self heightForRow:[indexPath row]];
	return [self.expanded containsObject:[self stringFromIndexPath:indexPath]] ? height : MIN([self clipHeight] + 40, height);
}

- (CGFloat)heightForRow:(int)row {
	Post *post = [self.feed objectAtIndex:row];
	CGFloat height = [post.message sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(round([self w] * .75), FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
	
	height = MAX(43, height) + 40;
	
	return height;
}

- (CGFloat)clipHeight {
	//NSLog(@"clipHeight is %f", [@"some test string" sizeWithFont:[UIFont systemFontOfSize:15.0f]].height * NUM_LINES_BEFORE_CLIP);
	return [@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" sizeWithFont:[UIFont systemFontOfSize:15.0f]].height * NUM_LINES_BEFORE_CLIP;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.feed count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"cellForRowAtIndexPath %i", [indexPath row]);
	static NSString *CellIdentifier = @"Cell";
    
    MCSwipeTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		[cell configureForTimeline];
		
		UIImageView *avatarView = [cell avatarView];
		
		avatarView.userInteractionEnabled = YES;
		UITapGestureRecognizer *doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAvatar:)];
		doubletapgr.numberOfTouchesRequired = 1;
		doubletapgr.numberOfTapsRequired = 2;
		doubletapgr.cancelsTouchesInView = YES;
		doubletapgr.delaysTouchesBegan = YES;
		[avatarView addGestureRecognizer:doubletapgr];
		[doubletapgr release];
    }
	
    Post *post = [self.feed objectAtIndex:[indexPath row]];
	User *user = [self.user_data objectForKey:post.uid];
	
	[cell setOptions:@{
		@"message":			post.message,
		@"is_expanded":		[NSNumber numberWithBool:[self.expanded containsObject:[self stringFromIndexPath:indexPath]]],
		@"name":			[NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name],
		@"has_comments":	[NSNumber numberWithBool:post.has_comments],
		@"time":			post.time,
		@"avatar":			user.image_square != nil ? user.image_square : [NSNumber numberWithInt:0] //stupid hack because nil can't exist in nsdictionary
	}];
	
	//set profile pic
	if (user.image_square == nil) {
		//hacky polling
		if (![User reachedFailureThreshold]) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				[self.tableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			});
		}
	}
	
	
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

- (void)zoomAvatar:(id)sender {
	NSLog(@"zoomAvatar");
	
	UITapGestureRecognizer *gr = (UITapGestureRecognizer *)sender;
	UITableViewCell *cell = (UITableViewCell *)gr.view.superview.superview;
	NSIndexPath *index_path = [self.tableview indexPathForCell:cell];
	Post *post = [self.feed objectAtIndex:[index_path row]];
	User *user = [self.user_data objectForKey:post.uid];
	
	UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:self.bounds];
	avatarzoom.avatarView.image = user.image_square;
	avatarzoom.avatarView.backgroundColor = [UIColor blackColor];
	
	[user loadPicBig:^{
		if (avatarzoom) {
			NSLog(@"LOADED BIG PIC");
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
				[avatarzoom.avatarView setImage:user.image_big];
			});
		}
	}];
	
	[self addSubview:avatarzoom];
	[avatarzoom release];
}

- (void)viewComments:(id)sender {
	NSLog(@"view comments");
	
	NSIndexPath *index_path = (NSIndexPath *)sender;
	PostDetailsView *details = [[PostDetailsView alloc] initWithFrame:self.bounds];
	details.post = [self.feed objectAtIndex:index_path.row];
	details.user = [self.user_data objectForKey:details.post.uid];
	
	[self addSubview:details];
	[details addedAsSubview];
}

- (void)viewFilterControls:(NSString *)uid {
	UserFilterView *filterview = [[UserFilterView alloc] initWithFrame:self.bounds];
	filterview.user = [self.user_data objectForKey:uid];
	[filterview setInitialFilterState:FILTER_STATE_VISIBLE];
	[filterview setFilterStateChanged:^(NSDictionary *filter_update) {
		NSString *state = [filter_update objectForKey:@"state"];
		NSString *uid = [NSString stringWithFormat:@"%@", [filter_update objectForKey:@"uid"]];
		
		if ([state isEqualToString:@"visible"]) {
			[self.filter removeObjectForKey:uid];
		}
		else { //filtered, filtered_day, filtered_week
			[self.filter setObject:filter_update forKey:uid];
			NSLog(@"filter description %@", [self.filter description]);
			
			//remove filtered user's posts from feed
			NSMutableIndexSet *to_remove = [[NSMutableIndexSet alloc] init];
			for (int i = 0; i < [self.feed count]; i++) {
				Post *post = [self.feed objectAtIndex:i];
				NSString *postuid = [NSString stringWithFormat:@"%@", post.uid];
				
				if ([postuid isEqualToString:uid]) {
					[to_remove addIndex:i];
				}
			}
			[self.feed removeObjectsAtIndexes:to_remove];
		}
		
		[self.tableview reloadData];
		
	}];
	[self addSubview:filterview];
}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode {
	if (state == MCSwipeTableViewCellState1) {
		NSLog(@"IndexPath : %@ - MCSwipeTableViewCellState : %d - MCSwipeTableViewCellMode : %d", [self.tableview indexPathForCell:cell], state, mode);
		[self viewComments:[self.tableview indexPathForCell:cell]];
		[self.tableview reloadRowsAtIndexPaths:@[[self.tableview indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
	}
	else if (state == MCSwipeTableViewCellState3) {
		Post *post = [self.feed objectAtIndex:[self.tableview indexPathForCell:cell].row];
		
		[self viewFilterControls:post.uid];
		[self.tableview reloadRowsAtIndexPaths:@[[self.tableview indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
	}
}

@end
