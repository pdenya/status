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
	UIView *commentsNotifierView;
	ThumbView *imgView;
	
	//hide defaults
	self.textLabel.hidden = YES;
	self.detailTextLabel.hidden = YES;
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	//self.clipsToBounds = YES;
	
	self.selectedBackgroundView = [[UIView alloc] init];
	
	avatarView = [[ThumbView alloc] initWithFrame:CGRectMake(0, 15, 79, 82)];
	avatarView.tag = 96;

	[self.contentView addSubview:avatarView];
	
	dateLabel = [[[UILabel alloc] init] autorelease];
	dateLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:dateLabel];
	dateLabel.font = [UIFont systemFontOfSize:12.0f];
	dateLabel.textColor = [UIColor colorWithHex:0xAAAAAA];
	dateLabel.numberOfLines = 1;
	dateLabel.textAlignment = NSTextAlignmentRight;
	dateLabel.text = @"an unknown amount of time ago";
	[dateLabel sizeToFit];
	dateLabel.text = @"";
	[dateLabel setx:[self w] - [dateLabel w] - 10];
	[dateLabel sety:[avatarView y] - 7];
	[dateLabel seth:20];
	dateLabel.tag = 91;
	
	messageLabel = [[[UILabel alloc] init] autorelease];
	messageLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:messageLabel];
	messageLabel.font = [UIFont systemFontOfSize:15.0f];
	messageLabel.numberOfLines = 0;
	messageLabel.textColor = [UIColor colorWithHex:0x333333];
	//messageLabel setw ignored here.  It's in setOptions
	[messageLabel setx:[avatarView rightEdge] + 7];
	[messageLabel sety:[dateLabel bottomEdge] + 2];
	[messageLabel seth:60]; //sizeToFit called in setOptions, this is ignored
	[messageLabel setwp:0.77f]; //sizeToFit called in setOptions, this is ignored
	messageLabel.tag = 90;
	[self bringSubviewToFront:messageLabel];
	
	nameLabel = [[[UILabel alloc] init] autorelease];
	nameLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:nameLabel];
	nameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
	nameLabel.textColor = [UIColor colorWithHex:0x1F506C];
	nameLabel.numberOfLines = 1;
	nameLabel.text = @"an unknown amount of time ago";
	[nameLabel sizeToFit];
	[nameLabel setx:[messageLabel x]];
	[nameLabel sety:[dateLabel y] + 3];
	[nameLabel seth:20];
	nameLabel.tag = 92;

	CGFloat imgview_w = 57;
	imgView = [[ThumbView alloc] initWithFrame:CGRectMake([self.contentView w] - (imgview_w + 4), [messageLabel y], imgview_w, imgview_w)];//CGRectMake(0, 0, 67, 67)];
	imgView.tag = 98;
	imgView.hidden = YES;
	[self.contentView addSubview:imgView];
	
	commentsNotifierView = [[UIView alloc] init];
	[commentsNotifierView setx:0];
	[commentsNotifierView setw:20];
	[commentsNotifierView seth:20];
	[commentsNotifierView sety:[self h] - [commentsNotifierView h]];
	commentsNotifierView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	
	CAShapeLayer *notifierMask = [CAShapeLayer layer];
	UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:commentsNotifierView.bounds byRoundingCorners:UIRectCornerTopRight cornerRadii:CGSizeMake(3.0f, 3.0f)];
	notifierMask.fillColor = [[UIColor whiteColor] CGColor];
	notifierMask.backgroundColor = [[UIColor clearColor] CGColor];
	notifierMask.path = [roundedPath CGPath];
	commentsNotifierView.layer.mask = notifierMask;
	
	
	UIImageView *bars = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bars.png"]];
	[bars sizeToFit];
	[commentsNotifierView addSubview:bars];
	[bars sethp:0.5f];
	[bars centerx];
	[bars centery];
	
	[self.contentView addSubview:commentsNotifierView];
	[self.contentView bringSubviewToFront:commentsNotifierView];
	commentsNotifierView.backgroundColor = [UIColor colorWithHex:0x138dff];
	commentsNotifierView.tag = 97;

	
	[self.contentView setBackgroundColor:[UIColor whiteColor]];
	
	UIImageView *backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cellbg.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:5]] autorelease];
	backgroundView.alpha = 0.8f;
	[self.contentView addSubview:backgroundView];
	[self.contentView sendSubviewToBack:backgroundView];
	backgroundView.frame = self.contentView.bounds;
	backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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

- (UIView *) commentsNotifierView {
	return (UIView *)[self viewWithTag:97];
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
	
	//status message
	messageLabel.text = [options objectForKey:@"message"];
	messageLabel.numberOfLines = [[options objectForKey:@"is_expanded"] boolValue] ? 0 : [self linesBeforeClip];
	[messageLabel sizeToFit];
	
	if ([options objectForKey:@"post"]) {
		post = (Post *)[options objectForKey:@"post"];
		[messageLabel setw:[post messageLabelWidth]];
	} else {
		[messageLabel setwp:.75f];
	}
	
	//name
	nameLabel.text = [options objectForKey:@"name"];
	[nameLabel sizeToFit];
	
	//date string
	if ([options objectForKey:@"time"]) {
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[options objectForKey:@"time"] integerValue]];
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"h:mma M/d"];
		dateLabel.text = [[df stringFromDate:date] lowercaseString];
		[df release];
	}
	
	//blue bar on the left
	[self commentsNotifierView].hidden = ![[options objectForKey:@"has_comments"] boolValue];
	
	//mark as read
	if (!self.commentsNotifierView.hidden) {
		BOOL should_mark_as_read = post && post.last_read && post.last_comment_at && [post.last_read compare:post.last_comment_at] == NSOrderedDescending;
		self.commentsNotifierView.backgroundColor = should_mark_as_read ? [UIColor colorWithHex:0xA4D3FF] : [UIColor colorWithHex:0x138DFF];
		
		NSLog(@"commentsNotifierView height %f", [self.commentsNotifierView h]);
	}
	else {
		//self.commentsNotifierView.hidden = NO;
		//self.commentsNotifierView.backgroundColor = [UIColor colorWithHex:0xBFBABA];
	}
	
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
