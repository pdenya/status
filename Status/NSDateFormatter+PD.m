//
//  NSDateFormatter+PD.m
//  Status
//
//  Created by Paul Denya on 8/1/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "NSDateFormatter+PD.h"

@implementation NSDateFormatter (PD)

+ (NSDateFormatter *)instance {
	static dispatch_once_t onceMark;
	static NSDateFormatter *formatter = nil;

	dispatch_once(&onceMark, ^{
        formatter = [[NSDateFormatter alloc] init];
	});
	
	return formatter;
}

@end
