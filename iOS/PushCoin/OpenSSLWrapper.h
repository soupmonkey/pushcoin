//
//  OpenSSLWrapper.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/25/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
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
#include <openssl/evp.h>

@class OpenSSLWrapper;

@protocol OpenSSLWrapperDSAPrivateKeyDelegate <NSObject>

-(NSData *)sslNeedsDsaPrivateKey:(OpenSSLWrapper *)ssl;

@end

@interface OpenSSLWrapper : NSObject
{
    RSA * rsa_;
    bool hasRSA_;
}
@property (nonatomic, assign) RSA * rsa;
@property (nonatomic, weak) NSObject<OpenSSLWrapperDSAPrivateKeyDelegate> * delegate;

+(void) initialize;
+(OpenSSLWrapper *) instance;

-(BOOL) prepareRsaWithKeyFile:(NSString*) keyFile;
-(NSData *) rsa_encryptData: (NSData*) data;

-(BOOL) generateDsaPrivateKey:(NSData **)privateKey 
                 andPublicKey:(NSData **)publicKey 
                     withBits:(NSInteger)bits 
                    toPEMFile:(NSString *)pemFile;

-(NSData *) dsa_signData: (NSData *) data;
-(NSData *) dsa_signData: (NSData *) data privateKey:(NSData *)privateKey;

-(BOOL) dsa_verifyData: (NSData *) data withSignature:(NSData *)signature;
-(BOOL) dsa_verifyData: (NSData *) data withSignature:(NSData *)signature privateKey:(NSData *)privateKey;

-(NSData *) sha1_hashData: (NSData*) data;
-(NSData *) md5_hashData: (NSData *) data;

-(NSData *) des3_encrypt: (NSData *) data withKey:(NSString *)key;
-(NSData *) des3_decrypt: (NSData *) data withKey:(NSString *)key;

@end
