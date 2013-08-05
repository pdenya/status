//
//  TimelineView.m
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "PostCreateView.h"
#import "PostDetailsView.h"
#import "TimelineView.h"
#import "UserAvatarView.h"
#import "ThumbView.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UpgradeHeader.h"

@implementation TimelineView
@synthesize feed, user_data, tableview, filter, filterButtonClicked, favoriteButtonClicked;

const int NUM_LINES_BEFORE_CLIP = 5;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.tableview = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
		self.tableview.delegate = self;
		self.tableview.dataSource = self;
		self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.tableview.separatorColor = [UIColor colorWithHex:0x3e9ed5];
		self.tableview.backgroundColor = [UIColor whiteColor];
		self.max_free_rows = 0;
		self.removeWhenFiltered = NO;
		[self.tableview setTableFooterView:[UIView new]];
		[self addSubview:self.tableview];
		
		self.feed = [FeedHelper instance].feed;
		self.user_data = [UsersHelper instance].users;
		self.filter = [FilterHelper instance].filter;
		self.isSnappingBack = NO;
		
		UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[postButton setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
		[postButton addTarget:self action:@selector(showPostCreateView) forControlEvents:UIControlEventTouchUpInside];
		
		UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[filterButton setImage:[UIImage imageNamed:@"filter.png"] forState:UIControlStateNormal];
		[filterButton addTarget:self action:@selector(didClickFilterButton) forControlEvents:UIControlEventTouchUpInside];
		
		UIButton *favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[favoritesButton setImage:[UIImage imageNamed:@"favorites.png"] forState:UIControlStateNormal];
		[favoritesButton addTarget:self action:@selector(didClickFavoritesButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - helpers

- (NSString *)stringFromIndexPath:(NSIndexPath *)indexPath {
	return [NSString stringWithFormat:@"%i", indexPath.row];
}

- (void)reloadRows:(NSArray *)to_reload {
	[tableview beginUpdates];
	[self.tableview reloadRowsAtIndexPaths:to_reload withRowAnimation:UITableViewRowAnimationFade];
	[tableview endUpdates];
}


- (void) setUpgradeHeader:(NSDictionary *)options {
	UpgradeHeader *header = [[UpgradeHeader alloc] initWithFrame:self.bounds];
	
	// NOTE: almost all of this configuration could be moved into UpgradeHeader.m
	//		 but it's only called from here anyway at the moment
	
	header.backgroundColor = [UIColor brandGreyColor];
	
	UILabel *title = [[UILabel alloc] init];
	title.backgroundColor = [UIColor clearColor];
	title.text = [options objectForKey:@"title"];
	title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
	[title sizeToFit];
	[title setx:93];
	[title sety:7];
	[header addSubview:title];
	
	UILabel *message = [[UILabel alloc] init];
	message.backgroundColor = [UIColor clearColor];
	message.text = [PDUtils isPro] && [options objectForKey:@"message_pro"] ? [options objectForKey:@"message_pro"] : [options objectForKey:@"message"];
	message.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
	message.numberOfLines = 0;
	[message setw:215];
	[message sizeToFit];
	[message setx:[title x]];
	[message sety:[title bottomEdge] + 3];
	[header addSubview:message];
	
	// left blue box
	UIView *gradient_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [message x] - 10, [message bottomEdge] + 10)];
	gradient_view.backgroundColor = [UIColor brandBlueColor];
	[header addSubview:gradient_view];
	
	UIImageView *iconview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[options objectForKey:@"icon"]]];
	int icon_padding = 15;
	iconview.contentMode = UIViewContentModeScaleAspectFit;
	iconview.frame = CGRectMake(icon_padding, 7, [gradient_view w] - (icon_padding * 2), [gradient_view h] - (icon_padding * 2));
	[iconview sizeToFit];
	[gradient_view addSubview:iconview];
	
	UILabel *iconlabel = [UILabel boldLabel:[options objectForKey:@"icon_label"]];
	iconlabel.textColor = header.backgroundColor;
	iconlabel.backgroundColor = [UIColor clearColor];
	[gradient_view addSubview:iconlabel];
	[iconlabel centerx];
	[iconlabel sety:[iconview bottomEdge] + 4];
	
	//vertically center gradient box contents
	[iconview sety:([gradient_view h] - ([iconlabel bottomEdge] - [iconview y])) / 2];
	[iconlabel sety:[iconview bottomEdge] + 4];
	
	if (![PDUtils isPro]) {
		// bottom border
		CALayer *blueBorder = [CALayer layer];
		blueBorder.frame = CGRectMake(0.0f, [gradient_view bottomEdge], [header w], 0.5f);
		blueBorder.backgroundColor = [UIColor colorWithHex:0x3e9ed5].CGColor; //grey - c3c2c2
		[header.layer addSublayer:blueBorder];
		
		UIButton *upgradeBtn = [UIButton flatBlueButton:@"Upgrade to Pro - $1.99"];
		[upgradeBtn addTarget:self action:@selector(promoUpgrade:) forControlEvents:UIControlEventTouchUpInside];
		[header addSubview:upgradeBtn];
		[upgradeBtn setx:[header w] - [upgradeBtn w] - 30];
		[upgradeBtn sety:[gradient_view bottomEdge] + 13];
		
		UIButton *learnmoreBtn = [UIButton flatBlueButton:@"Learn More"];
		[learnmoreBtn setTitleColor:[UIColor colorWithHex:0x3e9ed5] forState:UIControlStateNormal];
		[header addSubview:learnmoreBtn];
		[learnmoreBtn sety:[upgradeBtn y]];
		[learnmoreBtn.titleLabel underline];
		learnmoreBtn.backgroundColor = [UIColor clearColor];
		[learnmoreBtn addTarget:[ViewController instance] action:@selector(showLearnMoreView) forControlEvents:UIControlEventTouchUpInside];
		
		UILabel *orlabel = [[UILabel alloc] init];
		orlabel.backgroundColor = [UIColor clearColor];
		orlabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
		orlabel.text = @"or";
		orlabel.textColor = [UIColor colorWithHex:0x444444];
		[orlabel sizeToFit];
		[header addSubview:orlabel];
		[orlabel setx:[upgradeBtn x] - [orlabel w] - 20];
		[orlabel sety:[upgradeBtn y] + ([upgradeBtn h] / 2) - ([orlabel h] / 2)];
		
		[learnmoreBtn setx:[orlabel x] - [learnmoreBtn w] - 2];
		
		[header seth:[upgradeBtn bottomEdge] + 14];
	}
	else {
		[header seth:[gradient_view bottomEdge] + 1];
	}
		
	CALayer *greyBorder = [CALayer layer];
	greyBorder.frame = CGRectMake(0.0f, [header bottomEdge] - 1.0f, [header w], 0.5f);
	greyBorder.backgroundColor = [UIColor colorWithHex:0x5d5c5c].CGColor;
	[header.layer addSublayer:greyBorder];
	
	
	[self.tableview setTableHeaderView:header];
	[header release];
}

