//
//  CellScrollView.m
//  Status
//
//  Created by Paul Denya on 9/8/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "CellScrollView.h"

@implementation CellScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	UIView *hitview = [super hitTest:point withEvent:event];
	
	if (hitview && hitview == self) {
		hitview = nil;
	}
	
	return hitview;
}

@end
