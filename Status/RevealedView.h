//
//  RevealedView.h
//  Status
//
//  Created by Paul Denya on 6/27/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RevealedView : UIView {
	Post *post;
	User *user;
	UIButton *filterbtn;
	UIButton *favbtn;
}

@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) UIButton *filterbtn;
@property (nonatomic, retain) UIButton *favbtn;

- (void) refresh;

@end
