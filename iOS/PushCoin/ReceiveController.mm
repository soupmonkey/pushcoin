//
//  SecondViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReceiveController.h"

@implementation ReceiveController
@synthesize resultLabel;

- (void)didReceiveMemoryWarning
{
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
}

- (void)viewDidUnload
{
    [self setResultLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (IBAction)ping:(id)sender 
{
    self.resultLabel.text = @"pinging";
    
    PingMessage * pingOut = [[PingMessage alloc] init];
    PCOSRawData * dataOut = [[PCOSRawData alloc] initWithData:buffer];
    
    [parser encodeMessage:pingOut to:dataOut];
    [webService sendMessage:dataOut.consumedData];
}

- (IBAction)register:(id)sender 
{
    self.resultLabel.text = @"registering";
    
    RegisterMessage * registerOut = [[RegisterMessage alloc] init];
    PCOSRawData * dataOut = [[PCOSRawData alloc] initWithData:buffer];
    
    registerOut.register_block.registration_id.string = @"VJHY-HFFZ-J7PY-N4DK";
    registerOut.register_block.public_key.string = @"01234567890123456789012345";
    registerOut.register_block.user_agent.string = @"PushCoin/1.0;iOS5.1;ObjC/XCode4";
    
    [parser encodeMessage:registerOut to:dataOut];
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
   resultLabel.text = [NSString stringWithFormat:@"registerAck.auth_token.len=%d", msg.auth_token.itemCount];        
}

-(void) didDecodeUnknownMessage:(PCOSMessage *)msg withHeader:(PCOSHeaderBlock*)hdr
{
    resultLabel.text = [NSString stringWithFormat:@"unexpected message received: [%@]", hdr.msg_id.string];
}

@end






































