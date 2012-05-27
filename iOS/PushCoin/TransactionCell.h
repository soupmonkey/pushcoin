//
//  TransactionCell.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * titleTextLabel;
@property (nonatomic, weak) IBOutlet UILabel * detailTextLabel;
@property (nonatomic, weak) IBOutlet UILabel * rightTextLabel;

@end
