//
//  FilterHelper.h
//  Status
//
//  Created by Paul on 3/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterHelper : NSObject {
    
}

@property (atomic, retain) NSMutableDictionary *filter;

+ (FilterHelper *)instance;
- (FilterHelper *)init;
- (void)load;
- (void)save;

@end
