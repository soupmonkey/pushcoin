//
//  PushCoinPayment.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PushCoinPayment.h"

@implementation PushCoinPayment
@synthesize amountScale;
@synthesize amountValue;
@synthesize tipScale;
@synthesize tipValue;
@synthesize tip;
@synthesize amount;
@synthesize amountType;


-(id) init
{
    self = [super init];
    if (self)
    {
        self.amountScale = 0;
        self.amountValue = 0;
        self.tipScale = 0;
        self.tipValue = 0;
    }
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    PushCoinPayment * other = [[PushCoinPayment alloc] init];
    if (other)
    {
        other.amountScale = self.amountScale;
        other.amountValue = self.amountValue;
        other.tipScale = self.tipScale;
        other.tipValue = self.tipValue;
    }
    return other;
    
}

-(Float32) tip
{
    return (Float32)self.tipValue * pow(10.0f, (Float32)self.tipScale);
}

-(Float32) amount
{
    return (Float32)self.amountValue * pow(10.0f, (Float32)self.amountScale);    
}

-(PushCoinPaymentAmountType) amountType
{
    Float32 value = self.amount * (1.0 + self.tip);
    if (value >= 500.0f)
        return PushCoinPaymentAmountTypeClear;
    else if (value >= 100.0f)
        return PushCoinPaymentAmountTypeYellow;
    else if (value >= 50.f)
        return PushCoinPaymentAmountTypeBrown;
    else if (value >= 10.f)
        return PushCoinPaymentAmountTypeRed;
    else if (value >= 5.0f)
        return PushCoinPaymentAmountTypePurple;
    else
        return PushCoinPaymentAmountTypeGreen;
}

/*
-(UIColor *) color
{
    UIColor * res;
    Float32 value = self.amount * (1.0 + self.tip);
    if (value >= 500.0f)
        res = [UIColor blackColor];
    else if (value >= 100.0f)
        res = [UIColor yellowColor];
    else if (value >= 50.f)
        res = [UIColor brownColor];
    else if (value >= 10.f)
        res = [UIColor redColor];
    else if (value >= 5.0f)
        res = [UIColor purpleColor];
    else
        res = [UIColor greenColor];
    
    // Make it darker
    float hue;
    float saturation;
    float brightness;
    float alpha;

    [res getHue:&hue 
     saturation:&saturation
     brightness:&brightness 
          alpha:&alpha];
    
    return [UIColor colorWithHue:hue
                      saturation:saturation
                      brightness:brightness * 0.3f
                           alpha:alpha];
}
*/
@end
