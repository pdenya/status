//
//  EditFilterView.m
//  Status
//
//  Created by Paul Denya on 4/30/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "EditFilterView.h"
#import <QuartzCore/QuartzCore.h>

@implementation EditFilterView

@synthesize user, filterStateChanged, tableview;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
	
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		
		self.tableview = [[UITableView alloc] initWithFrame:self.bounds];
		self.tableview.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.8f];
		self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.tableview.separatorColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.9f];
		self.tableview.delegate = self;
		self.tableview.dataSource = self;
		self.tableview.rowHeight = 50;
		self.tableview.layer.cornerRadius = 5.0f;
		self.tableview.scrollEnabled = NO;
		[self addSubview:self.tableview];
		[self.tableview seth:[self tableView:tableview numberOfRowsInSection:0] * self.tableview.rowHeight];
		[self.tableview setwp:0.9f];
		self.tableview.center = self.center;
		
		UIButton *close_btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[close_btn setTitle:@"×" forState:UIControlStateNormal];
		[close_btn.titleLabel setFont:[UIFont boldSystemFontOfSize:38.0f]];
		[close_btn sizeToFit];
		[close_btn addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:close_btn];
		[close_btn sety:[self.tableview y] - 2];
		[close_btn setx:[self.tableview rightEdge] - [close_btn w] - 10];
    }
	
    return self;
}

-(void)setUser:(User *)new_user {
	user = new_user;
	
	
    NSDictionary *favorite_state = [[FavoritesHelper instance].favorites objectForKey:new_user.uid];
    if (favorite_state) {
    //    [self viewWithTag:44].backgroundColor = [self highlightColor];
    }
	
	NSDictionary *filter_state = [[FilterHelper instance].filter objectForKey:new_user.uid];
	if (filter_state) {
	//	[self setInitialFilterState:[filter_state objectForKey:@"state"]];
	}
}

- (void)visibleClicked:(id)sender {
	NSLog(@"Visible Clicked");
	[self setFilterState:@{
	 @"state": FILTER_STATE_VISIBLE,
	 @"uid": self.user.uid
	 }];
	[self removeFromSuperview];
}

- (void)filterClicked:(id)sender {
	NSLog(@"filter clicked");
	[self setFilterState:@{
	 @"state": FILTER_STATE_FILTERED,
	 @"uid": self.user.uid,
	 @"start": [NSDate date] //not really necessary but maybe we'll do something with it
	 }];
	[self removeFromSuperview];
}

- (void)filterDayClicked:(id)sender {
	NSLog(@"filter day Clicked");
	[self setFilterState:@{
	 @"state": FILTER_STATE_FILTERED_DAY,
	 @"start": [NSDate date],
	 @"uid": self.user.uid
	 }];
	[self removeFromSuperview];
}

- (void)filterWeekClicked:(id)sender {
	NSLog(@"filter week Clicked");
	[self setFilterState:@{
	 @"state": FILTER_STATE_FILTERED_WEEK,
	 @"start": [NSDate date],
	 @"uid": self.user.uid
	 }];
	[self removeFromSuperview];
}

- (UIColor *)highlightColor {
    return [UIColor colorWithHex:0x6d9e42];
}

- (UIColor *)buttonColor {
    return [UIColor colorWithHex:0x242424];
}

- (void)setInitialFilterState:(NSString *)filter_state {
	if ([filter_state isEqualToString:FILTER_STATE_VISIBLE]) {
		[self viewWithTag:43].backgroundColor = [self highlightColor];
	}
	else if ([filter_state isEqualToString:FILTER_STATE_FILTERED]) {
		[self viewWithTag:42].backgroundColor = [self highlightColor];
	}
	else if ([filter_state isEqualToString:FILTER_STATE_FILTERED_DAY]) {
		[self viewWithTag:40].backgroundColor = [self highlightColor];
	}
	else if ([filter_state isEqualToString:FILTER_STATE_FILTERED_WEEK]) {
		[self viewWithTag:41].backgroundColor = [self highlightColor];
	}
}

