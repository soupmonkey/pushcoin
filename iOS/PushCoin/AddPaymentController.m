//
//  AddPaymentController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddPaymentController.h"
#import "AppDelegate.h"

@implementation AddPaymentController
@synthesize paymentTextField;
@synthesize addButton;
@synthesize paymentValue;
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
    
    storedValue = [NSMutableString stringWithString:@""];
    self.paymentTextField.delegate = self;
    self.paymentTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.paymentTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setPaymentTextField:nil];
    [self setAddButton:nil];
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

- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate addPaymentControllerDidCancel:self];
}

- (IBAction)addButtonTapped:(id)sender {
    [self.delegate addPaymentControllerDidClose:self];
}

- (IBAction)backgroundTapped:(id)sender {
     //[self.paymentTextField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length > 0)
    {
        if (storedValue.length > 0)
            [storedValue replaceCharactersInRange:NSMakeRange([storedValue length]-1, 1) withString:@""];
    }
    else
    {
        if (storedValue.length + string.length <= 6)
            [storedValue appendString:string];
    }
    
    double value = storedValue.doubleValue;
    if (value == 0)
        storedValue.string = @"";
    
    NSString *newAmount = [self formatCurrencyValue:(value/100)];
    [textField setText:[NSString stringWithFormat:@"%@",newAmount]];
    return NO;

}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = @"$0.00";
    storedValue.string = @"";
    return NO;
}

-(NSString*) formatCurrencyValue:(double)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}


-(NSUInteger) paymentValue
{
    if (storedValue.length)
        return [storedValue intValue];
    return 0;
}

-(NSInteger) paymentScale
{
    return -2;
}


@end
