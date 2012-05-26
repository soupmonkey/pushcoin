//
//  PushCoinTransaction.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PushCoinTransaction.h"

@implementation PushCoinTransaction
@synthesize amountScale = amountScale_;
@synthesize amountValue = amountValue_;
@synthesize transactionID    = transactionID_;
@synthesize transactionType    = transactionType_;
@synthesize merchantName    = merchantName_;
@synthesize timestamp = timestamp_;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.transactionID = @"";
        self.transactionType = 'C';
        self.amountValue = 0;
        self.amountScale = 0;
        self.merchantName = @"";
        self.timestamp = 0;
    }
    return self;
}

-(id) initWithID:(NSString *)transactionID
            type:(char)transactionType
     amountValue:(NSUInteger)amountValue
     amountScale:(NSInteger)amountScale
    merchantName:(NSString*)merchantName
       timestamp:(NSUInteger)timestamp
{
    self = [super init];
    if (self)
    {
        self.amountScale = amountScale;
        self.amountValue = amountValue;
        self.merchantName = merchantName;
        self.transactionType = transactionType;
        self.transactionID = transactionID;
        self.timestamp = timestamp;
    }
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    PushCoinTransaction * other = [[PushCoinTransaction alloc] initWithID:self.transactionID
                                                                     type:self.transactionType
                                                              amountValue:self.amountValue
                                                              amountScale:self.amountScale
                                                             merchantName:self.merchantName
                                                                timestamp:self.timestamp];
    return other;
    
}
@end
