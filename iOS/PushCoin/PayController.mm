//
//  FirstViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PayController.h"
#import "VSKeypadView.h"


@implementation PayController
@synthesize amountTextField;
@synthesize encodedData;
@synthesize keypadView;
@synthesize receiverLabel;
@synthesize scrollView;
@synthesize pageControl;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.keypadView = [VSKeypadView keypadViewWithFrame:
                       CGRectMake(0, 0, 
                                  self.scrollView.frame.size.width,
                                  self.scrollView.frame.size.height)];
	self.keypadView.delegate = self;	
	[self.keypadView setOpaque:YES];
    [self.scrollView addSubview:keypadView];    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * 2, 
                                               self.scrollView.frame.size.height)];    
    enteredAmountString = @"";
    
    //amountTextField.keyboardType = UIKeyboardTypeDecimalPad;
    //[amountTextField becomeFirstResponder];
        
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setAmountTextField:nil];
    [self setReceiverLabel:nil];
    [self setScrollView:nil];
    [self setPageControl:nil];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide keyboard
    //if (textField == amountTextField)
    //    [textField resignFirstResponder];
    
    [self push:textField];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue 
                 sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"SegueToQR"])
	{
		UIViewController *viewController = segue.destinationViewController;
		QRViewController *qrViewController = (QRViewController *)viewController;
		qrViewController.delegate = self;
        [qrViewController setQRData:[encodedData dataUsingEncoding:NSASCIIStringEncoding]
                        withSummary:encodedData];
	}
}

-(void)qrViewControllerDidCloseQR:(QRViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)push:(id)sender
{
    //set data
    encodedData = self.amountTextField.text;
    
    if (encodedData.length)
    {
        //show qr view
        [self performSegueWithIdentifier:@"SegueToQR"
                                  sender:self ];   
    }
}

-(int) numberOfRows
{
	return 4;
}

-(int) numberOfColumns
{
	return 3;
}

-(CGSize) sizeForButtonOnRow:(int)row 
                   andColumn:(int)column
{
    int width = self.scrollView.frame.size.width / 3;
    int height = self.scrollView.frame.size.height / 4;
       
    return CGSizeMake(width, height);
}

-(NSString *) titleForButtonOnRow:(int)row
                        andColumn:(int)column
{
	if (REVERSE_KEYPAD) {		
		if (row == 0) {
			if (column == 0) return @"7";
			if (column == 1) return @"8";
			if (column == 2) return @"9";
		}
		if (row == 1) {
			if (column == 0) return @"4";
			if (column == 1) return @"5";
			if (column == 2) return @"6";
		}
		if (row == 2) {
			if (column == 0) return @"1";
			if (column == 1) return @"2";
			if (column == 2) return @"3";
		}
		if (row == 3) {
            if (column == 0) return @"Receiver";
			if (column == 1) return @"0";
            if (column == 2) return @"OK";
        }
		return @"";
	} else {
		if (row == 3) {
            if (column == 0) return @"Receiver";
			if (column == 1) return @"0";
            if (column == 2) return @"OK";
			return @"";
		}
		return [NSString stringWithFormat:@"%d", row*[keypadView.delegate numberOfColumns]+column+1];
	}
	return nil;
}

-(id) valueForButtonOnRow:(int)row 
                andColumn:(int)column
{
    return [self titleForButtonOnRow:row andColumn:column];
}

-(void) receivedValue:(id)value
{
    if ([value isEqualToString:@"OK"] == YES)
    {
        [self push:nil];
        return;
    }
    else if ([value isEqualToString:@"Receiver"] == YES)
    {
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        [self presentModalViewController:picker animated:YES];
    }
    else
    {
        // Empty Check
        if (amountTextField.text.length == 0)
        {
            enteredAmountString = @"";
        }

        // Sanity check (8.2)
        if (enteredAmountString.length < 10)
        {
            enteredAmountString = [enteredAmountString stringByAppendingFormat:@"%@", value];
        }
    
        // Zero check
        if ([enteredAmountString isEqualToString:@"0"])
        {
            enteredAmountString =@"";
        }
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        NSNumber *number = [f numberFromString:enteredAmountString];
        NSString *numStr = [NSString stringWithFormat:@"$ %.2lf", number.doubleValue / 100];
        amountTextField.text = numStr;
    }
}

-(UIImage *) backgroundImageForState:(UIControlState)state 
                         forKeyAtRow:(int)row 
                           andColumn:(int)column
{
    if (state != UIControlStateHighlighted)
        return [UIImage imageNamed:@"keyBG.png"];
    else
        return [UIImage imageNamed:@"keyBG_touched.png"];
}

-(CGPoint) keypadOrigin
{
	return CGPointMake(0, 0);
}

-(BOOL)isButtonEnabledAtRow:(int)row 
                  andColumn:(int)column
{
	return ![[self titleForButtonOnRow:row andColumn:column] isEqualToString:@""];
}


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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Receiver" 
                                                    message:[NSString stringWithFormat:@"%@\n<%@>", name, email]
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];    
    receiverLabel.text = email;
}
@end
