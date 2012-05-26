//
//  AppDelegate.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenSSLWrapper.h"
#import "NSString+HexStringToBytes.h"
#import "NSData+BytesToHexString.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize keychain = _keychain;
@synthesize images = _images;
@synthesize pemDsaPublicKey = _pemDsaPublicKey;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self prepareKeyFiles];
    [self prepareKeyChain];
    [self prepareDSA];
    [self prepareRSA];
    [self prepareImageCache];
    return YES;
}

-(BOOL) prepareKeyFiles
{
    NSError * error;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * files = [NSArray arrayWithObjects:PushCoinRSAPublicKeyFile, nil];
    NSString * fromPath = [[NSBundle mainBundle] bundlePath];
    NSString * toPath = [self documentPath];
    BOOL ret = YES;
    for (id file in files)
    {
        ret &= [fileManager copyItemAtPath:[fromPath stringByAppendingPathComponent:file]
                                    toPath:[toPath stringByAppendingPathComponent:file]
                                     error:&error];
    }
    return ret;
}

-(BOOL) prepareImageCache
{
    self.images = [NSArray arrayWithObjects:
                   [UIImage imageNamed:@"1.00.png"],
                   [UIImage imageNamed:@"5.00.png"],
                   [UIImage imageNamed:@"10.00.png"],
                   [UIImage imageNamed:@"50.00.png"],
                   [UIImage imageNamed:@"100.00.png"],
                   [UIImage imageNamed:@"500.00.png"], 
                   nil];
    return YES;

}
             
-(UIImage *) imageForAmountType:(PushCoinPaymentAmountType) type
{
    switch(type)
    {
        case PushCoinPaymentAmountTypeGreen:    return [self.images objectAtIndex:0];
        case PushCoinPaymentAmountTypePurple:   return [self.images objectAtIndex:1];
        case PushCoinPaymentAmountTypeRed:      return [self.images objectAtIndex:2];
        case PushCoinPaymentAmountTypeBrown:    return [self.images objectAtIndex:3];
        case PushCoinPaymentAmountTypeYellow:   return [self.images objectAtIndex:4];
        case PushCoinPaymentAmountTypeClear:    return [self.images objectAtIndex:5];
        default:                                return [self.images objectAtIndex:5];
    }
}

-(BOOL) prepareKeyChain
{
    self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:PushCoinKeychainId accessGroup:nil];
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
    [ssl prepareRsaWithKeyFile:[NSString stringWithFormat:@"%@/%@", self.documentPath, PushCoinRSAPublicKeyFile]];
    return YES;
}

- (BOOL) registered
{
    return self.authToken.length != 0;
}

- (void) setPasscode:(NSString *)hash
{
    if (hash && hash.length != 0)
    {
        OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
        NSData * data = [ssl sha1_hashData:[hash dataUsingEncoding:NSASCIIStringEncoding]];
        [self.keychain setObject:data.bytesToHexString forKey:(__bridge id)kSecAttrDescription];
    }
    else
    {
        [self.keychain setObject:@"" forKey:(__bridge id)kSecAttrDescription];            
    }
}

- (BOOL) hasPasscode
{
    NSString * hash = [self.keychain objectForKey:(__bridge id)kSecAttrDescription];            
    return (hash && hash.length != 0);
}

-(BOOL) validatePasscode:(NSString *)passcode
{
    NSString * hash = [self.keychain objectForKey:(__bridge id)kSecAttrDescription];            
    if (!hash || hash.length == 0) return YES;
    
    OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
    NSData * data = [ssl sha1_hashData:[passcode dataUsingEncoding:NSASCIIStringEncoding]];
    
    return [data isEqualToData:hash.hexStringToBytes];
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

-(NSString *) pemDsaPublicKey
{
    NSString * pemPublicKey = [NSString stringWithContentsOfFile:[self.documentPath stringByAppendingPathComponent: PushCoinDSAPublicKeyFile] encoding:NSASCIIStringEncoding error:nil];
    
    NSRange headerRange = [pemPublicKey rangeOfString:@"---\n"];
    pemPublicKey = [pemPublicKey substringFromIndex:headerRange.location + headerRange.length];
    
    NSRange footerRange = [pemPublicKey rangeOfString:@"\n---"];
    pemPublicKey = [pemPublicKey substringToIndex:footerRange.location];
    
    return pemPublicKey;
}

- (void) setDsaPrivateKey:(NSString *)dsaPrivateKey
{
    [self.keychain setObject:dsaPrivateKey forKey:(__bridge id)kSecValueData];
}

- (NSString *)documentPath
{
	NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return dir;
}

-(void)requestRegistrationWithDelegate:(NSObject<RegistrationControllerDelegate> *)delegate
{
    if (!self.registered)
    {
        RegistrationController * controller = [self viewControllerWithIdentifier:@"RegistrationController"];
        controller.delegate = delegate;
        controller.modalTransitionStyle =  UIModalTransitionStyleCoverVertical;
        
        [self.window.rootViewController presentModalViewController:controller animated:NO];
    }
}

-(void)requestPasscodeWithDelegate:(NSObject<KKPasscodeViewControllerDelegate> *)delegate
{
    KKPasscodeViewController * controller = [[KKPasscodeViewController alloc] init];
    controller.delegate = delegate;
    controller.mode = KKPasscodeModeEnter;
    controller.passcodeLockOn = YES;
    controller.eraseData = NO;
    controller.passcode = @"";
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self.window.rootViewController presentModalViewController:controller animated:YES];
}

-(id)viewControllerWithIdentifier:(NSString *) identifier
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    id controller = [storyboard instantiateViewControllerWithIdentifier:identifier];
    return controller;
}


- (void) showAlert:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Close" 
                                          otherButtonTitles:nil];
    [alert show];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"handleCleanup" 
                                                        object: nil 
                                                      userInfo: nil];
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
