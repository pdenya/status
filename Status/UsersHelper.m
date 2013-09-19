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


//TODO: remove this method after sending to beta testers
- (void) loadOld {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSData *userData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/userdata",docDir]];
	NSDictionary *tmp = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
	NSMutableDictionary *loaded_users = [NSMutableDictionary dictionaryWithDictionary:tmp];
	[tmp enumerateKeysAndObjectsUsingBlock:^(id key, User *user, BOOL *stop) {
		if (![user.uid isKindOfClass:[NSString class]]) {
			//update uid to string
			user.uid = [(NSDecimalNumber *)user.uid stringValue];
			
			//update key to string
			[loaded_users setObject:user forKey:user.uid];
		}
	}];
	
	self.users = loaded_users;
	NSLog(@"Loaded User Data %@", [self.users description]);
}

- (void) load {
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSData *userdata = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/users.plist",docDir]];
	if(userdata == nil) {
		//TODO: remove this backwards compatability which won't be necessary in production
		[self loadOld];
		//TODO: uncomment these before sending to joel
		//[self save];
		//[self load];
		return;
	}
	
	NSString *error = nil;
	NSDictionary *userdicts= [NSPropertyListSerialization propertyListFromData:userdata mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&error];
	NSLog(@"userdicts %@", [userdicts description]);
	if(error != nil) return;

	NSMutableDictionary *loaded_users = self.users;
	
	[userdicts enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *userdict, BOOL *stop) {
		User *user = [User userFromDictionary:userdict];
		[loaded_users setObject:user forKey:user.uid];
	}];
}

- (void) save {
	NSMutableDictionary *userdicts = [[NSMutableDictionary alloc] initWithCapacity:[self.users count]];
	[self.users enumerateKeysAndObjectsUsingBlock:^(id key, User *user, BOOL *stop) {
		NSString *k = [key isKindOfClass:[NSDecimalNumber class]] ? [(NSDecimalNumber *)key stringValue] : (NSString *)key;
		[userdicts setObject:[user toDict] forKey:k];
	}];
	
	NSError *err = nil;
	NSData *data = [NSPropertyListSerialization dataWithPropertyList:userdicts format:NSPropertyListBinaryFormat_v1_0 options:0 error:&err];
	
	if (err != nil) {
		return;
	}
	
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	[data writeToFile:[NSString stringWithFormat:@"%@/users.plist",docDir] atomically:YES];
	
	NSLog(@"break");
}


@end
