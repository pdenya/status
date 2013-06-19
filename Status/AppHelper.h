//
//  AppHelper.h
//  Status
//
//  Created by Paul Denya on 5/21/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ViewController;

@interface AppHelper : NSObject

@property (nonatomic, retain) ViewController *vc;

+ (AppHelper *)instance;

@end
