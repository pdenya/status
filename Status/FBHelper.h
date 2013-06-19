//
//  FBHelper.h
//  Status
//
//  Created by Paul Denya on 1/26/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

typedef void (^FBArrayBlock)(NSArray *response);
typedef void (^FBDictionaryBlock)(NSDictionary *response);
typedef void (^FBVoidBlock)();

@interface FBHelper : NSObject

+ (FBHelper *) instance;
- (void) logout;
- (void)openSession:(FBVoidBlock)opened_callback allowLoginUI:(BOOL)allowLoginUI onFail:(FBVoidBlock)failed_callback;
- (void) getStream:(FBDictionaryBlock)completed options:(NSDictionary *)options;
- (void) postStatus:(NSString *)message completed:(FBArrayBlock)completed;
- (void) getComments:(NSString *)post_id completed:(FBDictionaryBlock)completed;
- (void) postComment:(NSString *)message onStatus:(NSString *)status_id completed:(FBArrayBlock)completed;

@end
