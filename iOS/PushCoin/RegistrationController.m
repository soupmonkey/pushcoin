//
//  RegistrationController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/8/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import "RegistrationController.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"
#import "NSData+BytesToHexString.h"
#import "NSData+Base64.h"


@implementation RegistrationController
@synthesize registrationIDTextBox;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-"];
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    int charCount = [newString length];
    
    if ([newString rangeOfCharacterFromSet:[charSet invertedSet]].location != NSNotFound
        || [string rangeOfString:@"-"].location != NSNotFound
        || charCount > 19) {
        return NO;
    }
    
    if ([newString characterAtIndex:newString.length -1] == '-')
    {
        newString = [newString substringToIndex:newString.length - 1];
    }
    else
    {
        if (charCount == 5 || charCount == 10 || charCount == 15) 
        {
            NSMutableString * mutableString = [NSMutableString stringWithString:newString];
            [mutableString insertString:@"-" atIndex:mutableString.length - 1];
            newString = mutableString;
        }
    }
    textField.text = newString;
    return NO;
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


-(void)register
{
    NSData * privateKey;
    NSData * publicKey;
    
    OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
    [ssl generateDsaPrivateKey:&privateKey andPublicKey:&publicKey withBits:512 toPEMFile:
    [self.appDelegate.documentPath stringByAppendingPathComponent:PushCoinDSAPublicKeyFile]];
    [self.appDelegate setDsaPrivateKey:privateKey withPasscode:@""];
    
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
    [[self appDelegate] showAlert:description
                        withTitle:[NSString stringWithFormat:@"Webservice Error - %d", statusCode]];
    [self.registrationIDTextBox becomeFirstResponder];
}

-(void) didDecodeErrorMessage:(ErrorMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    [[self appDelegate] showAlert:msg.block.reason.string 
                        withTitle:[NSString stringWithFormat:@"Error - %d", msg.block.error_code.val]];
    [self.registrationIDTextBox becomeFirstResponder];

}

-(void) didDecodeRegisterAckMessage:(RegisterAckMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    self.appDelegate.authToken = [msg.register_ack_block.mat.data bytesToHexString];
    [self.delegate registrationControllerDidClose:self];
}

-(void) didDecodeUnknownMessage:(PCOSMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    [[self appDelegate] showAlert:[NSString stringWithFormat:@"unexpected message received: [%@]",
                                   hdr.message_id.string]
                        withTitle:@"Error"];
    [self.registrationIDTextBox becomeFirstResponder];
}



@end
