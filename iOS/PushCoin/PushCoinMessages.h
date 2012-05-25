//
//  PCOSMessages.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCOSMessage.h"
#import "PCOSParser.h"
#import "PushCoinConfig.h"

extern NSString * const MID_ERROR;
extern NSString * const MID_SUCCESS;
extern NSString * const MID_POLL;
extern NSString * const MID_PENDING;
extern NSString * const MID_PING;
extern NSString * const MID_PONG;
extern NSString * const MID_TRANSACTION_HISTORY_QUERY;
extern NSString * const MID_TRANSACTION_HISTORY_REPORT;
extern NSString * const MID_BALANCE_QUERY;
extern NSString * const MID_BALANCE_REPORT;
extern NSString * const MID_REGISTER;
extern NSString * const MID_REGISTER_ACK;
extern NSString * const MID_PAYMENT_TRANSFER_AUTHORIZATION;
extern NSString * const MID_TRANSFER_REQUEST;
extern NSString * const MID_PREAUTHORIZATION_REQUEST;

/* Common Types */
@interface Amount : PCOSBlock
@property (nonatomic, strong) PCOSInt64 * value;
@property (nonatomic, strong) PCOSInt16 * scale;
@end

@interface Gratuity : PCOSBlock
@property (nonatomic, strong) PCOSChar * type;
@property (nonatomic, strong) Amount * add;
@end

@interface Transaction : PCOSBlock
@property (nonatomic, strong) PCOSShortArray * transaction_id;
@property (nonatomic, strong) PCOSChar * tx_type;
@property (nonatomic, strong) Amount * amount;
@property (nonatomic, strong) PCOSFixedArray * currency;
@property (nonatomic, strong) PCOSShortArray * merchant_name;
@property (nonatomic, strong) PCOSShortArray * merchant_account;
@property (nonatomic, strong) PCOSShortArray * pta_receiver;
@property (nonatomic, strong) PCOSShortArray * pta_ref_data;
@property (nonatomic, strong) PCOSShortArray * invoice;
@end

/* Error Message */
@interface ErrorMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSShortArray * ref_data;
@property (nonatomic, strong) PCOSShortArray * transaction_id;
@property (nonatomic, strong) PCOSInt32 * error_code;
@property (nonatomic, strong) PCOSShortArray * reason;
@end

@interface ErrorMessage : PCOSMessage
@property (nonatomic, strong) ErrorMessageBlock * block;
@end

/* Success Message */
@interface SuccessMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSShortArray * ref_data;
@property (nonatomic, strong) PCOSShortArray * transaction_id;
@end

@interface SuccessMessage : PCOSMessage
@property (nonatomic, strong) SuccessMessageBlock * block;
@end

/* Poll Message */
@interface PollMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSShortArray * ref_data;
@end

@interface PollMessage : PCOSMessage
@property (nonatomic, strong) PollMessageBlock * block;
@end

/* Pending Message */
@interface PendingMessage : PCOSMessage
@end

/* Ping Message */
@interface PingMessage : PCOSMessage
@end

/* Pong Message */
@interface PongMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSInt64 * tm;
@end

@interface PongMessage : PCOSMessage
@property (nonatomic, strong) PongMessageBlock * block;
@end

/* Transaction History Query Message */
@interface TransactionHistoryQueryMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSFixedArray * mat;
@property (nonatomic, strong) PCOSShortArray * ref_data;
@property (nonatomic, strong) PCOSShortArray * keywords;
@property (nonatomic, strong) PCOSInt16 * page;
@property (nonatomic, strong) PCOSInt16 * page_size_hint;
@end

@interface TransactionHistoryQueryMessage : PCOSMessage
@property (nonatomic, strong) TransactionHistoryQueryMessageBlock * block;
@end

/* Transaction History Report Message */
@interface TransactionHistoryReportMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSShortArray * ref_data;
@property (nonatomic, strong) PCOSLongArray * tx_seq;
@end

@interface TransactionHistoryReportMessage : PCOSMessage
@property (nonatomic, strong) TransactionHistoryReportMessageBlock * block;
@end

