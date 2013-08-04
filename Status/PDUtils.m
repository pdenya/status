//
//  PDUtils.m
//  Status
//
//  Created by Paul Denya on 7/30/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "ViewController.h"
#import "PDUtils.h"
#import "IAPHelper.h"

@implementation PDUtils

+ (BOOL) isPro {
	NSLog(@"keys: %@", [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys]);
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"is_pro"] ? YES : NO;
}

+ (void) upgradeToPro {
	[[IAPHelper instance] buyProduct];
}

+ (void) upgradeComplete {
	[[NSUserDefaults standardUserDefaults] setObject:@"pro" forKey:@"is_pro"];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upgrade complete!"
													message:@"All Status features are fully unlocked. Thanks for upgrading."
												   delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[[ViewController instance] upgraded];
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
		[[ViewController instance] upgraded];
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
