//
//  PaymentDetailsController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushCoinPayment.h"

@class PaymentDetailsController;

@protocol PaymentDetailsControllerDelegate <NSObject>

- (void)paymentDetailsControllerDidClose:
(PaymentDetailsController *)controller;
- (void)paymentDetailsControllerDidCancel:
(PaymentDetailsController *)controller;

@end


@interface PaymentDetailsController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) NSObject<PaymentDetailsControllerDelegate> * delegate;
- (IBAction)cancelButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tipTableView;
@property (strong, nonatomic) PushCoinPayment * payment;
@end
