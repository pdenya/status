//
//  PostDetailsView.m
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "PostDetailsView.h"
#import "PostCreateView.h"
#import "UserAvatarView.h"
#import "ThumbView.h"
#import "ViewController.h"
#import "HeaderView.h"
#import "UserProfileView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostDetailsView
@synthesize post, user, tableview, comments, user_data;

- (PostDetailsView *)init {
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];

	if (self) {
		self.backgroundColor = [UIColor brandGreyColor];
	}
	
	return self;
}

- (void) dealloc {
	[self.postcreate release];
	[self.tableview release];
	
	[self.comments removeAllObjects];
	[self.comments release];
	
	[self.user_data removeAllObjects];
	[self.user_data release];
	
	[super dealloc];
}

- (void)addedAsSubview {
	if (!self.post) NSLog(@"ERROR: Post not set in addedAsSubview");
		
	self.comments = [[NSMutableArray alloc] init];
	self.user_data = [[NSMutableDictionary alloc] init];
	
	
	HeaderView *header_view = [[HeaderView alloc] init];
	[header_view addCloseButton];
	[header_view addTitle:[self.user full_name]];
	
	//favorite icon in the header bar
	UIButton *favbtn = [UIButton buttonWithType:UIButtonTypeCustom];
	favbtn.tag = 97;
	[header_view addSubview:favbtn];
	[favbtn seth:[header_view h] - 20];
	[favbtn setw:[favbtn h]];
	[favbtn setx:[header_view w] - [favbtn w] - 2];
	[favbtn centery];
	[favbtn sety:[favbtn y] + 10];
	CGFloat img_inset = 7.0f;
	[favbtn setImageEdgeInsets:UIEdgeInsetsMake(img_inset, img_inset, img_inset, img_inset)];
	[favbtn addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
	
	//add header view
	[self addSubview:header_view];
	[self bringSubviewToFront:header_view];
	
	//comments table header view which contains the post and stuff
	UIView *topView = [[UIView alloc] initWithFrame:self.bounds];
	topView.backgroundColor = [UIColor whiteColor];
	[topView seth:250];
	
	// User Avatar
	ThumbView *avatarView = [[ThumbView alloc] initWithFrame:CGRectMake(7, 10, 80, 80)];
	[topView addSubview:avatarView];
	[avatarView setUser:self.user];
	avatarView.userInteractionEnabled = YES;
	UITapGestureRecognizer *doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomUserAvatar:)];
	doubletapgr.numberOfTouchesRequired = 1;
	doubletapgr.numberOfTapsRequired = 2;
	doubletapgr.cancelsTouchesInView = YES;
	doubletapgr.delaysTouchesBegan = YES;
	[avatarView addGestureRecognizer:doubletapgr];
	[doubletapgr release];
	
	// Post Date
	UILabel *dateLabel = [[UILabel alloc] init];
	dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9.0f];
	dateLabel.textColor = [UIColor colorWithHex:0x7c7c7c];
	dateLabel.backgroundColor = [UIColor clearColor];
	[dateLabel setw:[avatarView w]];
	[dateLabel setx:[avatarView x]];
	[dateLabel sety:[avatarView bottomEdge] + 2];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"'at 'h:mma' on 'M/d"];
	dateLabel.text = [[dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.post.time integerValue]]] lowercaseString];
	dateLabel.textAlignment = NSTextAlignmentCenter;
	[dateFormat release];
	
	[dateLabel sizeToFit];
	[topView addSubview:dateLabel];
	
	// Post Message
	UILabel *postLabel = [[UILabel alloc] init];
	postLabel.backgroundColor = [UIColor clearColor];
	postLabel.lineBreakMode = UILineBreakModeWordWrap;
	postLabel.text = self.post.message;
	postLabel.font = [Post getPostFont];
	postLabel.textColor = [UIColor colorWithHex:0x333333];
	postLabel.numberOfLines = 0;
	[postLabel setw:[topView w] - [avatarView rightEdge] - 14];
	[postLabel sizeToFit];
	[postLabel sety:[avatarView y] - 3];
	[postLabel setx:[avatarView rightEdge] + 10];
	[topView addSubview:postLabel];
	
	[topView seth:MAX(110, MAX([postLabel bottomEdge] + 20, [dateLabel bottomEdge]))];

	
    if ([post hasImages] && [post.images count] > 1) {
        //multiple images, show thumbnails
		
        CGFloat thumby = 5;
        CGFloat padding = [avatarView x];
        CGFloat thumbx = padding;
		CGFloat thumbw = 180;
		CGFloat thumbh = 180;
		
		UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [topView bottomEdge], [self w], thumbh + (thumby * 2))];
		scrollview.backgroundColor = [UIColor brandMediumGrey];
		scrollview.showsHorizontalScrollIndicator = NO;
		
		for (int index = 0; index < [post.images count]; index++) {
			ThumbView *imgthumb = ({
				ThumbView *imgthumb = [[ThumbView alloc] initWithFrame:CGRectMake(thumbx, thumby, thumbw, thumbh)];
				[imgthumb setPost:post index:index];
				
				imgthumb.userInteractionEnabled = YES;
				
				UITapGestureRecognizer *doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
				doubletapgr.numberOfTouchesRequired = 1;
				doubletapgr.numberOfTapsRequired = 1;
				doubletapgr.cancelsTouchesInView = YES;
				doubletapgr.delaysTouchesBegan = NO;
				[imgthumb addGestureRecognizer:doubletapgr];
				[doubletapgr release];
				
				[scrollview addSubview:imgthumb];
				thumbx = [imgthumb rightEdge] + padding;
				
				imgthumb;
			});
			
			
			[imgthumb release];
		}
		
		scrollview.contentSize = CGSizeMake(MAX([scrollview w], thumbx), [scrollview h]);
		[scrollview scrollRectToVisible:CGRectMake(scrollview.contentSize.width - 10.0f, 0, 10.0f, [scrollview h]) animated:NO];
		
		[self performSelector:@selector(scrollToBeginning:) withObject:scrollview afterDelay:0.2f];
		
		[topView addSubview:scrollview];
		[scrollview release];
		
		[topView seth:[scrollview bottomEdge]];
    }
	else if ([post hasImages]) {
        //1 image, embed it here
        
		//create hr
		UIView *hr = [self hrWithText:@"Images"];
		[topView addSubview:hr];
		[hr sety:[topView h]];
		
		//embed image view
		UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:[[ViewController instance] contentFrame]];
		avatarzoom.should_resize = YES;
		[avatarzoom hideHeader];
		[avatarzoom setPost:self.post];
		[avatarzoom sety:[hr bottomEdge]];
		[topView addSubview:avatarzoom];
		[avatarzoom release];
		
		//adjust topview height
		[topView seth:[topView h] + [hr h] + [avatarzoom h]];
	}
	
	//post/comment separator
	UIView *hr = [self hrWithText:@"Comments"];
    [topView seth:[topView h] + [hr h]];
    [hr sety:[topView h] - [hr h]];
	hr.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	[topView addSubview:hr];
	
    
	
	// footer
	UIView *bottomview = [[UIView alloc] initWithFrame:self.bounds];
	bottomview.backgroundColor = [UIColor brandGreyColor];
	[bottomview seth:100];
	[bottomview addTopBorder:[UIColor colorWithHex:0xa7a6a6]];
	
	UIButton *upgradeBtn = [UIButton flatBlueButton:@"Add a comment" modifier:1.5f];
	[bottomview addSubview:upgradeBtn];
	[upgradeBtn addTarget:self action:@selector(addCommentClicked:) forControlEvents:UIControlEventTouchUpInside];
	[upgradeBtn centerx];
	[upgradeBtn centery];
	
	//comments list
	self.tableview = [[UITableView alloc] initWithFrame:[[ViewController instance] contentFrame]];
	self.tableview.delegate = self;
	self.tableview.dataSource = self;
	self.tableview.tableHeaderView = topView;
	self.tableview.backgroundColor = [UIColor brandGreyColor];
	[self.tableview setTableFooterView:bottomview];
	[self addSubview:self.tableview];
		
	[self updateFavBtn];
	[self getFBComments];
	self.post.last_read = [NSDate date];
}

