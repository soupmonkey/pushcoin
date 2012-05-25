//
//  PushCoinConfig.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/25/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import "PushCoinConfig.h"

NSString * const PushCoinRSAPublicKeyID = @"652fce08";
NSString * const PushCoinRSAPublicKeyFile = @"pushcoin_rsa.pub";
NSString * const PushCoinDSAPublicKeyFile = @"pushcoin_dsa.pub";
NSString * const PushCoinWebServicePath = @"https://api.pushcoin.com:20001/pcos/";
NSString * const PushCoinKeychainId = @"PushCoin.com";
NSString * const PushCoinAppUserAgent = @"PushCoin/1.0;iOS5.1;ObjC/XCode4";
NSUInteger const PushCoinWebServiceOutBufferSize = 3000;