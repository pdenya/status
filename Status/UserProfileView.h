//
//  UserProfileView.h
//  Status
//
//  Created by Paul Denya on 8/21/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineView.h"

@interface UserProfileView : UIView

@property (assign) User *user;
@property (nonatomic, retain) TimelineView *timeline;
@property (nonatomic, retain) NSMutableArray *feed;

- (id) initWithUser:(User *)user;

@end
