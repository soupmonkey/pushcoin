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
    FILE * publicKeyFile = fopen(keyFile.UTF8String, "r");
    if (publicKeyFile == NULL)
        return NO;
    
    self.rsa = PEM_read_RSAPublicKey(publicKeyFile, 0, 0, 0);
    fclose(publicKeyFile);
    
    return self.rsa != NULL;
}

-(BOOL) prepareRsaWithPublicKey:(NSString *)publicKey
{ 
    BIO *bio = BIO_new(BIO_s_mem()); //buffered IO
    BIO_write(bio, publicKey.UTF8String, publicKey.length);
    self.rsa = PEM_read_bio_RSAPublicKey(bio, 0, 0, 0);
    
    BIO_free_all(bio);
    return self.rsa != NULL;
}


-(BOOL) prepareRsaWithPrivateKey:(NSString *)privateKey
{ 
    BIO *bio = BIO_new(BIO_s_mem()); //buffered IO
    BIO_write(bio, privateKey.UTF8String, privateKey.length);
    self.rsa = PEM_read_bio_RSAPrivateKey(bio, 0, 0, 0);
    
    BIO_free_all(bio);
    return self.rsa != NULL;
}


-(BOOL) generateRsaPrivateKey:(NSString **)privateKey andPublicKey:(NSString **) publicKey withBits:(NSInteger) bits andExp:(NSInteger) exp
{
    int keylen;
    char *pri_key;
    char *pub_key;
    
    self.rsa = RSA_generate_key(bits, exp, 0, 0);
    BIO *bio = BIO_new(BIO_s_mem()); //buffered IO
    
    // Get Private Key
    PEM_write_bio_RSAPrivateKey(bio, self.rsa, NULL, NULL, 0, NULL, NULL);
    
    keylen = BIO_pending(bio);
    pri_key = (char *) calloc(keylen+1, 1); /* Null-terminate */
    BIO_read(bio, pri_key, keylen);
    
    *privateKey = [NSString stringWithCString:(char*)pri_key encoding:NSASCIIStringEncoding];
    (void) BIO_reset(bio);
    
    // Get Public Key
    PEM_write_bio_RSAPublicKey(bio, self.rsa);
    keylen = BIO_pending(bio);
    pub_key = (char *) calloc(keylen+1, 1);
    BIO_read(bio, pub_key, keylen);
    *publicKey = [NSString stringWithCString:(char*)pub_key encoding:NSASCIIStringEncoding];
    
    (void) BIO_reset(bio);    
    BIO_free_all(bio);

    free(pri_key);
    free(pub_key);
    
    return self.rsa != NULL;
}

-(BOOL) prepareDsaWithPublicKey:(NSString *)publicKey
{
    BIO *bio = BIO_new(BIO_s_mem());  
    BIO_write(bio, publicKey.UTF8String, publicKey.length);
    
    self.dsa = PEM_read_bio_DSA_PUBKEY(bio, 0, 0, 0);
    BIO_free_all(bio);
    
    return self.dsa != NULL;
}

-(BOOL) prepareDsaWithPrivateKey:(NSString *)privateKey
{
    BIO *bio = BIO_new(BIO_s_mem());  
    BIO_write(bio, privateKey.UTF8String, privateKey.length);
    
    self.dsa = PEM_read_bio_DSAPrivateKey(bio, 0, 0, 0);
    BIO_free_all(bio);
    
    return self.dsa != NULL;
}

-(BOOL) generateDsaPrivateKey:(NSString **)privateKey andPublicKey:(NSString**)publicKey withBits:(NSInteger)bits
{
    BIO *bio = BIO_new(BIO_s_mem());  
    self.dsa = DSA_generate_parameters(bits,NULL,0,NULL,NULL,NULL,NULL);
    if (!self.dsa)
        return NO;
    
    if (!DSA_generate_key(self.dsa))
    {
        self.dsa = NULL;
        return NO;
    }
    int len;
    char * buf;
    
    BN_print(bio, self.dsa->priv_key);
    len = BIO_pending(bio);
    buf = (char *) calloc(len+1, 1); /* Null-terminate */
    BIO_read(bio, buf, len);
    
    *privateKey = [NSString stringWithCString:(char*)buf encoding:NSASCIIStringEncoding];
    
    free(buf);
    (void) BIO_reset(bio);

    BN_print(bio, self.dsa->pub_key);
    len = BIO_pending(bio);
    buf = (char *) calloc(len+1, 1); /* Null-terminate */
    BIO_read(bio, buf, len);
    
    *publicKey = [NSString stringWithCString:(char*)buf encoding:NSASCIIStringEncoding];
    
    free(buf);
    (void) BIO_reset(bio);
    BIO_free_all(bio);
    
    return self.dsa != NULL;
}

-(void) dealloc
{
    self.dsa = NULL;
    self.rsa = NULL;
}

-(NSData *) rsa_encryptData: (NSData*) data toBytes:(NSData **)bytes
{
    unsigned char * outbuf = (unsigned char *) calloc(RSA_size(self.rsa), 1);
    bzero(outbuf, RSA_size(self.rsa));
    
    int len = RSA_public_encrypt(data.length, data.bytes, outbuf, self.rsa, RSA_PKCS1_PADDING);

    NSData * res = [NSData dataWithBytes:outbuf length:len];
    free(outbuf);
    
    return res;
}

-(NSData *) rsa_decryptData: (NSData *) data
{
    unsigned char * outbuf = (unsigned char *) calloc(RSA_size(self.rsa), 1);
    bzero(outbuf, RSA_size(self.rsa));
    
    int len = RSA_private_decrypt(data.length, data.bytes, outbuf, self.rsa, RSA_PKCS1_PADDING);
    
    NSData * res = [NSData dataWithBytes:outbuf length:len];
    free(outbuf);
    
    return res;
}

-(NSData *) sha1_hashData: (NSData*) data
{
    unsigned char md[SHA_DIGEST_LENGTH];
    bzero(md, SHA_DIGEST_LENGTH);

    SHA1(data.bytes, data.length, md);
    
    return [NSData dataWithBytes:md length:SHA_DIGEST_LENGTH];
}

-(NSData *) md5_hashData: (NSData *) data
{
    unsigned char md[MD5_DIGEST_LENGTH];
    bzero(md, MD5_DIGEST_LENGTH);
    
    MD5(data.bytes, data.length, md);
    
    return [NSData dataWithBytes:md length:MD5_DIGEST_LENGTH];
}

-(NSData *) dsa_signData: (NSData *) data
{
    unsigned char * sig = (unsigned char *) calloc(DSA_size(self.dsa), 1);
    unsigned int sig_len;
    
    bzero(sig, DSA_size(self.dsa));
    
    if (DSA_sign(0, data.bytes, data.length, sig, &sig_len, self.dsa) != 1)
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
    return DSA_verify(0, data.bytes, data.length, signature.bytes, signature.length, self.dsa) == 1;
}


@end
























