//
//  HistoryController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsController.h"

#import "PushCoinWebService.h"
#import "PushCoinMessages.h"

@interface HistoryController : UIViewController<PushCoinWebServiceDelegate, PushCoinMessageReceiver, SettingsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    PushCoinMessageParser * parser;
    PushCoinWebService * webService;
    NSMutableData * buffer;
    NSMutableArray * transactions;
    NSNumberFormatter * numberFormatter;
    Float32 balance;
    NSInteger timestamp;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)settingsButtonTapped:(id)sender;

@end
