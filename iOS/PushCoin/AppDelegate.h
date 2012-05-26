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

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) KeychainItemWrapper * keychain;
@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) NSArray * images;

@property (nonatomic, readonly) BOOL registered;
@property (nonatomic, readonly) BOOL hasPasscode;

@property (nonatomic, readonly) NSString * pemDsaPublicKey;
@property (nonatomic, readonly) NSString * keyFilePath;

@property (nonatomic) NSString * authToken;
@property (nonatomic) NSString * dsaPrivateKey;

-(BOOL) validatePasscode:(NSString *)passcode;

-(void)setPasscode:(NSString *)passcode;
-(void)registerFromController:(UIViewController<RegistrationControllerDelegate> *)viewController;
-(void)passcodeFromController:(UIViewController<KKPasscodeViewControllerDelegate> *)viewController;

-(id)viewControllerWithIdentifier:(NSString *) identifier;
- (void) showAlert:(NSString *)message withTitle:(NSString *)title;
-(UIImage *) imageForAmountType:(PushCoinPaymentAmountType) type;
@end
