//
//  PCOSMessages.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PushCoinMessages.h"
#import "OpenSSLWrapper.h"

NSString * const MID_ERROR = @"Er";
NSString * const MID_PING = @"Pi";
NSString * const MID_PONG = @"Po";
NSString * const MID_REGISTER = @"Re";
NSString * const MID_REGISTER_ACK = @"Ac";
NSString * const MID_PAYMENT_TRANSFER_AUTHORIZATION = @"Pa";


/* Error Message */
@implementation ErrorMessageBlock
@synthesize error_code;
@synthesize error_reason;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.error_code = [[PCOSInt32 alloc] init];
        self.error_reason =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        
        [self addField:self.error_code withName:@"error_code"];
        [self addField:self.error_reason withName:@"error_reason"];
    }
    return self;
}
@end

@implementation ErrorMessage
@synthesize error_block;
+(NSString*) messageID { return MID_ERROR; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(error_block = [[ErrorMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end

/* Ping Message */
@implementation PingMessage
+(NSString*) messageID { return MID_PING; }
-(id) init { return [super init]; }
@end

/* Pong Message */
@implementation PongMessage
@synthesize tm;
+(NSString*) messageID { return MID_PONG; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(tm = [[PCOSInt64 alloc] init]) withName:@"Tm"];
    return self;
}
@end

/* Register Message */
@implementation RegisterMessageBlock
@synthesize registration_id;
@synthesize public_key;
@synthesize user_agent;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.registration_id =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        self.public_key =[[PCOSLongArray alloc] initWithItemPrototype:protoByte]; 
        self.user_agent =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        
        [self addField:self.registration_id withName:@"registration_id"];
        [self addField:self.public_key withName:@"public_key"];
        [self addField:self.user_agent withName:@"user_agent"];
    }
    return self;
}
@end

@implementation RegisterMessage
@synthesize register_block;
+(NSString*) messageID { return MID_REGISTER; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(register_block = [[RegisterMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end

/* Register Ack Message */
@implementation RegisterAckMessage
@synthesize auth_token;
+(NSString*) messageID { return MID_REGISTER_ACK; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(auth_token = [[PCOSFixedArray alloc] initWithItemPrototype:protoByte andCount:20]) withName:@"auth_token"];
    return self;
}
@end


/* Payment Transfer Authorization Message */
@implementation PaymentTransferAuthorizationPrivateBlock
@synthesize mat;
@synthesize sig;
@synthesize ref;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.mat =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.sig =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.ref =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        
        [self addField:self.mat withName:@"mat"];
        [self addField:self.sig withName:@"sig"];
        [self addField:self.ref withName:@"ref"];
    }
    return self;
}
@end

@implementation PaymentTransferAuthorizationPublicBlock
@synthesize ct;
@synthesize ep;
@synthesize amt;
@synthesize cur;
@synthesize rcv;
@synthesize note;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.ct =[[PCOSInt64 alloc] init]; 
        self.ep =[[PCOSInt64 alloc] init]; 
        self.amt =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        self.cur =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:3]; 
        self.rcv =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        self.note =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        
        [self addField:self.ct withName:@"ct"];
        [self addField:self.ep withName:@"ep"];
        [self addField:self.amt withName:@"amt"];
        [self addField:self.cur withName:@"cur"];
        [self addField:self.rcv withName:@"rcv"];
        [self addField:self.note withName:@"note"];

    }
    return self;
}
@end

@implementation PaymentTransferAuthorizationMessage
@synthesize keyid;
@synthesize prv_block;
@synthesize pub_block;

+(NSString*) messageID { return MID_PAYMENT_TRANSFER_AUTHORIZATION; }
-(id) init
{
    self = [super init];
    if (self)
    {   
        [self addBlock:(keyid = [[PCOSShortArray alloc] initWithItemPrototype:protoByte]) withName:@"ki"];
        [self addBlock:(prv_block = [[PaymentTransferAuthorizationPrivateBlock alloc] init]) withName:@"Pr"];
        [self addBlock:(pub_block = [[PaymentTransferAuthorizationPublicBlock alloc] init]) withName:@"Pb"];
    }
    return self;
}
@end


/* PushCoinMessageParser */

@implementation PushCoinMessageParser

-(id) init
{
    self = [super init];
    if (self)
    {
        [super registerMessageClass:[ErrorMessage class]];
        [super registerMessageClass:[PingMessage class]];
        [super registerMessageClass:[PongMessage class]];
        [super registerMessageClass:[RegisterMessage class]];
        [super registerMessageClass:[RegisterAckMessage class]];
        [super registerMessageClass:[PaymentTransferAuthorizationMessage class]];
        
        selectors = [NSDictionary dictionaryWithObjectsAndKeys:
                     NSStringFromSelector(@selector(didDecodeErrorMessage:withHeader:)), [ErrorMessage class],
                     NSStringFromSelector(@selector(didDecodePingMessage:withHeader:)), [PingMessage class],
                     NSStringFromSelector(@selector(didDecodePongMessage:withHeader:)), [PongMessage class],
                     NSStringFromSelector(@selector(didDecodeRegisterMessage:withHeader:)), [RegisterMessage class],
                     NSStringFromSelector(@selector(didDecodeRegisterAckMessage:withHeader:)), [RegisterAckMessage class],
                      NSStringFromSelector(@selector(didDecodePaymentTransferAuthorizationMessage:withHeader:)), [PaymentTransferAuthorizationMessage class],
                     nil];
    }
    return self;
}

-(NSUInteger) decode:(NSData *)data toReceiver:(NSObject<PushCoinMessageReceiver> *)recv
{
    PCOSRawData * dataIn = [[PCOSRawData alloc] initWithData:[data mutableCopy]];
    
    PCOSMessage * msgIn;
    PCOSHeaderBlock *hdrIn;
    
    NSUInteger size = [super decodeMessage:&msgIn andHeader:&hdrIn from:dataIn];
    NSString * selectorString = [selectors objectForKey:[msgIn class]];
    SEL selector = @selector(didDecodeUnknownMessage:withHeader:);
    
    if (selectorString != nil)
        selector = NSSelectorFromString(selectorString);
    
    if (recv != nil)
    {
        NSMethodSignature *signature = [[recv class] instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:recv];
        [invocation setArgument:&msgIn atIndex:2];
        [invocation setArgument:&hdrIn atIndex:3];
        [invocation invoke];
    }
    
    return size;
}


@end