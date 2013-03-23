//
//  UITableViewCell+PD.h
//  Status
//
//  Created by Paul Denya on 3/1/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (PD)

- (void) configureForTimeline;
- (void) configureWithOptions:(NSDictionary *)options;
- (UILabel *) messageLabel;
- (UILabel *) dateLabel;
- (UILabel *) nameLabel;
- (UIImageView *) avatarView;
- (UIView *) commentsNotifierView;
- (void)setOptions:(NSDictionary *)options;
- (void)setExpanded:(BOOL)should_be_expanded;
- (int) linesBeforeClip;
@end
