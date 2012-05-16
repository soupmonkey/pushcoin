//
//  SecondViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ZXingWidgetController.h>
#import <QRCodeReader.h>

@interface ReceiveController : UIViewController<ZXingDelegate>
- (IBAction)scan:(id)sender;
@end
