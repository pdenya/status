//
//  PostCreateView.h
//  Status
//
//  Created by Paul Denya on 2/14/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PCBlock)(void);

@interface PostCreateView : UIView {
	UITextView *messageTextField;
	PCBlock postClicked;
	PCBlock focused;
	Post *post;
}

@property (nonatomic, retain) UITextView *messageTextField;
@property (assign) Post *post;
@property (readwrite, copy) PCBlock postClicked;
@property (readwrite, copy) PCBlock focused;

- (void)addedAsSubview:(NSDictionary *)options;
- (void)switchToComment:(Post *)p;

@end
