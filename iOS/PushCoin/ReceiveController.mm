//
//  SecondViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReceiveController.h"
#import "PushCoinMessages.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"
#import "NSData+BytesToHexString.h"
#import "NSData+Base64.h"



@implementation ReceiveController
@synthesize paymentTextField;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    webService = [[PushCoinWebService alloc] initWithDelegate:self];
    buffer =  [[NSMutableData alloc] initWithLength:PushCoinWebServiceOutBufferSize];
    parser = [[PushCoinMessageParser alloc] init];

    storedValue = [NSMutableString stringWithString:@""];
    self.paymentTextField.delegate = self;
    self.paymentTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.paymentTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setPaymentTextField:nil];
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
    
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    widController.readers = [[NSSet alloc] initWithObjects:qrcodeReader, nil];
    [self presentModalViewController:widController animated:YES];
}

- (void) alert:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Close" 
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark -
#pragma mark ZXingDelegateMethods

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSData*)data
{
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
    [self alert:msg.block.reason.string withTitle:@"Error"];
}

-(void) didDecodeSuccessMessage:(SuccessMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    [self alert:@"Success!" withTitle:@"Success"];
}

-(void) didDecodeUnknownMessage:(PCOSMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    [self alert:@"Unknown message received." withTitle:@"Unknown"];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%d %d", range.location, range.length);
    if (range.length > 0)
    {
        if (storedValue.length > 0)
            [storedValue replaceCharactersInRange:NSMakeRange([storedValue length]-1, 1) withString:@""];
    }
    else
    {
        [storedValue appendString:string];
    }
    
    NSString *newAmount = [self formatCurrencyValue:([storedValue doubleValue]/100)];
    
    [textField setText:[NSString stringWithFormat:@"%@",newAmount]];
    return NO;
}

-(NSString*) formatCurrencyValue:(double)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}


@end






































