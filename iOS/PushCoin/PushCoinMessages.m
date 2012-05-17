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
NSString * const MID_SUCCESS = @"Ok";
NSString * const MID_PING = @"Pi";
NSString * const MID_PONG = @"Po";
NSString * const MID_REGISTER = @"Re";
NSString * const MID_REGISTER_ACK = @"Ac";
NSString * const MID_PAYMENT_TRANSFER_AUTHORIZATION = @"Pa";
NSString * const MID_PREAUTHORIZATION_REQUEST = @"Pr";

/* Common Types */
@implementation Amount
@synthesize value;
@synthesize scale;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.value =[[PCOSInt64 alloc] init]; 
        self.scale =[[PCOSInt16 alloc] init]; 
        
        [self addField:self.value withName:@"value"];
        [self addField:self.scale withName:@"scale"];
    }
    return self;
}
@end


/* Error Message */
@implementation ErrorMessageBlock
@synthesize error_code;
@synthesize reason;
@synthesize user_data;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.error_code = [[PCOSInt32 alloc] init];
        self.reason =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        self.user_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        
        [self addField:self.error_code withName:@"error_code"];
        [self addField:self.reason withName:@"reason"];
        [self addField:self.user_data withName:@"user_data"];
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

/* Success Message */
@implementation SuccessMessageBlock
@synthesize user_data;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.user_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        [self addField:self.user_data withName:@"user_data"];
    }
    return self;
}
@end

@implementation SuccessMessage
@synthesize success_block;
+(NSString*) messageID { return MID_SUCCESS; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(success_block = [[SuccessMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end


/* Ping Message */
@implementation PingMessage
+(NSString*) messageID { return MID_PING; }
-(id) init { return [super init]; }
@end

/* Pong Message */
@implementation PongMessageBlock
@synthesize tm;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.tm =[[PCOSInt64 alloc] init]; 
        [self addField:self.tm withName:@"tm"];
    }
    return self;
}
@end

@implementation PongMessage
@synthesize pong_block;
+(NSString*) messageID { return MID_PONG; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(pong_block = [[PongMessageBlock alloc] init]) withName:@"Bo"];
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
@implementation RegisterAckMessageBlock
@synthesize mat;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.mat =[[PCOSFixedArray alloc] initWithItemPrototype:protoByte andCount:20]; 
        [self addField:self.mat withName:@"mat"];
    }
    return self;
}
@end
@implementation RegisterAckMessage
@synthesize register_ack_block;
+(NSString*) messageID { return MID_REGISTER_ACK; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(register_ack_block = [[RegisterAckMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end


/* Payment Transfer Authorization Message */
@implementation PaymentTransferAuthorizationPrivateBlockV1
@synthesize mat;
@synthesize signature;
@synthesize user_data;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.mat =[[PCOSFixedArray alloc] initWithItemPrototype:protoByte andCount:20]; 
        self.signature =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.user_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        
        [self addField:self.mat withName:@"mat"];
        [self addField:self.signature withName:@"signature"];
        [self addField:self.user_data withName:@"user_data"];
    }
    return self;
}
@end

@implementation PaymentTransferAuthorizationPublicBlockV1
@synthesize utc_ctime;
@synthesize utc_etime;
@synthesize payment_limit;
@synthesize currency;
@synthesize keyid;
@synthesize receiver;
@synthesize note;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.utc_ctime =[[PCOSInt64 alloc] init]; 
        self.utc_etime =[[PCOSInt64 alloc] init]; 
        self.payment_limit =[[Amount alloc] init]; 
        self.currency =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:3]; 
        self.keyid =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:4]; 
        self.receiver =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        self.note =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        
        [self addField:self.utc_ctime withName:@"utc_ctime"];
        [self addField:self.utc_etime withName:@"utc_etime"];
        [self addField:self.payment_limit withName:@"payment_limit"];
        [self addField:self.currency withName:@"currency"];
        [self addField:self.keyid withName:@"keyid"];
        [self addField:self.receiver withName:@"receiver"];
        [self addField:self.note withName:@"note"];
    }
    return self;
}
@end

@implementation PaymentTransferAuthorizationMessage
@synthesize prv_block;
@synthesize pub_block;

