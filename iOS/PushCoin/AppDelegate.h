//
//  AppDelegate.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) KeychainItemWrapper * keychain;
@property (strong, nonatomic) UIWindow *window;
@property (readonly) BOOL registered;
@property (getter = authToken, setter = setAuthToken:) NSString * authToken;
@property (getter = dsaPrivateKey, setter = setDsaPrivateKey:) NSString * dsaPrivateKey;
@end
