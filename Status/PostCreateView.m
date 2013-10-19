//
//  PostCreateView.m
//  Status
//
//  Created by Paul Denya on 2/14/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "PostCreateView.h"
#import "ViewController.h"
#import "OHActionSheet.h"
#import "UIImagePickerController+DelegateBlocks.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation PostCreateView
@synthesize messageTextField, postClicked, focused, post;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
		
		int padding = 4;
		self.messageTextField = [[[UITextView alloc] init] autorelease];
		[self addSubview:self.messageTextField];
		NSLog(@"self h %f", [self h]);
		
		[self.messageTextField seth:[self h] - (216 + 65)];
		
		if (!SYSTEM_VERSION_LESS_THAN(@"7.0")) {
			[self.messageTextField seth:[self.messageTextField h] - 8];
		}
		
		[self.messageTextField setw:[self w] - (padding * 2)];
		[self.messageTextField sety:SYSTEM_VERSION_LESS_THAN(@"7.0") ? padding : 20];
		[self.messageTextField setx:padding];
		self.messageTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
		self.messageTextField.textColor = [UIColor brandDarkGrey];
    }
    return self;
}

- (void)addedAsSubview:(NSDictionary *)options {
	[self performSelector:@selector(focus) withObject:nil afterDelay:0.0f];
	[self performSelector:@selector(addControls) withObject:nil afterDelay:0.3f];
}


- (void)addControls {
	int padding = 4;
	
	UIButton *postButton = (UIButton *)[self viewWithTag:60];
	if (postButton) {
		//already initialized
		return;
	}
	
	postButton = [UIButton flatBlueButton:@"Post to Facebook" modifier:1.2];
	postButton.hidden = YES;
	postButton.alpha = 0;
	[self addSubview:postButton];
	[postButton sety:[self.messageTextField bottomEdge] + padding];
	[postButton setx:[self.messageTextField rightEdge] - [postButton w] - padding];
	[postButton addTarget:self action:@selector(postToFacebookClicked:) forControlEvents:UIControlEventTouchUpInside];
	postButton.tag = 60;
	
	UILabel *close_btn = [[UILabel alloc] init];
	close_btn.hidden = YES;
	close_btn.alpha = 0;
	close_btn.backgroundColor = [UIColor clearColor];
	close_btn.text = @"×";
	close_btn.textColor = [UIColor colorWithHex:0x444444];
	close_btn.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40.0f];
	close_btn.userInteractionEnabled = YES;
	close_btn.textAlignment = NSTextAlignmentCenter;
	
	UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelClicked:)];
	gr.numberOfTapsRequired = 1;
	gr.numberOfTouchesRequired = 1;
	[close_btn addGestureRecognizer:gr];
	
	[self addSubview:close_btn];
	[close_btn sizeToFit];
	[close_btn setx:padding];
	[close_btn setw:[close_btn w] + 10];
	[close_btn sety:[postButton y] - (SYSTEM_VERSION_LESS_THAN(@"7.0") ? 14 : 7)];
	
	UIImageView *add_image_btn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_add_image.png"]];
	add_image_btn.contentMode = UIViewContentModeCenter;
	add_image_btn.frame = close_btn.frame;
	[add_image_btn setx:[close_btn rightEdge] + 10.0f];
	[add_image_btn sety:[add_image_btn y] + 8.0f];
	[add_image_btn seth:[add_image_btn h] - 8.0f];
	add_image_btn.userInteractionEnabled = YES;
	add_image_btn.tag = 61;
	[self addSubview:add_image_btn];
	
	UITapGestureRecognizer *imggr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageOptions:)];
	[add_image_btn addGestureRecognizer:imggr];
	[imggr release];
	
	[add_image_btn release];
	
	if (self.post) {
		[self switchToComment:self.post];
	}
	
	UIView *keyboardbg = [UIView new];
	keyboardbg.backgroundColor = [UIColor brandGreyColor];
	keyboardbg.frame = CGRectMake(0, [self h] - 216, [self w], 216);
	[self addSubview:keyboardbg];
	[keyboardbg release];
	
	[UIView animateWithDuration:0.2f animations:^{
		postButton.alpha = 1;
		postButton.hidden = NO;
		close_btn.alpha = 1;
		close_btn.hidden = NO;
	} completion:^(BOOL finished) {
		[close_btn release];
	}];
}


- (void)focus {
	[self.messageTextField becomeFirstResponder];
}

