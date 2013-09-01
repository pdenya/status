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
@property (assign) CGFloat row_height;
@property (readwrite) BOOL has_comments;
@property (readwrite) BOOL has_liked;

+ (Post *)postFromDictionary:(NSDictionary *)post_data;
+ (UIFont *)getPostFont;

- (BOOL)hasImages;
- (BOOL)has_unread_comments;
- (CGFloat)rowHeight;
- (CGFloat)minRowHeight;
- (CGFloat)messageLabelWidth;
- (NSString *)image:(NSInteger)index size:(NSString *)size;
- (NSString *)combined_id;
- (User *)user;
- (NSDate *) date;

- (void)unlike;
- (void)like;

@end
