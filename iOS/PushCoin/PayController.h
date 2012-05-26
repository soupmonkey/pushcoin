//
//  FirstViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <AddressBookUI/AddressBookUI.h>
#import "QRViewController.h"
#import "GMGridView.h"
#import "PaymentCell.h"
#import "AddPaymentController.h"
#import "PasscodeViewController.h"


@interface PayController : UIViewController <QRViewControllerDelegate, AddPaymentControllerDelegate, /*ABPeoplePickerNavigationControllerDelegate,*/ GMGridViewDataSource, GMGridViewSortingDelegate,  GMGridViewActionDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, KKPasscodeViewControllerDelegate>
{
    NSMutableArray *payments_;
    NSInteger lastDeleteItemIndexAsked_;
    BOOL movingCell_;
    PushCoinPayment * savedPayment_;
}


@property (strong, nonatomic) GMGridView * gridView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIView *placeHolderView;

- (IBAction)push:(id)sender;
- (IBAction)editPayment:(id)sender;
- (IBAction)addPayment:(id)sender;

@end
