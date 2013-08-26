//
//  ThumbView.h
//  Status
//
//  Created by Paul Denya on 5/12/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User, Post;
@interface ThumbView : UIView

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) UIImageView *imgview;
@property (assign) int index;

- (void)setPost:(Post *)new_post index:(int)index;
- (void) makeTappable;

@end
