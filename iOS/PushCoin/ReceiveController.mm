//
//  SecondViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import "ReceiveController.h"
#import "PushCoinMessages.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"
#import "NSData+BytesToHexString.h"
#import "NSData+Base64.h"



@implementation ReceiveController
@synthesize navigationBar;
@synthesize paymentTextField;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:usLocale];

    webService = [[PushCoinWebService alloc] initWithDelegate:self];
    buffer =  [[NSMutableData alloc] initWithLength:PushCoinWebServiceOutBufferSize];
    parser = [[PushCoinMessageParser alloc] init];

    storedValue = [NSMutableString stringWithString:@""];
    self.paymentTextField.delegate = self;
    self.paymentTextField.keyboardType = UIKeyboardTypeNumberPad;
}

- (void)viewDidUnload
{
    [self setPaymentTextField:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (IBAction)scan:(id)sender 
{
    [self.paymentTextField resignFirstResponder];
    
    if (storedValue.intValue == 0)
        return;
        
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self
                                                                                showCancel:YES 
                                                                                  OneDMode:NO];
    
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    widController.readers = [[NSSet alloc] initWithObjects:qrcodeReader, nil];
    widController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    [self presentModalViewController:widController animated:YES];
}

- (IBAction)backgroundTouched:(id)sender 
{
    //[self.paymentTextField resignFirstResponder];
}

#pragma mark -
#pragma mark ZXingDelegateMethods

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSData*)data
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self dismissModalViewControllerAnimated:NO];
    
    NSDate * now = [NSDate date];
    
    // Create transfer request
    TransferRequestMessage * msgOut = [[TransferRequestMessage alloc] init];
    PCOSRawData * dataOut = [[PCOSRawData alloc] initWithData:buffer];
    
    msgOut.block.mat.data = self.appDelegate.authToken.hexStringToBytes;
    msgOut.block.ref_data.string=@"";
    msgOut.block.utc_ctime.val = (SInt64)[now timeIntervalSince1970];
    
    msgOut.block.transfer.value.val = [storedValue intValue];
    msgOut.block.transfer.scale.val = -2;
    
    msgOut.block.currency.string = @"USD";
    msgOut.block.note.string = @"";
    
    msgOut.pta_block.data = data;
    
    [parser encodeMessage:msgOut to:dataOut];
    [webService sendMessage:dataOut.consumedData];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller 
{
    [self dismissModalViewControllerAnimated:YES];
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


#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length > 0)
    {
        if (storedValue.length > 0)
            [storedValue replaceCharactersInRange:NSMakeRange([storedValue length]-1, 1) withString:@""];
    }
    else
    {
        if (storedValue.length + string.length <= 6)
            [storedValue appendString:string];
    }
    
    double value = storedValue.doubleValue;
    if (value == 0)
        storedValue.string = @"";
    
    NSString *newAmount = [self formatCurrencyValue:(value/100)];
    [textField setText:[NSString stringWithFormat:@"%@",newAmount]];
    return NO;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = @"$0.00";
    storedValue.string = @"";
    return NO;
}


-(NSString*) formatCurrencyValue:(double)value
{
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    UINavigationItem * item = [self.navigationBar.items objectAtIndex:self.navigationBar.items.count - 1];
    UIBarButtonItem * hideItem = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStyleBordered
                                                                   target:self action:@selector(hideButtonTapped:)];
    hideItem.tintColor = UIColorFromRGB(0xC84131);
    
    if (item)
        item.rightBarButtonItem = hideItem;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    UINavigationItem * item = [self.navigationBar.items objectAtIndex:self.navigationBar.items.count - 1];
    if (item)
        item.rightBarButtonItem = nil;
}

-(void) hideButtonTapped:(id)sender
{
    [self.paymentTextField resignFirstResponder];
}

@end






































