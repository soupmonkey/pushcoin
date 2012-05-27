//
//  HistoryController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryController.h"
#import "PushCoinMessages.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"
#import "NSData+BytesToHexString.h"
#import "NSData+Base64.h"
#import "PushCoinTransaction.h"
#import "TransactionCell.h"
#import "BalanceCell.h"

@implementation HistoryController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    webService = [[PushCoinWebService alloc] initWithDelegate:self];
    buffer =  [[NSMutableData alloc] initWithLength:PushCoinWebServiceOutBufferSize];
    parser = [[PushCoinMessageParser alloc] init];
    transactions = [[NSMutableArray alloc] init];
    balance = 0;
    timestamp = 0;

    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];

    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setLocale:usLocale];
    
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDoesRelativeDateFormatting:YES];
    [timeFormatter setTimeStyle:NSTimeZoneNameStyleShortGeneric];
    [timeFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [timeFormatter setLocale:usLocale];

    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:usLocale];
    
    self.tableView.dataSource = self;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self queryRequest];
}

- (IBAction)refreshButtonTapped:(id)sender 
{
    [self queryRequest];
}

-(void)queryRequest
{
    if (!self.appDelegate.registered)
        return;

    // Create transfer request
    TransactionHistoryQueryMessage * trxMsg = [[TransactionHistoryQueryMessage alloc] init];
    PCOSRawData * trxData = [[PCOSRawData alloc] initWithData:buffer];
    
    trxMsg.block.mat.data = self.appDelegate.authToken.hexStringToBytes;
    trxMsg.block.ref_data.string=@"";
    trxMsg.block.keywords.string=@"";
    trxMsg.block.page.val = 0;
    trxMsg.block.page_size_hint.val = 50;
    
    [parser encodeMessage:trxMsg to:trxData];
    [webService sendMessage:trxData.consumedData];
    
    // Create balance request
    BalanceQueryMessage * balMsg = [[BalanceQueryMessage alloc] init];
    PCOSRawData * balData = [[PCOSRawData alloc] initWithData:buffer];
    
    balMsg.block.mat.data = self.appDelegate.authToken.hexStringToBytes;
    balMsg.block.ref_data.string=@"";
    
    [parser encodeMessage:balMsg to:balData];
    [webService sendMessage:balData.consumedData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (IBAction)settingsButtonTapped:(id)sender 
{
    SettingsController * controller = [self.appDelegate viewControllerWithIdentifier:@"SettingsController"];
    
    if (controller)
    {
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:controller animated:YES];
    }
}

#pragma mark PushCoinWebserviceDelegate

- (void)webService:(PushCoinWebService *)webService didReceiveMessage:(NSData *)data
{
    [parser decode:data toReceiver:self];
}


- (void)webService:(PushCoinWebService *)webService didFailWithStatusCode:(NSInteger)statusCode 
andDescription:(NSString *)description
{
}

#pragma mark PushCoinMessageParserDelegate


-(void) didDecodeErrorMessage:(ErrorMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
[self.appDelegate showAlert:msg.block.reason.string 
                  withTitle:[NSString stringWithFormat:@"Error - %d", msg.block.error_code.val]];
}

-(void) didDecodeSuccessMessage:(SuccessMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
[self.appDelegate showAlert:@"Success!" 
                  withTitle:@"Success"];
}

-(void) didDecodeUnknownMessage:(PCOSMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
[self.appDelegate showAlert:@"Unknown message received." 
                  withTitle:@"Unknown"];
}

-(void) didDecodeTransactionHistoryReportMessage:(TransactionHistoryReportMessage *)msg withHeader:(PCOSHeaderBlock *)hdr
{
    [transactions removeAllObjects];
    for(int i = 0; i < msg.block.tx_seq.itemCount; ++i)
    {
        Transaction * trx = [msg.block.tx_seq.val objectAtIndex:i];
        
        PushCoinTransaction * pTrx = [[PushCoinTransaction alloc] initWithID:trx.transaction_id.data.bytesToHexString
                                                                        type:trx.tx_type.val
                                                                 amountValue:trx.amount.value.val
                                                                 amountScale:trx.amount.scale.val
                                                                merchantName:trx.merchant_name.string
                                                                   timestamp:trx.utc_transaction_time.val];
        [transactions addObject:pTrx];
    }
    
    [self.tableView reloadData];
}

-(void) didDecodeBalanceReportMessage:(BalanceReportMessage *)msg withHeader:(PCOSHeaderBlock *)hdr
{
    NSDate *now = [[NSDate alloc] init];
    
    balance = msg.block.balance.value.val * (pow(10.0f, (Float32)msg.block.balance.scale.val));
    timestamp = [now timeIntervalSince1970];
    
    [self.tableView reloadData];
}

#pragma mark UITableViewDelegates

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if (section == 1 && transactions.count)
        return @"Transaction History";
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else
        return transactions.count;
}

-(NSString*) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return @"";
    
    if (timestamp == 0)
        return @"";
        
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [NSString stringWithFormat:@"Last Updated: %@, %@", [dateFormatter stringFromDate:date],
            [timeFormatter stringFromDate:date]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        BalanceCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"Balance"];
        if (!cell)
        {
            cell = [[BalanceCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Balance"];
        }

        NSNumber *c = [NSNumber numberWithFloat:balance];
        cell.detailTextLabel.text = [numberFormatter stringFromNumber:c];
        cell.textLabel.text = @"Balance";
        
        return cell;
    }
    else
    {
        TransactionCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"Transaction"];
        if (!cell)
        {
            cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Transaction"];
        }
    
        PushCoinTransaction * trx = [transactions objectAtIndex:indexPath.row];
    
        Float32 amount = trx.amountValue * pow(10.0f, (Float32)trx.amountScale);
        if (trx.transactionType == 'D')
            amount *= -1.0f;
        
        NSNumber *c = [NSNumber numberWithFloat:amount];
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:trx.timestamp];

        cell.titleTextLabel.text = trx.merchantName;
        cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
        cell.rightTextLabel.text = [numberFormatter stringFromNumber:c];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end

