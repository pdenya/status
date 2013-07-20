//
//  FBHelper.m
//  Status
//
//  Created by Paul Denya on 1/26/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "FBHelper.h"

@implementation FBHelper

//FACEBOOK

+ (FBHelper *)instance {
	static FBHelper *fbhelper;
	
	if (!fbhelper) {
		fbhelper = [[FBHelper alloc] init];
	}
	
	return fbhelper;
}


- (void)openSession:(FBVoidBlock)opened_callback allowLoginUI:(BOOL)allowLoginUI onFail:(FBVoidBlock)failed_callback {
	NSArray *permissions = @[ @"publish_stream" ];
	NSArray *read_permissions = @[ @"read_stream" ];
	
	/*
	 //  stackoverflow.com/questions/12810353/error-when-using-fbsession-openactivesessionwithpublishpermissions
	 ACAccountStore* as = [[ACAccountStore new] autorelease];
	 ACAccountType* at = [as accountTypeWithAccountTypeIdentifier: @"com.apple.facebook"];
	 if ( at != nil ) {
	 // iOS6+, call  [FBSession openActiveSessionWithReadPermissions: ...]
	 
	 } else  {
	 // iOS5, call [FBSession openActiveSessionWithPublishPermissions: ...]
	 }

	 */
	
	
	
	void (^completionHandler)(FBSession *session, FBSessionState status, NSError *error) = ^(FBSession *session, FBSessionState status, NSError *error) {
		NSLog(@"completion");
		switch (status) {
			case FBSessionStateOpen:
				NSLog(@"FB State Open");
				opened_callback();
				break;
			case FBSessionStateClosed:
			case FBSessionStateClosedLoginFailed:
				NSLog(@"FB State closed");
				[FBSession.activeSession closeAndClearTokenInformation];
				failed_callback();
				break;
			default:
				NSLog(@"default");
				break;
		}
		
		if (error) {
			NSLog(@"error %@", [error description]);
			session = [[FBSession alloc] initWithPermissions:permissions];
		}
	};
	
	NSLog(@"Trying without Login UI");
	BOOL is_opening = [FBSession openActiveSessionWithReadPermissions:read_permissions allowLoginUI:NO completionHandler:completionHandler];
	
	if (!is_opening && allowLoginUI) {
		NSLog(@"Trying with Login UI");
		is_opening = [FBSession openActiveSessionWithReadPermissions:read_permissions allowLoginUI:allowLoginUI completionHandler:completionHandler];
	}
	else if (!is_opening) {
		failed_callback();
	}
	
	/*
	NSLog(@"calling open active session");
    [FBSession openActiveSessionWithPublishPermissions:permissions
									   defaultAudience:FBSessionDefaultAudienceFriends
										  allowLoginUI:allowLoginUI
									 completionHandler:
	 ^(FBSession *session, FBSessionState state, NSError *error) {
		 NSLog(@"completion");
		 switch (state) {
			 case FBSessionStateOpen:
				 opened_callback();
				 break;
			 case FBSessionStateClosed:
			 case FBSessionStateClosedLoginFailed:
				 [FBSession.activeSession closeAndClearTokenInformation];
				 failed_callback();
				 break;
			 default:
				 NSLog(@"default");
				 break;
		 }
		 
		 if (error) {
			 NSLog(@"error");
			 session = [[FBSession alloc] initWithPermissions:permissions];
		 }
	 }];
	 */
}

- (void)logout {
	[[FBSession activeSession] closeAndClearTokenInformation];
}

