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
#import "AQGridView.h"
#import "SpringBoardIconCell.h"
#import "PushCoinMessages.h"
#import "KeychainItemWrapper.h"


BOOL REVERSE_KEYPAD = YES;
int KeyBackgroundStyle = 1;

@class SpringBoardIconCell;

@interface PayController : UIViewController <UITextFieldDelegate,QRViewControllerDelegate, VSKeypadViewDelegate, ABPeoplePickerNavigationControllerDelegate, AQGridViewDataSource, AQGridViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>
{
    NSString *enteredAmountString_;
    
    NSMutableArray * icons_;
    AQGridView * gridView_;
    
    NSUInteger emptyCellIndex_;
    
    NSUInteger dragOriginIndex_;
    CGPoint dragOriginCellOrigin_;
    
    SpringBoardIconCell * draggingCell_;
    
    VSKeypadView * keypadView_;
    
    BOOL pageControlUsed_;
    
    PushCoinMessageParser * parser_;
    NSMutableData * buffer_;
    
    KeychainItemWrapper * keychain_;
}

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UILabel *receiverLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) NSData * encodedData;
- (IBAction)amountTextFieldTouched:(id)sender;

- (IBAction)push:(id)sender;

@end
