//
//  PCOSMessages.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import "PushCoinMessages.h"
#import "OpenSSLWrapper.h"

NSString * const MID_ERROR = @"Er";
NSString * const MID_SUCCESS = @"Ok";
NSString * const MID_POLL = @"Up";
NSString * const MID_PENDING = @"Pe";
NSString * const MID_PING = @"Pi";
NSString * const MID_PONG = @"Po";
NSString * const MID_TRANSACTION_HISTORY_QUERY = @"Hq";
NSString * const MID_TRANSACTION_HISTORY_REPORT = @"Hr";
NSString * const MID_BALANCE_QUERY = @"Bq";
NSString * const MID_BALANCE_REPORT = @"Br";
NSString * const MID_REGISTER = @"Re";
NSString * const MID_REGISTER_ACK = @"Ac";
NSString * const MID_PAYMENT_TRANSFER_AUTHORIZATION = @"Pa";
NSString * const MID_TRANSFER_REQUEST = @"Tt";
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

-(id) copyWithZone:(NSZone *)zone
{
    Amount * other = [[Amount alloc] init];
       return other;
}
@end


@implementation Gratuity
@synthesize type;
@synthesize add;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.type =[[PCOSChar alloc] init]; 
        self.add =[[Amount alloc] init]; 
        
        [self addField:self.type withName:@"type"];
        [self addField:self.add withName:@"add"];
    }
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    Gratuity * other = [[Gratuity alloc] init];
      return other;
}
@end


@implementation Transaction
@synthesize transaction_id;
@synthesize tx_type;
@synthesize amount;
@synthesize currency;
@synthesize merchant_name;
@synthesize merchant_account;
@synthesize pta_receiver;
@synthesize pta_ref_data;
@synthesize invoice;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.transaction_id =[[PCOSShortArray alloc] initWithItemPrototype:protoByte];
        self.tx_type =[[PCOSChar alloc] init]; 
        self.amount =[[Amount alloc] init]; 
        self.currency =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:3]; 
        self.merchant_name =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        self.merchant_account =[[PCOSShortArray alloc] initWithItemPrototype:protoChar];
        self.pta_receiver =[[PCOSShortArray alloc] initWithItemPrototype:protoChar];
        self.pta_ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte];
        self.invoice =[[PCOSShortArray alloc] initWithItemPrototype:protoChar];
        
        [self addField:self.transaction_id withName:@"transaction_id"];
        [self addField:self.tx_type withName:@"tx_type"];
        [self addField:self.amount withName:@"amount"];
        [self addField:self.currency withName:@"currency"];
        [self addField:self.merchant_name withName:@"merchant_name"];
        [self addField:self.merchant_account withName:@"merchant_account"];
        [self addField:self.pta_receiver withName:@"pta_receiver"];
        [self addField:self.pta_ref_data withName:@"pta_ref_data"];
        [self addField:self.invoice withName:@"invoice"];
    }
    return self;
}


-(id) copyWithZone:(NSZone *)zone
{
    Transaction * other = [[Transaction alloc] init];
    return other;
}

@end



/* Error Message */
@implementation ErrorMessageBlock
@synthesize ref_data;
@synthesize transaction_id;
@synthesize error_code;
@synthesize reason;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.transaction_id =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.error_code = [[PCOSInt32 alloc] init];
        self.reason =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 

        [self addField:self.ref_data withName:@"ref_data"];
        [self addField:self.transaction_id withName:@"transaction_id"];
        [self addField:self.error_code withName:@"error_code"];
        [self addField:self.reason withName:@"reason"];

    }
    return self;
}
@end

