//
//  UserFilterView.h
//  Status
//
//  Created by Paul Denya on 3/6/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UFBlock)(NSDictionary *filter_update);

#define FILTER_STATE_FILTERED_WEEK @"filtered_week"
#define FILTER_STATE_FILTERED_DAY @"filtered_day"
#define FILTER_STATE_FILTERED @"filtered"
#define FILTER_STATE_VISIBLE @"visible"

@interface UserFilterView : UIView {
	User *user;
	UIImageView *avatarView;
	UFBlock filterStateChanged;
}

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) UIImageView *avatarView;
@property (readwrite, copy) UFBlock filterStateChanged;

- (void)setInitialFilterState:(NSString *)filter_state;

@end
