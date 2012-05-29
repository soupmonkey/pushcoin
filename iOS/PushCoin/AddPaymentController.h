//
//  AddPaymentController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddPaymentController;
@protocol AddPaymentControllerDelegate <NSObject>

- (void) addPaymentControllerDidClose:(AddPaymentController *)controller;
- (void) addPaymentControllerDidCancel:(AddPaymentController *)controller;


@end

@interface AddPaymentController : UIViewController<UITextFieldDelegate>
{
    NSMutableString * storedValue;
    NSNumberFormatter * numberFormatter;
}
@property (weak, nonatomic) IBOutlet UITextField *paymentTextField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic, readonly) NSUInteger paymentValue;
@property (nonatomic, readonly) NSInteger paymentScale;
@property (weak, nonatomic) NSObject<AddPaymentControllerDelegate> * delegate;


- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)addButtonTapped:(id)sender;
- (IBAction)backgroundTapped:(id)sender;

@end
