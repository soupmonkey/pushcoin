//
//  RegistrationController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegistrationController.h"

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
    if (textField == registrationIDTextBox)
        [registrationIDTextBox resignFirstResponder];
    
    [self.delegate registrationControllerDidClose:self];
    return YES;
}

@end
