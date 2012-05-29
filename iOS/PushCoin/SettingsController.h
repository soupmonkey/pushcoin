//
//  ThirdViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushCoinWebService.h"
#import "PushCoinMessages.h"
#import "KeychainItemWrapper.h"
#import "OpenSSLWrapper.h"
#import "RegistrationController.h"
#import "PasscodeViewController.h"

@interface SettingsController : UIViewController< PushCoinWebServiceDelegate, PushCoinMessageReceiver,
    UIAlertViewDelegate, RegistrationControllerDelegate, KKPasscodeViewControllerDelegate>
{
    PushCoinMessageParser * parser;
    PushCoinWebService * webService;
    NSMutableData * buffer;
    KKPasscodeViewController * setPasscodeController;
    KKPasscodeViewController * preAuthTestPasscodeController;
    
}

@property (weak, nonatomic) IBOutlet UIButton *unregisterButton;
@property (weak, nonatomic) IBOutlet UIButton *preAuthorizationTestButton;
@property (weak, nonatomic) IBOutlet UIButton *passcodeButton;

- (IBAction)unregister:(id)sender;
- (IBAction)preAuthorizationTest:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)enablePasscode:(id)sender;

@end
