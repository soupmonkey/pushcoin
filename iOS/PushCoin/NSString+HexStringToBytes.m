//
//  NSString+HexToBytes.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/13/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import "NSString+HexStringToBytes.h"

@implementation NSString (HexStringToBytes)
-(NSData*) hexStringToBytes {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
@end
