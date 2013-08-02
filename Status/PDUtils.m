//
//  PDUtils.m
//  Status
//
//  Created by Paul Denya on 7/30/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "PDUtils.h"

@implementation PDUtils

+ (BOOL) isPro {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"is_pro"] ? YES : NO;
}

+ (void) upgradeToPro {
	[[NSUserDefaults standardUserDefaults] setObject:@"pro" forKey:@"is_pro"];
}

+ (void) downgradeFromPro {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_pro"];
}

+ (BOOL) processCommand:(UITextView *)tf {
	
	if ([tf.text isEqualToString:@"status:upgrade"]) {
		[PDUtils upgradeToPro];
		tf.text = @"upgraded";
		return YES;
	}
	else if ([tf.text isEqualToString:@"status:downgrade"]) {
		[PDUtils downgradeFromPro];
		tf.text = @"downgraded";
		return YES;
	}
	else if ([tf.text isEqualToString:@"status:is_pro"]) {
		tf.text = [PDUtils isPro] ? @"Pro" : @"Free";
		return YES;
	}
	
	return NO;
}
@end