- (void) scrollToBeginning:(UIScrollView *)scrollview {
	BOOL isios7 = !SYSTEM_VERSION_LESS_THAN(@"7.0");
	if (isios7) {
		[UIView animateWithDuration:1.3f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.0f options:nil animations:^{
			[scrollview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
		} completion:^(BOOL finished) {}];
	}
	else {
		[UIView animateWithDuration:1.0f animations:^{
			[scrollview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
		}];
	}
}

- (UIView *)hrWithText:(NSString *)hr_string {
	UIView *hr = [[UIView alloc] init];
	[hr setw:[UIScreen mainScreen].bounds.size.width];
	[hr setx:0];
	hr.backgroundColor = [UIColor colorWithHex:0xf1f0f0];
	
	UILabel *hr_comments = [[UILabel alloc] init];
	hr_comments.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f];
	hr_comments.text = hr_string;
	hr_comments.backgroundColor = [UIColor clearColor];
	hr_comments.textColor = [UIColor colorWithHex:0x444444];
	[hr_comments sizeToFit];
	[hr addSubview:hr_comments];
	[hr seth:[hr_comments h] + 4];
	[hr_comments centerx];
	[hr_comments centery];
	
	CALayer *topBorder = [CALayer layer];
	topBorder.frame = CGRectMake(0.0f, 0, [hr w], 0.5f);
	topBorder.backgroundColor = [UIColor colorWithHex:0xd9d8d8].CGColor;
	[hr.layer addSublayer:topBorder];
	
	CALayer *bottomBorder = [CALayer layer];
	bottomBorder.frame = CGRectMake(0.0f, [hr h] - 0.5f, [hr w], 0.5f);
	bottomBorder.backgroundColor = [UIColor colorWithHex:0xc3c2c2].CGColor;
	[hr.layer addSublayer:bottomBorder];
	
	return hr;
}

- (void)userAvatarViewResized:(NSNumber *)height_difference {
	UIView *topView = self.tableview.tableHeaderView;
	[topView seth:[topView h] - [height_difference floatValue]];
	[self.tableview setTableHeaderView:topView];
}

- (void) zoomImage:(UIGestureRecognizer *)gr {
	ThumbView *imgthumb = (ThumbView *)gr.view;
	UIScrollView *scrollview = [[UIScrollView alloc] init];
	int x = 0;
	
	for (int i = 0; i < [self.post.images count]; i++) {
		UserAvatarView *imgzoom = [[UserAvatarView alloc] init];
		[imgzoom setPost:self.post index:i];
		[imgzoom setx:x];
		[imgzoom hideHeader];
		x = [imgzoom rightEdge];
		[scrollview addSubview:imgzoom];
		[imgzoom release];
	}
	
	scrollview.frame = [UIScreen mainScreen].bounds;
	scrollview.pagingEnabled = YES;
	scrollview.contentSize = CGSizeMake(x, [scrollview h]);
	scrollview.contentOffset = CGPointMake([scrollview w] * imgthumb.index, 0);
	scrollview.backgroundColor = [UIColor blackColor];
	
	UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:scrollview action:@selector(shrinkAndRemove)];
	tapgr.numberOfTapsRequired = 1;
	tapgr.numberOfTouchesRequired = 1;
	[scrollview addGestureRecognizer:tapgr];
	[tapgr release];
	
	[[ViewController instance] openModal:scrollview fromPoint:[gr locationOfTouch:0 inView:[ViewController instance].view]];
	[scrollview release];
}

