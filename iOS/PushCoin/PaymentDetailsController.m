//
//  PaymentDetailsController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaymentDetailsController.h"
#import "PaymentTipCell.h"

static NSUInteger tipValues[] = { 0, 1, 5, 10, 15, 20, 25, 30, 50 };

@implementation PaymentDetailsController
@synthesize tipTableView;
@synthesize delegate;
@synthesize payment;

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
    self.tipTableView.delegate = self;
    self.tipTableView.dataSource = self;
}

- (void)viewDidUnload
{
    [self setTipTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate paymentDetailsControllerDidCancel:self];
}

#pragma mark UITableViewDelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaymentTipCell * cell = [self.tipTableView dequeueReusableCellWithIdentifier:@"PaymentTip"];
    if (!cell)
    {
        cell = [[PaymentTipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PaymentTip"];
    }

    if (ABS(self.payment.tip * 100.0f - (Float32)tipValues[indexPath.row]) < 0.01f)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%.2f%%",(Float32) tipValues[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.payment.tipValue = tipValues[indexPath.row];
    self.payment.tipScale = -2;
    
    [self.delegate paymentDetailsControllerDidClose:self];
}

@end
