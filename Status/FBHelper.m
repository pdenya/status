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


- (void)openSession:(FBVoidBlock)sessionOpened {
	NSArray *permissions = @[ @"publish_stream" ];
	
    [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:
	 ^(FBSession *session, FBSessionState state, NSError *error) {
		 switch (state) {
			 case FBSessionStateOpen:
				 sessionOpened();
				 break;
			 case FBSessionStateClosed:
			 case FBSessionStateClosedLoginFailed:
				 [FBSession.activeSession closeAndClearTokenInformation];
				 break;
			 default:
				 break;
		 }
		 
		 if (error) {
			 NSArray* permissions = [[NSArray alloc] initWithObjects:@"user_likes",@"offline_access", nil];
			 session = [[FBSession alloc] initWithPermissions:permissions];
		 }
	 }
	 ];
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
		@"'status_query': 'SELECT uid,status_id,message,time,concat(uid,\"_\",status_id) FROM status WHERE (uid IN (SELECT uid2 FROM friend WHERE uid1= me()) OR uid=me()) AND message != \"\" AND time > %@ %@ LIMIT 200', "
		@"'friend_info_query': 'SELECT uid,first_name, last_name, pic_square, pic_big FROM user WHERE uid IN (SELECT uid FROM #status_query)', "
		@"'comment_count_query': 'SELECT object_id FROM comment WHERE object_id IN (SELECT status_id FROM #status_query)', "
		@"'photo_query': 'SELECT app_data.images, post_id FROM stream WHERE post_id IN (SELECT anon FROM #status_query ) AND app_data.images != \"\"' "
    @"}";
	
	//apply filter if available
	NSString *condition = @"";
	if ([options objectForKey:@"filtered_uids"]) {
		NSMutableArray *filter = [options objectForKey:@"filtered_uids"];
		
		if ([filter count] > 0) {
			condition = [NSString stringWithFormat:@"AND NOT (uid IN (%@))", [filter componentsJoinedByString:@","]];
		}
	}
	
	query = [NSString stringWithFormat:query, latest_stream_time, condition];
	
	
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
					 NSLog(@"handle comments count");
					 NSArray *comment_results = [query_result valueForKey:@"fql_result_set"];
					 
					 //set up comments map to be { #status_id#: true } for each status
					 for (int j= 0; j < [comment_results count]; j++) {
						 [comment_map setValue:@"true" forKey:[[comment_results objectAtIndex:j] valueForKey:@"object_id"]];
					 }
				 }
				 else if ([[query_result valueForKey:@"name"] isEqualToString:@"photo_query"]) {
					 NSLog(@"handle post attachments");
					 NSArray *fql_result_set = [query_result valueForKey:@"fql_result_set"];
					 
					 for (int j = 0; j < [fql_result_set count]; j++) {
						 NSDictionary *appdata = [fql_result_set objectAtIndex:j];
						 
						 if ([appdata objectForKey:@"app_data"] && [[appdata objectForKey:@"app_data"] objectForKey:@"images"]) {
							 NSLog(@"AppData images %@", [[appdata objectForKey:@"app_data"] objectForKey:@"images"]);
							 
							 NSData *img_json = [[[appdata objectForKey:@"app_data"] objectForKey:@"images"] dataUsingEncoding:NSUTF8StringEncoding];
							 NSError *err = nil;
							 NSArray *images = [NSJSONSerialization JSONObjectWithData:img_json options:NSJSONReadingMutableLeaves error:&err];
							 
							 if (!images) {
								 NSLog(@"Error parsing JSON: %@", err);
							 }
							 
							 NSString *post_id = [[[appdata objectForKey:@"post_id"] componentsSeparatedByString:@"_"] objectAtIndex:1];
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

- (void)postStatus:(NSString *)message completed:(FBArrayBlock)completed {
	NSLog(@"Posting Status to Facebook: %@", message);
	
	[FBRequestConnection startWithGraphPath:@"/me/feed" parameters:@{ @"message": message } HTTPMethod:@"POST" completionHandler:
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
}

- (void)postComment:(NSString *)message onStatus:(NSString *)status_id completed:(FBArrayBlock)completed {
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
