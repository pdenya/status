//
//  UsersHelper.h
//  Status
//
//  Created by Paul on 3/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersHelper : NSObject {

}

@property (atomic, retain) NSMutableDictionary *users;

+ (UsersHelper *)instance;
- (UsersHelper *)init;
- (void)load;
- (void)save;


@end
