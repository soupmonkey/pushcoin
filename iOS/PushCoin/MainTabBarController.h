//
//  MainTabBarControllerViewController.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/15/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegistrationController.h"


@interface MainTabBarController : UITabBarController<RegistrationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
    

@end
