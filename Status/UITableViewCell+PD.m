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

- (void) configureForTimeline {
	UILabel *messageLabel;
	UILabel *dateLabel;
	UILabel *nameLabel;
	ThumbView *avatarView;
	UIImageView *commentsNotifierView;
	ThumbView *imgView;
	
	//hide defaults
	self.textLabel.hidden = YES;
	self.detailTextLabel.hidden = YES;
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	//self.clipsToBounds = YES;
	
	self.selectedBackgroundView = [[UIView alloc] init];
	
	avatarView = [[ThumbView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
	avatarView.tag = 96;

	[self.contentView addSubview:avatarView];
	
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
	
	commentsNotifierView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_no_comments.png"]];
	[commentsNotifierView setw:11];
	[commentsNotifierView seth:11];
	[commentsNotifierView setx:[self w] - [commentsNotifierView w] - 8];
	
	[self.contentView addSubview:commentsNotifierView];
	[self.contentView bringSubviewToFront:commentsNotifierView];
	commentsNotifierView.tag = 97;
	
	[self.contentView setBackgroundColor:[UIColor whiteColor]];
	
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

- (ThumbView *) imgView {
	return (ThumbView *)[self viewWithTag:98];
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

- (void)setOptions:(NSDictionary *)options {
	UILabel *messageLabel = [self messageLabel];
	UILabel *dateLabel = [self dateLabel];
	UILabel *nameLabel = [self nameLabel];
	ThumbView *avatarView = [self avatarView];
	ThumbView *imgView = [self imgView];
	Post *post = nil;
	
	if ([options objectForKey:@"post"]) {
		post = (Post *)[options objectForKey:@"post"];
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
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"h:mma M/d"];
		dateLabel.text = [NSString stringWithFormat:@"at %@", [[df stringFromDate:date] lowercaseString]];
		[df release];
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
		imgView.hidden = NO;
		imgView.post = [options objectForKey:@"post"];
	} else {
		imgView.hidden = YES;
	}
	
	//profile pic
	if ([options objectForKey:@"user"]) {
		User *user = (User *)[options objectForKey:@"user"];
		avatarView.user = user;
	} else {
		//stupid
		avatarView.image = [[options objectForKey:@"avatar"] isKindOfClass:[UIImage class]] ? [options objectForKey:@"avatar"] : nil;
	}
}

@end