/* Balance Query Message */
@interface BalanceQueryMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSFixedArray * mat;
@property (nonatomic, strong) PCOSShortArray * ref_data;
@end

@interface BalanceQueryMessage : PCOSMessage
@property (nonatomic, strong) BalanceQueryMessageBlock * block;
@end

/* Balance Report Message */
@interface BalanceReportMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSShortArray * ref_data;
@property (nonatomic, strong) Amount * balance;
@property (nonatomic, strong) PCOSInt64 * utc_balance_time;
@end

@interface BalanceReportMessage : PCOSMessage
@property (nonatomic, strong) BalanceReportMessageBlock * block;
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
@property (nonatomic, strong) PCOSShortArray * ref_data;
@property (nonatomic, strong) PCOSShortArray * signature;
@end


@interface PaymentTransferAuthorizationPublicBlockV1 : PCOSBlock
@property (nonatomic, strong) PCOSInt64 * utc_ctime;
@property (nonatomic, strong) PCOSInt64 * utc_etime;
@property (nonatomic, strong) Amount * payment_limit;
@property (nonatomic, strong) PCOSShortArray * tip;
@property (nonatomic, strong) PCOSFixedArray * currency;
@property (nonatomic, strong) PCOSFixedArray * keyid;
@property (nonatomic, strong) PCOSShortArray * receiver;
@property (nonatomic, strong) PCOSShortArray * note;
@end


@interface PaymentTransferAuthorizationMessage : PCOSMessage
@property (nonatomic, strong) PaymentTransferAuthorizationPrivateBlockV1 * prv_block;
@property (nonatomic, strong) PaymentTransferAuthorizationPublicBlockV1 * pub_block;
@end


/* Transfer Request Message */
@interface TransferRequestMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSFixedArray * mat;
@property (nonatomic, strong) PCOSShortArray * ref_data;
@property (nonatomic, strong) PCOSInt64 * utc_ctime;
@property (nonatomic, strong) Amount * transfer;
@property (nonatomic, strong) PCOSFixedArray * currency;
@property (nonatomic, strong) PCOSShortArray * note;
@end

@interface TransferRequestMessage : PCOSMessage
@property (nonatomic, strong) TransferRequestMessageBlock * block;
@property (nonatomic, strong) PCOSDataBlock * pta_block;
@end



/* Preauthorization Request Message */
@interface PreauthorizationRequestMessageBlock : PCOSBlock
@property (nonatomic, strong) PCOSFixedArray * mat;
@property (nonatomic, strong) PCOSShortArray * ref_data;
@property (nonatomic, strong) Amount * preauthorization_amount;
@property (nonatomic, strong) PCOSFixedArray * currency;
@end

@interface PreauthorizationRequestMessage : PCOSMessage
@property (nonatomic, strong) PreauthorizationRequestMessageBlock * block;
@property (nonatomic, strong) PCOSDataBlock * pta_block;
@end


/* PushCoinMessageParser */
@class PushCoinMessageParser;
@protocol PushCoinMessageReceiver <NSObject>

@required
-(void) didDecodeErrorMessage:(ErrorMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeUnknownMessage:(PCOSMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;

@optional
-(void) didDecodeSuccessMessage:(SuccessMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePollMessage:(PollMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePendingMessage:(PendingMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePingMessage:(PingMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePongMessage:(PongMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeTransactionHistoryQueryMessage:(TransactionHistoryQueryMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeTransactionHistoryReportMessage:(TransactionHistoryReportMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeBalanceQueryMessage:(BalanceQueryMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeBalanceReportMessage:(BalanceReportMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeRegisterMessage:(RegisterMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeRegisterAckMessage:(RegisterAckMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePaymentTransferAuthorizationMessage:(PaymentTransferAuthorizationMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodeTransferRequestMessage:(TransferRequestMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;
-(void) didDecodePreauthorizationRequestMessage:(PreauthorizationRequestMessage *)msg withHeader:(PCOSHeaderBlock*)hdr;

@end

@interface PushCoinMessageParser : PCOSParser
{
    NSDictionary * selectors;
}
-(NSUInteger) decode:(NSData *)data toReceiver:(NSObject<PushCoinMessageReceiver> *)recv;
@end