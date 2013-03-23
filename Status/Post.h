//
//  Post.h
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject <NSCoding>


@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *status_id;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *uid;
@property (readwrite) BOOL has_comments;

+(Post *)postFromDictionary:(NSDictionary *)post_data;

@end
