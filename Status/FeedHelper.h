//
//  FeedHelper.h
//  Status
//
//  Created by Paul on 3/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedHelper : NSObject {

}

@property (atomic, retain) NSMutableArray *feed;

+ (FeedHelper *)instance;
- (FeedHelper *)init;
- (void)load;
- (void)save;

@end
