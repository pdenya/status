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
		fbhelper.isGettingStream = NO;
	}
	
	return fbhelper;
}

- (BOOL) hasSession {
	return FBSession.activeSession.isOpen;
}

- (void)openSession:(FBVoidBlock)opened_callback allowLoginUI:(BOOL)allowLoginUI onFail:(FBVoidBlock)failed_callback {
	NSArray *permissions = @[ @"publish_stream" ];
	NSArray *read_permissions = @[ @"read_stream" ];
	
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
			
			//not sure what to do with this..
			session = [[[FBSession alloc] initWithPermissions:permissions] autorelease];
		}
	};
	
	NSLog(@"Trying without Login UI");
	BOOL is_opening = [FBSession openActiveSessionWithReadPermissions:read_permissions allowLoginUI:NO completionHandler:completionHandler];
	
	if (!is_opening && allowLoginUI) {
		NSLog(@"Trying with Login UI");
		is_opening = [FBSession openActiveSessionWithReadPermissions:read_permissions allowLoginUI:allowLoginUI completionHandler:completionHandler];
	}
	
	if (!is_opening) {
		failed_callback();
	}
}

- (void)logout {
	[[FBSession activeSession] closeAndClearTokenInformation];
}

- (void)refreshUser:(NSString *)uid completed:(FBBoolBlock)completed {
	NSString *query = [NSString stringWithFormat:@"{ 'friend_info_query': 'SELECT uid,first_name, last_name, pic_square, pic_big FROM user WHERE uid=\"%@\"' }", uid];
	NSDictionary *queryParam = @{ @"q": query };
	
	[FBRequestConnection startWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:
	 ^(FBRequestConnection *connection, id result, NSError *error) {
		 if (error) {
			 NSLog(@"Error refreshing user %@", uid);
			 completed(NO);
			 self.isGettingStream = NO;
		 } else {
			 // Get the friend data to display
			 NSArray *results = (NSArray *) [result objectForKey:@"data"];
			 
			 for (int i = 0; i < [results count]; i++) {
				 if ([[[results objectAtIndex:i] valueForKey:@"name"] isEqualToString:@"friend_info_query"]) {
					 NSArray *fql_result_set = [[results objectAtIndex:i] valueForKey:@"fql_result_set"];
					 
					 //set user data
					 for (int j = 0; j < [fql_result_set count]; j++) {
						 User *user = [User userFromDictionary:[fql_result_set objectAtIndex:j]];
						 [[UsersHelper instance].users setValue:user forKey:user.uid];
					 }
					 
				 }
			 }
			 
			 completed(YES);
		 }
	 }];
}

