//
//  ZKRevealingTableViewCell.m
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

#import "ZKRevealingTableViewCell.h"


@interface ZKRevealingTableViewCell ()

@property (nonatomic, strong) UIPanGestureRecognizer   *_panGesture;
@property (nonatomic, assign) CGFloat _initialTouchPositionX;
@property (nonatomic, assign) CGFloat _initialHorizontalCenter;
@property (nonatomic, assign) ZKRevealingTableViewCellDirection _lastDirection;
@property (nonatomic, assign) ZKRevealingTableViewCellDirection _currentDirection;
@property (nonatomic, assign) UITableViewCellSelectionStyle originalSelectionStyle;
@property (nonatomic, strong) UIView *horizontalShadowView;
@property (nonatomic, strong) UIView *verticalShadowView;

@end

@implementation ZKRevealingTableViewCell

#pragma mark - Private Properties

@synthesize _panGesture;
@synthesize _initialTouchPositionX;
@synthesize _initialHorizontalCenter;
@synthesize _lastDirection;
@synthesize _currentDirection;

#pragma mark - Lifecycle

- (void)commonInit
{
    self.direction = ZKRevealingTableViewCellDirectionBoth;
    self.shouldBounce = YES;
    self.pixelsToRevealRight = 0;
	self.pixelsToRevealLeft = 0;

    self._panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_pan:)];
    self._panGesture.delegate = self;

    [self addGestureRecognizer:self._panGesture];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

    CGRect rect = self.frame;
    rect.origin = CGPointZero;
    self.revealedView.frame = rect;

    // Needed to get the revealed view behind the selected view. Can't be done in setSelected: since
    // that is not called when the selection is briefly highlighted and the user starts scrolling.
    [self sendSubviewToBack:self.revealedView];
}

#pragma mark - Accessors
- (void)setRevealing:(BOOL)revealing
{
	// Don't change the value if its already that value.
	// Reveal unless the delegate says no
	if (revealing == self.revealing ||
		(revealing && !self._shouldReveal)) {
		return;
    }
	
	[self _setRevealing:revealing];

	if (self.isRevealing) {
		[self _slideOutContentViewInDirection:(self.isRevealing) ? self._currentDirection : self._lastDirection];
	} else {
		[self _slideInContentViewFromDirection:(self.isRevealing) ? self._currentDirection : self._lastDirection offsetMultiplier:self._bounceMultiplier emitSnapBack:NO];
    }
}

- (void)_setRevealing:(BOOL)revealing
{
    _revealing = revealing;

    // Disable selection highlighting completely when revealing so the highlight doesn't interfer with
    // our moving the background view (seletion also uses the background view). It also looks and feels
    // better when you can't select the revealed row.
    if (revealing) {
        self.originalSelectionStyle = self.selectionStyle;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        self.selectionStyle = self.originalSelectionStyle;
    }

	if (self.isRevealing && [self.delegate respondsToSelector:@selector(cellDidReveal:)])
		[self.delegate cellDidReveal:self];
}

- (void)setRevealedView:(UIView *)revealedView {
    if (revealedView == _revealedView) {
        return;
    }

    _revealedView = revealedView;
}

- (BOOL)_shouldReveal
{
	// Conditions are checked in order
	return (![self.delegate respondsToSelector:@selector(cellShouldReveal:)] || [self.delegate cellShouldReveal:self]);
}

- (void)prepareForReuse
{
    if (self.isRevealing) {
        self.selectionStyle = self.originalSelectionStyle;
    }
    _revealing = NO;

    [self sendSubviewToBack:self.revealedView];

    CGRect rect = self.frame;
    rect.origin = CGPointZero;
    self.backgroundView.frame = rect;
	
	self.contentView.frame = rect;

    [super prepareForReuse];
}

- (CGFloat)pannedAmount
{
    CGPoint center = self.contentView.center;
    CGFloat dx = center.x - self._originalCenter;

    CGFloat totalWidth = self.frame.size.width;
    if (self.pixelsToRevealRight != 0) {
        totalWidth = self.pixelsToRevealRight;
    }

    CGFloat amount = dx / totalWidth;
    return MAX(MIN(amount, 1), -1);
}

#pragma mark - Handling the background view
- (void)syncBackgroundViewWithContentView
{
    // Line up the background view with the content view.
    CGPoint center = self.contentView.center;
    CGFloat dx = self._originalCenter - center.x;
    CGRect rect = self.backgroundView.frame;
    rect.origin.x = -dx;
    self.backgroundView.frame = rect;

    rect = CGRectInset(self.revealedView.frame, 0, 0);
    rect.origin.x = -dx;

    // Let the vertical shadow stick out a bit on the appropriate side).
    if (dx < 0) {
        rect.origin.x -= 6;
    }
    else if (dx > 0) {
        rect.origin.x += 6;
    }

    self.verticalShadowView.frame = rect;
}

