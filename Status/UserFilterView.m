//
//  UserFilterView.m
//  Status
//
//  Created by Paul Denya on 3/6/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "UserFilterView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UserFilterView
@synthesize user, avatarView, filterStateChanged;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
	
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
		
		self.avatarView = [[UIImageView alloc] init];
		[self addSubview:self.avatarView];
		self.avatarView.layer.cornerRadius = 3.0f;
		self.avatarView.layer.borderColor = [UIColor colorWithHex:0xa2caf1].CGColor;
		self.avatarView.layer.borderWidth = 1.0f;
		self.avatarView.layer.masksToBounds = YES;
		self.avatarView.backgroundColor = [UIColor colorWithHex:0xa2caf1];
				
		[self addFilterBtns];
    }
	
    return self;
}

-(void)setUser:(User *)new_user {
	user = new_user;
	avatarView.image = self.user.image_square;
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
	
	UILabel *nameLabel = [[UILabel alloc] init];
	nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.first_name, self.user.last_name];
	
	UIView *headerView = [UIView headerView:nameLabel leftButton:backButton rightButton:nil secondRightButton:nil thirdRightButton:nil];
	[self addSubview:headerView];
}

-(void)addFilterBtns {
	
	//Favorite
	UIButton *favoritebtn = [self filterButton];
	favoritebtn.tag = 44;
	[self addSubview:favoritebtn];
	[favoritebtn setx:164];
	[favoritebtn sety:65];
	[favoritebtn addTarget:self action:@selector(favoriteClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	UIImageView *favimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorites.png"]];
	[favoritebtn addSubview:favimg];
	[favimg sizeToFit];
	[favimg setxp:0.5f];
	[favimg setyp:0.42f];
	
	UILabel *favdescription = [self descriptionWithText:@"Favorite"];
	[favoritebtn addSubview:favdescription];
	[favdescription sety:[favoritebtn h] - [favdescription h] - 15];
	[favdescription setxp:0.5f];
	
	self.avatarView.frame = favoritebtn.frame;
	[self.avatarView setx:15];
	
	//hr
	UIView *hr = [UIView horizontalRule];
	[hr setx:35];
	[hr setw:[self w] - 70];
	[hr seth:1];
	[hr sety:[favoritebtn bottomEdge] + 10];
	hr.alpha = 0.3f;
	[self addSubview:hr];
	
	
	//Filter 1 day
	UIButton *filterdaybtn = [self filterButton];
	[filterdaybtn setx:15];
	[filterdaybtn sety:[favoritebtn bottomEdge] + 20];
	[filterdaybtn addTarget:self action:@selector(filterDayClicked:) forControlEvents:UIControlEventTouchUpInside];
	filterdaybtn.tag = 40;
	[self addSubview:filterdaybtn];
	
	UIImageView *filterdaycancelimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_day.png"]];
	[filterdaybtn addSubview:filterdaycancelimg];
	[filterdaycancelimg sizeToFit];
	[filterdaycancelimg setxp:0.56f];
	[filterdaycancelimg setyp:0.4f];
	
	UILabel *filterdaydescription = [self descriptionWithText:@"Filtered for a day"];
	[filterdaybtn addSubview:filterdaydescription];
	[filterdaydescription sety:[filterdaybtn h] - [filterdaydescription h] - 15];
	[filterdaydescription setxp:0.5f];

	//Filter 1 week
	UIButton *filterweekbtn = [self filterButton];
	filterweekbtn.frame = filterdaybtn.frame;
	filterweekbtn.tag = 41;
	[filterweekbtn setx:164];
	[filterweekbtn addTarget:self action:@selector(filterWeekClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:filterweekbtn];
	
	UIImageView *filterweekcancelimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_week.png"]];
	[filterweekbtn addSubview:filterweekcancelimg];
	[filterweekcancelimg sizeToFit];
	[filterweekcancelimg setxp:0.58f];
	[filterweekcancelimg setyp:0.4f];
	
	UILabel *filterweekdescription = [self descriptionWithText:@"Filtered for a week"];
	[filterweekbtn addSubview:filterweekdescription];
	[filterweekdescription sety:[filterweekbtn h] - [filterweekdescription h] - 15];
	[filterweekdescription setxp:0.5f];

	//Filter
	UIButton *filterbtn = [self filterButton];
	filterbtn.tag = 42;
	[filterbtn setx:15];
	[filterbtn sety:[filterdaybtn bottomEdge] + 9];
	[filterbtn addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:filterbtn];
	
	UIImageView *filtercancelimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter.png"]];
	[filterbtn addSubview:filtercancelimg];
	[filtercancelimg sizeToFit];
	[filtercancelimg setxp:0.5f];
	[filtercancelimg setyp:0.42f];
	
	UILabel *filterdescription = [self descriptionWithText:@"Filtered"];
	[filterbtn addSubview:filterdescription];
	[filterdescription sety:[filterbtn h] - [filterdescription h] - 15];
	[filterdescription setxp:0.5f];
	
	//Visible
	UIButton *visiblebtn = [self filterButton];
	visiblebtn.tag = 43;
	[self addSubview:visiblebtn];
	[visiblebtn setx:164];
	[visiblebtn sety:[filterbtn y]];
	[visiblebtn addTarget:self action:@selector(visibleClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	UIImageView *visiblecommentimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"visible.png"]];
	[visiblebtn addSubview:visiblecommentimg];
	[visiblecommentimg sizeToFit];
	[visiblecommentimg setxp:0.5f];
	[visiblecommentimg setyp:0.42f];
	
	UILabel *visibledescription = [self descriptionWithText:@"Visible"];
	[visiblebtn addSubview:visibledescription];
	[visibledescription sety:[visiblebtn h] - [visibledescription h] - 15];
	[visibledescription setxp:0.5f];
}

- (UILabel *)descriptionWithText:(NSString *)description {
	UILabel *filterdescription = [[UILabel alloc] init];
	filterdescription.font = [UIFont boldSystemFontOfSize:13.0f];
	filterdescription.text = description;
	filterdescription.textColor = [UIColor colorWithHex:0xFFFFFF];
	[filterdescription sizeToFit];
	filterdescription.backgroundColor = [UIColor clearColor];
	
	return filterdescription;
}

- (UIButton *)filterButton {
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn seth:[self h] * 0.24f];
	[btn setw:140];
	[btn setBackgroundColor:[UIColor colorWithHex:0x242424]]; //selected color: 6d9e42
	btn.layer.cornerRadius = 4.0f;
	btn.adjustsImageWhenHighlighted = YES;
	
	return btn;
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

- (void)favoriteClicked:(id)sender {
	
}

- (void)setInitialFilterState:(NSString *)filter_state {
	if ([filter_state isEqualToString:FILTER_STATE_VISIBLE]) {
		[self viewWithTag:43].backgroundColor = [UIColor colorWithHex:0x6d9e42];
	}
	else if ([filter_state isEqualToString:FILTER_STATE_FILTERED]) {
		[self viewWithTag:42].backgroundColor = [UIColor colorWithHex:0x6d9e42];
	}
	else if ([filter_state isEqualToString:FILTER_STATE_FILTERED_DAY]) {
		[self viewWithTag:40].backgroundColor = [UIColor colorWithHex:0x6d9e42];
	}
	else if ([filter_state isEqualToString:FILTER_STATE_FILTERED_WEEK]) {
		[self viewWithTag:41].backgroundColor = [UIColor colorWithHex:0x6d9e42];
	}
}

- (void)setFilterState:(NSDictionary *)filter_state {
	if (self.filterStateChanged) {
		self.filterStateChanged(filter_state);
	}
}

@end
