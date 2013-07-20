//
//  ZKRevealingTableViewCell.h
//  ZKRevealingTableViewCell
//
//  Created by Alex Zielenski on 4/29/12.
//  Copyright (c) 2012 Alex Zielenski.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense,  and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>

@class ZKRevealingTableViewCell;

typedef enum {
	ZKRevealingTableViewCellDirectionNone  = 0,
	ZKRevealingTableViewCellDirectionRight = 0x1,
	ZKRevealingTableViewCellDirectionLeft  = 0x2,
	ZKRevealingTableViewCellDirectionBoth  = ZKRevealingTableViewCellDirectionLeft | ZKRevealingTableViewCellDirectionRight
} ZKRevealingTableViewCellDirection;

@protocol ZKRevealingTableViewCellDelegate <NSObject>

@optional
- (BOOL)cellShouldReveal:(ZKRevealingTableViewCell *)cell;
- (void)cellDidBeginPan:(ZKRevealingTableViewCell *)cell;
- (void)cellDidPan:(ZKRevealingTableViewCell *)cell;
- (void)cellDidReveal:(ZKRevealingTableViewCell *)cell;
- (void)cellWillSnapBack:(ZKRevealingTableViewCell *)cell;

@end

@interface ZKRevealingTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *revealedView;
@property (nonatomic, assign, getter = isRevealing) BOOL revealing;
@property (nonatomic, weak) id <ZKRevealingTableViewCellDelegate> delegate;
@property (nonatomic, assign) ZKRevealingTableViewCellDirection direction;
@property (nonatomic, assign) BOOL shouldBounce;
@property (nonatomic, assign) BOOL shouldAutoSnapBack;
@property (nonatomic, assign) CGFloat pixelsToReveal;
@property (nonatomic, assign, readonly) CGFloat pannedAmount;

@end