- (void)addCommentClicked:(UIButton *)btn {
	//TODO fix this
	if (!self.postcreate) {
		self.postcreate = [[PostCreateView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		self.postcreate.postClicked = ^{
			[self getFBComments];
		};
		
		self.postcreate.messageTextField.text = @"";
	}
	
	self.postcreate.post = self.post;
	
	//TODO: Translate btn.center into [viewcontroller instance].view
	[[ViewController instance] openModal:self.postcreate fromPoint:btn.center];
	[self.postcreate addedAsSubview:@{}];
}

- (void)getFBComments {
	FBHelper *fb = [FBHelper instance];
	[fb getComments:self.post.status_id completed:^(NSDictionary *response) {
		//response should be: [ { id, from, message, created_time } ]
		[self.comments removeAllObjects];
		[self.comments addObjectsFromArray:[response objectForKey:@"comments"]];
		[self.user_data addEntriesFromDictionary:[response objectForKey:@"users"]];
		[self.tableview reloadData];
	}];
}

- (void)zoomAvatar:(UITapGestureRecognizer *)gr {
	NSLog(@"zoomAvatar");
	
	UITableViewCell *cell = (UITableViewCell *)[gr.view parents:[UITableViewCell class]];
	NSIndexPath *index_path = [self.tableview indexPathForCell:cell];
	
	NSLog(@"index_path %i", [index_path row]);
	
	User *comment_user = (User *)[self.user_data objectForKey:[[[self.comments objectAtIndex:index_path.row] valueForKey:@"fromid"] stringValue]];
	
	UserProfileView *profileview = [[UserProfileView alloc] initWithUser:comment_user];
	[[ViewController instance] openModal:profileview fromPoint:[gr locationOfTouch:0 inView:[ViewController instance].view]];
	[profileview release];
}

- (void)zoomUserAvatar:(UITapGestureRecognizer *)gr {
	UserProfileView *profileview = [[UserProfileView alloc] initWithUser:self.user];
	[[ViewController instance] openModal:profileview fromPoint:[gr locationOfTouch:0 inView:[ViewController instance].view]];
	[profileview release];
}

- (void)toggleFavorite:(id)sender {
	if ([self.user is_favorite]) {
		[self.user unfavorite];
	}
	else {
		[self.user favorite];
	}
	
	[self updateFavBtn];
}

- (void) updateFavBtn {
	[((UIButton *)[self viewWithTag:97]) setImage:[UIImage imageNamed:([self.user is_favorite] ? @"icon_favorite_active.png" : @"icon_favorite.png")] forState:UIControlStateNormal];
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = [[[self.comments objectAtIndex:indexPath.row] valueForKey:@"text"] sizeWithFont:[UIFont systemFontOfSize:15.0f]
																				   constrainedToSize:CGSizeMake(round([self w] * .75), FLT_MAX)
																					   lineBreakMode:UILineBreakModeWordWrap].height;
	return MAX(height, 50) + 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
	UILabel *messageLabel;
	UILabel *dateLabel;
	UILabel *nameLabel;
	ThumbView *avatarView;
	
	
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		//hide defaults
		cell.textLabel.hidden = YES;
		cell.detailTextLabel.hidden = YES;
		cell.selectedBackgroundView = [[UIView alloc] init];
		cell.contentView.backgroundColor = [UIColor whiteColor];
		
		messageLabel = [[[UILabel alloc] init] autorelease];
		[cell.contentView addSubview:messageLabel];
		messageLabel.font = [UIFont systemFontOfSize:15.0f];
		messageLabel.numberOfLines = 0;
		messageLabel.textColor = [UIColor colorWithHex:0x444444];
		[messageLabel setwp:.75f];
		[messageLabel setx:70];
		[messageLabel sety:24];
		[messageLabel seth:60];
		messageLabel.tag = 90;
		[cell.contentView bringSubviewToFront:messageLabel];
		
		dateLabel = [[[UILabel alloc] init] autorelease];
		[cell.contentView addSubview:dateLabel];
		dateLabel.font = [UIFont systemFontOfSize:12.0f];
		dateLabel.textColor = [UIColor colorWithHex:0xAAAAAA];
		dateLabel.numberOfLines = 1;
		dateLabel.textAlignment = NSTextAlignmentRight;
		dateLabel.text = @"an unknown amount of time ago";
		[dateLabel sizeToFit];
		[dateLabel setx:[self w] - [dateLabel w] - 10];
		[dateLabel sety:5];
		[dateLabel seth:20];
		dateLabel.tag = 91;
		
		nameLabel = [[[UILabel alloc] init] autorelease];
		[cell.contentView addSubview:nameLabel];
		nameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
		nameLabel.textColor = [UIColor colorWithHex:0x222222];
		nameLabel.numberOfLines = 1;
		nameLabel.text = @"an unknown amount of time ago";
		[nameLabel sizeToFit];
		[nameLabel setx:70];
		[nameLabel sety:5];
		[nameLabel seth:20];
		nameLabel.tag = 92;
		
		avatarView = [[ThumbView alloc] initWithFrame:CGRectMake(5, 8, 60, 60)];
		avatarView.tag = 96;
		[cell.contentView addSubview:avatarView];
				
		avatarView.userInteractionEnabled = YES;
		UITapGestureRecognizer *doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAvatar:)];
		doubletapgr.numberOfTouchesRequired = 1;
		doubletapgr.numberOfTapsRequired = 2;
		doubletapgr.cancelsTouchesInView = YES;
		doubletapgr.delaysTouchesBegan = YES;
		[avatarView addGestureRecognizer:doubletapgr];
		[doubletapgr release];
	} else {
		messageLabel = (UILabel *)[cell viewWithTag:90];
		dateLabel = (UILabel *)[cell viewWithTag:91];
		nameLabel = (UILabel *)[cell viewWithTag:92];
		avatarView = (ThumbView *)[cell viewWithTag:96];
	}
	
	User *comment_user = (User *)[self.user_data objectForKey:[[[self.comments objectAtIndex:indexPath.row] valueForKey:@"fromid"] stringValue]];
	
	messageLabel.text = [[self.comments objectAtIndex:indexPath.row] valueForKey:@"text"];
	[messageLabel sizeToFit];
	[messageLabel setwp:.75f];
	
	nameLabel.text = [NSString stringWithFormat:@"%@ %@", comment_user.first_name, comment_user.last_name];
	[nameLabel sizeToFit];
	
	avatarView.user = comment_user;
		
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[[self.comments objectAtIndex:indexPath.row] valueForKey:@"time"] integerValue]];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"h:mma M/d"];
	dateLabel.text = [[df stringFromDate:date] lowercaseString];
	[df release];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[PDUtils parseAndOpenLink:[[self.comments objectAtIndex:indexPath.row] valueForKey:@"text"]];
	[self.tableview deselectRowAtIndexPath:indexPath animated:YES];
}

@end
