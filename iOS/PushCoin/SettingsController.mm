//
//  ThirdViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsController.h"
#import "Security/Security.h"

#include <openssl/rsa.h>
#include <openssl/engine.h>
#include <openssl/pem.h>


@implementation SettingsController
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
    webService = [[PushCoinWebService alloc] initWithDelegate:self];
    buffer =  [[NSMutableData alloc] init];
    [buffer setLength:PushCoinWebServiceOutBufferSize];
    
    parser = [[PushCoinMessageParser alloc] init];
    
    [self updateRegisterButtonStatus];
    
}

- (void) updateRegisterButtonStatus
{
    OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
    if (ssl.dsa == NULL || ssl.rsa == NULL || !self.authToken.length)
    {
        registerButton.enabled = YES;
        registerButton.titleLabel.text = @"Register Device";
    }
    else 
    {
        registerButton.enabled = NO;
        registerButton.titleLabel.text = @"Device Registered";
    }
}
- (void)viewDidUnload
{
    [self setResultLabel:nil];
    [self setRegisterButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSString *) authToken
{ return [keychain objectForKey:(__bridge id)kSecAttrAccount]; }

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
    [keychain setObject:(id)privateKey forKey:(__bridge id)kSecValueData];
    
    RegisterMessage * msgOut = [[RegisterMessage alloc] init];
    PCOSRawData * dataOut = [[PCOSRawData alloc] initWithData:buffer];
    
    msgOut.register_block.registration_id.string = controller.registrationIDTextBox.text;
    msgOut.register_block.public_key.string = publicKey;
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
}

-(void) didDecodeErrorMessage:(ErrorMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"error message received with code:%d reason:%@",
                        msg.error_block.error_code.val, msg.error_block.error_reason.string];
}

-(void) didDecodePongMessage:(PongMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"pong.tm=%lld", msg.tm.val];        
}

-(void) didDecodeRegisterAckMessage:(RegisterAckMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    [keychain setObject:(id)msg.auth_token.string forKey:(__bridge id)kSecAttrAccount];
    resultLabel.text = @"Device successfully registered.";      
    
    [self updateRegisterButtonStatus];
}

-(void) didDecodeUnknownMessage:(PCOSMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"unexpected message received: [%@]", hdr.message_id.string];
}


@end