#pragma mark - Handling Touch

- (void)_pan:(UIPanGestureRecognizer *)recognizer
{
	
	CGPoint translation           = [recognizer translationInView:self];
	CGPoint currentTouchPoint     = [recognizer locationInView:self];
	CGPoint velocity              = [recognizer velocityInView:self];
	
	CGFloat originalCenter        = self._originalCenter;
	CGFloat currentTouchPositionX = currentTouchPoint.x;
	CGFloat panAmount             = self._initialTouchPositionX - currentTouchPositionX;
	CGFloat newCenterPosition     = self._initialHorizontalCenter - panAmount;
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		
		// Set a baseline for the panning
		self._initialTouchPositionX = currentTouchPositionX;
		self._initialHorizontalCenter = self.contentView.center.x;

		if ([self.delegate respondsToSelector:@selector(cellDidBeginPan:)])
			[self.delegate cellDidBeginPan:self];
		
		
	} else if (recognizer.state == UIGestureRecognizerStateChanged) {
		
		// If the pan amount is negative, then the last direction is left, and vice versa.
		if (newCenterPosition - self.contentView.center.x < 0)
			self._lastDirection = ZKRevealingTableViewCellDirectionLeft;
		else
			self._lastDirection = ZKRevealingTableViewCellDirectionRight;
		
		// Don't let you drag past a certain point depending on direction
		if ((newCenterPosition < originalCenter && !self._shouldDragLeft) || (newCenterPosition > originalCenter && !self._shouldDragRight))
			newCenterPosition = originalCenter;
		
		if (self.pixelsToRevealRight != 0) {
			// Let's not go waaay out of bounds
            if (newCenterPosition >= originalCenter + self.pixelsToRevealLeft) {
				newCenterPosition = originalCenter + self.pixelsToRevealLeft;
            }
            else if (newCenterPosition <= originalCenter - self.pixelsToRevealRight) {
				newCenterPosition = originalCenter - self.pixelsToRevealRight;
            }
        } else {
			// Let's not go waaay out of bounds
			if (newCenterPosition > self.bounds.size.width + originalCenter)
				newCenterPosition = self.bounds.size.width + originalCenter;
			
			else if (newCenterPosition < -originalCenter)
				newCenterPosition = -originalCenter;
		}
		
		CGPoint center = self.contentView.center;
		center.x = newCenterPosition;

		self.contentView.center = center;
        [self syncBackgroundViewWithContentView];

        if ([self.delegate respondsToSelector:@selector(cellDidPan:)]) {
            [self.delegate cellDidPan:self];
        }

	} else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
				
		// Swiping left, velocity is below 0.
		// Swiping right, it is above 0
		// If the velocity is above the width in points per second at any point in the pan, push it to the acceptable side
		// Otherwise, if we are 60 points in, push to the other side
		// If we are < 60 points in, bounce back
		
#define kMinimumVelocity self.contentView.frame.size.width
#define kMinimumPan      60.0
		
		CGFloat velocityX = velocity.x;
		
		BOOL push = (velocityX < -kMinimumVelocity);
		push |= (velocityX > kMinimumVelocity);
		push |= ((self._lastDirection == ZKRevealingTableViewCellDirectionLeft && translation.x < -kMinimumPan) || (self._lastDirection == ZKRevealingTableViewCellDirectionRight && translation.x > kMinimumPan));
		push &= self._shouldReveal;
		push &= ((self._lastDirection == ZKRevealingTableViewCellDirectionRight && self._shouldDragRight) || (self._lastDirection == ZKRevealingTableViewCellDirectionLeft && self._shouldDragLeft)); 
		
		if (velocityX > 0 && self._lastDirection == ZKRevealingTableViewCellDirectionLeft)
			push = NO;
		
		else if (velocityX < 0 && self._lastDirection == ZKRevealingTableViewCellDirectionRight)
			push = NO;
		
		if (push && !self.isRevealing) {
			
			[self _slideOutContentViewInDirection:self._lastDirection];
			[self _setRevealing:YES];
			
			self._currentDirection = self._lastDirection;
			
		} else if (self.isRevealing && translation.x != 0) {
			CGFloat multiplier = self._bounceMultiplier;
			if (!self.isRevealing)
				multiplier *= -1.0;

			[self _slideInContentViewFromDirection:self._currentDirection offsetMultiplier:multiplier emitSnapBack:YES];
			[self _setRevealing:NO];
			
		} else if (translation.x != 0) {
			// Figure out which side we've dragged on.
			ZKRevealingTableViewCellDirection finalDir = ZKRevealingTableViewCellDirectionRight;
			if (translation.x < 0)
				finalDir = ZKRevealingTableViewCellDirectionLeft;

			[self _slideInContentViewFromDirection:finalDir offsetMultiplier:-1.0 * self._bounceMultiplier emitSnapBack:YES];
			[self _setRevealing:NO];
		}
	}
}

