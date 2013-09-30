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
