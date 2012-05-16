//
//  OpenSSLWrapper.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushCoinConfig.h"
#import "KeychainItemWrapper.h"

#include <openssl/md5.h>
#include <openssl/dsa.h>
#include <openssl/rsa.h>
#include <openssl/sha.h>
#include <openssl/engine.h>
#include <openssl/pem.h>


@interface OpenSSLWrapper : NSObject
{
    RSA * rsa_;
    DSA * dsa_;
    bool hasRSA_;
    bool hasDSA_;
}
@property (nonatomic, assign) RSA * rsa;
@property (nonatomic, assign) DSA * dsa;


+(void) initialize;
+(OpenSSLWrapper *) instance;


-(BOOL) generateRsaPrivateKey:(NSString **)privateKey andPublicKey:(NSString **) publicKey withBits:(NSInteger) bits andExp:(NSInteger) exp;
-(BOOL) prepareRsaWithKeyFile:(NSString*) keyFile;
-(NSData *) rsa_encryptData: (NSData*) data;

-(BOOL) generateDsaPrivateKey:(NSString **)privateKey andPublicKey:(NSString**)publicKey withBits:(NSInteger)bits;
-(BOOL) prepareDsaWithPrivateKey:(NSString *)privateKey;
-(NSData *) dsa_signData: (NSData *) data;
-(BOOL) dsa_verifyData: (NSData *) data withSignature:(NSData *)signature;

-(NSData *) sha1_hashData: (NSData*) data;
-(NSData *) md5_hashData: (NSData *) data;
@end
