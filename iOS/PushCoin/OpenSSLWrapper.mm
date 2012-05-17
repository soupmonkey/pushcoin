//
//  OpenSSLWrapper.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OpenSSLWrapper.h"
#import "NSData+BytesToHexString.h"
#import "NSString+HexStringToBytes.h"


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
    if (self)
    {
        self.dsa = NULL;
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
- (DSA *) dsa
{ 
    return hasDSA_ ? dsa_ : NULL;
}
- (void) setDsa:(DSA *)dsa
{
    if (hasDSA_)
        DSA_free(dsa_);

    dsa_ = dsa;
    hasDSA_ = (dsa != NULL);
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

-(BOOL) prepareDsaWithKeyFile:(NSString*) keyFile
{
    NSString * path = keyFile;
    FILE * privateKeyFile = fopen(path.UTF8String, "r");
    if (privateKeyFile == NULL)
        return NO;
    
    self.dsa = ::PEM_read_DSAPrivateKey(privateKeyFile, 0, 0, 0);
    fclose(privateKeyFile);
    
    return self.dsa != NULL;
}



-(BOOL) prepareDsaWithPrivateKey:(NSString *)privateKey
{
    NSData * bytes = privateKey.hexStringToBytes;
    unsigned char const * p = (unsigned char const *) bytes.bytes;
    self.dsa = d2i_DSAPrivateKey(NULL, &p, bytes.length);
    return self.dsa != NULL;
}

-(BOOL) generateDsaPrivateKey:(NSString **)privateKey 
                 andPublicKey:(NSString**)publicKey 
                     withBits:(NSInteger)bits 
                    toPEMFile:(NSString *)pemFile
{
    self.dsa = DSA_generate_parameters(bits,NULL,0,NULL,NULL,NULL,NULL);
    if (!self.dsa)
        return NO;
    
    if (!DSA_generate_key(self.dsa))
    {
        self.dsa = NULL;
        return NO;
    }

    
     
    int len;
    unsigned char * buf = NULL;
    
    len = ::i2d_DSAPrivateKey(self.dsa, &buf);
    NSData * pri_data = [NSData dataWithBytes:buf length:len];
    *privateKey = [pri_data bytesToHexString];
    
    free(buf);
    buf = NULL;
    
    len = ::i2d_DSAPublicKey(self.dsa, &buf);
    NSData * pub_data = [NSData dataWithBytes:buf length:len];
    *publicKey = [pub_data bytesToHexString];
    
    free(buf);
    buf = NULL;
    
    NSString * path = pemFile;
    FILE * fp = fopen(path.UTF8String, "w+");
    PEM_write_DSA_PUBKEY(fp, self.dsa);
    fclose(fp);
    
    return self.dsa != NULL;
}

-(void) dealloc
{
    self.dsa = NULL;
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

-(NSData *) dsa_signData: (NSData *) data
{
    unsigned char * sig = (unsigned char *) calloc(DSA_size(self.dsa), 1);
    unsigned int sig_len;
    
    bzero(sig, DSA_size(self.dsa));

    if (::DSA_sign(0, (const unsigned char *) data.bytes, data.length, sig, &sig_len, self.dsa) != 1)
    {
        free(sig);
        return nil;
    }
    
    NSData * res = [NSData dataWithBytes:sig length:sig_len];
    free(sig);
    
    return res;
}


-(BOOL) dsa_verifyData: (NSData *) data withSignature:(NSData *)signature
{
    return ::DSA_verify(0, (const unsigned char *) data.bytes, data.length, (const unsigned char *) signature.bytes, signature.length, self.dsa) == 1;
}


@end
























