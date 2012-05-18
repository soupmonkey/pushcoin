//
//  ThirdViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushCoinWebService.h"
#import "PushCoinMessages.h"
#import "KeychainItemWrapper.h"
#import "OpenSSLWrapper.h"
#import "RegistrationController.h"

@interface SettingsController : UIViewController< PushCoinWebServiceDelegate, PushCoinMessageReceiver,
    UIAlertViewDelegate, RegistrationControllerDelegate>
{
    PushCoinMessageParser * parser;
    PushCoinWebService * webService;
    NSMutableData * buffer;
}
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
- (IBAction)unregister:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *unregisterButton;
@property (weak, nonatomic) IBOutlet UIButton *preAuthorizationTestButton;
- (IBAction)preAuthorizationTest:(id)sender;

@end
