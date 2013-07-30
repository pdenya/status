//
//  FavoritesView.h
//  Status
//
//  Created by Paul on 3/26/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditFilterView.h"
#import "TimelineView.h"

@interface FavoritesView : UIView <TimelineContainer> {
    TimelineView *timeline;
	NSMutableDictionary *favorites;
	NSMutableArray *keys;
	NSMutableArray *feed;
}

@property (nonatomic, retain) TimelineView *timeline;
@property (nonatomic, retain) NSMutableDictionary *favorites;
@property (nonatomic, retain) NSMutableArray *keys;
@property (nonatomic, retain) NSMutableArray *feed;

- (void) refreshFeed;

@end
