//
//  RegistrationController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/8/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushCoinWebService.h"
#import "PushCoinMessages.h"
#import "KeychainItemWrapper.h"
#import "OpenSSLWrapper.h"

@class RegistrationController;

@protocol RegistrationControllerDelegate <NSObject>


- (void)registrationControllerDidClose:
(RegistrationController *)controller;

@end

@interface RegistrationController : UIViewController<UITextFieldDelegate, PushCoinMessageReceiver, PushCoinWebServiceDelegate>
{
    PushCoinMessageParser * parser;
    PushCoinWebService * webService;
    NSMutableData * buffer;
}

@property (nonatomic, weak) id <RegistrationControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *registrationIDTextBox;
@end