#pragma mark - Event Handlers

-(void)didClickFilterButton {
	if (self.filterButtonClicked) {
		self.filterButtonClicked();
	}
}

-(void)didClickFavoritesButton {
	if (self.favoriteButtonClicked) {
		NSLog(@"fav btn clicked");
		self.favoriteButtonClicked();
	}
}

- (void)zoomAvatar:(id)sender {
	NSLog(@"zoomAvatar");
	
	UITapGestureRecognizer *gr = (UITapGestureRecognizer *)sender;
	UITableViewCell *cell = (UITableViewCell *)[gr.view parents:[UITableViewCell class]];
	NSIndexPath *index_path = [self.tableview indexPathForCell:cell];
	Post *post = [self.feed objectAtIndex:[index_path row]];
	User *user = [self.user_data objectForKey:post.uid];
	
	UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[avatarzoom setUser:user];
	[[ViewController instance] openModal:avatarzoom];
	[avatarzoom release];
}

- (void) zoomPostImage:(id)sender {
	NSLog(@"zoomPostImage");
	UITapGestureRecognizer *gr = (UITapGestureRecognizer *)sender;
	UITableViewCell *cell = (UITableViewCell *)gr.view.superview.superview;
	NSIndexPath *index_path = [self.tableview indexPathForCell:cell];
	Post *post = [self.feed objectAtIndex:[index_path row]];
	
	UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:self.bounds];
	[avatarzoom setPost:post];
	[self addSubview:avatarzoom];
	[avatarzoom release];
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