- (void) getStream:(FBDictionaryBlock)completed options:(NSDictionary *)options {
	NSLog(@"getStream");
	
	if (self.isGettingStream) {
		NSLog(@"returning because we're already getting the stream");
		return;
	}
	
	self.isGettingStream = YES;
	
	NSString *latest_stream_time = @"0";
	if ([options objectForKey:@"max_time"]) {
		latest_stream_time = [[options objectForKey:@"max_time"] stringValue];
	}
	
	//post_id is ${uid}_${status_id}
	NSString *query = @"{"
		@"'status_query': 'SELECT uid,status_id,message,time,concat(uid,\"_\",status_id) FROM status "
						@" WHERE (uid IN (SELECT uid2 FROM friend WHERE uid1= me()) OR uid=me()) AND message != \"\" AND time > \"%1$@\" LIMIT 100', "
		@"'stream_query': 'SELECT attachment.media, attachment.name, attachment.fb_checkin, actor_id, post_id, message, created_time FROM stream "
						@" WHERE (attachment.media.alt!=\"\" OR message!=\"\") AND actor_id=source_id AND created_time > \"%1$@\" AND attachment.media.type!=\"link\" AND (source_id IN (SELECT uid2 FROM friend WHERE uid1= me()) OR source_id=me()) LIMIT 50', "
		@"'friend_info_query': 'SELECT uid,first_name, last_name, pic_square, pic_big FROM user WHERE uid IN (SELECT uid FROM #status_query) OR (uid IN (SELECT actor_id FROM #stream_query))', "
		@"'comment_count_query': 'SELECT object_id, time FROM comment WHERE (object_id IN (SELECT status_id FROM #status_query) OR (object_id IN (SELECT post_id FROM #stream_query))) %2$@', "
		@"'photo_query': 'SELECT attachment.media, post_id FROM stream WHERE post_id IN (SELECT anon FROM #status_query ) AND app_data.images != \"\" AND NOT (post_id IN (SELECT post_id FROM #stream_query))' "
    @"}";
	
	NSString *comment_condition = @"";
	if ([[FeedHelper instance].feed count] > 0) {
		NSMutableArray *status_ids = [[NSMutableArray alloc] init];
		
		//TODO: add some more sensible limits here (time based maybe?)
		for (int i = 0; i < [[FeedHelper instance].feed count]; i++) {
			Post *post = (Post *)[[FeedHelper instance].feed objectAtIndex:i];
			[status_ids addObject:post.status_id];
			
			if (i > 200) break;
		}
		
		comment_condition = [NSString stringWithFormat:@"OR object_id IN (\"%@\")", [status_ids componentsJoinedByString:@"\",\""]];
		
		[status_ids removeAllObjects];
		[status_ids release];
	}
	
	query = [NSString stringWithFormat:query, latest_stream_time, comment_condition];
	
	
	NSLog(@"query: \n %@", query);
	
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
	
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:
	 ^(FBRequestConnection *connection, id result, NSError *error) {
		 if (error) {
			 NSLog(@"Error getting stream");
			 completed(nil);
			 self.isGettingStream = NO;
		 } else {
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
					 NSArray *fql_result_set = [query_result valueForKey:@"fql_result_set"];
					 NSLog(@"handle statuses. %i rows", [fql_result_set count]);
					 
					 //set post data
					 for (int j = 0; j < [fql_result_set count]; j++) {
						 Post *post = [Post postFromDictionary:[fql_result_set objectAtIndex:j]];
						 [statuses addObject:post];
					 }
					 
					 [statuses sortUsingComparator:[User timeComparator]];
				 
				 }
				 //handle stream, another source of statuses
				 else if ([[query_result valueForKey:@"name"] isEqualToString:@"stream_query"]) {
					 NSArray *stream_results = [query_result valueForKey:@"fql_result_set"];
					 NSLog(@"handle stream. %i rows", [stream_results count]);
					 
					 for (int j = 0; j < [stream_results count]; j++) {
						 //first identify the type of status so we know which info to pull out of it
						 NSDictionary *stream_result = [stream_results objectAtIndex:j];
						 NSArray *media = [stream_result valueForKeyPath:@"attachment.media"];
						 BOOL is_facebook_being_an_asshole = NO;
						 
						 //handle status_id, it'll either be an NSDecimalNumber or a string like uid_statusid
						 NSString *status_id;
						 if ([[stream_result valueForKey:@"post_id"] isKindOfClass:[NSNumber class]]) {
							 status_id = [[stream_result valueForKey:@"post_id"] stringValue];
						 } else {
							 status_id = [[[stream_result valueForKey:@"post_id"] componentsSeparatedByString:@"_"] lastObject];
						 }
						 
						 
						 NSLog(@"a");
						 // Find an existing post already handled by status_query
						 // i wonder if this is efficient enough, might be better to just de-dupe later
						 NSUInteger matching_post_index = [statuses indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
							 stop = [((Post *)obj).status_id isEqualToString:status_id];
							 return stop;
						 }];
						 
						 Post *post;
						 
						 if (matching_post_index == NSNotFound) {
							 post = [[Post alloc] init];
							 post.status_id = status_id;
							 post.time = [stream_result objectForKey:@"created_time"];
							 post.uid = [[stream_result objectForKey:@"actor_id"] isKindOfClass:[NSString class]] ? [stream_result objectForKey:@"actor_id"] : [[stream_result objectForKey:@"actor_id"] stringValue];
							 post.has_comments = NO;
							 post.has_liked = NO;
							 post.images = [[NSMutableArray alloc] init];
						 }
						 else {
							 post = (Post *)[statuses objectAtIndex:matching_post_index];
						 }
						 
						 
						 BOOL is_photo = media && [media count] > 0 && [[media objectAtIndex:0] valueForKey:@"type"] && [[[media objectAtIndex:0] valueForKey:@"type"] isEqualToString:@"photo"];
						 BOOL is_location = !is_photo && [stream_result valueForKeyPath:@"attachment.fb_checkin"];
						 
						 NSLog(@"%@", [[stream_results objectAtIndex:j] description]);
						 
						 if (is_photo) {
							 //should always have either message or media[0].alt
							 post.message = [stream_result valueForKey:@"message"] && [[stream_result valueForKey:@"message"] length] > 0 ? [stream_result valueForKey:@"message"] : [[media objectAtIndex:0] valueForKey:@"alt"];
							 //post.message = [NSString stringWithFormat:@"=IP= %@", post.message];
							 
							 //add images
							 for (int k = 0; k < [media count]; k++) {
								[post.images addObject:@{
									 @"alt": [[media objectAtIndex:k] valueForKey:@"alt"],
									 @"src": [[media objectAtIndex:k] valueForKey:@"src"]
								}];
							 }
							 
							 //TODO: maybe handle location data that comes with photos?
						 }
						 else if (is_location) {
							 //should always have either message or media[0].alt
							 //post.message = [NSString stringWithFormat:@"=LL= %@", [stream_result valueForKey:@"message"]];
							 post.message = [stream_result valueForKey:@"message"];
							 post.images = [[NSMutableArray alloc] init];
							 post.location = [stream_result valueForKeyPath:@"attachment.name"];
						 }
						 //check for link
						 else if (media && [media count] > 0 && [[[media objectAtIndex:0] objectForKey:@"type"] isEqualToString:@"link"]) {
							 //fuckin facebook, are you kidding me? I specifically told you not to get these.
							 is_facebook_being_an_asshole = YES;
						 }
						 //just a status
						 else {
							 //post.message = [NSString stringWithFormat:@"=FS= %@", [stream_result valueForKey:@"message"]];
							 post.message = [stream_result valueForKey:@"message"];
							 post.images = [[NSMutableArray alloc] init];
						 }
						 
						 if (matching_post_index == NSNotFound && !is_facebook_being_an_asshole) {
							[statuses addObject:post];
						 }
						 else if (is_facebook_being_an_asshole) {
							 [post release];
						 }
					 }
					 
					 [statuses sortUsingComparator:[User timeComparator]];
					
				 }	//Handle user data
				 else if ([[query_result valueForKey:@"name"] isEqualToString:@"friend_info_query"]) {
					 NSArray *fql_result_set = [query_result valueForKey:@"fql_result_set"];
					 NSLog(@"handle user data. %i users", [fql_result_set count]);
					 
					 //set user data
					 for (int j = 0; j < [fql_result_set count]; j++) {
						 User *user = [User userFromDictionary:[fql_result_set objectAtIndex:j]];
						 [user_data setValue:user forKey:user.uid];
					 }

				 } //Handle comments list
				 else if ([[query_result valueForKey:@"name"] isEqualToString:@"comment_count_query"]) {
					 NSArray *comment_results = [query_result valueForKey:@"fql_result_set"];
					 NSLog(@"handle comments map: %i rows", [comment_map count]);
					 
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
					 
					 NSLog(@"User images %i", [images_map count]);
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
			 
			 [statuses release];
			 [user_data release];
			 [comment_map release];
			 [images_map release];
			 
			 NSLog(@"Stream Results: %@", [response_container description]);
			 
			 NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
			 NSDateFormatter *df = [NSDateFormatter instance];
			 [df setDateFormat:@"'Last checked at 'h:mma' on 'M/d"];
			 [userdefaults setObject:[df stringFromDate:[NSDate date]] forKey:@"fb_last_successful_update"];
			 
			 completed(response_container);
			 
			 self.isGettingStream = NO;
		 }
	 }];
}

