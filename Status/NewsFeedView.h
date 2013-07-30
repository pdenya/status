//
//  HomeUsersView.h
//  Status
//
//  Created by Paul Denya on 7/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineView.h"

@interface NewsFeedView : UIView <TimelineContainer>

@property (nonatomic, retain) TimelineView *timeline;
@property (nonatomic, retain) NSMutableArray *feed;

- (void) refreshFeed;

@end
