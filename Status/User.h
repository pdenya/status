//
//  User.h
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Post;

@interface User : NSObject <NSCoding> {
	BOOL is_fetching_square_image;
	BOOL is_fetching_big_image;
}

@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *pic_square;
@property (nonatomic, retain) NSString *pic_big;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) UIImage *image_square;
@property (nonatomic, retain) UIImage *image_big;
@property (nonatomic, retain) NSMutableArray *callbacks;

+ (User *)userFromDictionary:(NSDictionary *)user_data;
+ (int)reachedFailureThreshold;
+ (NSComparisonResult(^)(id a, id b))timeComparator;

- (void)loadPicSquare;
- (void)loadPicSquare:(PDBlock)completed;
- (void)loadPicBig:(PDBlock)loaded;
- (Post *)most_recent_post;
- (NSString *)filter_state;
- (NSDate *)filtered_until;
- (NSString *)full_name;
- (NSString *)picSquareUrl;
- (NSString *)picBigUrl;
- (BOOL) is_favorite;
- (BOOL) is_filtered;
- (void) favorite;
- (void) unfavorite;

@end
