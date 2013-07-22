//
//  RevealedView.m
//  Status
//
//  Created by Paul Denya on 6/27/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "RevealedView.h"

@implementation RevealedView
@synthesize	post, user, filterbtn, favbtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
        // Initialization code
		self.backgroundColor = [UIColor colorWithHex:0xf7f6f6];
		self.autoresizesSubviews = YES;
		
		self.favbtn = [self revealedButton:@{
		   @"icon": @"icon_edit_favorite.png",
		   @"text": @"Tap to favorite"
		}];
		
		[self.favbtn addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.favbtn];
		self.favbtn.tag = 60;
		
		NSString *favorite_state  = ([[FavoritesHelper instance].favorites objectForKey:user.uid]) ? FAVORITE_STATE_FAVORITED : FAVORITE_STATE_NOT_FAVORITED;
		[self updateBtn:self.favbtn forState:favorite_state];
		
		UIView *hr = [[UIView alloc] init];
		[hr setx:[self.favbtn rightEdge]];
		[hr sety:0];
		[hr seth:[self h]];
		[hr setw:1];
		[self addSubview:hr];
		hr.backgroundColor = [UIColor colorWithHex:0xe9e8e8];
		hr.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
		
		self.filterbtn = [self revealedButton:@{
		 @"icon": @"icon_edit_filter.png",
		 @"text": @"Tap to filter"
		}];
		
		[self.filterbtn addTarget:self action:@selector(toggleFilter:) forControlEvents:UIControlEventTouchUpInside];
		[self.filterbtn setx:101];
		[self addSubview:self.filterbtn];
		self.filterbtn.tag = 61;
    }
    return self;
}

- (void) setPost:(Post *)new_post {
	post = new_post;
	self.user = [[UsersHelper instance].users objectForKey:post.uid];
	
	[self refresh];
}

- (void) refresh {
	NSDictionary *filter_dict = [[FilterHelper instance].filter objectForKey:[NSString stringWithFormat:@"%@", self.user.uid]];
	NSString *filter_state = filter_dict ? [filter_dict objectForKey:@"state"] : FILTER_STATE_VISIBLE;
	[self updateBtn:self.filterbtn forState:filter_state];
	
	NSString *favorite_state  = ([[FavoritesHelper instance].favorites objectForKey:self.user.uid]) ? FAVORITE_STATE_FAVORITED : FAVORITE_STATE_NOT_FAVORITED;
	[self updateBtn:self.favbtn forState:favorite_state];
	
	UIImageView *favicon = (UIImageView *)[self.favbtn	viewWithTag:62];
	[favicon seth:[self iconSize]];
	[favicon setw:[favicon h]];
	[favicon centerx];
	[favicon setyp:0.45f];

	UIImageView *filtericon = (UIImageView *)[self.filterbtn viewWithTag:62];
	filtericon.frame = favicon.frame;
}

- (void)updateBtn:(UIButton *)btn forState:(NSString *)filter_state {
	NSString *labelText = @"";
	NSString *icon = @"";
	
	NSLog(@"updateBtn %@", filter_state);
	NSLog(@"%@", [self.user.uid description]);
	NSLog(@"%@", [[FavoritesHelper instance].favorites description]);
	
	if([filter_state isEqualToString:FILTER_STATE_FILTERED_WEEK]) {
		icon = @"icon_edit_filter_active.png";
		labelText = @"Hidden for a week";
	}
	else if([filter_state isEqualToString:FILTER_STATE_FILTERED]) {
		icon = @"icon_edit_filter_active.png";
		labelText = @"Hidden";
	}
	else if([filter_state isEqualToString:FILTER_STATE_FILTERED_DAY]) {
		icon = @"icon_edit_filter_active.png";
		labelText = @"Hidden for a day";
	}
	else if([filter_state isEqualToString:FILTER_STATE_VISIBLE]) {
		icon = @"icon_edit_filter.png";
		labelText = @"Tap to filter";
	}
	else if([filter_state isEqualToString:FAVORITE_STATE_FAVORITED]) {
		labelText = @"Favorite";
		icon = @"icon_edit_favorite_active.png";
	}
	else if([filter_state isEqualToString:FAVORITE_STATE_NOT_FAVORITED]) {
		labelText = @"Tap to favorite";
		icon = @"icon_edit_favorite.png";
	}
	
	
	//update label
	UILabel *lbl = (UILabel *)[btn viewWithTag:63];
	lbl.text = labelText;
	[lbl setwp:1];
	[lbl sizeToFit];
	[lbl centerx];
	
	//update icon
	UIImageView *iconview = (UIImageView *)[btn viewWithTag:62];
	[iconview setImage:[UIImage imageNamed:icon]];
}

