//
//  SpringBoardIconCell.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AQGridViewCell.h"

@interface SpringBoardIconCell : AQGridViewCell
{
    UIImageView * _iconView;
}
@property (nonatomic, retain) UIImage * icon;
@end