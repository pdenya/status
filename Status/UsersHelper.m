//
//  UsersHelper.m
//  Status
//
//  Created by Paul on 3/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "UsersHelper.h"

@implementation UsersHelper


+ (UsersHelper *)instance {
	static UsersHelper *usershelper;
	
	if (!usershelper) {
		usershelper = [[UsersHelper alloc] init];
	}
	
	return usershelper;
}

- (UsersHelper *)init {
    
    if (self = [super init]) {
        self.users = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void) load {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSData *userData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/userdata",docDir]];
	NSDictionary *tmp = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
	self.users = [NSMutableDictionary dictionaryWithDictionary:tmp];
	NSLog(@"Loaded User Data %@", [self.users description]);
}

- (void) save {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:self.users];
	[userData writeToFile:[NSString stringWithFormat:@"%@/userdata",docDir] atomically:YES];
}


@end
