//
//  UITableViewCell+PD.h
//  Status
//
//  Created by Paul Denya on 3/1/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ThumbView;
@interface UITableViewCell (PD)

- (void) configureForTimeline;
- (UILabel *) messageLabel;
- (UILabel *) dateLabel;
- (UILabel *) nameLabel;
- (ThumbView *) avatarView;
- (UIView *) commentsNotifierView;
- (UIImageView *) imageView;
- (void)setOptions:(NSDictionary *)options;
- (void)setExpanded:(BOOL)should_be_expanded;
- (int) linesBeforeClip;
@end