- (void) switchToComment:(Post *)p {
	self.post = p;
	UIButton *postbtn = (UIButton *)[self viewWithTag:60];
	[postbtn setTitle:@"Post comment" forState:UIControlStateNormal];
	[postbtn removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
	[postbtn addTarget:self action:@selector(postCommentClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	//todo: build post display view and add to the top
	
	UIView *responding_to = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self w], SYSTEM_VERSION_LESS_THAN(@"7.0") ? 50 : 60)];
	responding_to.backgroundColor = [UIColor brandGreyColor];
	[responding_to addFlexibleBottomBorder:[UIColor brandMediumGrey]];
	[self addSubview:responding_to];
	
	UILabel *r_message = [UILabel label:self.post.message];
	[r_message setw:[self w] - 20];
	[r_message seth:[responding_to h] - (SYSTEM_VERSION_LESS_THAN(@"7.0") ? 10 : 20)];
	[r_message setx:10];
	[r_message sety:SYSTEM_VERSION_LESS_THAN(@"7.0") ? 5 : 15];
	r_message.backgroundColor = responding_to.backgroundColor;
	[responding_to addSubview:r_message];
	
	[self.messageTextField sety:[responding_to bottomEdge]];

	[responding_to release];
	
	UIImageView *imgview = (UIImageView *)[self viewWithTag:61];
	[imgview removeFromSuperview];
}

- (void)showLoader {
	UIView *overlay = [UIView new];
	overlay.backgroundColor = [UIColor blackColor];
	overlay.frame = [self frame];
	overlay.alpha = 0.6;
	overlay.tag = 62;
	[self addSubview:overlay];
	[overlay release];
	
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
	[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityIndicator startAnimating];
	
	[self addSubview:activityIndicator];
	[activityIndicator centerx];
	[activityIndicator centery];
	activityIndicator.tag = 63;
	[activityIndicator release];
}

- (void)removeLoader {
	UIView *overlay = [self viewWithTag:62];
	if (overlay) {
		[overlay removeFromSuperview];
	}
	
	UIActivityIndicatorView *activity_indicator = (UIActivityIndicatorView *)[self viewWithTag:63];
	if (activity_indicator) {
		[activity_indicator removeFromSuperview];
	}
}

- (void) alert:(NSString *)title message:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];

}

- (void)postCommentClicked:(id)sender {
	FBHelper *fb = [FBHelper instance];
	
	[self.messageTextField resignFirstResponder];
	[self showLoader];
	
	[fb postComment:self.messageTextField.text onStatus:[self.post combined_id] completed:
	 ^(BOOL response) {
		 [self removeLoader];
		 if (response) {
			 if ([self postClicked]) {
				 [self postClicked]();
			 }
			 
			 //todo: make this happen immediately rather than waiting for this response
			 [self clear];
			 [[ViewController instance] closeModal:self];
		 }
		 else {
			 [self alert:@"Comment Error" message:@"Couldn't connect to Facebook."];
		 }
	 }];
}

- (void)postToFacebookClicked:(id)sender {
	NSLog(@"post to facebook clicked");
	
	if ([PDUtils processCommand:self.messageTextField]) {
		return;
	}

	[self.messageTextField resignFirstResponder];
	[self showLoader];
	
	
	
	FBHelper *fb = [FBHelper instance];
	
	void (^completed)(BOOL response) = ^(BOOL response) {
		[self removeLoader];
		
		if (response) {
			// call the result handler block on the main queue (i.e. main thread)
			dispatch_async( dispatch_get_main_queue(), ^{
				//todo: make this happen immediately rather than waiting for this response
				if ([self postClicked]) {
					[self postClicked]();
				}
				
				// running synchronously on the main thread now -- call the handler
				[self clear];
				[[ViewController instance] closeModal:self];
			});
			
		}
		else {
			[self alert:@"Post Error" message:@"Couldn't connect to Facebook."];
		}
	};
	
	if (self.img != nil) {
		UIImage *img = self.img;
		
		//resize the image a little bit to make it smaller/easier to send
		//img = [img rotateAndScaleFromCameraWithMaxSize:1500];
		img = scaleAndRotateImage(img);
		
		[fb postStatus:self.messageTextField.text withImage:img completed:completed];
	}
	else {
		[fb postStatus:self.messageTextField.text completed:completed];
	}
	
}

- (void) clear {
	self.messageTextField.text = @"";
	[self setAttachedImage:nil];
}

UIImage *scaleAndRotateImage(UIImage *image)
{
	int kMaxResolution = 1280; // Or whatever
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}


- (void)cancelClicked:(id)sender {
	[[ViewController instance] closeModal:self];
}

