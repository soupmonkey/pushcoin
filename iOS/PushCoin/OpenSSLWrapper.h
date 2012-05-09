//
//  OpenSSLWrapper.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushCoinConfig.h"
#import "KeychainWrapper.h"

#include <openssl/md5.h>
#include <openssl/dsa.h>
#include <openssl/rsa.h>
#include <openssl/sha.h>
#include <openssl/engine.h>
#include <openssl/pem.h>


@interface OpenSSLWrapper : NSObject
{
    RSA * rsa;
    DSA * dsa;
}

+(void) initialize;
+(OpenSSLWrapper *) instance;

-(NSData *) rsa_encrypt: (NSData *) data;
-(NSData *) sha1_hash: (NSData *) data;
-(NSData *) md5_hash: (NSData *) data;
-(NSData *) dsa_sign: (NSData *) data;

@end