- (void) getStream:(FBDictionaryBlock)completed options:(NSDictionary *)options {
	NSLog(@"getStream");
	
	NSString *latest_stream_time = @"0";
	if ([options objectForKey:@"max_time"]) {
		latest_stream_time = [[options objectForKey:@"max_time"] stringValue];
	}
	
	//select app_data, attachment, post_id from stream where post_id IN ('1315663027_10200756640981133') AND app_data.images != ''
	//post_id is ${uid}_${status_id}
	NSString *query = @"{"
		@"'status_query': 'SELECT uid,status_id,message,time,concat(uid,\"_\",status_id) FROM status WHERE (uid IN (SELECT uid2 FROM friend WHERE uid1= me()) OR uid=me()) AND message != \"\" AND time > %@ %@ LIMIT 400', "
		@"'friend_info_query': 'SELECT uid,first_name, last_name, pic_square, pic_big FROM user WHERE uid IN (SELECT uid FROM #status_query)', "
		@"'comment_count_query': 'SELECT object_id, time FROM comment WHERE object_id IN (SELECT status_id FROM #status_query) %@', "
		@"'photo_query': 'SELECT attachment.media, post_id FROM stream WHERE post_id IN (SELECT anon FROM #status_query ) AND app_data.images != \"\"' "
    @"}";
	
	//apply filter if available
	NSString *condition = @"";
	if ([options objectForKey:@"filtered_uids"]) {
		NSMutableArray *filter = [options objectForKey:@"filtered_uids"];
		
		if ([filter count] > 0) {
			condition = [NSString stringWithFormat:@"AND NOT (uid IN (%@))", [filter componentsJoinedByString:@","]];
		}
	}
	
	NSString *comment_condition = @"";
	if ([[FeedHelper instance].feed count] > 0) {
		NSMutableArray *status_ids = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < [[FeedHelper instance].feed count]; i++) {
			Post *post = (Post *)[[FeedHelper instance].feed objectAtIndex:i];
			[status_ids addObject:post.status_id];
		}
		
		comment_condition = [NSString stringWithFormat:@"OR object_id IN (%@)", [status_ids componentsJoinedByString:@","]];
	}
	
	query = [NSString stringWithFormat:query, latest_stream_time, condition, comment_condition];
	
	
	//NSLog(@"query: \n %@", query);
	
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
	
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:
	 ^(FBRequestConnection *connection, id result, NSError *error) {
		 if (error) {
			 NSLog(@"Error: %@", [error localizedDescription]);
			 NSLog(@"Error: %@", [error description]);
			 NSLog(@"Error: %@", [[error userInfo] description]);
			 completed(nil);
		 } else {
			 NSLog(@"Result: %@", [result description]);
			 // Get the friend data to display
			 NSArray *results = (NSArray *) [result objectForKey:@"data"];
			 NSMutableArray *statuses = [[NSMutableArray alloc] init];
			 NSMutableDictionary *user_data = [[NSMutableDictionary alloc] init];
			 NSMutableDictionary *comment_map = [[NSMutableDictionary alloc] init];
			 NSMutableDictionary *images_map = [[NSMutableDictionary alloc] init];
			 
			 //handle all result sets
			 for (int i = 0; i < [results count]; i++) {
				 NSDictionary *query_result = [results objectAtIndex:i];
				 
				 //Handle Statuses
				 if ([[query_result valueForKey:@"name"] isEqualToString:@"status_query"]) {
					 NSLog(@"handle statuses");
					 NSArray *fql_result_set = [query_result valueForKey:@"fql_result_set"];
					 
					 //set post data
					 for (int j = 0; j < [fql_result_set count]; j++) {
						 Post *post = [Post postFromDictionary:[fql_result_set objectAtIndex:j]];
						 [statuses addObject:post];
					 }
					 
					 [statuses sortUsingComparator:[User timeComparator]];
				 
					 
				 }	//Handle user data
				 else if ([[query_result valueForKey:@"name"] isEqualToString:@"friend_info_query"]) {
					 NSLog(@"handle user data");
					 NSArray *fql_result_set = [query_result valueForKey:@"fql_result_set"];
					 
					 //set user data
					 for (int j = 0; j < [fql_result_set count]; j++) {
						 User *user = [User userFromDictionary:[fql_result_set objectAtIndex:j]];
						 [user_data setValue:user forKey:user.uid];
					 }
				 
				 
				 } //Handle comments list
				 else if ([[query_result valueForKey:@"name"] isEqualToString:@"comment_count_query"]) {
					 NSArray *comment_results = [query_result valueForKey:@"fql_result_set"];
					 NSLog(@"handle comments map %@", [comment_map description]);
					 
					 //set up comments map to be { #status_id#: date_of_most_recent_comment } for each status
					 for (int j= 0; j < [comment_results count]; j++) {
						 NSDictionary *comment_result = [comment_results objectAtIndex:j];
						 NSDate *previous_comment_time = [comment_map objectForKey:[comment_result valueForKey:@"object_id"]];
						 NSDate *comment_time = [NSDate dateWithTimeIntervalSince1970:[[comment_result valueForKey:@"time"] integerValue]];
						 
						 if (!previous_comment_time || [previous_comment_time compare:comment_time] == NSOrderedAscending) {
							 [comment_map setObject:comment_time forKey:[comment_result valueForKey:@"object_id"]];
						 }
					 }
				 }
				 else if ([[query_result valueForKey:@"name"] isEqualToString:@"photo_query"]) {
					 NSLog(@"handle post attachments");
					 NSArray *fql_result_set = [query_result valueForKey:@"fql_result_set"];
					 
					 for (int j = 0; j < [fql_result_set count]; j++) {
						 NSDictionary *imgdata = [fql_result_set objectAtIndex:j];
						 
						 if ([imgdata objectForKey:@"attachment"] && [[imgdata objectForKey:@"attachment"] objectForKey:@"media"]) {
							 //build photo array from attachment.media
							 NSMutableArray *images = [[NSMutableArray alloc] init];
							 NSArray *media = [[imgdata objectForKey:@"attachment"] objectForKey:@"media"];
							 for (int k = 0; k < [media count]; k++) {
								 [images addObject:@{
									@"alt": [[media objectAtIndex:k] objectForKey:@"alt"],
									@"src": [[media objectAtIndex:k] objectForKey:@"src"]
								 }];
							 }
							 
							 NSString *post_id = [[[imgdata objectForKey:@"post_id"] componentsSeparatedByString:@"_"] objectAtIndex:1];
							 [images_map setValue:images forKey:post_id];
						 }
					 }
					 
					 NSLog(@"User images %@", [images_map description]);
				 }
			 }
			 
			 for (int i = 0; i < [statuses count]; i++) {
				 Post *post = (Post *)[statuses objectAtIndex:i];
				 
				 if ([comment_map objectForKey:post.status_id]) {
					 post.has_comments = YES;
					 post.last_comment_at = [comment_map objectForKey:post.status_id];
				 }
				 
				 if ([images_map objectForKey:post.status_id]) {
					 post.images = [NSMutableArray arrayWithArray:[images_map objectForKey:post.status_id]];
				 }
			 }
			 
			 for (int i = 0; i < [[FeedHelper instance].feed count]; i++) {
				 Post *post = (Post *)[[FeedHelper instance].feed objectAtIndex:i];
				 
				 if ([comment_map objectForKey:post.status_id]) {
					 post.has_comments = YES;
					 post.last_comment_at = [comment_map objectForKey:post.status_id];
				 }
				 
				 if ([images_map objectForKey:post.status_id]) {
					 post.images = [NSMutableArray arrayWithArray:[images_map objectForKey:post.status_id]];
				 }
			 }
			 
			 NSDictionary *response_container = @{
				@"feed": statuses,
				@"users": user_data
			 };
			 
			 NSLog(@"Stream Results: %@", [response_container description]);
			 
			 completed(response_container);
		 }
	 }];
}

