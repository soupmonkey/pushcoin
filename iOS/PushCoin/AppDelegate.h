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
#import "PushCoinPayment.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) KeychainItemWrapper * keychain;
@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) NSArray * images;

@property (nonatomic, readonly) BOOL registered;
@property (nonatomic, getter = authToken, setter = setAuthToken:) NSString * authToken;
@property (nonatomic, getter = dsaPrivateKey, setter = setDsaPrivateKey:) NSString * dsaPrivateKey;
@property (nonatomic, readonly, getter = pemDsaPublicKey) NSString * pemDsaPublicKey;
@property (nonatomic, readonly, getter = keyFilePath) NSString * keyFilePath;

-(void)registerFromController:(UIViewController<RegistrationControllerDelegate> *)viewController;
-(id)viewControllerWithIdentifier:(NSString *) identifier;
- (void) showAlert:(NSString *)message withTitle:(NSString *)title;
-(UIImage *) imageForAmountType:(PushCoinPaymentAmountType) type;
@end