- (void)setFilterState:(NSDictionary *)filter_state {
	if (self.filterStateChanged) {
		self.filterStateChanged(filter_state);
	}
	else {
		NSString *state = [filter_state objectForKey:@"state"];
		NSString *uid = [NSString stringWithFormat:@"%@", self.user.uid];
		
		if ([state isEqualToString:@"visible"]) {
			[[FilterHelper instance].filter removeObjectForKey:uid];
		}
		else { //filtered, filtered_day, filtered_week
			[[FilterHelper instance].filter setObject:filter_state forKey:uid];
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"EFCell";
    
	
    UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
	UIView *colorMarker;
	UILabel *statusLabel;
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0f];
		UIView *select_bg = [[UIView alloc] init];
		select_bg.alpha = 0.0f;
		cell.selectedBackgroundView = select_bg;
		
		colorMarker = [[UIView alloc] init];
		[colorMarker seth:self.tableview.rowHeight];
		[colorMarker setw:20];
		[colorMarker sety:0];
		[colorMarker setx:0];
		colorMarker.tag = 80;
		[cell.contentView addSubview:colorMarker];
		
		statusLabel = [[UILabel alloc] init];
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.textColor = [UIColor whiteColor];
		statusLabel.font = [UIFont boldSystemFontOfSize:18.0f];
		[statusLabel sety:10];
		[statusLabel setx:30];
		[statusLabel setw:[self.tableview w]];
		[statusLabel seth:self.tableview.rowHeight - 20];
		statusLabel.tag = 81;
		[cell.contentView addSubview:statusLabel];
    }
	else {
		colorMarker = (UIView *)[cell viewWithTag:80];
		statusLabel = (UILabel *)[cell viewWithTag:81];
	}
	
	statusLabel.text = @"";
	cell.textLabel.text = @"";
	colorMarker.backgroundColor = [UIColor clearColor];
	
	switch([indexPath row]) {
		case 0:
			cell.textLabel.text = self.user ? [NSString stringWithFormat:@"%@ %@", self.user.first_name, self.user.last_name] : @"Username";
			cell.textLabel.font = [UIFont boldSystemFontOfSize:24.0f];
			break;
		case 1:
			statusLabel.text = @"Favorite";
			colorMarker.backgroundColor = [UIColor colorWithHex:0x60c306];
			break;
		case 2:
			statusLabel.text = @"Not Favorite";
			colorMarker.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
			break;
		case 3:
			cell.textLabel.text = @"Visibility";
			cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0f];
			colorMarker.backgroundColor = [UIColor clearColor];
			break;
		case 4:
			statusLabel.text = @"Visible";
			colorMarker.backgroundColor = [UIColor colorWithHex:0x60c306];
			break;
		case 5:
			statusLabel.text = @"Filter ..for a day";
			colorMarker.backgroundColor = [UIColor colorWithHex:0xeec315];
			break;
		case 6:
			statusLabel.text = @"Filter ..for a week";
			colorMarker.backgroundColor = [UIColor colorWithHex:0xe46100];
			break;
		case 7:
			statusLabel.text = @"Filter";
			colorMarker.backgroundColor = [UIColor colorWithHex:0xe40000];
			break;
		default:
			break;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath	{
	NSLog(@"editFilterVIew didSelectRowAtIndexPath");
	BOOL should_close = YES;
	
	switch([indexPath row]) {
		case 1:
			[[FavoritesHelper instance].favorites setObject:@{
			 @"state": FAVORITE_STATE_FAVORITED,
			 @"start": [NSDate date],
			 @"uid": self.user.uid
			 } forKey:self.user.uid];
			break;
		case 2:
			[[FavoritesHelper instance].favorites removeObjectForKey:self.user.uid];
			break;
		case 4:
			[self setFilterState:@{
			 @"state": FILTER_STATE_VISIBLE,
			 @"uid": self.user.uid
			 }];
			break;
		case 5:
			[self setFilterState:@{
			 @"state": FILTER_STATE_FILTERED_DAY,
			 @"start": [NSDate date],
			 @"uid": self.user.uid
			 }];
			break;
		case 6:
			[self setFilterState:@{
			 @"state": FILTER_STATE_FILTERED_WEEK,
			 @"start": [NSDate date],
			 @"uid": self.user.uid
			 }];
			break;
		case 7:
			[self setFilterState:@{
			 @"state": FILTER_STATE_FILTERED,
			 @"uid": self.user.uid,
			 @"start": [NSDate date] //not really necessary but maybe we'll do something with it
			 }];
			break;
		default:
			should_close = NO;
			break;
	}
	
	if (should_close) {
		[self close];
	}
}

- (void)close:(CGFloat)delay {
	[UIView animateWithDuration:0.2
						  delay:0.2f
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.transform = CGAffineTransformMakeScale(0.4, 0.4);
						 self.alpha = 0.0f;
					 }
					 completion:^(BOOL finished){ [self removeFromSuperview]; }];
}

-(void)closeButtonClicked:(id)sender {
	[self close:0.0f];
}

-(void)close {
	[self close:0.2f];
}

@end
