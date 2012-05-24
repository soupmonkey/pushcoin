//
//  RegistrationController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegistrationController.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"
#import "NSData+BytesToHexString.h"
#import "NSData+Base64.h"


@implementation RegistrationController
@synthesize registrationIDTextBox;
@synthesize resultLabel;
@synthesize delegate;

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
	// Do any additional setup after loading the view.
    
    webService = [[PushCoinWebService alloc] initWithDelegate:self];
    buffer =  [[NSMutableData alloc] initWithLength:PushCoinWebServiceOutBufferSize];
    parser = [[PushCoinMessageParser alloc] init];
    
    [self.registrationIDTextBox becomeFirstResponder];
    self.registrationIDTextBox.delegate = self;
}

- (void)viewDidUnload
{
    [self setRegistrationIDTextBox:nil];
    [self setResultLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self register];
    return YES;
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


-(void)register
{
    NSString * privateKey;
    NSString * publicKey;
    
    OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
    [ssl generateDsaPrivateKey:&privateKey andPublicKey:&publicKey withBits:512 toPEMFile:
     [self.appDelegate.keyFilePath stringByAppendingPathComponent:PushCoinDSAPublicKeyFile]];
    self.appDelegate.dsaPrivateKey = privateKey;
    
    RegisterMessage * msgOut = [[RegisterMessage alloc] init];
    PCOSRawData * dataOut = [[PCOSRawData alloc] initWithData:buffer];
    
    msgOut.register_block.registration_id.string = self.registrationIDTextBox.text;
    msgOut.register_block.public_key.data = [NSData dataFromBase64String:self.appDelegate.pemDsaPublicKey];
    msgOut.register_block.user_agent.string = PushCoinAppUserAgent;
    
    [parser encodeMessage:msgOut to:dataOut];
    [webService sendMessage:dataOut.consumedData];
}


- (void)webService:(PushCoinWebService *)webService didReceiveMessage:(NSData *)data
{
    [parser decode:data toReceiver:self];
}


- (void)webService:(PushCoinWebService *)webService didFailWithStatusCode:(NSInteger)statusCode 
    andDescription:(NSString *)description
{
    resultLabel.text = [NSString stringWithFormat:@"web service returns %d; %@", statusCode, description];
    [resultLabel sizeToFit];
    [self.registrationIDTextBox becomeFirstResponder];
}

-(void) didDecodeErrorMessage:(ErrorMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"error message received with code:%d reason:%@",
                        msg.block.error_code.val, msg.block.reason.string];
    [resultLabel sizeToFit];
    [self.registrationIDTextBox becomeFirstResponder];

}

-(void) didDecodeRegisterAckMessage:(RegisterAckMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    self.appDelegate.authToken = [msg.register_ack_block.mat.data bytesToHexString];
    resultLabel.text = @"Device successfully registered.";      
    
    [resultLabel sizeToFit];
    [self.delegate registrationControllerDidClose:self];
}

-(void) didDecodeUnknownMessage:(PCOSMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"unexpected message received: [%@]", hdr.message_id.string];
    [self.registrationIDTextBox becomeFirstResponder];

}



@end
