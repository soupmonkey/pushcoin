//
//  PCOSMessages.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCOSMessage.h"
#import "PCOSParser.h"
#import "PushCoinConfig.h"

extern NSString * const MID_ERROR;
extern NSString * const MID_PING;
extern NSString * const MID_PONG;
extern NSString * const MID_REGISTER;
extern NSString * const MID_REGISTER_ACK;
extern NSString * const MID_PAYMENT_TRANSFER_AUTHORIZATION;



/* Error Message */
@interface ErrorMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSInt32 * error_code;
@property (nonatomic, strong) PCOSShortArray * error_reason;
@end

@interface ErrorMessage : PCOSMessage
@property (nonatomic, strong) ErrorMessageBlock * error_block;
@end


/* Ping Message */
@interface PingMessage : PCOSMessage
@end

/* Pong Message */
@interface PongMessage : PCOSMessage
@property (nonatomic, strong) PCOSInt64 * tm;
@end

/* Register Message */
@interface RegisterMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSShortArray * registration_id;
@property (nonatomic, strong) PCOSLongArray * public_key;
@property (nonatomic, strong) PCOSShortArray * user_agent;
@end

@interface RegisterMessage : PCOSMessage
@property (nonatomic, strong) RegisterMessageBlock * register_block;
@end

/* Register Ack Message */
@interface RegisterAckMessage : PCOSMessage
@property (nonatomic, strong) PCOSFixedArray * auth_token;
@end


/* Payment Transfer Authorization Message */
@interface PaymentTransferAuthorizationPrivateBlock : PCOSBlock
@property (nonatomic, strong) PCOSShortArray * mat;
@property (nonatomic, strong) PCOSShortArray * sig;
@property (nonatomic, strong) PCOSShortArray * ref;
@end

@interface PaymentTransferAuthorizationPublicBlock : PCOSBlock
@property (nonatomic, strong) PCOSInt64 * ct;
@property (nonatomic, strong) PCOSInt64 * ep;
@property (nonatomic, strong) PCOSShortArray * amt;
@property (nonatomic, strong) PCOSFixedArray * cur;
@property (nonatomic, strong) PCOSShortArray * rcv;
@property (nonatomic, strong) PCOSShortArray * note;
@end


@interface PaymentTransferAuthorizationMessage : PCOSMessage
@property (nonatomic, strong) PCOSShortArray * keyid;
@property (nonatomic, strong) PaymentTransferAuthorizationPrivateBlock * prv_block;
@property (nonatomic, strong) PaymentTransferAuthorizationPublicBlock * pub_block;
@end

/* PushCoinMessageParser */
@class PushCoinMessageParser;
@protocol PushCoinMessageReceiver <NSObject>

-(void) didDecodeErrorMessage:(ErrorMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePingMessage:(PingMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePongMessage:(PongMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeRegisterMessage:(RegisterMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeRegisterAckMessage:(RegisterAckMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePaymentTransferAuthorizationMessage:(PaymentTransferAuthorizationMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeUnknownMessage:(PCOSMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;

@end

@interface PushCoinMessageParser : PCOSParser
{
    NSDictionary * selectors;
}
-(NSUInteger) decode:(NSData *)data toReceiver:(NSObject<PushCoinMessageReceiver> *)recv;
@end