//
//  PCOSMessage.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCOS.h"
#import "PCOSTypes.h"

extern const PCOSByte   * protoByte;
extern const PCOSBool   * protoBool;
extern const PCOSChar   * protoChar;
extern const PCOSInt16  * protoInt16;
extern const PCOSInt32  * protoInt32;
extern const PCOSInt64  * protoInt64;
extern const PCOSDouble * protoDouble;

@interface PCOSHeaderBlock : PCOSBlock
@property (nonatomic, strong) PCOSFixedArray * magic;
@property (nonatomic, strong) PCOSInt32 * message_length;
@property (nonatomic, strong) PCOSFixedArray * message_id;
@property (nonatomic, strong) PCOSFixedArray * reserved;
@end

@interface PCOSBlockMetaBlock : PCOSBlock
@property (nonatomic, strong) PCOSFixedArray * block_id;
@property (nonatomic, strong) PCOSInt16 * block_length;
@end




@interface PCOSMessage : NSObject<PCOSSerializable, NSCopying>
@property (nonatomic, strong) PCOSLongArray * block_meta;
@property (nonatomic, strong) NSMutableDictionary * blocks;

+(NSString *) messageID;

-(id) copyWithZone:(NSZone *)zone;
-(void) addBlock:(NSObject<PCOSSerializable> *)block withName:(NSString *)name;
-(void) block:(NSObject<PCOSSerializable> *)block withKey:(NSString *)key encodedToBytes:(void const *)bytes withLength:(NSUInteger)len;

@end
