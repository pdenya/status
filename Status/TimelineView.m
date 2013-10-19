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
#import "UpgradeHeader.h"
#import "UserProfileView.h"
#import "CellScrollView.h"

@implementation TimelineView
@synthesize feed, user_data, tableview, filter, filterButtonClicked, favoriteButtonClicked;

const int NUM_LINES_BEFORE_CLIP = 5;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.tableview = [[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain] autorelease];
		self.tableview.delegate = self;
		self.tableview.dataSource = self;
		self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.tableview.separatorColor = [UIColor colorWithHex:0xa7a6a6];
		self.tableview.backgroundColor = [UIColor whiteColor];
		self.max_free_rows = 0;
		self.removeWhenFiltered = NO;
		[self.tableview setTableFooterView:[[UIView new] autorelease]];
		[self addSubview:self.tableview];
        
		
		self.feed = [FeedHelper instance].feed;
		self.user_data = [UsersHelper instance].users;
		self.filter = [FilterHelper instance].filter;
		self.isSnappingBack = NO;
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
	
	UILabel *title = [[[UILabel alloc] init] autorelease];
	title.backgroundColor = [UIColor clearColor];
	title.text = [options objectForKey:@"title"];
	title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
	[title sizeToFit];
	[title setx:93];
	[title sety:7];
	[header addSubview:title];
	
	UILabel *message = [[[UILabel alloc] init] autorelease];
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
	UIView *gradient_view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, [message x] - 10, [message bottomEdge] + 10)] autorelease];
	gradient_view.backgroundColor = [UIColor brandBlueColor];
	[header addSubview:gradient_view];
	
	UIImageView *iconview = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[options objectForKey:@"icon"]]] autorelease];
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
		[orlabel release];
		
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

- (void) createTutorial:(NSDictionary *)options {
	
	UIView *tutorial = [UIView new];
	tutorial.backgroundColor = [UIColor whiteColor];
	[tutorial setw:[self w]];
	
	UILabel *tutorial_title = [UILabel boldLabel:[options objectForKey:@"header"] modifier:1.2f];
	[tutorial addSubview:tutorial_title];
	[tutorial_title centerx];
	[tutorial_title sety:50];
	
	UILabel *stepone = [UILabel label:[options objectForKey:@"stepone"]];
	[tutorial addSubview:stepone];
	[stepone sety:[tutorial_title bottomEdge] + 10];
	[stepone setw:[self w] - 40];
	[stepone centerx];
	[stepone seth:100];
	stepone.textColor = [UIColor colorWithHex:0x555555];
	[stepone sizeToFit];
	
	UIView *example = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swiped_example.jpg"]];
	[example addSubtleShadow];
	[example sizeToFit];
	[tutorial addSubview:example];
	[example centerx];
	[example sety:[stepone bottomEdge] + 20];
	
	UILabel *steptwo = [UILabel label:[options objectForKey:@"steptwo"]];
	[tutorial addSubview:steptwo];
	[steptwo sety:[example bottomEdge] + 20];
	[steptwo setw:[self w] - 40];
	[steptwo centerx];
	[steptwo seth:100];
	steptwo.textColor = [UIColor colorWithHex:0x555555];
	[steptwo sizeToFit];

	
	[tutorial seth:[steptwo bottomEdge] + 20];
	
	self.tutorial = tutorial;
	
	[tutorial release];
	[example release];
}

- (void) beginRefreshing {
	if (!self.refreshingview) {
		self.refreshingview = ({
			UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, [self w], 30.0f)] autorelease];
			view.backgroundColor = [UIColor colorWithHex:0xFCFCFC];
			[view addBottomBorder:self.tableview.separatorColor];
			
			UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
			[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
			[activityIndicator startAnimating];
			
			[view addSubview:activityIndicator];
			[activityIndicator centerx];
			[activityIndicator centery];
			activityIndicator.tag = 53;
			[activityIndicator release];
			
			UILabel *lbl = [UILabel label:[[NSUserDefaults standardUserDefaults] objectForKey:@"fb_last_successful_update"] size:10.0f];
			lbl.textAlignment = UITextAlignmentCenter;
            lbl.backgroundColor = view.backgroundColor;
			[view addSubview:lbl];
            [lbl setw:[self w]];
            [lbl seth:20.0f];
			[lbl centerx];
			[lbl centery];
			lbl.hidden = YES;
			lbl.tag = 54;
			
			view;
		});
		
		if (self.tableview.contentOffset.y == 0) {
			self.tableview.contentOffset = CGPointMake(0, [self.refreshingview h]);
		}
	}
	else {
		if (self.tableview.contentOffset.y == [self.refreshingview h]) {
			[self.tableview setContentOffset:CGPointMake(0, 0) animated:YES];
		}
		
		UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.refreshingview viewWithTag:53];
		activityIndicator.hidden = NO;
		
		UILabel *lbl = (UILabel *)[self.refreshingview viewWithTag:54];
		lbl.hidden = YES;
	}
	
	if (!self.refreshingview.superview) {
		[self.tableview setTableHeaderView:self.refreshingview];
	}
}

