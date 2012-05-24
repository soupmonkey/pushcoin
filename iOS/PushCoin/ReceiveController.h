//
//  SecondViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ZXingWidgetController.h>
#import <QRCodeReader.h>

#import "PushCoinWebService.h"
#import "PushCoinMessages.h"
#import "KeychainItemWrapper.h"

@interface ReceiveController : UIViewController<PushCoinWebServiceDelegate, PushCoinMessageReceiver, ZXingDelegate, UITextFieldDelegate>
{
    PushCoinMessageParser * parser;
    PushCoinWebService * webService;
    NSMutableData * buffer;
    NSMutableString * storedValue;
}
@property (weak, nonatomic) IBOutlet UITextField *paymentTextField;
- (IBAction)scan:(id)sender;
@end
