//
//  UITableViewCell+PD.m
//  Status
//
//  Created by Paul Denya on 3/1/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "UITableViewCell+PD.h"
#import "ThumbView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITableViewCell (PD)

//TODO: move this into timelineview
- (void) configureForTimeline {
	UILabel *messageLabel;
	UILabel *dateLabel;
	UILabel *nameLabel;
	ThumbView *avatarView;
	UIView *filter_countdown;
	UILabel *countdown_label;
	UIImageView *commentsNotifierView;
	UIImageView *imageNotifierView;
	ThumbView *imgView;
	
	//hide defaults
	self.textLabel.hidden = YES;
	self.detailTextLabel.hidden = YES;
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	self.selectedBackgroundView = [[UIView alloc] init];
	[self.contentView setBackgroundColor:[UIColor whiteColor]];
	
	
	// Avatar View
	avatarView = [[ThumbView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
	avatarView.tag = 96;
	[self.contentView addSubview:avatarView];
	
	
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

	[self.contentView addSubview:filter_countdown];

	
	// Main Post
	messageLabel = [[[UILabel alloc] init] autorelease];
	messageLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:messageLabel];
	messageLabel.font = [Post getPostFont];
	messageLabel.numberOfLines = 0;
	messageLabel.textColor = [UIColor colorWithHex:0x333333];
	//messageLabel setw ignored here.  It's in setOptions
	[messageLabel setx:[avatarView rightEdge] + 7];
	[messageLabel sety:[avatarView y] - 3];
	[messageLabel seth:60]; //sizeToFit called in setOptions, this is ignored
	[messageLabel setwp:0.77f]; //sizeToFit called in setOptions, this is ignored
	messageLabel.tag = 90;
	[self bringSubviewToFront:messageLabel];
	
	// Time stamp
	dateLabel = [[[UILabel alloc] init] autorelease];
	dateLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:dateLabel];
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
	[self.contentView addSubview:nameLabel];
	nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
	nameLabel.textColor = [UIColor colorWithHex:0x3e9ed5];
	nameLabel.numberOfLines = 1;
	nameLabel.text = @"an unknown amount of time ago";
	[nameLabel sizeToFit];
	nameLabel.tag = 92;

	CGFloat imgview_w = 57;
	imgView = [[ThumbView alloc] initWithFrame:CGRectMake([self.contentView w] - (imgview_w + 4), [messageLabel y], imgview_w, imgview_w)];//CGRectMake(0, 0, 67, 67)];
	imgView.tag = 98;
	imgView.hidden = YES;
	[self.contentView addSubview:imgView];
	
	// Comments icon
	commentsNotifierView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_no_comments.png"]];
	[commentsNotifierView setw:11];
	[commentsNotifierView seth:11];
	[commentsNotifierView setx:[self w] - [commentsNotifierView w] - 8];
	commentsNotifierView.tag = 97;
	[self.contentView addSubview:commentsNotifierView];
	[self.contentView bringSubviewToFront:commentsNotifierView];
	
	// Images icon
	imageNotifierView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_no_comments.png"]];
	[imageNotifierView setw:11];
	[imageNotifierView seth:11];
	[imageNotifierView setx:[commentsNotifierView x] - [imageNotifierView w] - 8];
	imageNotifierView.tag = 93;
	[self.contentView addSubview:commentsNotifierView];
	[self.contentView bringSubviewToFront:commentsNotifierView];
	
	/*
	UIImageView *backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cellbg.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:5]] autorelease];
	backgroundView.alpha = 0.8f;
	[self.contentView addSubview:backgroundView];
	[self.contentView sendSubviewToBack:backgroundView];
	backgroundView.frame = self.contentView.bounds;
	backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	*/
	
/*	UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [self h] - 0.5f, [self w], 1.0f)];
	bottomBorder.backgroundColor = [UIColor colorWithHex:0x3e9ed5];
	bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	[self.contentView addSubview:bottomBorder]; */
	
}

- (UILabel *) messageLabel {
	return (UILabel *)[self.contentView viewWithTag:90];
}

- (UILabel *) dateLabel {
	return (UILabel *)[self.contentView viewWithTag:91];
}

- (UILabel *) nameLabel {
	return (UILabel *)[self.contentView viewWithTag:92];	
}

- (ThumbView *) avatarView {
	return (ThumbView *)[self viewWithTag:96];
}

- (UIImageView *) commentsNotifierView {
	return (UIImageView *)[self viewWithTag:97];
}

- (UIImageView *) imageNotifierView {
	return (UIImageView *)[self viewWithTag:93];
}

- (ThumbView *) imgView {
	return (ThumbView *)[self viewWithTag:98];
}

- (UIView *) filter_countdown {
	return (UIView *)[self viewWithTag:99];
}

- (UILabel *) infinity_label {
	return (UILabel *)[self.contentView viewWithTag:94];
}

- (UILabel *) countdown_label {
	return (UILabel *)[self.contentView viewWithTag:95];
}

- (BOOL) isCompletelyVisible {
	UITableView *tableview = (UITableView *)[self parents:[UITableView class]];
	CGRect cellRect = [tableview rectForRowAtIndexPath:[tableview indexPathForCell:self]];
	cellRect = [tableview convertRect:cellRect toView:tableview.superview];
	BOOL completelyVisible = CGRectContainsRect(tableview.frame, cellRect);

	return completelyVisible;
}

- (int) linesBeforeClip {
	return 5;
}

