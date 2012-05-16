//
//  ThirdViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsController.h"
#import "Security/Security.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"
#import "NSData+BytesToHexString.h"

#include <openssl/rsa.h>
#include <openssl/engine.h>
#include <openssl/pem.h>


@implementation SettingsController
@synthesize unregisterButton;
@synthesize preAuthorizationTestButton;
@synthesize registerButton;
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
    
    [registerButton setTitle:@"Register Device" forState:UIControlStateNormal];
    [registerButton setTitle:@"Device Registered" forState:UIControlStateDisabled];
    
    [unregisterButton setTitle:@"Unregister Device" forState:UIControlStateNormal];
    [unregisterButton setTitle:@"Unregister Device" forState:UIControlStateDisabled];
    
    webService = [[PushCoinWebService alloc] initWithDelegate:self];
    buffer =  [[NSMutableData alloc] initWithLength:PushCoinWebServiceOutBufferSize];
    parser = [[PushCoinMessageParser alloc] init];
    
    [self updateRegisterButtonStatus];    
}

- (void) updateRegisterButtonStatus
{
    if (!self.appDelegate.registered)
    {
        registerButton.enabled = YES;
        unregisterButton.enabled = NO;
        preAuthorizationTestButton.enabled = NO;
    }
    else 
    {
        registerButton.enabled = NO;
        unregisterButton.enabled = YES;
        preAuthorizationTestButton.enabled = YES;
    }
}
- (void)viewDidUnload
{
    [self setResultLabel:nil];
    [self setRegisterButton:nil];
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

- (IBAction)register:(id)sender 
{
    [self performSegueWithIdentifier:@"SegueToRegistration"
                              sender:self ];  
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue 
                 sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"SegueToRegistration"])
	{
		UIViewController *viewController = segue.destinationViewController;
		RegistrationController *controller = (RegistrationController *)viewController;
		controller.delegate = self;
	}
}
        
-(void)registrationControllerDidClose:(RegistrationController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];

    NSString * privateKey;
    NSString * publicKey;

    OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
    [ssl generateDsaPrivateKey:&privateKey andPublicKey:&publicKey withBits:512];
    self.appDelegate.dsaPrivateKey = privateKey;
    
    RegisterMessage * msgOut = [[RegisterMessage alloc] init];
    PCOSRawData * dataOut = [[PCOSRawData alloc] initWithData:buffer];
    
    msgOut.register_block.registration_id.string = controller.registrationIDTextBox.text;
    msgOut.register_block.public_key.data = publicKey.hexStringToBytes;
    msgOut.register_block.user_agent.string = PushCoinAppUserAgent;
    
    [parser encodeMessage:msgOut to:dataOut];
    [webService sendMessage:dataOut.consumedData];
}

- (IBAction)unregister:(id)sender 
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unregistering device" message:@"Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
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
    }
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
                        msg.error_block.error_code.val, msg.error_block.reason.string];
}

-(void) didDecodeSuccessMessage:(SuccessMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"OK"];
}

-(void) didDecodePongMessage:(PongMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"pong.tm=%lld", msg.pong_block.tm.val];        
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
    
    msgOut.prv_block.mat.string=self.appDelegate.authToken;
    msgOut.prv_block.user_data.string=@"";
    msgOut.prv_block.reserved.string=@"";
    
    msgOut.pub_block.utc_ctime.val = [now timeIntervalSince1970];
    msgOut.pub_block.utc_etime.val = [now timeIntervalSince1970] + 60; /* exp in 1 min */
    
    msgOut.pub_block.payment_limit.payment_limit.val = 100;
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
    
    msgOut2.preauthorization_block.mat.string = self.appDelegate.authToken;
    msgOut2.preauthorization_block.payment_limit.payment_limit.val = 100;
    msgOut2.preauthorization_block.payment_limit.scale.val = -2;
    msgOut2.preauthorization_block.currency.string = @"USD";
    msgOut2.preauthorization_block.user_data.string=@"";

    msgOut2.payment_transfer_authorization_block.data =encodedData;
    
    [parser encodeMessage:msgOut2 to:dataOut2];
    [webService sendMessage:dataOut2.consumedData];
}
@end























