//
//  AppHelper.m
//  Status
//
//  Created by Paul Denya on 5/21/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "AppHelper.h"

@implementation AppHelper
@synthesize vc;

+ (AppHelper *)instance {
	static AppHelper *apphelper;
	
	if (!apphelper) {
		apphelper = [[AppHelper alloc] init];
	}
	
	return apphelper;
}

@end
