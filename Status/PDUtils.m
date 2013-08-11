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

+ (void) markAsPro {
	[[NSUserDefaults standardUserDefaults] setObject:@"pro" forKey:@"is_pro"];
}

+ (void) upgradeComplete {
	[PDUtils markAsPro];
	
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
		[PDUtils markAsPro];
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

+ (BOOL) parseAndOpenLink:(NSString *)message {
	NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
	NSArray *matches = [detect matchesInString:message options:0 range:NSMakeRange(0, [message length])];
	[detect release];
	
	if ([matches count] > 0) {
		[PDUtils openURL:[((NSTextCheckingResult *)[matches objectAtIndex:0]) URL]];
		return YES;
	}
	
	return NO;
}

// Method to escape parameters in the URL.
static NSString * encodeByAddingPercentEscapes(NSString *input) {
	NSString *encodedValue =
	(NSString *)CFURLCreateStringByAddingPercentEscapes(
														kCFAllocatorDefault,
														(CFStringRef)input,
														NULL,
														(CFStringRef)@"!*'();:@&=+$,/?%#[]",
														kCFStringEncodingUTF8);
	return [encodedValue autorelease];
}

+ (void)openURL:(NSURL *)inputURL {
	NSLog(@"attributedLabel didSelectLinkWithURL");
	
	//change url to open in chrome if it's installed…
	NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	NSURL *callbackURL = [NSURL URLWithString:@"nmstatus://"];
	
	NSString *scheme = inputURL.scheme;
	
	// Chrome with callback
	if ([scheme isEqualToString:@"http"] ||[scheme isEqualToString:@"https"]) {
		NSLog(@"Chrome with callback");
		NSString *chromeURLString = [NSString stringWithFormat:
									 @"googlechrome-x-callback://x-callback-url/open/?x-source=%@&x-success=%@&url=%@",
									 encodeByAddingPercentEscapes(appName),
									 encodeByAddingPercentEscapes([callbackURL absoluteString]),
									 encodeByAddingPercentEscapes([inputURL absoluteString])];
		NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
		
		// Open the URL with Google Chrome.
		[[UIApplication sharedApplication] openURL:chromeURL];
	}
	// Chrome without callback
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
		NSLog(@"Chrome without callback");
		// Replace the URL Scheme with the Chrome equivalent.
		NSString *scheme = inputURL.scheme;
		NSString *chromeScheme = nil;
		
		if ([scheme isEqualToString:@"http"]) {
			chromeScheme = @"googlechrome";
		} else if ([scheme isEqualToString:@"https"]) {
			chromeScheme = @"googlechromes";
		}
		
		// Proceed only if a valid Google Chrome URI Scheme is available.
		if (chromeScheme) {
			NSString *absoluteString = [inputURL absoluteString];
			NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
			NSString *chromeURLString = [chromeScheme stringByAppendingString:[absoluteString substringFromIndex:rangeForScheme.location]];
			
			// Open the URL with Chrome.
			inputURL = [NSURL URLWithString:chromeURLString];
		}
	}
	//else Safari
	
	[[UIApplication sharedApplication] openURL:inputURL];
}

@end
