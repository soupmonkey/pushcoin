//
//  QRViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushCoinPayment.h"

@class QRViewController;

@protocol QRViewControllerDelegate <NSObject>

- (void)qrViewControllerDidCloseQR:
(QRViewController *)controller;

@end

@interface QRViewController : UIViewController


@property (nonatomic, strong) NSData * data;
@property (nonatomic, weak) id <QRViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (nonatomic, strong) PushCoinPayment * detail;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

-(void) setQRData:(NSData*)d withDetails:(PushCoinPayment *)detail;


@end
