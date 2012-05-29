//
//  AppDelegate.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"
#import "RegistrationController.h"
#import "PasscodeViewController.h"
#import "PushCoinPayment.h"
#import "OpenSSLWrapper.h"


@interface SingleUseData : NSObject
{
    NSData * data_;
}
@property (nonatomic, strong) NSData * data;

+(id) dataWithData:(NSData *)d;
-(id) initWithData:(NSData *)d;
@end


@interface AppDelegate : UIResponder <UIApplicationDelegate, OpenSSLWrapperDSAPrivateKeyDelegate>
@property (strong, nonatomic) KeychainItemWrapper * keychain;
@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) NSArray * images;

@property (nonatomic, readonly) BOOL registered;
@property (nonatomic, readonly) BOOL hasPasscode;

@property (nonatomic, readonly) NSString * pemDsaPublicKey;
@property (nonatomic, readonly) NSString * documentPath;

@property (nonatomic) NSString * authToken;
@property (nonatomic, readonly) NSData * dsaPrivateKey;

@property (nonatomic, strong) SingleUseData * dsaDecryptedKey;

-(void) setPasscode:(NSString *)passcode oldPasscode:(NSString *)oldPasscode;
-(BOOL) validatePasscode:(NSString *)passcode;

-(void) setDsaPrivateKey:(NSData *)dsaPrivateKey withPasscode:(NSString *)passcode;
-(BOOL) unlockDsaPrivateKeyWithPasscode:(NSString *)passcode;

-(KKPasscodeViewController *) requestPasscodeWithDelegate:(NSObject<KKPasscodeViewControllerDelegate> *)delegate;
-(KKPasscodeViewController *) requestPasscodeWithDelegate:(NSObject<KKPasscodeViewControllerDelegate> *)delegate
                                           viewController:(UIViewController *)controller;

-(RegistrationController *) requestRegistrationWithDelegate:(NSObject<RegistrationControllerDelegate> *)delegate;
-(RegistrationController *) requestRegistrationWithDelegate:(NSObject<RegistrationControllerDelegate> *)delegate
                                             viewController:(UIViewController *)controller;

-(UIAlertView *) showAlert:(NSString *)message withTitle:(NSString *)title;

-(id)viewControllerWithIdentifier:(NSString *) identifier;
-(UIImage *) imageForAmountType:(PushCoinPaymentAmountType) type;
@end
