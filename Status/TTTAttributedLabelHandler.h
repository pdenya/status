//
//  TTTAttributedLabelHandler.h
//  Status
//
//  Created by Paul Denya on 5/25/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTTAttributedLabel.h"

@interface TTTAttributedLabelHandler : NSObject <TTTAttributedLabelDelegate>

+ (TTTAttributedLabelHandler *)instance;
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url;

@end