- (CGFloat)iconSize {
	NSLog(@"iconSize rowheight %f %@", [self.post rowHeight], [self.post message]);
	return self.post && [self.post rowHeight] < 90 ? 40 : 70;
}

- (UIButton *)revealedButton:(NSDictionary *)options {
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn setBackgroundColor:[UIColor colorWithHex:0xf7f6f6]];
	[btn setw:100];
	[btn seth:100];
	[btn setx:0];
	[btn sety:0];
	btn.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
	
	UIImageView *iconview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[options objectForKey:@"icon"]]];
	
	[iconview seth:[self iconSize]];
	[iconview setw:[iconview h]];
	iconview.contentMode = UIViewContentModeScaleAspectFit;
	[btn addSubview:iconview];
	[iconview centerx];
	[iconview setyp:0.45f];
	iconview.tag = 62;
	iconview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	UILabel *lbl = [[UILabel alloc] init];
	lbl.text = [options objectForKey:@"text"];
	lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
	[lbl sizeToFit];
	lbl.textColor = [UIColor colorWithHex:0x7f7e7e];
	lbl.backgroundColor = btn.backgroundColor;
	[btn addSubview:lbl];
	[lbl centerx];
	[lbl sety:[iconview bottomEdge] + 1];
	lbl.tag = 63;
	lbl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	return btn;
}

- (void)toggleFavorite:(id)sender {
	NSLog(@"ToggleFavorite %@", [self.user full_name]);
	
	NSString *favorite_state  = ([[FavoritesHelper instance].favorites objectForKey:self.user.uid]) ? FAVORITE_STATE_FAVORITED : FAVORITE_STATE_NOT_FAVORITED;
	
	if ([favorite_state isEqualToString:FAVORITE_STATE_FAVORITED]) {
		//update user favorites
		[[FavoritesHelper instance].favorites removeObjectForKey:self.user.uid];
	}
	else {
		//update user favorites
		[[FavoritesHelper instance].favorites setObject:@{
		  @"state": FAVORITE_STATE_FAVORITED,
		  @"start": [NSDate date],
		  @"uid": self.user.uid
		} forKey:self.user.uid];
	}
	
	favorite_state = ([[FavoritesHelper instance].favorites objectForKey:self.user.uid]) ? FAVORITE_STATE_FAVORITED : FAVORITE_STATE_NOT_FAVORITED;
	[self updateBtn:self.favbtn forState:favorite_state];
}

- (void)toggleFilter:(id)sender {
	NSLog(@"ToggleFilter %@", [self.user full_name]);
	
	NSDictionary *filter_dict = [[FilterHelper instance].filter objectForKey:[NSString stringWithFormat:@"%@", self.user.uid]];
	NSString *filter_state = filter_dict ? [filter_dict objectForKey:@"state"] : FILTER_STATE_VISIBLE;
	NSDictionary *new_filter_state;
	
	if([filter_state isEqualToString:FILTER_STATE_FILTERED_DAY]) {
		filter_state = FILTER_STATE_FILTERED_WEEK;
		new_filter_state = @{
			 @"state": FILTER_STATE_FILTERED_WEEK,
			 @"start": [NSDate date],
			 @"uid": self.user.uid
		 };
	}
	else if([filter_state isEqualToString:FILTER_STATE_FILTERED_WEEK]) {
		filter_state = FILTER_STATE_FILTERED;
		new_filter_state = @{
			 @"state": FILTER_STATE_FILTERED,
			 @"start": [NSDate date],
			 @"uid": self.user.uid
		 };
	}
	else if([filter_state isEqualToString:FILTER_STATE_FILTERED]) {
		filter_state = FILTER_STATE_VISIBLE;
		new_filter_state = @{
			 @"state": FILTER_STATE_VISIBLE,
			 @"uid": self.user.uid
		 };
	}
	else { //FILTER_STATE_VISIBLE
		filter_state = FILTER_STATE_FILTERED_DAY;
		new_filter_state = @{
			 @"state": FILTER_STATE_FILTERED_DAY,
			 @"start": [NSDate date],
			 @"uid": self.user.uid
		 };
	}
	
	//update users filters
	NSString *uid = [NSString stringWithFormat:@"%@", [new_filter_state objectForKey:@"uid"]];
	if ([[new_filter_state objectForKey:@"state"] isEqualToString:@"visible"]) {
		[[FilterHelper instance].filter removeObjectForKey:uid];
	}
	else { //filtered, filtered_day, filtered_week
		[[FilterHelper instance].filter setObject:new_filter_state forKey:uid];
	}
	
	[self updateBtn:self.filterbtn forState:[new_filter_state objectForKey:@"state"]];
}
@end
