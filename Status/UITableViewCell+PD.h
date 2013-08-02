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
- (UIImageView *) commentsNotifierView;
- (ThumbView *) imgView;
- (void)setOptions:(NSDictionary *)options;
- (void)setExpanded:(BOOL)should_be_expanded;
- (int) linesBeforeClip;
- (UIImageView *) imageNotifierView;
- (UIView *) filter_countdown;
- (UILabel *) infinity_label;
- (UILabel *) countdown_label;
- (BOOL) isCompletelyVisible;
@end