- (void) reauthorizeWithWritePermissions:(FBVoidBlock)completed {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"fb_publish_authorized"]) {
		[[FBSession activeSession] reauthorizeWithPublishPermissions:@[@"publish_stream"] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
			if (!error) {
				completed();
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"fb_publish_authorized"];
			}
		}];
	}
	else {
		completed();
	}

}

- (void)postStatus:(NSString *)message completed:(FBArrayBlock)completed {
	NSLog(@"Posting Status to Facebook: %@", message);
	
	FBVoidBlock success = ^{
		[FBRequestConnection startWithGraphPath:@"/me/feed" parameters:@{ @"message": message } HTTPMethod:@"POST" completionHandler:
			^(FBRequestConnection *connection, id result, NSError *error) {
				if (error) {
					NSLog(@"Error: %@", [error localizedDescription]);
					NSLog(@"Error: %@", [error description]);
					NSLog(@"Error: %@", [[error userInfo] description]);
				} else {
					NSLog(@"Result: %@", [result description]);
					completed(nil);
				}

			}
		 ];
	};
	
	[self reauthorizeWithWritePermissions:success];
}

- (void)postComment:(NSString *)message onStatus:(NSString *)status_id completed:(FBArrayBlock)completed {
	FBVoidBlock success = ^{
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/comments", status_id] parameters:@{ @"message": message } HTTPMethod:@"POST" completionHandler:
			^(FBRequestConnection *connection, id result, NSError *error) {
				if (error) {
					NSLog(@"Error: %@", [error localizedDescription]);
					NSLog(@"Error: %@", [error description]);
					NSLog(@"Error: %@", [[error userInfo] description]);
					completed(nil);
				} else {
					NSLog(@"Result: %@", [result description]);
					// Get the friend data to display
					completed(nil);
					
				}
			}
		];
	};
	
	[self reauthorizeWithWritePermissions:success];
}

