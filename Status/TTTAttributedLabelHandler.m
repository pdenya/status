//
//  TTTAttributedLabelHandler.m
//  Status
//
//  Created by Paul Denya on 5/25/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "TTTAttributedLabelHandler.h"

@implementation TTTAttributedLabelHandler

+ (TTTAttributedLabelHandler *)instance {
	static TTTAttributedLabelHandler *handler;
	
	if (!handler) {
		handler = [[TTTAttributedLabelHandler alloc] init];
	}
	
	return handler;
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

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)inputURL {
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
