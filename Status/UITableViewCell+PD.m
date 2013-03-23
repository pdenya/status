//
//  UITableViewCell+PD.m
//  Status
//
//  Created by Paul Denya on 3/1/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "UITableViewCell+PD.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITableViewCell (PD)

- (void) configureForTimeline {
	UILabel *messageLabel;
	UILabel *dateLabel;
	UILabel *nameLabel;
	UIImageView *avatarView;
	UIView *commentsNotifierView;
	
	//hide defaults
	self.textLabel.hidden = YES;
	self.detailTextLabel.hidden = YES;
	//self.clipsToBounds = YES;
	
	self.selectedBackgroundView = [[UIView alloc] init];
	
	messageLabel = [[[UILabel alloc] init] autorelease];
	messageLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:messageLabel];
	messageLabel.font = [UIFont systemFontOfSize:15.0f];
	messageLabel.numberOfLines = 0;
	messageLabel.textColor = [UIColor colorWithHex:0x3b444f];
	[messageLabel setwp:.75f];
	[messageLabel setx:71];
	[messageLabel sety:29];
	[messageLabel seth:60];
	messageLabel.tag = 90;
	[self bringSubviewToFront:messageLabel];
	
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
	[dateLabel sety:6];
	[dateLabel seth:20];
	dateLabel.tag = 91;
	
	nameLabel = [[[UILabel alloc] init] autorelease];
	nameLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:nameLabel];
	nameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
	nameLabel.textColor = [UIColor colorWithHex:0x222222];
	nameLabel.numberOfLines = 1;
	nameLabel.text = @"an unknown amount of time ago";
	[nameLabel sizeToFit];
	[nameLabel setx:[messageLabel x]];
	[nameLabel sety:[dateLabel y] + 1];
	[nameLabel seth:20];
	nameLabel.tag = 92;
	 
	avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 10, 62, 62)];//CGRectMake(0, 0, 67, 67)];
	avatarView.tag = 96;
	avatarView.layer.cornerRadius = 3.0f;
	avatarView.layer.borderColor = [UIColor colorWithHex:0xa2caf1].CGColor;
	avatarView.layer.borderWidth = 1.0f;
	avatarView.layer.masksToBounds = YES;
	avatarView.backgroundColor = [UIColor colorWithHex:0xa2caf1];
	[self.contentView addSubview:avatarView];
	
	commentsNotifierView = [[UIView alloc] init];
	[self.contentView addSubview:commentsNotifierView];
	[self.contentView bringSubviewToFront:commentsNotifierView];
	[commentsNotifierView setx:0];
	[commentsNotifierView sety:0];
	[commentsNotifierView setw:3];
	[commentsNotifierView seth:[self.contentView h]];
	commentsNotifierView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
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

- (void)configureWithOptions:(NSDictionary *)options {
	UIImageView *avatarView = [self avatarView];
	
	//	avatar_selector can be set with: [NSValue valueWithPointer:@selector(whatever)]
	if ([options objectForKey:@"avatar_target"] && [options objectForKey:@"avatar_selector"]) {
		avatarView.userInteractionEnabled = YES;
		
		UITapGestureRecognizer *doubletapgr = [[UITapGestureRecognizer alloc] initWithTarget:[options objectForKey:@"avatar_target"] action:[[options objectForKey:@"avatar_selector"] pointerValue]];
		doubletapgr.numberOfTapsRequired = 2;
		[avatarView addGestureRecognizer:doubletapgr];
		[doubletapgr release];
		
		NSLog(@"Added double tap gesture recognizer");
	}
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

- (UIImageView *) avatarView {
	return (UIImageView *)[self viewWithTag:96];
}

- (UIView *) commentsNotifierView {
	return (UIView *)[self viewWithTag:97];
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
	UIImageView *avatarView = [self avatarView];
	
	messageLabel.text = [options objectForKey:@"message"];
	messageLabel.numberOfLines = [[options objectForKey:@"is_expanded"] boolValue] ? 0 : [self linesBeforeClip];
	[messageLabel sizeToFit];
	[messageLabel setwp:.75f];
	
	nameLabel.text = [options objectForKey:@"name"];
	[nameLabel sizeToFit];
	
	if ([options objectForKey:@"time"]) {
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[options objectForKey:@"time"] integerValue]];
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"h:mma M/d"];
		dateLabel.text = [[df stringFromDate:date] lowercaseString];
		[df release];
	}
	
	[self commentsNotifierView].hidden = ![[options objectForKey:@"has_comments"] boolValue];
	
	//stupid
	avatarView.image = [[options objectForKey:@"avatar"] isKindOfClass:[UIImage class]] ? [options objectForKey:@"avatar"] : nil;
	
	
}

@end