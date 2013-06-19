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
#import "TTTAttributedLabel.h"
#import "TTTAttributedLabelHandler.h"
#import "ThumbView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostDetailsView
@synthesize post, user, tableview, comments, user_data;

- (PostDetailsView *)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.backgroundColor = [UIColor whiteColor];
	}
	
	return self;
}

- (void)addedAsSubview {
	if (!self.post) NSLog(@"ERROR: Post not set in addedAsSubview");
		
	
	self.comments = [[NSMutableArray alloc] init];
	self.user_data = [[NSMutableDictionary alloc] init];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
	
	UILabel *nameLabel = [[UILabel alloc] init];
	nameLabel.text = [self.user full_name];
	
	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[commentButton setImage:[UIImage imageNamed:@"comment.png"] forState:UIControlStateNormal];
	[commentButton addTarget:self action:@selector(addCommentClicked) forControlEvents:UIControlEventTouchUpInside];
	commentButton.contentMode = UIViewContentModeScaleAspectFit;
	
	UIView *headerView = [UIView headerView:nameLabel leftButton:backButton rightButton:commentButton secondRightButton:nil thirdRightButton:nil];
	[self addSubview:headerView];
	
	self.tableview = [[UITableView alloc] initWithFrame:self.bounds];
	self.tableview.delegate = self;
	self.tableview.dataSource = self;
	[self.tableview seth:[self.tableview h] - [headerView h]];
	[self.tableview sety:[headerView bottomEdge]];
	[self addSubview:self.tableview];
	
	UIView *topView = [[UIView alloc] initWithFrame:self.bounds];
	[topView seth:250];
	topView.layer.borderColor = [UIColor colorWithHex:0xCCCCCC].CGColor;
	topView.layer.borderWidth = 1.0f;
	
	
	ThumbView *avatarView = [[ThumbView alloc] initWithFrame:CGRectMake(7, 10, 60, 60)];
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
	
	TTTAttributedLabel *postLabel = [[TTTAttributedLabel alloc] init];
	postLabel.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypeAddress | UIDataDetectorTypePhoneNumber;
	postLabel.lineBreakMode = UILineBreakModeWordWrap;
	postLabel.text = self.post.message;
	postLabel.delegate = [TTTAttributedLabelHandler instance];
	postLabel.font = [UIFont systemFontOfSize:15.0f];
	postLabel.textColor = [UIColor blackColor];
	postLabel.numberOfLines = 0;
	[postLabel setw:200];
	[postLabel sizeToFit];
	[postLabel sety:[avatarView y]];
	[postLabel setx:[avatarView rightEdge] + 10];
	[topView addSubview:postLabel];
	
	[topView seth:MAX(70, [postLabel h] + 10) + 30];

	tableview.tableHeaderView = topView;
	
	self.post.last_read = [NSDate date];
	
	[self getFBComments];
}

- (void)addCommentClicked {
	PostCreateView *postcreate = [[PostCreateView alloc] initWithFrame:self.bounds];
	postcreate.focused = ^{
		CGRect rect = self.tableview.bounds;
		rect.origin.y = self.tableview.contentSize.height - rect.size.height;
		
		[self.tableview scrollRectToVisible:rect animated:YES];
	};
	
	
	postcreate.postClicked = ^{
		NSLog(@"post postclicked");
		FBHelper *fb = [FBHelper instance];
		
		[fb postComment:postcreate.messageTextField.text onStatus:[NSString stringWithFormat:@"%@_%@",self.user.uid, self.post.status_id] completed:
		 ^(NSArray *response) {
			 [self getFBComments];
		 }
		 ];
		
	};
	
	[self addSubview:postcreate];
	[postcreate addedAsSubview:@{
	 @"autofocus": [NSNumber numberWithBool:YES],
	 @"button_text": @"Post Comment"
	 }];
	postcreate.messageTextField.text = @"";
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

- (void)zoomAvatar:(id)sender {
	NSLog(@"zoomAvatar");
	
	UITapGestureRecognizer *gr = (UITapGestureRecognizer *)sender;
	UITableViewCell *cell = (UITableViewCell *)gr.view.superview.superview;
	NSIndexPath *index_path = [self.tableview indexPathForCell:cell];
	
	User *comment_user = (User *)[self.user_data objectForKey:[[self.comments objectAtIndex:index_path.row] valueForKey:@"fromid"]];
	
	UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:self.bounds];
	[avatarzoom setUser:comment_user];
	
	[self addSubview:avatarzoom];
	[avatarzoom release];
}

- (void)zoomUserAvatar:(id)sender {
	UserAvatarView *avatarzoom = [[UserAvatarView alloc] initWithFrame:self.bounds];
	[avatarzoom setUser:self.user];
	[self addSubview:avatarzoom];
	[avatarzoom release];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = [[[self.comments objectAtIndex:indexPath.row] valueForKey:@"text"] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(round([self w] * .75), FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		//hide defaults
		cell.textLabel.hidden = YES;
		cell.detailTextLabel.hidden = YES;
		cell.selectedBackgroundView = [[UIView alloc] init];
		
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
	
	User *comment_user = (User *)[self.user_data objectForKey:[[self.comments objectAtIndex:indexPath.row] valueForKey:@"fromid"]];
	
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

@end
