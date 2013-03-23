//
//  User.h
//  Status
//
//  Created by Paul Denya on 2/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>

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

+ (User *)userFromDictionary:(NSDictionary *)user_data;
+ (int)reachedFailureThreshold;
+ (NSComparisonResult(^)(id a, id b))timeComparator;

- (void)loadPicSquare;
- (void)loadPicBig:(PDBlock)loaded;
- (NSString *)full_name;



@end
