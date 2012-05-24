//
//  ThirdViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsController.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"
#import "NSData+BytesToHexString.h"
#import "NSData+Base64.h"



@implementation SettingsController
@synthesize unregisterButton;
@synthesize preAuthorizationTestButton;
@synthesize resultLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [unregisterButton setTitle:@"Unregister Device" forState:UIControlStateNormal];
    [unregisterButton setTitle:@"Unregister Device" forState:UIControlStateDisabled];
    
    webService = [[PushCoinWebService alloc] initWithDelegate:self];
    buffer =  [[NSMutableData alloc] initWithLength:PushCoinWebServiceOutBufferSize];
    parser = [[PushCoinMessageParser alloc] init];
    
    [self.unregisterButton setBackgroundImage:[[UIImage imageNamed:@"iphone_delete_button.png"]
                                           stretchableImageWithLeftCapWidth:8.0f
                                           topCapHeight:0.0f]
                                 forState:UIControlStateNormal];
    
    [self.unregisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.unregisterButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.unregisterButton.titleLabel.shadowColor = [UIColor lightGrayColor];
    self.unregisterButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [self updateRegisterButtonStatus];    
}

- (void) updateRegisterButtonStatus
{
    if (!self.appDelegate.registered)
    {
        unregisterButton.enabled = NO;
        preAuthorizationTestButton.enabled = NO;
    }
    else 
    {
        unregisterButton.enabled = YES;
        preAuthorizationTestButton.enabled = YES;
    }
}
- (void)viewDidUnload
{
    [self setResultLabel:nil];
    [self setUnregisterButton:nil];
    [self setPreAuthorizationTestButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
    
- (IBAction)unregister:(id)sender 
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unregistering device"
                                                     message:@"Are you sure?"
                                                    delegate:self 
                                           cancelButtonTitle:@"No" 
                                           otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
        ssl.dsa = NULL;
        
        self.appDelegate.authToken = @"";
        self.appDelegate.dsaPrivateKey = @"";
        
        [self updateRegisterButtonStatus];
        [self.appDelegate registerFromController:self];
    }
}

-(void) registrationControllerDidClose:(RegistrationController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)webService:(PushCoinWebService *)webService didReceiveMessage:(NSData *)data
{
    [parser decode:data toReceiver:self];
}


- (void)webService:(PushCoinWebService *)webService didFailWithStatusCode:(NSInteger)statusCode 
    andDescription:(NSString *)description
{
    resultLabel.text = [NSString stringWithFormat:@"web service returns %d; %@", statusCode, description];
}

-(void) didDecodeErrorMessage:(ErrorMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"error message received with code:%d reason:%@",
                        msg.block.error_code.val, msg.block.reason.string];
}

-(void) didDecodeSuccessMessage:(SuccessMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"OK"];
}

-(void) didDecodePongMessage:(PongMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"pong.tm=%lld", msg.block.tm.val];        
}

-(void) didDecodeRegisterAckMessage:(RegisterAckMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    self.appDelegate.authToken = [msg.register_ack_block.mat.data bytesToHexString];
    resultLabel.text = @"Device successfully registered.";      
    
    [self updateRegisterButtonStatus];
}

-(void) didDecodeUnknownMessage:(PCOSMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"unexpected message received: [%@]", hdr.message_id.string];
}

- (IBAction)preAuthorizationTest:(id)sender 
{
    NSDate * now = [NSDate date];

    //set data
    PaymentTransferAuthorizationMessage * msgOut = [[PaymentTransferAuthorizationMessage alloc] init];
    PCOSRawData * dataOut = [[PCOSRawData alloc] initWithData:buffer];
    
    msgOut.prv_block.mat.data = self.appDelegate.authToken.hexStringToBytes;
    msgOut.prv_block.ref_data.string=@"";
    
    msgOut.pub_block.utc_ctime.val = (SInt64)[now timeIntervalSince1970];
    msgOut.pub_block.utc_etime.val = (SInt64)[now timeIntervalSince1970] + 60; /* exp in 1 min */
    
    msgOut.pub_block.payment_limit.value.val = 399;
    msgOut.pub_block.payment_limit.scale.val = -2;
    
    msgOut.pub_block.currency.string = @"USD";
    msgOut.pub_block.keyid.data = [PushCoinRSAPublicKeyID hexStringToBytes];
    msgOut.pub_block.receiver.string = @"";
    msgOut.pub_block.note.string = @"";
    
    [parser encodeMessage:msgOut to:dataOut];
    NSData * encodedData = dataOut.consumedData;
    
    
    // Create Preauth request
    PreauthorizationRequestMessage * msgOut2 = [[PreauthorizationRequestMessage alloc] init];
    PCOSRawData * dataOut2 = [[PCOSRawData alloc] initWithData:buffer];
    
    msgOut2.block.mat.data = self.appDelegate.authToken.hexStringToBytes;
    msgOut2.block.preauthorization_amount.value.val = 200;
    msgOut2.block.preauthorization_amount.scale.val = -2;
    msgOut2.block.currency.string = @"USD";
    msgOut2.block.ref_data.string=@"";

    msgOut2.pta_block.data = encodedData;
    
    [parser encodeMessage:msgOut2 to:dataOut2];
    [webService sendMessage:dataOut2.consumedData];
}
@end























