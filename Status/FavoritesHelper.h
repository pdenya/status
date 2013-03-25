//
//  FavoritesHelper.h
//  Status
//
//  Created by Paul on 3/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoritesHelper : NSObject {

}

@property (atomic, retain) NSMutableDictionary *favorites;

+ (FavoritesHelper *)instance;
- (FavoritesHelper *)init;
- (void)load;
- (void)save;

@end
