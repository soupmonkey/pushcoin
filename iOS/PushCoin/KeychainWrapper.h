//
//  KeychainWrapper.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>


//Define an Objective-C wrapper class to hold Keychain Services code.
@interface KeychainWrapper : NSObject
{
    NSMutableDictionary        *keychainData;
    NSMutableDictionary        *genericPasswordQuery;
}

@property (nonatomic, retain) NSMutableDictionary *keychainData;
@property (nonatomic, retain) NSMutableDictionary *genericPasswordQuery;

- (void)setMyObject:(id)inObject forKey:(id)key;
- (id)myObjectForKey:(id)key;
- (void)resetMyObject;

@end

/* ********************************************************************** */
//Unique string used to identify the keychain item:
static const UInt8 kKeychainItemIdentifier[]    = "com.pushcoin\0";

@interface KeychainWrapper (PrivateMethods)


//The following two methods translate dictionaries between the format used by
// the view controller (NSString *) and the Keychain Services API:
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;
// Method used to write data to the keychain:
- (void)writeToKeychain;

@end