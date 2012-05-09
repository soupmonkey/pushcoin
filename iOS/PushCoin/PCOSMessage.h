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
@property (nonatomic, strong) PCOSFixedArray * msg_id;
@property (nonatomic, strong) PCOSInt16 * msg_len;
@end

@interface PCOSBlockMetaBlock : PCOSBlock
@property (nonatomic, strong) PCOSFixedArray * block_name;
@property (nonatomic, strong) PCOSInt16 * block_len;
@end

@interface PCOSMessage : NSObject<PCOSSerializable, NSCopying>
@property (nonatomic, strong) PCOSLongArray * block_enum;
@property (nonatomic, strong) NSMutableDictionary * blocks;

+(NSString *) messageID;

-(id) copyWithZone:(NSZone *)zone;
-(void) addBlock:(NSObject<PCOSSerializable> *)block withName:(NSString *)name;
@end
