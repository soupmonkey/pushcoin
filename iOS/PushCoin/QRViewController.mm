//
//  QRViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QRViewController.h"
#import "QREncoder.h"

@implementation QRViewController

@synthesize delegate;
@synthesize imageView;
@synthesize summaryLabel;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *singleFingerTap = 
    [[UITapGestureRecognizer alloc] initWithTarget:self 
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    int qrcodeImageDimension = self.imageView.frame.size.width;    
    
    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO
                                                version:QR_VERSION_AUTO
                                                  bytes:data];
    
    UIImage *qrcodeImage = [QREncoder renderDataMatrix:qrMatrix 
                                        imageDimension:qrcodeImageDimension];
    
    self.imageView.image = qrcodeImage;
    self.summaryLabel.text = summary;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer 
{
    [self.delegate qrViewControllerDidCloseQR:self];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setSummaryLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) setQRData:(NSData*)d withSummary:(NSString*)s
{
    data = d;
    summary = s;
}

@end