- (void) endRefreshing {
	if (self.tableview.contentOffset.y == 0) {
		[self.tableview setContentOffset:CGPointMake(0, [self.refreshingview h]) animated:YES];
	}
	
	//[self.tableview setTableHeaderView:nil];
	UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.refreshingview viewWithTag:53];
	activityIndicator.hidden = YES;
	
	UILabel *lbl = (UILabel *)[self.refreshingview viewWithTag:54];
	lbl.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_last_successful_update"];
	lbl.hidden = NO;
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
	
	UserProfileView *profileview = [[UserProfileView alloc] initWithUser:user];
	CGPoint p = [gr locationOfTouch:0 inView:[ViewController instance].view];
	[[ViewController instance] openModal:profileview fromPoint:p];
	[profileview release];
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

- (void)viewComments:(id)sender {
	NSIndexPath *index_path = (NSIndexPath *)sender;
	[self viewComments:index_path fromPoint:self.center];
}

- (void)viewComments:(NSIndexPath *)index_path fromPoint:(CGPoint)touch_point {
	NSLog(@"view comments");
	
	PostDetailsView *details = [[PostDetailsView alloc] init];
	details.post = [self.feed objectAtIndex:index_path.row];
	details.user = [self.user_data objectForKey:details.post.uid];
	
	[[ViewController instance] openModal:details fromPoint:touch_point];
	[details addedAsSubview];
	[details release];
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
	int count = limit ? self.max_free_rows + 1 : [self.feed count];

	if (count == 0 && self.tutorial && [self.tableview tableFooterView] != self.tutorial) {
		[self.tableview setTableFooterView:self.tutorial];
	}
	else if (count > 0 && self.tutorial && [self.tableview tableFooterView] == self.tutorial) {
		[self.tableview setTableFooterView:[[UIView new] autorelease]];
	}
	
	return count;
}