- (void)viewComments:(id)sender {
	NSLog(@"view comments");
	
	NSIndexPath *index_path = (NSIndexPath *)sender;
	PostDetailsView *details = [[PostDetailsView alloc] initWithFrame:self.bounds];
	details.post = [self.feed objectAtIndex:index_path.row];
	details.user = [self.user_data objectForKey:details.post.uid];
	
	[[ViewController instance] openModal:details];
	[details addedAsSubview];
}

- (void)promoLearnMore:(id)sender {
	
}

- (void)promoUpgrade:(id)sender {
	[PDUtils upgradeToPro];
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.max_free_rows > 0 && ![PDUtils isPro] && [indexPath row] >= self.max_free_rows) {
		return 100;
	}
	
	Post *post = [self.feed objectAtIndex:[indexPath row]];
	CGFloat h = [post rowHeight];
	if (h < 20) {
		NSLog(@"Height is less than 20: %f", h);
	}
	return h;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	BOOL limit = self.max_free_rows > 0 && self.max_free_rows < [self.feed count] && ![PDUtils isPro];
	return limit ? self.max_free_rows + 1 : [self.feed count];
}

- (UITableViewCell *)upgradeCell {
	static NSString *UpgradeCellIdentifier = @"UpgradeCell";
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UpgradeCellIdentifier];
	
	cell.textLabel.hidden = YES;
	cell.contentView.backgroundColor = [UIColor brandGreyColor];
	
	UIButton *btn = [UIButton flatBlueButton:[NSString stringWithFormat:@"Upgrade to see %i more", [self.feed count] - self.max_free_rows] modifier:1.5f];
	[cell.contentView addSubview:btn];
	[btn centerx];
	[btn centery];
	btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[btn addTarget:self action:@selector(promoUpgrade:) forControlEvents:UIControlEventTouchUpInside];
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.max_free_rows > 0 && ![PDUtils isPro] && [indexPath row] >= self.max_free_rows) {
		return [self upgradeCell];
	}
	
	RevealedView *revealedview;
	UIView *rightBorder;
	UILabel *messageLabel;
	UILabel *dateLabel;
	UILabel *nameLabel;
	ThumbView *avatarView;
	UIView *filter_countdown;
	UILabel *countdown_label;
	UIImageView *commentsNotifierView;
	UIImageView *imageNotifierView;

    static NSString *CellIdentifier = @"Cell";
    ZKRevealingTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ZKRevealingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.delegate = self;
		cell.direction = ZKRevealingTableViewCellDirectionLeft;
		
		//hide defaults
		cell.textLabel.hidden = YES;
		cell.detailTextLabel.hidden = YES;
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		cell.selectedBackgroundView = [[UIView alloc] init];
		[cell.contentView setBackgroundColor:[UIColor whiteColor]];
		
		// right border
		rightBorder = [[UIView alloc] init];
		rightBorder.frame = CGRectMake([cell.contentView w], 0.0f, 0.5f, [cell h]);
		rightBorder.backgroundColor = [UIColor colorWithHex:0xDDDDDD]; //grey - c3c2c2
		[cell.contentView addSubview:rightBorder];
		rightBorder.tag = 51;
		
		// Avatar View
		avatarView = [[ThumbView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
		avatarView.tag = 96;
		[cell.contentView addSubview:avatarView];
		
		
		// Filter Countdown
		filter_countdown = [[UIView alloc] initWithFrame:CGRectMake(10, [avatarView bottomEdge] + 2, [avatarView w], 14)];
		filter_countdown.backgroundColor = [UIColor brandBlueColor];
		filter_countdown.tag = 99;
		
		UILabel *infinity_label = [UILabel label:@"∞" modifier:1.5f];
		infinity_label.textColor = [UIColor whiteColor];
		infinity_label.backgroundColor = [UIColor clearColor];
		[filter_countdown addSubview:infinity_label];
		[infinity_label setx:0];
		[infinity_label setw:[filter_countdown w]];
		[infinity_label centery];
		[infinity_label sety:[infinity_label y] + (SYSTEM_VERSION_LESS_THAN(@"7.0") ? -1 : -2)];
		infinity_label.textAlignment = NSTextAlignmentCenter;
		infinity_label.hidden = YES;
		infinity_label.tag = 94;
		
		countdown_label = [UILabel label:@"2d 4hrs" modifier:0.9f];
		countdown_label.textColor = [UIColor whiteColor];
		countdown_label.backgroundColor = [UIColor clearColor];
		[filter_countdown addSubview:countdown_label];
		[countdown_label setx:0];
		[countdown_label setw:[filter_countdown w]];
		[countdown_label centery];
		[countdown_label sety:[countdown_label y] + (SYSTEM_VERSION_LESS_THAN(@"7.0") ? 1 : -1)];
		countdown_label.textAlignment = NSTextAlignmentCenter;
		countdown_label.tag = 95;
		
		[cell.contentView addSubview:filter_countdown];
		
		
		// Main Post
		messageLabel = [[[UILabel alloc] init] autorelease];
		messageLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:messageLabel];
		messageLabel.font = [Post getPostFont];
		messageLabel.numberOfLines = 0;
		messageLabel.textColor = [UIColor colorWithHex:0x333333];
		//messageLabel setw ignored here.  It's in setOptions
		[messageLabel setx:[avatarView rightEdge] + 7];
		[messageLabel sety:[avatarView y] - 3];
		[messageLabel seth:60]; //sizeToFit called in setOptions, this is ignored
		[messageLabel setwp:0.77f]; //sizeToFit called in setOptions, this is ignored
		messageLabel.tag = 90;
		[cell bringSubviewToFront:messageLabel];
		
		// Time stamp
		dateLabel = [[[UILabel alloc] init] autorelease];
		dateLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:dateLabel];
		dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9.0f];
		dateLabel.textColor = [UIColor colorWithHex:0x5b5c5c];
		dateLabel.numberOfLines = 1;
		dateLabel.text = @"an unknown amount of time ago";
		[dateLabel sizeToFit];
		dateLabel.text = @"";
		dateLabel.tag = 91;
		
		// User's Name
		nameLabel = [[[UILabel alloc] init] autorelease];
		nameLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:nameLabel];
		nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
		nameLabel.textColor = [UIColor colorWithHex:0x3e9ed5];
		nameLabel.numberOfLines = 1;
		nameLabel.text = @"an unknown amount of time ago";
		[nameLabel sizeToFit];
		nameLabel.tag = 92;
		
		// Comments icon
		commentsNotifierView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_no_comments.png"]];
		[commentsNotifierView setw:11];
		[commentsNotifierView seth:11];
		[commentsNotifierView setx:[cell w] - [commentsNotifierView w] - 8];
		commentsNotifierView.tag = 97;
		[cell.contentView addSubview:commentsNotifierView];
		[cell.contentView bringSubviewToFront:commentsNotifierView];
		
		// Images icon
		imageNotifierView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_has_images.png"]];
		[imageNotifierView setw:11];
		[imageNotifierView seth:11];
		imageNotifierView.tag = 93;
		[cell.contentView addSubview:imageNotifierView];
		[cell.contentView bringSubviewToFront:imageNotifierView];
		
		avatarView.userInteractionEnabled = YES;
		UITapGestureRecognizer *doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAvatar:)];
		doubletapgr.numberOfTouchesRequired = 1;
		doubletapgr.numberOfTapsRequired = 2;
		doubletapgr.cancelsTouchesInView = YES;
		doubletapgr.delaysTouchesBegan = YES;
		[avatarView addGestureRecognizer:doubletapgr];
		[doubletapgr release];
		
		
		int reveal_w = 201;
		revealedview = [[RevealedView alloc] initWithFrame:CGRectMake(0, -1, reveal_w, 100)];
		revealedview.tag = 50;
		cell.pixelsToReveal = reveal_w;
		[cell addSubview:revealedview];
		[cell sendSubviewToBack:revealedview];
		cell.revealedView = revealedview;
    }
	else {
		revealedview = (RevealedView *)[cell viewWithTag:50];
		rightBorder = (UIView *)[cell viewWithTag:51];
		
		messageLabel = [cell messageLabel];
		dateLabel = [cell dateLabel];
		nameLabel = [cell nameLabel];
		avatarView = [cell avatarView];
		imageNotifierView = [cell imageNotifierView];
	}
	
    Post *post = [self.feed objectAtIndex:[indexPath row]];
	User *user = [self.user_data objectForKey:post.uid];
	
	[revealedview seth:[post rowHeight]];
	revealedview.post = post;
	
	[rightBorder seth:[revealedview h]];
	
	if ([post hasImages]) {
		NSLog(@"Post has images %@", [post.images description]);
	}

	

	NSDateFormatter *df = [NSDateFormatter instance];
	
	if ([user is_filtered]) {
		[cell filter_countdown].hidden = NO;
		
		if ([[user filter_state] isEqualToString:FILTER_STATE_FILTERED]) {
			[cell infinity_label].hidden = NO;
			[cell countdown_label].hidden = YES;
		}
		else {
			[cell infinity_label].hidden = YES;
			[cell countdown_label].hidden = NO;
			
			//print date to countdown_label
			
			static dispatch_once_t onceMark;
			static NSCalendar *calendar = nil;
			
			dispatch_once(&onceMark, ^{
				calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			});
			
			
			NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date] toDate:[user filtered_until] options:0];
			
			if (components.day > 1) {
				[cell countdown_label].text = [NSString stringWithFormat:@"%i days", components.day];
			}
			//1d 4hrs
			else if (components.day > 0 && components.hour > 1) {
				[cell countdown_label].text = [NSString stringWithFormat:@"%id %ihrs", components.day, components.hour];
			}
			//1d 1hr
			else if (components.day > 0 && components.hour == 1) {
				[cell countdown_label].text = [NSString stringWithFormat:@"%id %ihr", components.day, components.hour];
			}
			//1 day  ..this probably won't happen
			else if (components.day > 0 && components.hour == 0) {
				[cell countdown_label].text = [NSString stringWithFormat:@"%i day", components.day];
			}
			//12 hours
			else if (components.hour > 1) {
				[cell countdown_label].text = [NSString stringWithFormat:@"%i hours", components.hour];
			}
			//1 hour
			else if (components.hour == 1) {
				[cell countdown_label].text = @"1 hour";
			}
			//48 mins
			else if (components.minute > 1) {
				[cell countdown_label].text = [NSString stringWithFormat:@"%i mins", components.minute];
			}
			//1 min
			else if (components.minute == 1) {
				[cell countdown_label].text = @"1 min";
			}
			//0 min or less
			else  {
				[cell countdown_label].text = @"now";
			}
		}
	}
	else {
		[cell filter_countdown].hidden = YES;
	}
	
	
	//status message
	CGFloat messageLabelWidth = post ? [post messageLabelWidth] : 0.75f;
	messageLabel.text = post.message;
	messageLabel.numberOfLines = 0;//[[options objectForKey:@"is_expanded"] boolValue] ? 0 : [cell linesBeforeClip];
	[messageLabel setw:messageLabelWidth];
	[messageLabel sizeToFit];
	
	//name
	nameLabel.text = [user full_name];
	[nameLabel sizeToFit];
	
	//date string
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[post.time integerValue]];
	[df setDateFormat:@"h:mma M/d"];
	dateLabel.text = [NSString stringWithFormat:@"at %@", [[df stringFromDate:date] lowercaseString]];
	
	//lower right coment icon
	[cell commentsNotifierView].hidden = !post.has_comments;
	
	//mark as read
	if (![cell commentsNotifierView].hidden) {
		BOOL should_mark_as_read = post && post.last_read && post.last_comment_at && [post.last_read compare:post.last_comment_at] == NSOrderedDescending;
		[[cell commentsNotifierView] setImage:[UIImage imageNamed:(should_mark_as_read ? @"icon_has_comments.png" : @"icon_has_unread")]];
	}
	else {
		[[cell commentsNotifierView] setImage:[UIImage imageNamed:@"icon_no_comments.png"]];
	}
	
	//lower right image icon
	[imageNotifierView setx:[[cell commentsNotifierView] x]];
	if (![cell commentsNotifierView].hidden) {
		[imageNotifierView setx:[imageNotifierView x] - [imageNotifierView w] - 8];
	}
	
	[nameLabel setx:[messageLabel x]];
	[nameLabel sety:MAX(([messageLabel bottomEdge] + 7), (post ? [post minRowHeight] - 21 : 0))];
	
	[nameLabel setw:[messageLabel w]];
	[nameLabel sizeToFit];
	
	dateLabel.center = nameLabel.center;
	//[dateLabel sety:[nameLabel bottomEdge] - [dateLabel h]];
	[dateLabel setx:[nameLabel rightEdge] + 2];
	
	[[cell commentsNotifierView] sety:[nameLabel y] + 2];
	[[cell imageNotifierView] sety:[[cell commentsNotifierView] y]];
	
	[cell imageNotifierView].hidden = ![post hasImages];
	
	//profile pic
	avatarView.user = user;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self viewComments:indexPath];
}

