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
extern NSString * const MID_SUCCESS;
extern NSString * const MID_PING;
extern NSString * const MID_PONG;
extern NSString * const MID_REGISTER;
extern NSString * const MID_REGISTER_ACK;
extern NSString * const MID_PAYMENT_TRANSFER_AUTHORIZATION;
extern NSString * const MID_PREAUTHORIZATION_REQUEST;

/* Common Types */
@interface Amount : PCOSBlock
@property (nonatomic, strong) PCOSInt64 * value;
@property (nonatomic, strong) PCOSInt16 * scale;
@end


/* Error Message */
@interface ErrorMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSInt32 * error_code;
@property (nonatomic, strong) PCOSShortArray * reason;
@property (nonatomic, strong) PCOSShortArray * user_data;
@end

@interface ErrorMessage : PCOSMessage
@property (nonatomic, strong) ErrorMessageBlock * error_block;
@end

/* Success Message */
@interface SuccessMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSShortArray * user_data;
@end

@interface SuccessMessage : PCOSMessage
@property (nonatomic, strong) SuccessMessageBlock * success_block;
@end

/* Ping Message */
@interface PingMessage : PCOSMessage
@end

/* Pong Message */
@interface PongMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSInt64 * tm;
@end

@interface PongMessage : PCOSMessage
@property (nonatomic, strong) PongMessageBlock * pong_block;
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
@interface RegisterAckMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSFixedArray * mat;
@end

@interface RegisterAckMessage : PCOSMessage
@property (nonatomic, strong) RegisterAckMessageBlock * register_ack_block;
@end


/* Payment Transfer Authorization Message */
@interface PaymentTransferAuthorizationPrivateBlockV1 : PCOSEncryptedBlock
@property (nonatomic, strong) PCOSFixedArray * mat;
@property (nonatomic, strong) PCOSShortArray * signature;
@property (nonatomic, strong) PCOSShortArray * user_data;
@end


@interface PaymentTransferAuthorizationPublicBlockV1 : PCOSBlock
@property (nonatomic, strong) PCOSInt64 * utc_ctime;
@property (nonatomic, strong) PCOSInt64 * utc_etime;
@property (nonatomic, strong) Amount * payment_limit;
@property (nonatomic, strong) PCOSFixedArray * currency;
@property (nonatomic, strong) PCOSFixedArray * keyid;
@property (nonatomic, strong) PCOSShortArray * receiver;
@property (nonatomic, strong) PCOSShortArray * note;
@end


@interface PaymentTransferAuthorizationMessage : PCOSMessage
@property (nonatomic, strong) PaymentTransferAuthorizationPrivateBlockV1 * prv_block;
@property (nonatomic, strong) PaymentTransferAuthorizationPublicBlockV1 * pub_block;
@end


/* Preauthorization Request Message */
@interface PreauthorizationRequestMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSFixedArray * mat;
@property (nonatomic, strong) Amount * preauthorization_amount;
@property (nonatomic, strong) PCOSFixedArray * currency;
@property (nonatomic, strong) PCOSShortArray * user_data;
@end

@interface PreauthorizationRequestMessage : PCOSMessage
@property (nonatomic, strong) PreauthorizationRequestMessageBlock * preauthorization_block;
@property (nonatomic, strong) PCOSDataBlock * payment_transfer_authorization_block;
@end


/* PushCoinMessageParser */
@class PushCoinMessageParser;
@protocol PushCoinMessageReceiver <NSObject>

-(void) didDecodeErrorMessage:(ErrorMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeSuccessMessage:(SuccessMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePingMessage:(PingMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePongMessage:(PongMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeRegisterMessage:(RegisterMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeRegisterAckMessage:(RegisterAckMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePaymentTransferAuthorizationMessage:(PaymentTransferAuthorizationMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePreauthorizationRequestMessage:(PreauthorizationRequestMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeUnknownMessage:(PCOSMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;

@end

@interface PushCoinMessageParser : PCOSParser
{
    NSDictionary * selectors;
}
-(NSUInteger) decode:(NSData *)data toReceiver:(NSObject<PushCoinMessageReceiver> *)recv;
@end