- (void) reauthorizeWithWritePermissions:(FBVoidBlock)completed {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"fb_publish_authorized"] && [FBSession.activeSession.permissions indexOfObject:@"publish_stream"] == NSNotFound) {
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

- (void)like:(NSString *)status_id completed:(FBBoolBlock)completed {
    NSLog(@"Path: %@", [NSString stringWithFormat:@"/%@/likes", status_id]);
	FBVoidBlock success = ^{
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/likes", status_id] parameters:nil HTTPMethod:@"POST" completionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			 if (error) {
				 NSLog(@"Error: %@", [error localizedDescription]);
				 NSLog(@"Error: %@", [error description]);
				 NSLog(@"Error: %@", [[error userInfo] description]);
				 completed(NO);
			 } else {
				 NSLog(@"Result: %@", [result description]);
				 // Get the friend data to display
				 completed(YES);
			 }
		 }
		];
	};
	
	[self reauthorizeWithWritePermissions:success];
}

- (void)unlike:(NSString *)status_id completed:(FBBoolBlock)completed {
    NSLog(@"Path: %@", [NSString stringWithFormat:@"/%@/likes", status_id]);
	FBVoidBlock success = ^{
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/likes", status_id] parameters:nil HTTPMethod:@"DELETE" completionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			 if (error) {
				 NSLog(@"Error: %@", [error localizedDescription]);
				 NSLog(@"Error: %@", [error description]);
				 NSLog(@"Error: %@", [[error userInfo] description]);
				 completed(NO);
			 } else {
				 NSLog(@"Result: %@", [result description]);
				 // Get the friend data to display
				 completed(YES);
			 }
		 }
         ];
	};
	
	[self reauthorizeWithWritePermissions:success];
}

