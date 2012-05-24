//
//  QRViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QRViewController.h"
#import "QREncoder.h"
#import "PaymentCell.h"

@implementation QRViewController
@synthesize detailView;
@synthesize detail;
@synthesize navigationBar;
@synthesize delegate;
@synthesize imageView;
@synthesize data;


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
    [self prepareNavigationBar];
    
    UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    UISwipeGestureRecognizer * swipeRecognizer = 
        [[UISwipeGestureRecognizer alloc] initWithTarget:self   
                                                  action:@selector(handleSwipe:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeRecognizer];
    
    int qrcodeImageDimension = self.imageView.frame.size.width;    
    
    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO
                                                version:QR_VERSION_AUTO
                                                  bytes:self.data];
    
    UIImage *qrcodeImage = [QREncoder renderDataMatrix:qrMatrix 
                                        imageDimension:qrcodeImageDimension];
    
    self.imageView.image = qrcodeImage;
    
    PaymentCell * cell = [[PaymentCell alloc] initWithFrame:CGRectMake(0,0, 
                                                                         self.detailView.bounds.size.width,
                                                                         self.detailView.bounds.size.height)];
    cell.payment = detail;
    
    [self.detailView addSubview:cell];

}

-(void) prepareNavigationBar
{
    /*
    UIImageView * logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.bounds = CGRectInset(self.navigationBar.bounds, 0, 5.0f);
    self.navigationBar.topItem.titleView = logoView;
     */
}

- (IBAction) handleSwipe:(UISwipeGestureRecognizer *) recognizer
{
    [self.delegate qrViewControllerDidCloseQR:self];
}

- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer 
{
    [self.delegate qrViewControllerDidCloseQR:self];
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

-(void) setQRData:(NSData*)data_ withDetails:(PushCoinPayment *)detail_
{
    self.data = data_;
    self.detail = detail_;
}

@end
