//
//  KeypadController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/23/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeypadView.h"
#import "PushCoinPayment.h"

@class KeypadController;

@protocol KeypadControllerDelegate <NSObject>

- (void)keypadControllerDidClose:(KeypadController *)controller;
- (void)keypadControllerDidCancel:(KeypadController *)controller;

@end


@interface KeypadController : UIViewController<UITextFieldDelegate, KeypadViewDelegate>

@property (nonatomic, strong) NSString * amountString;
@property (nonatomic, strong) PushCoinPayment * payment;

@property (strong, nonatomic) KeypadView * keypadView;
@property (strong, nonatomic) UILabel * displayLabel;
@property (strong, nonatomic) UIView * displayBackground;
@property (nonatomic, weak) id <KeypadControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *placeHolderView;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)clearButtonTapped:(id)sender;

@end
