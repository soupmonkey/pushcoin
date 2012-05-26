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
@property (nonatomic, readonly) NSString * documentPath;

@property (nonatomic) NSString * authToken;
@property (nonatomic) NSString * dsaPrivateKey;

-(void)setPasscode:(NSString *)passcode;
-(BOOL) validatePasscode:(NSString *)passcode;

-(void)requestPasscodeWithDelegate:(NSObject<KKPasscodeViewControllerDelegate> *)delegate;
-(void)requestRegistrationWithDelegate:(NSObject<RegistrationControllerDelegate> *)delegate;
- (void) showAlert:(NSString *)message withTitle:(NSString *)title;

-(id)viewControllerWithIdentifier:(NSString *) identifier;
-(UIImage *) imageForAmountType:(PushCoinPaymentAmountType) type;
@end
