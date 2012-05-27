//
//  OpenSSLWrapper.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/25/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import "OpenSSLWrapper.h"
#import "NSData+BytesToHexString.h"
#import "NSString+HexStringToBytes.h"
#import <CommonCrypto/CommonCryptor.h>


@implementation OpenSSLWrapper
@synthesize delegate;

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
    if (self)
    {
        self.rsa = NULL;
    }
    return self;
}

- (RSA *) rsa
{
    return hasRSA_ ? rsa_ : NULL;
}
- (void) setRsa:(RSA *)rsa
{
    if (hasRSA_)
        RSA_free(rsa_);
    
    rsa_ = rsa;
    hasRSA_ = (rsa != NULL);
}

-(BOOL) prepareRsaWithKeyFile:(NSString*) keyFile
{
    NSString * path = keyFile;
    FILE * publicKeyFile = fopen(path.UTF8String, "r");
    if (publicKeyFile == NULL)
        return NO;
    
    self.rsa = ::PEM_read_RSA_PUBKEY(publicKeyFile, 0, 0, 0);
    fclose(publicKeyFile);
    
    return self.rsa != NULL;
}

-(DSA *) prepareDsaWithKeyFile:(NSString*) keyFile
{
    NSString * path = keyFile;
    FILE * privateKeyFile = fopen(path.UTF8String, "r");
    if (privateKeyFile == NULL)
        return NO;
    
    DSA * dsa = ::PEM_read_DSAPrivateKey(privateKeyFile, 0, 0, 0);
    fclose(privateKeyFile);
    
    return dsa;
}

-(DSA *) prepareDsaWithPrivateKey:(NSData *)privateKey
{
    unsigned char const * p = (unsigned char const *) privateKey.bytes;
    return d2i_DSAPrivateKey(NULL, &p, privateKey.length);
}

-(BOOL) generateDsaPrivateKey:(NSData **)privateKey 
                 andPublicKey:(NSData **)publicKey 
                     withBits:(NSInteger)bits 
                    toPEMFile:(NSString *)pemFile
{
    DSA * dsa = DSA_generate_parameters(bits,NULL,0,NULL,NULL,NULL,NULL);
    if (!dsa)
        return NO;
    
    if (!DSA_generate_key(dsa))
    {
        DSA_free(dsa);
        return NO;
    }

    int len;
    unsigned char * buf = NULL;
    
    len = ::i2d_DSAPrivateKey(dsa, &buf);
    NSData * pri_data = [NSData dataWithBytes:buf length:len];
    *privateKey = [pri_data copy];
    
    free(buf);
    buf = NULL;
    
    len = ::i2d_DSAPublicKey(dsa, &buf);
    NSData * pub_data = [NSData dataWithBytes:buf length:len];
    *publicKey = [pub_data copy];
    
    free(buf);
    buf = NULL;
    
    NSString * path = pemFile;
    FILE * fp = fopen(path.UTF8String, "w+");
    PEM_write_DSA_PUBKEY(fp, dsa);
    fclose(fp);
    
    DSA_free(dsa);
    return YES;
}

-(void) dealloc
{
    self.rsa = NULL;
}

-(NSData *) rsa_encryptData: (NSData*) data
{
    unsigned char * outbuf = (unsigned char *) calloc(RSA_size(self.rsa), 1);
    bzero(outbuf, RSA_size(self.rsa));
    
    int len = ::RSA_public_encrypt(data.length, (const unsigned char *) data.bytes, outbuf, self.rsa, RSA_PKCS1_OAEP_PADDING);

    NSData * res = [NSData dataWithBytes:outbuf length:len];
    free(outbuf);
    
    return res;
}

-(NSData *) sha1_hashData: (NSData*) data
{
    unsigned char md[SHA_DIGEST_LENGTH];
    bzero(md, SHA_DIGEST_LENGTH);

    ::SHA1((const unsigned char *) data.bytes, data.length, md);
    
    return [NSData dataWithBytes:md length:SHA_DIGEST_LENGTH];
}

