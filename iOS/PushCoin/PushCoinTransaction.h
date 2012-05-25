//
//  PushCoinTransaction.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushCoinTransaction : NSObject<NSCopying>
@property (nonatomic, assign) NSString * transactionID;
@property (nonatomic, assign) char transactionType;
@property (nonatomic, assign) NSUInteger amountValue;
@property (nonatomic, assign) NSInteger amountScale;
@property (nonatomic, assign) NSString * merchantName;

-(id) initWithID:(NSString *)transactionID
            type:(char)transactionType
     amountValue:(NSUInteger)amountValue
     amountScale:(NSInteger)amountScale
    merchantName:(NSString*)merchantName;


@end
