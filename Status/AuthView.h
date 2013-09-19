//
//  AuthView.h
//  Status
//
//  Created by Paul Denya on 5/27/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthView : UIView {
	
}

@property (nonatomic, copy) void (^success)(void);
@property (nonatomic, retain) UIScrollView *tourview;

@end