-(NSData *) md5_hashData: (NSData *) data
{
    unsigned char md[MD5_DIGEST_LENGTH];
    bzero(md, MD5_DIGEST_LENGTH);
    
    ::MD5((const unsigned char *) data.bytes, data.length, md);
    
    return [NSData dataWithBytes:md length:MD5_DIGEST_LENGTH];
}

-(NSData *) des3_encrypt: (NSData *) data withKey:(NSString *)originalKey
{
    NSMutableData * key = [NSMutableData dataWithLength:MAX(originalKey.length, 24)];
    
    NSRange range;
    range.length = originalKey.length;
    range.location = 0;
    
    /// key has to be at least 24 bytes
    [key replaceBytesInRange:range withBytes:originalKey.UTF8String length:originalKey.length];
    
    NSString *initVec = @"init Vec";
    NSMutableData * res = [[NSMutableData alloc] initWithLength:data.length * 2];
    size_t movedBytes = 0;
    
    CCCrypt(kCCEncrypt, kCCAlgorithm3DES, kCCOptionPKCS7Padding,
            key.bytes, key.length, initVec.UTF8String, data.bytes, data.length, res.mutableBytes, res.length, &movedBytes);
   
    res.length = movedBytes;
    return [NSData dataWithData:res];
}

-(NSData *) des3_decrypt: (NSData *) data withKey:(NSString *)originalKey
{
    NSMutableData * key = [NSMutableData dataWithLength:MAX(originalKey.length, 24)];
    
    NSRange range;
    range.length = originalKey.length;
    range.location = 0;
    
    /// key has to be at least 24 bytes
    [key replaceBytesInRange:range withBytes:originalKey.UTF8String length:originalKey.length];
    
    NSString *initVec = @"init Vec";
    NSMutableData * res = [[NSMutableData alloc] initWithLength:data.length * 2];
    size_t movedBytes = 0;
    
    CCCrypt(kCCDecrypt, kCCAlgorithm3DES, kCCOptionPKCS7Padding,
            key.bytes, key.length, initVec.UTF8String, data.bytes, data.length, res.mutableBytes, res.length, &movedBytes);

    res.length = movedBytes;
    return [NSData dataWithData:res];
}

-(NSData *) dsa_signData: (NSData *) data 
{
    return [self dsa_signData:data privateKey:[self.delegate sslNeedsDsaPrivateKey:self]];
}

-(NSData *) dsa_signData: (NSData *) data privateKey:(NSData *)privateKey
{
    DSA * dsa = [self prepareDsaWithPrivateKey:privateKey];
    if (dsa)
    {
        unsigned char * sig = (unsigned char *) calloc(DSA_size(dsa), 1);
        unsigned int sig_len;
    
        bzero(sig, DSA_size(dsa));

        if (::DSA_sign(0, (const unsigned char *) data.bytes, data.length, sig, &sig_len, dsa) != 1)
        {
            free(sig);
            return nil;
        }
    
        NSData * res = [NSData dataWithBytes:sig length:sig_len];
        free(sig);
        DSA_free(dsa);
        
        return res;
    }
    
    return nil;
}

-(BOOL) dsa_verifyData: (NSData *) data withSignature:(NSData *)signature
{
    return [self dsa_verifyData:data withSignature:signature privateKey:[self.delegate sslNeedsDsaPrivateKey:self]];
}

-(BOOL) dsa_verifyData: (NSData *) data withSignature:(NSData *)signature privateKey:(NSData *)privateKey
{
    DSA * dsa = [self prepareDsaWithPrivateKey:privateKey];
    if (dsa)
    {
        BOOL res = ::DSA_verify(0, (const unsigned char *) data.bytes, 
                                data.length, (const unsigned char *) signature.bytes, 
                                signature.length, dsa) == 1;
        DSA_free(dsa);
        return res;
    } 
    return NO;
}


@end
























