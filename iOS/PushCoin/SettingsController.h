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

#import "RegistrationController.h"

@interface SettingsController : UIViewController<RegistrationControllerDelegate, PushCoinWebServiceDelegate, PushCoinMessageReceiver>
{
    PushCoinMessageParser * parser;
    PushCoinWebService * webService;
    NSMutableData * buffer;

}
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
- (IBAction)register:(id)sender;

@end
