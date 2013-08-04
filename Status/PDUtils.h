//
//  PDUtils.h
//  Status
//
//  Created by Paul Denya on 7/30/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDUtils : NSObject

+ (BOOL) isPro;
+ (void) upgradeToPro;
+ (void) downgradeFromPro;
+ (BOOL) processCommand:(UITextView *)tf;
+ (void) upgradeComplete;
+ (void) openURL:(NSURL *)inputURL;
+ (BOOL) parseAndOpenLink:(NSString *)message;
@end
