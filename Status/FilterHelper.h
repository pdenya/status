//
//  FilterHelper.h
//  Status
//
//  Created by Paul on 3/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FILTER_STATE_FILTERED_WEEK @"filtered_week"
#define FILTER_STATE_FILTERED_DAY @"filtered_day"
#define FILTER_STATE_FILTERED @"filtered"
#define FILTER_STATE_VISIBLE @"visible"

#define FAVORITE_STATE_FAVORITED @"favorited"
#define FAVORITE_STATE_NOT_FAVORITED @"not_favorited"

#define LIKE_STATE_LIKED @"liked"
#define LIKE_STATE_NOT_LIKED @"not_liked"

@interface FilterHelper : NSObject {
    
}

@property (atomic, retain) NSMutableDictionary *filter;

+ (FilterHelper *)instance;
- (FilterHelper *)init;
- (void)load;
- (void)save;
+ (NSString *) stringForState:(NSString *)state;

@end
