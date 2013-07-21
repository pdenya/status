//
//  UnreadPostsView.h
//  Status
//
//  Created by Paul Denya on 7/20/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineView.h"

@interface UnreadPostsView : UIView {
	NSMutableArray *feed;
	TimelineView *timeline;
}

@property (nonatomic, retain) NSMutableArray *feed;
@property (nonatomic, retain) TimelineView *timeline;

@end
