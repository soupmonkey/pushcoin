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

@interface HistoryController : UIViewController<PushCoinWebServiceDelegate, PushCoinMessageReceiver, UITableViewDataSource, UITableViewDelegate>
{
    PushCoinMessageParser * parser;
    PushCoinWebService * webService;
    NSMutableData * buffer;
    NSMutableArray * transactions;
    NSNumberFormatter * numberFormatter;
    NSDateFormatter * dateFormatter;
    NSDateFormatter * timeFormatter;
    Float32 balance;
    NSInteger timestamp;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)settingsButtonTapped:(id)sender;
- (IBAction)refreshButtonTapped:(id)sender;

@end
