//
//  QRViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/21/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import "QRViewController.h"
#import "QREncoder.h"
#import "PaymentCell.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"

@implementation QRViewController
@synthesize detailView;
@synthesize payment = payment_;
@synthesize navigationBar;
@synthesize delegate;
@synthesize imageView;
@synthesize parser;
@synthesize buffer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.buffer = [[NSMutableData alloc] initWithLength:PushCoinWebServiceOutBufferSize];
    self.parser = [[PushCoinMessageParser alloc] init];
    
    UISwipeGestureRecognizer * swipeRecognizer = 
        [[UISwipeGestureRecognizer alloc] initWithTarget:self   
                                                  action:@selector(handleSwipe:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeRecognizer];
    
    [self prepareQR];
}

- (void) prepareQR
{
    NSDate * now = [NSDate date];
    
    //set data
    PaymentTransferAuthorizationMessage * msgOut = [[PaymentTransferAuthorizationMessage alloc] init];
    PCOSRawData * dataOut = [[PCOSRawData alloc] initWithData:self.buffer];
    
    msgOut.prv_block.mat.data = self.appDelegate.authToken.hexStringToBytes;
    msgOut.prv_block.ref_data.string=@"";
    
    msgOut.pub_block.utc_ctime.val = (SInt64)[now timeIntervalSince1970];
    msgOut.pub_block.utc_etime.val = (SInt64)[now timeIntervalSince1970] + 60;    
    msgOut.pub_block.payment_limit.value.val = self.payment.amountValue;
    msgOut.pub_block.payment_limit.scale.val = self.payment.amountScale;
    
    if (self.payment.tipValue != 0)
    {
        Gratuity * tip = [[Gratuity alloc] init];
        tip.type.val = 'P';
        tip.add.value.val = self.payment.tipValue;
        tip.add.scale.val = self.payment.tipScale;
        
        [msgOut.pub_block.tip.val addObject:tip];
    }
    
    msgOut.pub_block.currency.string = @"USD";
    msgOut.pub_block.keyid.data = [PushCoinRSAPublicKeyID hexStringToBytes];
    msgOut.pub_block.receiver.string = @"";
    msgOut.pub_block.note.string = @"";
    
    [self.parser encodeMessage:msgOut to:dataOut];
    NSData * data = dataOut.consumedData;
    
    if (data.length)
    {
        int qrcodeImageDimension = self.imageView.frame.size.width;    
        
        DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO
                                                    version:QR_VERSION_AUTO
                                                      bytes:data];
        
        UIImage *qrcodeImage = [QREncoder renderDataMatrix:qrMatrix 
                                            imageDimension:qrcodeImageDimension];
        
        self.imageView.image = qrcodeImage;
        
        CGRect frame = CGRectMake(0,0,                                                                            self.detailView.bounds.size.width,                                                                           self.detailView.bounds.size.height);
        
        PaymentCell * cell = [[PaymentCell alloc] 
                              initWithFrame:frame];
        
        cell.payment = self.payment;
        
        [self.detailView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [self.detailView addSubview:cell];
    }
    else 
    {
        [self.delegate qrViewControllerDidClose:self];
    }
}

- (IBAction) handleSwipe:(UISwipeGestureRecognizer *) recognizer
{
    [self.delegate qrViewControllerDidClose:self];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setDetailView:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (IBAction)closeButtonTapped:(id)sender 
{
    [self.delegate qrViewControllerDidClose:self];
}

- (IBAction)addTipsButtonTapped:(id)sender 
{
    [self showPaymentDetails];
}

- (void) showPaymentDetails
{
    PaymentDetailsController * controller = [self.appDelegate viewControllerWithIdentifier:@"PaymentDetailsController"];
    
    if (controller)
    {
        controller.delegate = self;
        controller.payment = self.payment;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    }
}

-(void) paymentDetailsControllerDidCancel:(PaymentDetailsController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}


-(void) paymentDetailsControllerDidClose:(PaymentDetailsController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
    self.payment = controller.payment;
    [self prepareQR];
}

@end
