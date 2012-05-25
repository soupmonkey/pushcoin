//
//  PushCoinPayment.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/19/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import "PushCoinPayment.h"

@implementation PushCoinPayment
@synthesize amountScale = amountScale_;
@synthesize amountValue = amountValue_;
@synthesize tipScale    = tipScale_;
@synthesize tipValue    = tipValue_;
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

-(id) initWithAmountValue:(NSUInteger)amountValue
              amountScale:(NSInteger)amountScale
                 tipValue:(NSUInteger)tipValue
                 tipScale:(NSInteger)tipScale
{
    self = [super init];
    if (self)
    {
        self.amountScale = amountScale;
        self.amountValue = amountValue;
        self.tipScale = tipScale;
        self.tipValue = tipValue;
    }
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    PushCoinPayment * other = [[PushCoinPayment alloc] initWithAmountValue:self.amountValue
                                                               amountScale:self.amountScale
                                                                  tipValue:self.tipValue 
                                                                  tipScale:self.tipScale];
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


#pragma mark NSCoding

#define kAmountValue   @"AmountValue"
#define kAmountScale   @"AmountScale"
#define kTipValue      @"TipValue"
#define kTipScale      @"TipScale"


- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:amountValue_ forKey:kAmountValue];
    [encoder encodeInteger:amountScale_ forKey:kAmountScale];
    [encoder encodeInteger:tipValue_ forKey:kTipValue];
    [encoder encodeInteger:tipScale_ forKey:kTipScale];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSUInteger amountValue = [decoder decodeIntegerForKey:kAmountValue];
    NSInteger amountScale = [decoder decodeIntegerForKey:kAmountScale];
    NSUInteger tipValue = [decoder decodeIntegerForKey:kTipValue];
    NSInteger tipScale = [decoder decodeIntegerForKey:kTipScale];
    
    return [self initWithAmountValue:amountValue
                         amountScale:amountScale
                            tipValue:tipValue 
                            tipScale:tipScale];
}
@end


























