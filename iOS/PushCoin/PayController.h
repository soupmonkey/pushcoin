//
//  FirstViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "QRViewController.h"
#import "VSKeypadView.h"

BOOL REVERSE_KEYPAD = YES;
int KeyBackgroundStyle = 1;

@interface PayController : UIViewController 
    <UITextFieldDelegate,QRViewControllerDelegate,VSKeypadViewDelegate, ABPeoplePickerNavigationControllerDelegate>
{
    NSString *enteredAmountString;
}

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (nonatomic, retain) NSString *encodedData;
@property (nonatomic, retain) VSKeypadView *keypadView;
@property (weak, nonatomic) IBOutlet UILabel *receiverLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;


- (IBAction)push:(id)sender;

@end
