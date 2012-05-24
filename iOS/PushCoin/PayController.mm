//
//  FirstViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "PayController.h"
#import "PushCoinConfig.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"

@implementation PayController
@synthesize navigationBar;
@synthesize placeHolderView;
@synthesize gridView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    buffer_ = [[NSMutableData alloc] initWithLength:PushCoinWebServiceOutBufferSize];
    parser_ = [[PushCoinMessageParser alloc] init];
 
    payments_ = [[NSMutableArray alloc] init];
    movingCell_ = NO;
    
    [self prepareNavigationBar];
    [self preparePaymentGrid];
}

-(void) prepareNavigationBar
{
    UIImageView * logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.bounds = CGRectInset(self.navigationBar.bounds, 0, 5.0f);
    self.navigationBar.topItem.titleView = logoView;
}

-(void) preparePaymentGrid
{
    self.gridView = [[GMGridView alloc] initWithFrame: 
                     CGRectMake(0, 0,
                                self.placeHolderView.frame.size.width,
                                self.placeHolderView.frame.size.height)];
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //self.gridView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"payment_grid_background.png"]];  
    self.gridView.backgroundColor = [UIColor darkGrayColor];
    self.gridView.opaque = YES;

    self.gridView.actionDelegate = self;
    self.gridView.sortingDelegate = self;
    self.gridView.dataSource = self;
    self.gridView.scrollEnabled = YES;
    
    [self.placeHolderView addSubview:self.gridView];    
    [self.gridView reloadData];
}
- (void)viewDidUnload
{
    self.gridView = nil;
    
    [self setNavigationBar:nil];
    [self setPlaceHolderView:nil];
    [self setGridView:nil];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (IBAction)push:(id)sender payment:(PushCoinPayment *)payment
{
    NSDate * now = [NSDate date];
    
    //set data
    PaymentTransferAuthorizationMessage * msgOut = [[PaymentTransferAuthorizationMessage alloc] init];
    PCOSRawData * dataOut = [[PCOSRawData alloc] initWithData:buffer_];
    
    msgOut.prv_block.mat.data = self.appDelegate.authToken.hexStringToBytes;
    msgOut.prv_block.ref_data.string=@"";
    
    msgOut.pub_block.utc_ctime.val = (SInt64)[now timeIntervalSince1970];
    msgOut.pub_block.utc_etime.val = (SInt64)[now timeIntervalSince1970] + 60;    
    msgOut.pub_block.payment_limit.value.val = payment.amountValue;
    msgOut.pub_block.payment_limit.scale.val = payment.amountScale;
    
    if (payment.tipValue != 0)
    {
        Gratuity * tip = [[Gratuity alloc] init];
        tip.type.val = 'P';
        tip.add.value.val = payment.tipValue;
        tip.add.scale.val = payment.tipScale;
        
        [msgOut.pub_block.tip.val addObject:tip];
    }
    
    msgOut.pub_block.currency.string = @"USD";
    msgOut.pub_block.keyid.data = [PushCoinRSAPublicKeyID hexStringToBytes];
    msgOut.pub_block.receiver.string = @"";
    msgOut.pub_block.note.string = @"";
    
    [parser_ encodeMessage:msgOut to:dataOut];
    
    if (dataOut.consumedData.length)
    {
        QRViewController * controller = [self.appDelegate viewControllerWithIdentifier:@"QRViewController"];
        
        if (controller)
        {
            controller.delegate = self;
            controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [controller setQRData:dataOut.consumedData withDetails:payment];
            [self presentModalViewController:controller animated:YES];
        }
    }
}

- (IBAction)editPayment:(id)sender 
{
    self.gridView.editing = !self.gridView.editing;
}

- (IBAction)addPayment:(id)sender 
{
    KeypadController * controller = [self.appDelegate viewControllerWithIdentifier:@"KeypadController"];
    
    if (controller)
    {
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    }
}


#pragma mark -
#pragma mark KeypadController
-(void)keypadControllerDidClose:(KeypadController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (controller.payment.amountValue != 0)
    {
        [payments_ addObject:[controller.payment copy]];
        [self.gridView insertObjectAtIndex:payments_.count-1 withAnimation:GMGridViewItemAnimationFade];
    }
}

#pragma mark -
#pragma mark QRController
-(void)qrViewControllerDidCloseQR:(QRViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark peoplePicker delegates
/*
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
    [self selectReceiver:person];
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}


- (void)selectReceiver:(ABRecordRef)receiver
{
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(receiver,                                                                    
                                                                    kABPersonFirstNameProperty);
    NSString* email = nil;
    ABMultiValueRef emails = ABRecordCopyValue(receiver, kABPersonEmailProperty);
    
    if (ABMultiValueGetCount(emails) > 0) 
    {
        email = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(emails, 0);
    } 
    else 
    {
        email = @"[None]";
    }
    
    // Do something here.
}
*/



//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)view
{
    return payments_.count;   
}

- (CGSize)GMGridView:(GMGridView *)view sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return ( CGSizeMake(150, 80) );
}

- (GMGridViewCell *)GMGridView:(GMGridView *)view cellForItemAtIndex:(NSInteger)index
{
    PaymentCell * cell = (PaymentCell *)[view dequeueReusableCell];
    if (!cell)
        cell = [[PaymentCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 80.0)];
    
    cell.payment = [[payments_ objectAtIndex:index] copy];
    return ( cell );
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES;
}



//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)view didTapOnItemAtIndex:(NSInteger)index;
{
    if (!movingCell_)
    {
        PaymentCell * cell = (PaymentCell *) [view cellForItemAtIndex:index];
        if (cell)
            [self push:view payment:cell.payment];
    }
}


- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" 
                                                    message:@"Are you sure you want to delete this payment?" 
                                                   delegate:self 
                                          cancelButtonTitle:@"Cancel" 
                                          otherButtonTitles:@"Delete", nil];
    
    [alert show];
    lastDeleteItemIndexAsked_ = index;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) 
    {
        [payments_ removeObjectAtIndex:lastDeleteItemIndexAsked_];
        [self.gridView removeObjectAtIndex:lastDeleteItemIndexAsked_ withAnimation:GMGridViewItemAnimationFade];
    }
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    movingCell_ = YES;
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    movingCell_ = NO;
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    NSObject *object = [payments_ objectAtIndex:oldIndex];
    [payments_ removeObject:object];
    [payments_ insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [payments_ exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}



@end