@implementation ErrorMessage
@synthesize block;
+(NSString*) messageID { return MID_ERROR; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(block = [[ErrorMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end

/* Success Message */
@implementation SuccessMessageBlock
@synthesize ref_data;
@synthesize transaction_id;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.transaction_id =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 

        [self addField:self.ref_data withName:@"ref_data"];
        [self addField:self.transaction_id withName:@"transaction_id"];
    }
    return self;
}
@end

@implementation SuccessMessage
@synthesize block;
+(NSString*) messageID { return MID_SUCCESS; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(block = [[SuccessMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end

/* Poll Message */
@implementation PollMessageBlock
@synthesize ref_data;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        [self addField:self.ref_data withName:@"ref_data"];
    }
    return self;
}
@end

@implementation PollMessage
@synthesize block;
+(NSString*) messageID { return MID_POLL; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(block = [[PollMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end


/* Pending Message */
@implementation PendingMessage
+(NSString*) messageID { return MID_PENDING; }
-(id) init { return [super init]; }
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
@synthesize block;
+(NSString*) messageID { return MID_PONG; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(block = [[PongMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end


/* Transaction History Query Message */
@implementation TransactionHistoryQueryMessageBlock
@synthesize mat;
@synthesize ref_data;
@synthesize keywords;
@synthesize page;
@synthesize page_size_hint;


-(id) init
{
    self = [super init];
    if (self)
    {
        self.mat =[[PCOSFixedArray alloc] initWithItemPrototype:protoByte andCount:20];
        self.ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.keywords =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        self.page =[[PCOSInt16 alloc] init]; 
        self.page_size_hint =[[PCOSInt16 alloc] init]; 

        
        [self addField:self.mat withName:@"mat"];
        [self addField:self.ref_data withName:@"ref_data"];    
        [self addField:self.keywords withName:@"keywords"];  
        [self addField:self.page withName:@"page"];
        [self addField:self.page_size_hint withName:@"page_size_hint"];
    }
    return self;
}
@end

@implementation TransactionHistoryQueryMessage
@synthesize block;
+(NSString*) messageID { return MID_TRANSACTION_HISTORY_QUERY; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(block = [[TransactionHistoryQueryMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end


/* Transaction History Report Message */
@implementation TransactionHistoryReportMessageBlock
@synthesize ref_data;
@synthesize tx_seq;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.tx_seq =[[PCOSLongArray alloc] initWithItemPrototype:
                      [[Transaction alloc] init]];         
        
        [self addField:self.ref_data withName:@"ref_data"];    
        [self addField:self.tx_seq withName:@"tx_seq"];  
    }
    return self;
}
@end

@implementation TransactionHistoryReportMessage
@synthesize block;
+(NSString*) messageID { return MID_TRANSACTION_HISTORY_REPORT; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(block = [[TransactionHistoryReportMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end



/* Balance Query Message */
@implementation BalanceQueryMessageBlock
@synthesize mat;
@synthesize ref_data;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.mat =[[PCOSFixedArray alloc] initWithItemPrototype:protoByte andCount:20];
        self.ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        
        [self addField:self.mat withName:@"mat"];
        [self addField:self.ref_data withName:@"ref_data"];    
    }
    return self;
}
@end

@implementation BalanceQueryMessage
@synthesize block;
+(NSString*) messageID { return MID_BALANCE_QUERY; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(block = [[BalanceQueryMessageBlock alloc] init]) withName:@"Bo"];
    return self;
}
@end


/* Balance Report Message */
@implementation BalanceReportMessageBlock
@synthesize ref_data;
@synthesize balance;
@synthesize utc_balance_time;


-(id) init
{
    self = [super init];
    if (self)
    {
        self.ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.balance =[[Amount alloc] init];
        self.utc_balance_time =[[PCOSInt64 alloc] init];
        
        [self addField:self.ref_data withName:@"ref_data"];    
        [self addField:self.balance withName:@"balance"];
        [self addField:self.utc_balance_time withName:@"utc_balance_time"];
    }
    return self;
}
@end

@implementation BalanceReportMessage
@synthesize block;
+(NSString*) messageID { return MID_BALANCE_REPORT; }
-(id) init
{
    self = [super init];
    if (self)
        [self addBlock:(block = [[BalanceReportMessageBlock alloc] init]) withName:@"Bo"];
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
@synthesize ref_data;
@synthesize signature;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.mat =[[PCOSFixedArray alloc] initWithItemPrototype:protoByte andCount:20]; 
        self.ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.signature =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        
        [self addField:self.mat withName:@"mat"];
        [self addField:self.ref_data withName:@"ref_data"];
        [self addField:self.signature withName:@"signature"];
    }
    return self;
}
@end

@implementation PaymentTransferAuthorizationPublicBlockV1
@synthesize utc_ctime;
@synthesize utc_etime;
@synthesize payment_limit;
@synthesize tip;
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
        self.tip = [[PCOSShortArray alloc] initWithItemPrototype:[[Gratuity alloc] init]];
        self.currency =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:3]; 
        self.keyid =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:4]; 
        self.receiver =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        self.note =[[PCOSShortArray alloc] initWithItemPrototype:protoChar]; 
        
        [self addField:self.utc_ctime withName:@"utc_ctime"];
        [self addField:self.utc_etime withName:@"utc_etime"];
        [self addField:self.payment_limit withName:@"payment_limit"];
        [self addField:self.tip withName:@"tip"];
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


/* Transfer Request Message */
@implementation TransferRequestMessageBlock
@synthesize mat;
@synthesize ref_data;
@synthesize utc_ctime;
@synthesize transfer;
@synthesize currency;
@synthesize note;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.mat =[[PCOSFixedArray alloc] initWithItemPrototype:protoByte andCount:20]; 
        self.ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.utc_ctime =[[PCOSInt64 alloc] init]; 
        self.transfer =[[Amount alloc] init]; 
        self.currency =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:3]; 
        self.note =[[PCOSLongArray alloc] initWithItemPrototype:protoChar]; 

        [self addField:self.mat withName:@"mat"];
        [self addField:self.ref_data withName:@"ref_data"];
        [self addField:self.utc_ctime withName:@"utc_ctime"];
        [self addField:self.transfer withName:@"transfer"];
        [self addField:self.currency withName:@"currency"];     
        [self addField:self.note withName:@"note"];     
    }
    return self;
}
@end

@implementation TransferRequestMessage
@synthesize block;
@synthesize pta_block;

+(NSString*) messageID { return MID_TRANSFER_REQUEST; }
-(id) init
{
    self = [super init];
    if (self)
    {  
        [self addBlock:(block = [[TransferRequestMessageBlock alloc] init]) withName:@"R1"];
        [self addBlock:(pta_block = [[PCOSDataBlock alloc] init]) withName:@"Pa"];
    }
    return self;
}

@end

/* Preauthorization Request Message */
@implementation PreauthorizationRequestMessageBlock
@synthesize mat;
@synthesize ref_data;
@synthesize preauthorization_amount;
@synthesize currency;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.mat =[[PCOSFixedArray alloc] initWithItemPrototype:protoByte andCount:20]; 
        self.ref_data =[[PCOSShortArray alloc] initWithItemPrototype:protoByte]; 
        self.preauthorization_amount =[[Amount alloc] init]; 
        self.currency =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:3]; 
        
        [self addField:self.mat withName:@"mat"];
        [self addField:self.ref_data withName:@"ref_data"];
        [self addField:self.preauthorization_amount withName:@"preauthorization_amount"];
        [self addField:self.currency withName:@"currency"];     
    }
    return self;
}
@end

@implementation PreauthorizationRequestMessage
@synthesize block;
@synthesize pta_block;

+(NSString*) messageID { return MID_PREAUTHORIZATION_REQUEST; }
-(id) init
{
    self = [super init];
    if (self)
    {  
        [self addBlock:(block = [[PreauthorizationRequestMessageBlock alloc] init]) withName:@"Pr"];
        [self addBlock:(pta_block = [[PCOSDataBlock alloc] init]) withName:@"Pa"];
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
        [super registerMessageClass:[PollMessage class]];
        [super registerMessageClass:[PendingMessage class]];
        [super registerMessageClass:[PingMessage class]];
        [super registerMessageClass:[PongMessage class]];
        [super registerMessageClass:[TransactionHistoryQueryMessage class]];
        [super registerMessageClass:[TransactionHistoryReportMessage class]];
        [super registerMessageClass:[BalanceQueryMessage class]];
        [super registerMessageClass:[BalanceReportMessage class]];
        [super registerMessageClass:[RegisterMessage class]];
        [super registerMessageClass:[RegisterAckMessage class]];
        [super registerMessageClass:[PaymentTransferAuthorizationMessage class]];
        [super registerMessageClass:[TransferRequestMessage class]];
        [super registerMessageClass:[PreauthorizationRequestMessage class]];
        
        selectors = [NSDictionary dictionaryWithObjectsAndKeys:
                     NSStringFromSelector(@selector(didDecodeErrorMessage:withHeader:)), [ErrorMessage class],
                     NSStringFromSelector(@selector(didDecodeSuccessMessage:withHeader:)), [SuccessMessage class],
                     NSStringFromSelector(@selector(didDecodePollMessage:withHeader:)), [PollMessage class],
                     NSStringFromSelector(@selector(didDecodePendingMessage:withHeader:)), [PendingMessage class],
                     NSStringFromSelector(@selector(didDecodePingMessage:withHeader:)), [PingMessage class],
                     NSStringFromSelector(@selector(didDecodePongMessage:withHeader:)), [PongMessage class],
                     NSStringFromSelector(@selector(didDecodeTransactionHistoryQueryMessage:withHeader:)), [TransactionHistoryQueryMessage class],
                     NSStringFromSelector(@selector(didDecodeTransactionHistoryReportMessage:withHeader:)), [TransactionHistoryReportMessage class],
                     NSStringFromSelector(@selector(didDecodeBalanceQueryMessage:withHeader:)), [BalanceQueryMessage class],
                     NSStringFromSelector(@selector(didDecodeBalanceReportMessage:withHeader:)), [BalanceReportMessage class],
                     NSStringFromSelector(@selector(didDecodeRegisterMessage:withHeader:)), [RegisterMessage class],
                     NSStringFromSelector(@selector(didDecodeRegisterAckMessage:withHeader:)), [RegisterAckMessage class],
                     NSStringFromSelector(@selector(didDecodePaymentTransferAuthorizationMessage:withHeader:)), [PaymentTransferAuthorizationMessage class],
                     NSStringFromSelector(@selector(didDecodeTransferRequestMessage:withHeader:)), [TransferRequestMessage class],
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
        SEL unknownSelector = @selector(didDecodeUnknownMessage:withHeader:);
        SEL selector = unknownSelector;
    
        if (selectorString != nil)
            selector = NSSelectorFromString(selectorString);
    
        if (recv != nil)
        {
            if (![recv respondsToSelector:selector])
                selector = unknownSelector;
            
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