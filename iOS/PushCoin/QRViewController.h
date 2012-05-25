//
//  QRViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/21/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushCoinMessages.h"
#import "PushCoinPayment.h"
#import "PaymentDetailsController.h"

@class QRViewController;

@protocol QRViewControllerDelegate <NSObject>

- (void)qrViewControllerDidClose:
(QRViewController *)controller;

@end

@interface QRViewController : UIViewController<PaymentDetailsControllerDelegate>

@property (nonatomic, strong) PushCoinMessageParser * parser;
@property (nonatomic, strong) NSMutableData * buffer;
@property (nonatomic, strong) PushCoinPayment * payment;
@property (nonatomic, weak) id <QRViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;


- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)addTipsButtonTapped:(id)sender;
- (IBAction)detailViewTapped:(id)sender;


@end
