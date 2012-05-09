//
//  SecondViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushCoinWebService.h"
#import "PCOSParser.h"
#import "PushCoinMessages.h"

@interface ReceiveController : UIViewController <PushCoinWebServiceDelegate, PushCoinMessageReceiver>
{
    PushCoinMessageParser * parser;
    PushCoinWebService * webService;
    NSMutableData * buffer;
}

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
- (IBAction)ping:(id)sender;
- (IBAction)register:(id)sender;

@end
