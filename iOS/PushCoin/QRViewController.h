//
//  QRViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QRViewController;

@protocol QRViewControllerDelegate <NSObject>

- (void)qrViewControllerDidCloseQR:
(QRViewController *)controller;

@end

@interface QRViewController : UIViewController
{
    NSData * data;
    NSString * summary;
}

@property (nonatomic, weak) id <QRViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

-(void) setQRData:(NSData*)d withSummary:(NSString*)s;

@end
