//
//  RegistrationController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegistrationController;

@protocol RegistrationControllerDelegate <NSObject>

- (void)registrationControllerDidClose:
(RegistrationController *)controller;

@end

@interface RegistrationController : UIViewController<UITextFieldDelegate>
@property (nonatomic, weak) id <RegistrationControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *registrationIDTextBox;

@end
