//
//  PushCoinPayment.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/19/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    PushCoinPaymentAmountTypeGreen,
    PushCoinPaymentAmountTypePurple,
    PushCoinPaymentAmountTypeRed,
    PushCoinPaymentAmountTypeBrown,
    PushCoinPaymentAmountTypeYellow,
    PushCoinPaymentAmountTypeClear
} PushCoinPaymentAmountType;

@interface PushCoinPayment : NSObject<NSCopying, NSCoding>

@property (nonatomic, assign) NSUInteger amountValue;
@property (nonatomic, assign) NSInteger amountScale;
@property (nonatomic, assign) NSUInteger tipValue;
@property (nonatomic, assign) NSInteger tipScale;

@property (nonatomic, readonly) Float32 amount;
@property (nonatomic, readonly) Float32 tip;
@property (nonatomic, readonly) PushCoinPaymentAmountType amountType;

@end