//not used yet
- (void)setExpanded:(BOOL)should_be_expanded {
	if (should_be_expanded) {
		
	}
	else {
		[self messageLabel].numberOfLines = [self linesBeforeClip];
	}
}

//TODO: move this into Timelineview
- (void)setOptions:(NSDictionary *)options {
	UILabel *messageLabel = [self messageLabel];
	UILabel *dateLabel = [self dateLabel];
	UILabel *nameLabel = [self nameLabel];
	ThumbView *avatarView = [self avatarView];
	ThumbView *imgView = [self imgView];
	Post *post = nil;
	User *user = nil;
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	
	if ([options objectForKey:@"post"]) {
		post = (Post *)[options objectForKey:@"post"];
		user = [post user];
	}
	else if ([options objectForKey:@"user"]) {
		user = (User *)[options objectForKey:@"user"];
	}
	
	
	if (user && [user is_filtered]) {
		NSLog(@" = = is_filtered = = %@", [user filter_state]);
		[self filter_countdown].hidden = NO;
		
		if ([[user filter_state] isEqualToString:FILTER_STATE_FILTERED]) {
			[self infinity_label].hidden = NO;
			[self countdown_label].hidden = YES;
		}
		else {
			[self infinity_label].hidden = YES;
			[self countdown_label].hidden = NO;
			
			//print date to countdown_label
			NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
			NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date] toDate:[user filtered_until] options:0];
			
			if (components.day > 1) {
				[self countdown_label].text = [NSString stringWithFormat:@"%i days", components.day];
			}
			//1d 4hrs
			else if (components.day > 0 && components.hour > 1) {
				[self countdown_label].text = [NSString stringWithFormat:@"%id %ihrs", components.day, components.hour];
			}
			//1d 1hr
			else if (components.day > 0 && components.hour == 1) {
				[self countdown_label].text = [NSString stringWithFormat:@"%id %ihr", components.day, components.hour];
			}
			//1 day  ..this probably won't happen
			else if (components.day > 0 && components.hour == 0) {
				[self countdown_label].text = [NSString stringWithFormat:@"%i day", components.day];
			}
			//12 hours
			else if (components.hour > 1) {
				[self countdown_label].text = [NSString stringWithFormat:@"%i hours", components.hour];
			}
			//1 hour
			else if (components.hour == 1) {
				[self countdown_label].text = @"1 hour";
			}
			//48 mins
			else if (components.minute > 1) {
				[self countdown_label].text = [NSString stringWithFormat:@"%i mins", components.minute];
			}
			//1 min
			else if (components.minute == 1) {
				[self countdown_label].text = @"1 min";
			}
			//0 min or less
			else  {
				[self countdown_label].text = @"now";
			}
		}
	}
	else {
		[self filter_countdown].hidden = YES;
	}
	
	
	//status message
	CGFloat messageLabelWidth = post ? [post messageLabelWidth] : 0.75f;
	messageLabel.text = [options objectForKey:@"message"];
	messageLabel.numberOfLines = 0;//[[options objectForKey:@"is_expanded"] boolValue] ? 0 : [self linesBeforeClip];
	[messageLabel setw:messageLabelWidth];
	[messageLabel sizeToFit];
	
	//name
	nameLabel.text = [options objectForKey:@"name"];
	[nameLabel sizeToFit];
	
	//date string
	if ([options objectForKey:@"time"]) {
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[options objectForKey:@"time"] integerValue]];
		[df setDateFormat:@"h:mma M/d"];
		dateLabel.text = [NSString stringWithFormat:@"at %@", [[df stringFromDate:date] lowercaseString]];
	}
	
	//blue bar on the left
	[self commentsNotifierView].hidden = ![[options objectForKey:@"has_comments"] boolValue];
	
	//mark as read
	if (!self.commentsNotifierView.hidden) {
		BOOL should_mark_as_read = post && post.last_read && post.last_comment_at && [post.last_read compare:post.last_comment_at] == NSOrderedDescending;
		[self.commentsNotifierView setImage:[UIImage imageNamed:(should_mark_as_read ? @"icon_has_comments.png" : @"icon_has_unread")]];
	}
	else {
		[self.commentsNotifierView setImage:[UIImage imageNamed:@"icon_no_comments.png"]];
	}
	
	[nameLabel setx:[messageLabel x]];
	[nameLabel sety:MAX(([messageLabel bottomEdge] + 7), (post ? [post minRowHeight] - 21 : 0))];
	
	[nameLabel setw:[messageLabel w]];
	[nameLabel sizeToFit];
	
	[dateLabel sety:[nameLabel bottomEdge] - [dateLabel h]];
	[dateLabel setx:[nameLabel rightEdge] + 2];
	
	[self.commentsNotifierView sety:[nameLabel y] + 2];

	
	
	//post images thumbnail
	if (post && [post hasImages]) {
		[self imageNotifierView].hidden = NO;
		//imgView.hidden = NO;
		//imgView.post = [options objectForKey:@"post"];
	} else {
		[self imageNotifierView].hidden = YES;
		imgView.hidden = YES;
	}
	
	//profile pic
	if ([options objectForKey:@"user"]) {
		avatarView.user = user;
	} else {
		//stupid
		avatarView.image = [[options objectForKey:@"avatar"] isKindOfClass:[UIImage class]] ? [options objectForKey:@"avatar"] : nil;
	}
	
	[df release];
}

@end
