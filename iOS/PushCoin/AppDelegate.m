//
//  AppDelegate.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenSSLWrapper.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize keychain = _keychain;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:PushCoinKeychainId accessGroup:nil];
    
    [self prepareDSA];
    [self prepareRSA];
    
    return YES;
}

- (BOOL) prepareDSA
{
    NSString * dsaPrivateKey = self.dsaPrivateKey;
    if (dsaPrivateKey.length == 0)
    {
        return NO;
    }
    else 
    {
        OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
        [ssl prepareDsaWithPrivateKey:dsaPrivateKey];
        return YES;
    }
}

- (BOOL) prepareRSA
{
    OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
    [ssl prepareRsaWithKeyFile:PushCoinRSAPublicKeyFile];
    return YES;
}

- (BOOL) registered
{
    OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
    return ssl.dsa && ssl.rsa && self.authToken.length;
}

- (NSString *) authToken
{
    return [self.keychain objectForKey:(__bridge id)kSecAttrAccount];
}

- (void) setAuthToken:(NSString *)authToken
{
    [self.keychain setObject:authToken forKey:(__bridge id)kSecAttrAccount];
}

- (NSString *) dsaPrivateKey
{
    return [self.keychain objectForKey:(__bridge id)kSecValueData];
}

- (void) setDsaPrivateKey:(NSString *)dsaPrivateKey
{
    [self.keychain setObject:dsaPrivateKey forKey:(__bridge id)kSecValueData];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