- (void)getComments:(NSString *)post_id completed:(FBDictionaryBlock)completed {
	
	NSString *query = @"{"
		@"'comments_query': 'select text, fromid, likes, user_likes, time from comment where object_id=%@', "
		@"'friend_info_query': 'SELECT uid,first_name, last_name, pic_square, pic_big FROM user WHERE uid IN (SELECT fromid FROM #comments_query)'"
    @"}";
	
	query = [NSString stringWithFormat:query, post_id];
	
	NSLog(@"query: \n %@", query);
	
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
	
	// Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:
		^(FBRequestConnection *connection, id result, NSError *error) {
			if (error) {
				NSLog(@"Error: %@", [error localizedDescription]);
				NSLog(@"Error: %@", [error description]);
				NSLog(@"Error: %@", [[error userInfo] description]);
				completed(nil);
			} else {
				NSLog(@"Result: %@", [result description]);
				// Get the friend data to display
				NSArray *results = (NSArray *) [result objectForKey:@"data"];
				NSMutableArray *formatted_results = [[NSMutableArray alloc] init];
				NSMutableDictionary *user_data = [[NSMutableDictionary alloc] init];
				
				//handle both result sets
				for (int i = 0; i < [results count]; i++) {
					NSDictionary *query_result = [results objectAtIndex:i];
					
					if ([[query_result valueForKey:@"name"] isEqualToString:@"comments_query"]) {
						[formatted_results addObjectsFromArray:[query_result valueForKey:@"fql_result_set"]];
					}
					else if ([[query_result valueForKey:@"name"] isEqualToString:@"friend_info_query"]) {
						NSArray *fql_result_set = [query_result valueForKey:@"fql_result_set"];
						
						//set user data
						for (int j = 0; j < [fql_result_set count]; j++) {
							User *user = [User userFromDictionary:[fql_result_set objectAtIndex:j]];
							[user_data setValue:user forKey:user.uid];
						}
					}
				}
				
				NSDictionary *response_container = @{
					@"comments": formatted_results,
					@"users": user_data
				};
				
				NSLog(@"Stream Results: %@", [response_container description]);
				
				completed(response_container);
			}
		}
	];
}

@end
