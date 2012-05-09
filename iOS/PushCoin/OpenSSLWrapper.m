//
//  OpenSSLWrapper.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OpenSSLWrapper.h"

@implementation OpenSSLWrapper

static OpenSSLWrapper * singleton;

// Runtime call this once before any messages is sent to this class
+ (void) initialize
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        singleton = [[OpenSSLWrapper alloc] init];
        initialized = YES;
    }
}

+(OpenSSLWrapper *) instance
{
    return singleton;
}

-(id) init
{
    self = [super init];
    if (self == nil)
        return self;
    
    [self prepareRSA];
    [self prepareDSA];
   
    return self;
}


-(BOOL) prepareRSA
{
    FILE * publicKeyFile = fopen(PEM_RSA_PublicKeyFile.UTF8String, "r");
    if (publicKeyFile == NULL)
        return NO;
    
    rsa = PEM_read_RSAPublicKey(publicKeyFile, 0, 0, 0);
    fclose(publicKeyFile);
    
    return YES;
}


-(BOOL) prepareDSA
{
    
    
    BIO *bio = BIO_new(BIO_s_mem());  
    BIO_write(bio, PEM_DSA_PrivateKey.UTF8String, PEM_DSA_PrivateKey.length);
    
    dsa = PEM_read_bio_DSAPrivateKey(bio, 0, 0, 0);
    BIO_free_all(bio);
    
    return YES;
}

-(void) dealloc
{
    RSA_free(rsa);
    DSA_free(dsa);
}

-(NSData *) rsa_encrypt: (NSData*) data
{
    unsigned char * outbuf = (unsigned char *) calloc(RSA_size(rsa), 1);
    int len = RSA_public_encrypt(data.length, data.bytes, outbuf, rsa, RSA_PKCS1_PADDING);

    NSData * res = [NSData dataWithBytes:outbuf length:len];
    free(outbuf);
    
    return res;
}

-(NSData *) sha1_hash: (NSData*) data
{
    unsigned char md[SHA_DIGEST_LENGTH];

    SHA1(data.bytes, data.length, md);
    
    return [NSData dataWithBytes:md length:SHA_DIGEST_LENGTH];
}

-(NSData *) md5_hash: (NSData *) data
{
    unsigned char md[MD5_DIGEST_LENGTH];
    
    MD5(data.bytes, data.length, md);
    
    return [NSData dataWithBytes:md length:MD5_DIGEST_LENGTH];
}

-(NSData *) dsa_sign: (NSData *) data
{
    unsigned char * sig = (unsigned char *) calloc(DSA_size(dsa), 1);
    unsigned int sig_len;
    
    if (DSA_sign(0, data.bytes, data.length, sig, &sig_len, dsa) != 1)
    {
        free(sig);
        return nil;
    }
    
    NSData * res = [NSData dataWithBytes:sig length:sig_len];
    free(sig);
    
    return res;
}


@end
























