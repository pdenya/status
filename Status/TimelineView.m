//
//  TimelineView.m
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "PostCreateView.h"
#import "PostDetailsView.h"
#import "EditFilterView.h"
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
		[self addSubview:self.tableview];
		
		self.feed = [FeedHelper instance].feed;
		self.user_data = [UsersHelper instance].users;
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
	
	header.backgroundColor = [UIColor colorWithHex:0xf7f6f6];
	
	UILabel *title = [[UILabel alloc] init];
	title.text = [options objectForKey:@"title"];
	title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
	[title sizeToFit];
	[title setx:93];
	[title sety:7];
	[header addSubview:title];
	
	UILabel *message = [[UILabel alloc] init];
	message.text = [options objectForKey:@"message"];
	message.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
	message.numberOfLines = 0;
	[message setw:215];
	[message sizeToFit];
	[message setx:[title x]];
	[message sety:[title bottomEdge] + 3];
	[header addSubview:message];
	
	UIView *gradient_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [message x] - 10, [message bottomEdge] + 10)];
	gradient_view.backgroundColor = [UIColor colorWithHex:0x3e9ed5];
	[header addSubview:gradient_view];
	
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
	orlabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
	orlabel.text = @"or";
	orlabel.textColor = [UIColor colorWithHex:0x444444];
	[orlabel sizeToFit];
	[header addSubview:orlabel];
	[orlabel setx:[upgradeBtn x] - [orlabel w] - 20];
	[orlabel sety:[upgradeBtn y] + ([upgradeBtn h] / 2) - ([orlabel h] / 2)];
	
	[learnmoreBtn setx:[orlabel x] - [learnmoreBtn w] - 2];
	
	[header seth:[upgradeBtn bottomEdge] + 14];
	
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
	
	UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:self.bounds];
	[avatarzoom setUser:user];
	[self addSubview:avatarzoom];
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
	
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
	return [self.feed count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    ZKRevealingTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ZKRevealingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.delegate = self;
		cell.direction = ZKRevealingTableViewCellDirectionLeft;
		[cell configureForTimeline];
		
		//add bottom border
		//[cell addFlexibleBottomBorder:[UIColor colorWithHex:0x3e9ed5]];
		
		ThumbView *avatarView = [cell avatarView];
		avatarView.userInteractionEnabled = YES;
		UITapGestureRecognizer *doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAvatar:)];
		doubletapgr.numberOfTouchesRequired = 1;
		doubletapgr.numberOfTapsRequired = 2;
		doubletapgr.cancelsTouchesInView = YES;
		doubletapgr.delaysTouchesBegan = YES;
		[avatarView addGestureRecognizer:doubletapgr];
		[doubletapgr release];
		
		ThumbView *imgview = [cell imgView];
		imgview.userInteractionEnabled = YES;
		UITapGestureRecognizer *imgview_doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomPostImage:)];
		imgview_doubletapgr.numberOfTouchesRequired = 1;
		imgview_doubletapgr.numberOfTapsRequired = 2;
		imgview_doubletapgr.cancelsTouchesInView = YES;
		imgview_doubletapgr.delaysTouchesBegan = YES;
		[imgview addGestureRecognizer:imgview_doubletapgr];
		[imgview_doubletapgr release];
		
		
    }
	
    Post *post = [self.feed objectAtIndex:[indexPath row]];
	User *user = [self.user_data objectForKey:post.uid];
	
	cell.revealedView = [self revealedView:indexPath];
	cell.pixelsToReveal = [cell.revealedView w];
	((RevealedView *)cell.revealedView).post = post;
	
	if ([post hasImages]) {
		NSLog(@"Post has images %@", [post.images description]);
	}
	
	[cell setOptions:@{
	   @"message":		post.message,
	   @"name":			[NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name],
	   @"has_comments":	[NSNumber numberWithBool:post.has_comments],
	   @"time":			post.time,
	   @"post":			post,
	   @"user":			user
	}];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self viewComments:indexPath];
}

#pragma mark - ZKRevealingTableViewCellDelegate

- (BOOL)cellShouldReveal:(ZKRevealingTableViewCell *)cell {
	return YES;
}

- (void)cellDidReveal:(ZKRevealingTableViewCell *)cell {
	NSLog(@"Revealed Cell with title: %@", cell.textLabel.text);
	[((RevealedView *)cell.revealedView) refresh];
	self.currentlyRevealedCell = cell;
}

- (void)cellDidBeginPan:(ZKRevealingTableViewCell *)cell {
	if (cell != self.currentlyRevealedCell) {
		self.currentlyRevealedCell = nil;
	}
}

- (void)cellDidPan:(ZKRevealingTableViewCell *)cell {
    //UILabel *starLabel = (UILabel *)cell.revealedView.subviews[0];
    if (cell.pannedAmount == 1) {
     
    }
}

- (void)cellWillSnapBack:(ZKRevealingTableViewCell *)cell {
    NSLog(@"Will snap back");
    self.currentlyRevealedCell = nil;
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

- (RevealedView *)revealedView:(NSIndexPath *)indexPath {
	Post *post = [self.feed objectAtIndex:[indexPath row]];
	
    RevealedView *revealedview = [[RevealedView alloc] initWithFrame:CGRectMake(0, -1, 201, 100)];
	revealedview.post = post;
	
    return revealedview;
}

- (void)updateButtonsForPost:(Post *)post {
	
}

@end