- (void)removeFromTimeline:(User *)user {
	NSMutableIndexSet *indexes_to_remove = [[NSMutableIndexSet alloc] init];
	NSMutableArray *index_paths_to_remove = [[NSMutableArray alloc] init];
	
	Post *p;
	for (int i = 0; i < [self.feed count]; i++) {
		p = (Post *)[self.feed objectAtIndex:i];
		if ([p user] == user) {
			[indexes_to_remove addIndex:i];
			[index_paths_to_remove addObject:[NSIndexPath indexPathForRow:i inSection:0]];
		}
	}
	
	[tableview beginUpdates];
	[self.feed removeObjectsAtIndexes:indexes_to_remove];
	[self.tableview deleteRowsAtIndexPaths:index_paths_to_remove withRowAnimation:UITableViewRowAnimationAutomatic];
	[tableview endUpdates];
	
}

#pragma mark - ZKRevealingTableViewCellDelegate

- (BOOL)cellShouldReveal:(ZKRevealingTableViewCell *)cell {
	return YES;
}

- (void)cellDidReveal:(ZKRevealingTableViewCell *)cell {
	self.currentlyRevealedCell = cell;
	
	[self.tableview scrollToRowAtIndexPath:[self.tableview indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)cellDidBeginPan:(ZKRevealingTableViewCell *)cell {
	if (cell != self.currentlyRevealedCell) {
		[((RevealedView *)cell.revealedView) refresh];
		self.currentlyRevealedCell = nil;
	}
}

- (void)cellDidPan:(ZKRevealingTableViewCell *)cell {
    //UILabel *starLabel = (UILabel *)cell.revealedView.subviews[0];
    if (cell.pannedAmount == 1) {
     
    }
}


-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	UIView *hitview = [super hitTest:point withEvent:event];
	
	if (self.currentlyRevealedCell || self.isSnappingBack) {
		if (!hitview || ![hitview parents:[RevealedView class]]) {
			[self snapBackRevealedCell];
			hitview = nil;
		}
	}
	
	return hitview;
}

- (void)snapBackRevealedCell {
	if (self.currentlyRevealedCell) {
		[[self currentlyRevealedCell] snapBack];
	}
	
	self.currentlyRevealedCell = nil;
}

- (void)cellWillSnapBack:(ZKRevealingTableViewCell *)cell {
    NSLog(@"Will snap back");
    self.currentlyRevealedCell = nil;
	self.isSnappingBack = YES;
}

- (void)cellDidSnapBack:(ZKRevealingTableViewCell *)cell {
	NSLog(@"Did snap back");
	self.isSnappingBack = NO;
	
	User *user = [(RevealedView *)[cell revealedView] user];
	if (self.removeWhenFiltered && [user is_filtered]) {
		[self removeFromTimeline:user];
	}
}

#pragma mark - ZKRevealing - Accessors

- (void)setCurrentlyRevealedCell:(ZKRevealingTableViewCell *)currentlyRevealedCell {
	if (_currentlyRevealedCell == currentlyRevealedCell)
		return;
	
	[_currentlyRevealedCell setRevealing:NO];
	
    //UILabel *starLabel = (UILabel *)_currentlyRevealedCell.revealedView.subviews[0];
    //starLabel.textColor = [UIColor whiteColor];
	
	_currentlyRevealedCell = currentlyRevealedCell;
}

- (void)updateButtonsForPost:(Post *)post {
	
}

@end
