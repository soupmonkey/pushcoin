#import <UIKit/UIKit.h>
#import "GMGridViewCell.h"
#import "PushCoinPayment.h"

@interface PaymentCell : GMGridViewCell

@property (nonatomic, strong) PushCoinPayment * payment;
@property (nonatomic, strong) UILabel * amountLabel;
@property (nonatomic, strong) UILabel * tipLabel;


-(id) initWithFrame:(CGRect)frame;
@end