- (BOOL)_shouldDragLeft
{
	return (self.direction & ZKRevealingTableViewCellDirectionLeft) != 0;
}

- (BOOL)_shouldDragRight
{
	return (self.direction & ZKRevealingTableViewCellDirectionRight) != 0;
}

- (CGFloat)_originalCenter
{
	return self.contentView.bounds.size.width / 2;
}

- (CGFloat)_bounceMultiplier
{
	return self.shouldBounce ? MIN(ABS(self._originalCenter - self.contentView.center.x) / kMinimumPan, 1.0) : 0.0;
}

#pragma mark - Sliding
#define kBOUNCE_DISTANCE 7.0

- (void) snapBack {
	//should probably calculate the direction
	[self _slideInContentViewFromDirection:ZKRevealingTableViewCellDirectionLeft offsetMultiplier:1 emitSnapBack:YES];
}

- (void)_slideInContentViewFromDirection:(ZKRevealingTableViewCellDirection)direction offsetMultiplier:(CGFloat)multiplier emitSnapBack:(BOOL)emitSnapBack
{
	CGFloat bounceDistance;

	if (self.contentView.center.x == self._originalCenter || self.isSliding)
		return;

	self.isSliding = YES;
	
    if (emitSnapBack) {
        if ([self.delegate respondsToSelector:@selector(cellWillSnapBack:)]) {
            [self.delegate cellWillSnapBack:self];
        }
    }

	switch (direction) {
		case ZKRevealingTableViewCellDirectionRight:
			bounceDistance = kBOUNCE_DISTANCE * multiplier;
			break;
		case ZKRevealingTableViewCellDirectionLeft:
			bounceDistance = -kBOUNCE_DISTANCE * multiplier;
			break;
		default:
			self.isSliding = NO;
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unhandled gesture direction" userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:direction] forKey:@"direction"]];
			break;
	}

	
	
	[UIView animateWithDuration:0.1
						  delay:0 
						options:UIViewAnimationOptionCurveEaseOut 
					 animations:^{
                         self.contentView.center = CGPointMake(self._originalCenter, self.contentView.center.y);
                         [self syncBackgroundViewWithContentView];
                     }
					 completion:^(BOOL f) {
						 self.isSliding = NO;
						 if ([self.delegate respondsToSelector:@selector(cellDidSnapBack:)]) {
							 [self.delegate cellDidSnapBack:self];
						 }
						 
						 
						  
					 }];
}

- (void)_slideOutContentViewInDirection:(ZKRevealingTableViewCellDirection)direction;
{
	CGFloat x;
	if (self.pixelsToRevealRight != 0) {
		switch (direction) {
			case ZKRevealingTableViewCellDirectionLeft:
				x = self._originalCenter - self.pixelsToRevealRight;
				break;
			case ZKRevealingTableViewCellDirectionRight:
				x = self._originalCenter + self.pixelsToRevealLeft;
				break;
			default:
				@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unhandled gesture direction" userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:direction] forKey:@"direction"]];
				break;
		}
	} else {
		switch (direction) {
			case ZKRevealingTableViewCellDirectionLeft:
				x = - self._originalCenter;
				break;
			case ZKRevealingTableViewCellDirectionRight:
				x = self.contentView.frame.size.width + self._originalCenter;
				break;
			default:
				@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unhandled gesture direction" userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:direction] forKey:@"direction"]];
				break;
		}
	}
	
	[UIView animateWithDuration:0.2 
						  delay:0 
						options:UIViewAnimationOptionCurveEaseOut 
					 animations:^{
                         self.contentView.center = CGPointMake(x, self.contentView.center.y);
                         [self syncBackgroundViewWithContentView];
                     }
					 completion:^(BOOL finished) {
                         if (self.shouldAutoSnapBack) {
                             if ([self.delegate respondsToSelector:@selector(cellWillSnapBack:)]) {
                                 [self.delegate cellWillSnapBack:self];
                             }
                             self.revealing = NO;
                         }
                     }
     ];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer == self._panGesture) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.superview];

        ZKRevealingTableViewCellDirection panDirection = ZKRevealingTableViewCellDirectionNone;
        if (translation.x < 0) {
            panDirection = ZKRevealingTableViewCellDirectionLeft;
        }
        else if (translation.x > 0) {
            panDirection = ZKRevealingTableViewCellDirectionRight;
        }

        if (self.isRevealing) {
            // If currently revealed, only allow a pan in the opposite direction.
            if (self._lastDirection == panDirection) {
                return NO;
            }
        } else {
            // Otherwise only allow a pan in one of the designated directions.
            if (!(self.direction & panDirection)) {
                return NO;
            }
        }

		// Make sure it is scrolling horizontally
		return ((fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO);
	}
	return NO;
}

@end