- (void)postStatus:(NSString *)message completed:(FBBoolBlock)completed {
	NSLog(@"Posting Status to Facebook: %@", message);
	
	FBVoidBlock success = ^{
		[FBRequestConnection startWithGraphPath:@"/me/feed" parameters:@{ @"message": message } HTTPMethod:@"POST" completionHandler:
			^(FBRequestConnection *connection, id result, NSError *error) {
				if (error) {
					NSLog(@"Error: %@", [error localizedDescription]);
					NSLog(@"Error: %@", [error description]);
					NSLog(@"Error: %@", [[error userInfo] description]);
					completed(NO);
				} else {
					NSLog(@"Result: %@", [result description]);
					completed(YES);
				}

			}
		 ];
	};
	
	[self reauthorizeWithWritePermissions:success];
}

- (void)postStatus:(NSString *)message withImage:(UIImage *)img completed:(FBBoolBlock)completed {
	NSLog(@"Posting Status to Facebook: %@", message);
	
	FBVoidBlock success = ^{
		[FBRequestConnection startWithGraphPath:@"/me/photos" parameters:@{ @"message": message, @"picture": UIImagePNGRepresentation(img) } HTTPMethod:@"POST" completionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			 if (error) {
				 NSLog(@"Error: %@", [error localizedDescription]);
				 NSLog(@"Error: %@", [error description]);
				 NSLog(@"Error: %@", [[error userInfo] description]);
				 completed(NO);
			 } else {
				 NSLog(@"Result: %@", [result description]);
				 completed(YES);
			 }
			 
		 }
		 ];
	};
	
	[self reauthorizeWithWritePermissions:success];
}

- (void)postComment:(NSString *)message onStatus:(NSString *)status_id completed:(FBBoolBlock)completed {
	FBVoidBlock success = ^{
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/comments", status_id] parameters:@{ @"message": message } HTTPMethod:@"POST" completionHandler:
			^(FBRequestConnection *connection, id result, NSError *error) {
				if (error) {
					NSLog(@"Error: %@", [error localizedDescription]);
					NSLog(@"Error: %@", [error description]);
					NSLog(@"Error: %@", [[error userInfo] description]);
					completed(NO);
				} else {
					NSLog(@"Result: %@", [result description]);
					// Get the friend data to display
					completed(YES);
					
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
				
				[formatted_results release];
				[user_data release];
				
				NSLog(@"Stream Results: %@", [response_container description]);
				
				completed(response_container);
			}
		}
	];
}

@end
