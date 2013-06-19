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
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSDate *last_read;
@property (nonatomic, retain) NSDate *last_comment_at;
@property (readwrite) BOOL has_comments;

+(Post *)postFromDictionary:(NSDictionary *)post_data;
- (BOOL)hasImages;
- (CGFloat)rowHeight;
- (CGFloat)messageLabelWidth;
- (NSString *)image:(NSInteger)index size:(NSString *)size;
@end