+(NSString*) messageID { return MID_PAYMENT_TRANSFER_AUTHORIZATION; }
-(id) init
{
    self = [super init];
    if (self)
    {  
        // Public first, handle the callback, and then Private
        [self addBlock:(pub_block = [[PaymentTransferAuthorizationPublicBlockV1 alloc] init]) withName:@"P1"];
        [self addBlock:(prv_block = [[PaymentTransferAuthorizationPrivateBlockV1 alloc] init]) withName:@"S1"];
    }
    return self;
}

-(void) block:(NSObject<PCOSSerializable> *)block withKey:(NSString *)key encodedToBytes:(void const *)bytes withLength:(NSUInteger)len;
{
    if ([key isEqualToString:@"P1"])
    {
        OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
        NSData * block_data = [NSData dataWithBytes:bytes length:len];
        NSData * block_hash = [ssl sha1_hashData:block_data];
        prv_block.signature.data = [ssl dsa_signData:block_hash];
    }
}
@end


/* Preauthorization Request Message */


@implementation PreauthorizationRequestMessageBlock
@synthesize mat;
@synthesize preauthorization_amount;
@synthesize currency;
@synthesize user_data;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.mat =[[PCOSFixedArray alloc] initWithItemPrototype:protoByte andCount:20]; 
        self.preauthorization_amount =[[Amount alloc] init]; 
        self.currency =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:3]; 
        self.user_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        
        [self addField:self.mat withName:@"mat"];
        [self addField:self.preauthorization_amount withName:@"preauthorization_amount"];
        [self addField:self.currency withName:@"currency"];
        [self addField:self.user_data withName:@"user_data"];
    }
    return self;
}
@end

@implementation PreauthorizationRequestMessage
@synthesize preauthorization_block;
@synthesize payment_transfer_authorization_block;

+(NSString*) messageID { return MID_PREAUTHORIZATION_REQUEST; }
-(id) init
{
    self = [super init];
    if (self)
    {  
        [self addBlock:(preauthorization_block = [[PreauthorizationRequestMessageBlock alloc] init]) withName:@"Pr"];
        [self addBlock:(payment_transfer_authorization_block = [[PCOSDataBlock alloc] init]) withName:@"Pa"];
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
        [super registerMessageClass:[SuccessMessage class]];
        [super registerMessageClass:[PingMessage class]];
        [super registerMessageClass:[PongMessage class]];
        [super registerMessageClass:[RegisterMessage class]];
        [super registerMessageClass:[RegisterAckMessage class]];
        [super registerMessageClass:[PaymentTransferAuthorizationMessage class]];
        [super registerMessageClass:[PreauthorizationRequestMessage class]];

        
        selectors = [NSDictionary dictionaryWithObjectsAndKeys:
                     NSStringFromSelector(@selector(didDecodeErrorMessage:withHeader:)), [ErrorMessage class],
                     NSStringFromSelector(@selector(didDecodeSuccessMessage:withHeader:)), [SuccessMessage class],
                     NSStringFromSelector(@selector(didDecodePingMessage:withHeader:)), [PingMessage class],
                     NSStringFromSelector(@selector(didDecodePongMessage:withHeader:)), [PongMessage class],
                     NSStringFromSelector(@selector(didDecodeRegisterMessage:withHeader:)), [RegisterMessage class],
                     NSStringFromSelector(@selector(didDecodeRegisterAckMessage:withHeader:)), [RegisterAckMessage class],
                     NSStringFromSelector(@selector(didDecodePaymentTransferAuthorizationMessage:withHeader:)), [PaymentTransferAuthorizationMessage class],
                     NSStringFromSelector(@selector(didDecodePreauthorizationRequestMessage:withHeader:)), [PreauthorizationRequestMessage class],
                     nil];
    }
    return self;
}

-(NSUInteger) decode:(NSData *)data toReceiver:(NSObject<PushCoinMessageReceiver> *)recv
{
    PCOSRawData * dataIn = [[PCOSRawData alloc] initWithData:[data mutableCopy]];
    NSUInteger size = 0;
    PCOSMessage * msgIn;
    PCOSHeaderBlock *hdrIn;
    
    while (size < data.length)
    {
        [super decodeMessage:&msgIn andHeader:&hdrIn from:dataIn];
        size += hdrIn.message_length.val;
        
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
    }
    return size;
}


@end