- (void) showImageOptions:(id)sender {
	
	NSMutableArray *options = [NSMutableArray arrayWithArray:@[ @"Use last photo taken", @"Choose photo from library"]];
	
	if (self.img != nil) {
		[options removeAllObjects];
		[options addObject:@"Remove photo"];
		
		//TODO: add view photo option
		//[options addObject:@"View photo"];
	} else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[options addObject:@"Take photo"];
	}
	
	
	[OHActionSheet showSheetInView:self.window
							 title:@"Attach Image"
				 cancelButtonTitle:@"Cancel"
			destructiveButtonTitle:nil
				 otherButtonTitles:options
						completion:^(OHActionSheet *sheet, NSInteger buttonIndex) {
		 NSLog(@"button tapped: %d",buttonIndex);
		 if (buttonIndex == sheet.cancelButtonIndex) {
			 
		 }
		 else {
			 NSString *option = [options objectAtIndex:(buttonIndex - sheet.firstOtherButtonIndex)];
			 
			 if ([option isEqualToString:@"Use last photo taken"]) {
				 
				 //get last photo taken
				 ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
				 [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
					  if (nil != group) {
						  // be sure to filter the group so you only get photos
						  [group setAssetsFilter:[ALAssetsFilter allPhotos]];
						  
						  
						  if (group.numberOfAssets > 0) {
							  [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
								  if (nil != result) {
									  ALAssetRepresentation *repr = [result defaultRepresentation];
									  // this is the most recent saved photo
									  [self setAttachedImage:[UIImage imageWithCGImage:[repr fullResolutionImage]]];
									  // we only need the first (most recent) photo -- stop the enumeration
									  *stop = YES;
								  }
							  }];
						  }
						  else {
							  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error fetching image!"
																			message:@"Looks like you don't have any images in your photo stream. Add some and try again."
																		   delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
							  [alert show];
							  [alert release];
						  }
					  }
					  
					  *stop = NO;
				  } failureBlock:^(NSError *error) {
					  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error fetching image!"
																	  message:@"Please try again."
																	 delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
					  [alert show];
					  [alert release];
				  }];
				 
			 }
			 else if ([option isEqualToString:@"Choose photo from library"]) {
				 UIImagePickerController *picker = [[UIImagePickerController alloc] init];
				 picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				 
				 [picker useBlocksForDelegate];
				 
				 [picker onDidFinishPickingMediaWithInfo:^(UIImagePickerController *picker, NSDictionary *info) {
					 UIImage *image= [info objectForKey:UIImagePickerControllerEditedImage];
					 image = image ? image : [info objectForKey:UIImagePickerControllerOriginalImage];
					 
					 [self setAttachedImage:image];
					 [[ViewController instance] dismissModalViewControllerAnimated:YES];
				 }];
				 
				 [picker onDidCancel:^(UIImagePickerController *picker) {
					 [[ViewController instance] dismissModalViewControllerAnimated:YES];
				 }];
				 
				 [[ViewController instance] presentModalViewController:picker animated:YES];
				 
				 [picker release];
			 }
			 else if ([option isEqualToString:@"Take photo"]) {
				 UIImagePickerController *picker = [[UIImagePickerController alloc] init];
				 picker.sourceType = UIImagePickerControllerSourceTypeCamera;
				 
				 [picker useBlocksForDelegate];
				 
				 [picker onDidFinishPickingMediaWithInfo:^(UIImagePickerController *picker, NSDictionary *info) {
					 UIImage *image= [info objectForKey:UIImagePickerControllerEditedImage];
					 image = image ? image : [info objectForKey:UIImagePickerControllerOriginalImage];
					 
					 [self setAttachedImage:image];
					 [[ViewController instance] dismissModalViewControllerAnimated:YES];
				 }];
				 
				 [picker onDidCancel:^(UIImagePickerController *picker) {
					 [[ViewController instance] dismissModalViewControllerAnimated:YES];
				 }];
				 
				 [[ViewController instance] presentModalViewController:picker animated:YES];
				 [picker release];
			 }
			 else if ([option isEqualToString:@"Remove photo"]) {
				 [self setAttachedImage:nil];
			 }
		 }
	 }];
}

- (void) setAttachedImage:(UIImage *)img {
	UIImageView *imgview = (UIImageView *)[self viewWithTag:61];
	
	if (img == nil) {
		self.img = nil;
		imgview.contentMode = UIViewContentModeCenter;
		imgview.image = [UIImage imageNamed:@"icon_add_image.png"];
	}
	else {
		self.img = img;
		
		imgview.contentMode = UIViewContentModeScaleAspectFit;
		imgview.image = img;
	}
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
