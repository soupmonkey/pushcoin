//
//  ThirdViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsController.h"
#import "Security/Security.h"
#import "KeychainWrapper.h"

#include <openssl/rsa.h>
#include <openssl/engine.h>
#include <openssl/pem.h>

#import "PushCoinMessages.pb.h"

@implementation SettingsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) test_keyChain
{
    // KeyChaiN test
    KeychainWrapper * wrapper = [[KeychainWrapper alloc] init];
    [wrapper setMyObject:@"PushCoin" forKey:(__bridge id)kSecAttrService];
    

    
    NSString * secret = [wrapper myObjectForKey:(__bridge id)kSecAttrService];
    [self alert:secret
      withTitle:@"KeyChain"];


}

-(void) test_rsa
{
    
    // RSA Key test
    const int kBits = 1024;
    const int kExp = 3;
    
    int keylen;
    char *pri_key;
    char *pub_key;
    
    RSA *rsa = RSA_generate_key(kBits, kExp, 0, 0);
    BIO *bio = BIO_new(BIO_s_mem()); //buffered IO
    
    // Get Private Key
    ::PEM_write_bio_RSAPrivateKey(bio, rsa, NULL, NULL, 0, NULL, NULL);
    
    keylen = BIO_pending(bio);
    pri_key = (char *) calloc(keylen+1, 1); /* Null-terminate */
    BIO_read(bio, pri_key, keylen);
    
    [self alert:[NSString stringWithCString:(char*)pri_key encoding:NSASCIIStringEncoding]
      withTitle:@"Private Key"];

    (void) BIO_reset(bio);
    
    // Get Public Key
    ::PEM_write_bio_RSAPublicKey(bio,rsa);
    keylen = BIO_pending(bio);
    pub_key = (char *) calloc(keylen+1, 1);
    BIO_read(bio, pub_key, keylen);
    [self alert:[NSString stringWithCString:(char*)pub_key encoding:NSASCIIStringEncoding]
      withTitle:@"Public Key"];
   
    
    (void) BIO_reset(bio);    
    RSA_free(rsa);
    
    // En/Decryption using the RSA key
    
    unsigned char cleartext[2560] = "TEST";
    unsigned char encrypted[2560] = "1234";
    unsigned char decrypted[2560] = "1234";
    
    ::bzero(encrypted,2560);
    ::bzero(decrypted,2560);
    
    // Read Public Key, Encrypt
    BIO_write(bio, pub_key, strlen(pub_key));
    RSA * encryptor = ::PEM_read_bio_RSAPublicKey(bio, 0, 0, 0);
    
    int len = ::RSA_public_encrypt(4 /*strlen*/, cleartext, encrypted, encryptor, RSA_PKCS1_PADDING);
    NSLog(@"encrypt returned %d", len);
    
    RSA_free(encryptor);
    (void) BIO_reset(bio);
    
    [self alert:[NSString stringWithCString:(char*)encrypted encoding:NSASCIIStringEncoding]
      withTitle:@"encryption"];
    
    // Read Private Key, decrypt
    BIO_write(bio, pri_key, strlen(pri_key));
    RSA * decryptor = ::PEM_read_bio_RSAPrivateKey(bio, 0, 0, 0);
    if (decryptor == 0)
        NSLog(@"decryptor null");
    
    ::RSA_private_decrypt(len, encrypted, decrypted, decryptor, RSA_PKCS1_PADDING);
    RSA_free(decryptor);
    
    [self alert:[NSString stringWithCString:(char*)decrypted encoding:NSASCIIStringEncoding]
      withTitle:@"decryption"];

    
    free(pub_key);
    free(pri_key);
    BIO_free_all(bio);

}

-(void) test_dsa
{
    // DSA Key test
    BIO *bio = BIO_new(BIO_s_mem()); //buffered IO
    DSA *dsa = NULL;
    unsigned char dgst[] = "etaonrishdlc";
    unsigned char sig[256];
    unsigned int siglen;
    
    dsa = DSA_generate_parameters(512,NULL,0,NULL,NULL,NULL,NULL);
    
    if (!dsa)
        return;
    if (!DSA_generate_key(dsa))
        return;
    if ( DSA_sign(0,dgst,sizeof(dgst) - 1,sig,&siglen,dsa) != 1 )
        return;
    if ( DSA_verify(0,dgst,sizeof(dgst) - 1,sig,siglen,dsa) != 1 )
        return;
    
    BN_print(bio, dsa->pub_key);
    int len = BIO_pending(bio);
    char * buf = (char *) calloc(len+1, 1); /* Null-terminate */
    BIO_read(bio, buf, len);
    
    [self alert:[NSString stringWithCString:(char*)buf encoding:NSASCIIStringEncoding]
      withTitle:@"DSA PubKey"];
    
    free(buf);
    (void) BIO_reset(bio);
    
    
    BN_print(bio, dsa->priv_key);
    len = BIO_pending(bio);
    buf = (char *) calloc(len+1, 1); /* Null-terminate */
    BIO_read(bio, buf, len);
    
    [self alert:[NSString stringWithCString:(char*)buf encoding:NSASCIIStringEncoding]
      withTitle:@"DSA PrivKey"];

    free(buf);
    (void) BIO_reset(bio);
    

    
    
    DSA_free(dsa);
    BIO_free_all(bio);

}


-(void) alert:(NSString *)string withTitle:(NSString *)title
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                       message:string
                                      delegate:nil 
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];        
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