- (UITableViewCell *)upgradeCell {
	static NSString *UpgradeCellIdentifier = @"UpgradeCell";
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UpgradeCellIdentifier] autorelease];
	
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
	UIView *leftBorder;
	UILabel *messageLabel;
	UILabel *dateLabel;
	UILabel *nameLabel;
	ThumbView *avatarView;
	UIView *filter_countdown;
	UILabel *countdown_label;
	UIImageView *commentsNotifierView;
	UIImageView *imageNotifierView;
	CellScrollView *scrollview;
    UIView *contentview;

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
		scrollview = [[CellScrollView alloc] initWithFrame:cell.bounds];
		[cell.contentView addSubview:scrollview];
		scrollview.tag = 55;
		scrollview.delegate = self;
		scrollview.showsHorizontalScrollIndicator = NO;
		scrollview.showsVerticalScrollIndicator = NO;
		
		contentview = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
		[scrollview addSubview:contentview];
		contentview.tag = 56;
		
		//hide defaults
		cell.textLabel.hidden = YES;
		cell.detailTextLabel.hidden = YES;
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		[contentview addBottomBorder:[UIColor colorWithHex:0xa7a6a6]];
		
		cell.selectedBackgroundView = [[[UIView alloc] init] autorelease];
		[contentview setBackgroundColor:[UIColor colorWithHex:0xFAFAFA]];
		
		// right border
		//NOTE: these are not visible when white, just hiding them in case it's convenient to add them back soon
		rightBorder = [[[UIView alloc] init] autorelease];
		rightBorder.frame = CGRectMake([cell.contentView w], 0.0f, 0.5f, [cell h]);
		rightBorder.backgroundColor = contentview.backgroundColor; //grey - DDDDDD
		[contentview addSubview:rightBorder];
		rightBorder.tag = 51;
		rightBorder.hidden = YES;
		
		// left border
		leftBorder = [[[UIView alloc] init] autorelease];
		leftBorder.frame = CGRectMake(0.0f, 0.0f, 0.5f, [cell h]);
		leftBorder.backgroundColor = contentview.backgroundColor; //grey - DDDDDD
		[contentview addSubview:leftBorder];
		leftBorder.tag = 52;
		leftBorder.hidden = YES;
		
		// Avatar View
		avatarView = [[[ThumbView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)] autorelease];
		avatarView.tag = 96;
		[contentview addSubview:avatarView];
		
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
		
		[contentview addSubview:filter_countdown];
		[filter_countdown release];
		
		// Main Post
		messageLabel = [[[UILabel alloc] init] autorelease];
		messageLabel.backgroundColor = [UIColor clearColor];
		[contentview addSubview:messageLabel];
		messageLabel.font = [Post getPostFont];
		messageLabel.numberOfLines = 0;
		messageLabel.textColor = [UIColor colorWithHex:0x333333];
		//messageLabel setw ignored here.  It's in setOptions
		[messageLabel setx:[avatarView rightEdge] + 8];
		[messageLabel sety:[avatarView y] - 3];
		[messageLabel seth:60]; //sizeToFit called in setOptions, this is ignored
		[messageLabel setwp:0.77f]; //sizeToFit called in setOptions, this is ignored
		messageLabel.tag = 90;
		[contentview bringSubviewToFront:messageLabel];
		
		// Time stamp
		dateLabel = [[[UILabel alloc] init] autorelease];
		dateLabel.backgroundColor = [UIColor clearColor];
		[contentview addSubview:dateLabel];
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
		[contentview addSubview:nameLabel];
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
		[contentview addSubview:commentsNotifierView];
		[contentview bringSubviewToFront:commentsNotifierView];
		[commentsNotifierView release];
		
		// Images icon
		imageNotifierView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_has_images.png"]];
		[imageNotifierView setw:11];
		[imageNotifierView seth:11];
		imageNotifierView.tag = 93;
		[contentview addSubview:imageNotifierView];
		[contentview bringSubviewToFront:imageNotifierView];
		[imageNotifierView release];

		UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectScrollview:)];
		tapgr.numberOfTapsRequired = 1;
		[contentview addGestureRecognizer:tapgr];
		
		avatarView.userInteractionEnabled = YES;
		UITapGestureRecognizer *doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAvatar:)];
		doubletapgr.numberOfTouchesRequired = 2;
		doubletapgr.numberOfTapsRequired = 2;
		doubletapgr.cancelsTouchesInView = YES;
		doubletapgr.delaysTouchesBegan = YES;
		[avatarView addGestureRecognizer:doubletapgr];
		
		[tapgr release];
		[doubletapgr release];
		
		revealedview = [[[RevealedView alloc] initWithFrame:CGRectMake(0, 0, [self w], 100)] autorelease];
		revealedview.tag = 50;
		
		scrollview.contentSize = CGSizeMake([self w] + 100 + 201, [cell h]);
		[contentview setx:100];
		scrollview.contentOffset = CGPointMake(100, 0);
		
		[cell.contentView addSubview:revealedview];
		[cell.contentView sendSubviewToBack:revealedview];
		//cell.revealedView = revealedview;
    }
	else {
		revealedview = (RevealedView *)[cell viewWithTag:50];
		rightBorder = (UIView *)[cell viewWithTag:51];
		leftBorder = (UIView *)[cell viewWithTag:52];
		scrollview = (CellScrollView *)[cell viewWithTag:55];
		contentview = (UIView *)[cell viewWithTag:56];
		
		messageLabel = [cell messageLabel];
		dateLabel = [cell dateLabel];
		nameLabel = [cell nameLabel];
		avatarView = [cell avatarView];
		imageNotifierView = [cell imageNotifierView];
	}
	
    Post *post = [self.feed objectAtIndex:[indexPath row]];
	User *user = [self.user_data objectForKey:post.uid];
	
	
	NSData *strdata = [post.message dataUsingEncoding:NSNonLossyASCIIStringEncoding];
	NSLog(@"%@", [[[NSString alloc] initWithData:strdata encoding:NSUTF8StringEncoding] autorelease]);
	
	if (![self.user_data objectForKey:post.uid]) {
		// FOR DEBUGGING
		//[self.user_data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) { NSLog(@"%@ != %@", ((User *)obj).uid, post.uid); }];
		
		[[FBHelper instance] refreshUser:post.uid completed:^(BOOL success) {
			NSLog(@"refresh response");
			if (success && [self.user_data objectForKey:post.uid]) {
				[self.tableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			}
		}];
	}
	
	[revealedview seth:[post rowHeight]];
	revealedview.post = post;
	
	[rightBorder seth:[post rowHeight]];
	[leftBorder seth:[rightBorder h]];

	[scrollview seth:[rightBorder h]];
	scrollview.contentSize = CGSizeMake(scrollview.contentSize.width, [scrollview h]);
	[contentview seth:[scrollview h]];
	
	UIView *bottom_border = [cell.contentView viewWithTag:102];
	[bottom_border sety:[post rowHeight] - [bottom_border h]];

	
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
			//TODO: put this somewhere else
			
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
	
	[dateLabel setx:[nameLabel rightEdge] + 2.5f];
	[dateLabel sety:[nameLabel y] + 1.5f];
	
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

- (void)didSelectScrollview:(UITapGestureRecognizer *)gr {
	if (self.currentlyRevealedCell) {
		[self snapCellBack:self.currentlyRevealedCell];
	}
	else {
		CGPoint point = [gr locationInView:gr.view];
		UIView *viewTouched = [gr.view hitTest:point withEvent:nil];
		
		if ([viewTouched isKindOfClass:[ThumbView class]] || [viewTouched parents:[ThumbView class]]) {
			[self zoomAvatar:gr];
		}
		else {
			UIView *contentview = gr.view;
			UITableViewCell *cell = (UITableViewCell *)[contentview parents:[UITableViewCell class]];
			[self viewComments:[self.tableview indexPathForCell:cell] fromPoint:[gr locationOfTouch:0 inView:[ViewController instance].view]];
		}
	}
}

- (void)removeFromTimeline:(User *)user {
	if (self.max_free_rows > 0) {
		[self.tableview reloadData];
		return;
	}
	
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
	[self.tableview deleteRowsAtIndexPaths:index_paths_to_remove withRowAnimation:UITableViewRowAnimationTop];
	[tableview endUpdates];
	
	[index_paths_to_remove removeAllObjects];
	[index_paths_to_remove release];
	[indexes_to_remove removeAllIndexes];
	[indexes_to_remove release];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollview {
	//skip for tableview
	if ([scrollview isMemberOfClass:[UITableView class]]) return;
	
	[self scrollViewDidEndDecelerating:scrollview];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollview {
	//skip for tableview
	if ([scrollview isMemberOfClass:[UITableView class]]) return;
	
	UIView *contentview = (UIView *)[scrollview viewWithTag:56];
	
	//right action view visible
	if (scrollview.contentOffset.x == 0 && [contentview x] == 100) {
		//disable left action view
		scrollview.contentSize = CGSizeMake([scrollview w] + 100, [scrollview h]);
		//self.currentlyRevealedCell = (UITableViewCell *)[scrollview parents:[UITableViewCell class]];
	}
	//centered on content
	else if (scrollview.contentOffset.x == [contentview x]) {
		//enable both action views
		scrollview.contentSize = CGSizeMake([scrollview w] + 100 + 201, [scrollview h]);
		scrollview.contentOffset = CGPointMake(100, 0);
		[contentview setx:100];
		[self cellDidSnapBack:((UITableViewCell *)[scrollview parents:[UITableViewCell class]])];
	}
	//left action view visible
	else if (scrollview.contentOffset.x == 100 + 201) {
		//disable right action view
		scrollview.contentSize = CGSizeMake([scrollview w] + 201, [scrollview h]);
		[contentview setx:0];
		//self.currentlyRevealedCell = (UITableViewCell *)[scrollview parents:[UITableViewCell class]];
	}
	else {
		[self snapCellBack:(UITableViewCell *)[scrollview parents:[UITableViewCell class]]];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollview willDecelerate:(BOOL)decelerate {
	//skip for tableview
	if ([scrollview isMemberOfClass:[UITableView class]]) return;
	
	if (!decelerate) {
		[self scrollViewDidEndDecelerating:scrollview];
	}
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollview withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)offset {
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollview {
	
	//skip for tableview
	if ([scrollview isMemberOfClass:[UITableView class]]) {
		if (self.currentlyRevealedCell) {
			[self snapCellBack:self.currentlyRevealedCell];
		}
		
		return;
	}

	//do as little scrolling as possible to get the cell fully into view (in most cases no scrolling)
	UITableViewCell *cell = (UITableViewCell *)[scrollview parents:[UITableViewCell class]];
	[self.tableview scrollToRowAtIndexPath:[self.tableview indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	
	if (self.currentlyRevealedCell && self.currentlyRevealedCell != cell) {
		[self snapCellBack:self.currentlyRevealedCell];
	}
	
	//update view we're revealing
	[(RevealedView *)[cell viewWithTag:50] refresh];
	
	self.currentlyRevealedCell = cell;
}



- (void)snapCellBack:(UITableViewCell *)cell {
	NSLog(@"snapCellBack");
	UIScrollView *scrollview = (UIScrollView *)[cell viewWithTag:55];
	UIView *contentview = (UIView *)[scrollview viewWithTag:56];
	[scrollview scrollRectToVisible:contentview.frame animated:YES];
	
	if (self.currentlyRevealedCell == cell) {
		self.currentlyRevealedCell = nil;
	}
}


#pragma mark - TableViewCellDelegate


- (void)cellDidSnapBack:(UITableViewCell *)cell {
	NSLog(@"Did snap back");
	self.isSnappingBack = NO;
	
	User *user = [(RevealedView *)[cell viewWithTag:50] user];
	if (self.removeWhenFiltered && [user is_filtered]) {
		[self removeFromTimeline:user];
	}
}

@end
