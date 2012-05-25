//
//  PCOSTypes.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCOS.h"

@interface PCOSBaseType : NSObject<PCOSSerializable, NSCopying>
@property (readonly) NSUInteger size;
-(id) copyWithZone:(NSZone *)zone;
-(NSUInteger) encode:(PCOSRawData *)data;
-(NSUInteger) decode:(PCOSRawData *)data;
@end

@interface PCOSBasicType : PCOSBaseType
@end

@interface PCOSBool : PCOSBasicType
@property (nonatomic, assign) BOOL val;
-(id) initWithValue:(BOOL)value;
-(id) copyWithZone:(NSZone *)zone;
@end

@interface PCOSChar : PCOSBasicType
@property (nonatomic, assign) UTF8Char val;
-(id) initWithValue:(UTF8Char)value;
-(id) copyWithZone:(NSZone *)zone;
@end

@interface PCOSByte : PCOSBasicType
@property (nonatomic, assign) Byte val;
-(id) initWithValue:(Byte)value;
-(id) copyWithZone:(NSZone *)zone;
@end

@interface PCOSInt16 : PCOSBasicType
@property (nonatomic, assign) SInt16 val;
-(id) initWithValue:(SInt16)value;
-(id) copyWithZone:(NSZone *)zone;
@end

@interface PCOSInt32 : PCOSBasicType
@property (nonatomic, assign) SInt32 val;
-(id) initWithValue:(SInt32)value;
-(id) copyWithZone:(NSZone *)zone;
@end

@interface PCOSInt64 : PCOSBasicType
@property (nonatomic, assign) SInt64 val;
-(id) initWithValue:(SInt64)value;
-(id) copyWithZone:(NSZone *)zone;
@end

@interface PCOSDouble : PCOSBasicType
@property (nonatomic, assign) Float64 val;
-(id) initWithValue:(Float64)value;
-(id) copyWithZone:(NSZone *)zone;
@end

@interface PCOSCompositeType : PCOSBaseType
@property (nonatomic, strong) NSMutableArray * val;
@end

@interface PCOSBaseArray : PCOSCompositeType
@property (nonatomic, strong) PCOSBaseType * itemPrototype;
@property (getter = itemCount, setter = setItemCount:) NSUInteger itemCount;
-(id) initWithItemPrototype:(PCOSBaseType const *)type;
-(id) initWithItemPrototype:(PCOSBaseType const *)type andCount:(NSUInteger)count;
@end

@interface PCOSBasicArray : PCOSBaseArray
{
    NSMutableData * bytes_;
}
@property (getter = data, setter = setData:) NSData * data;
@property (getter = string, setter = setString:) NSString * string;

-(void) setData:(NSData *) data;
-(NSData *) data;

-(void) setString:(NSString *) str;
-(NSString *) string;

@end

@interface PCOSFixedArray : PCOSBasicArray
-(id) copyWithZone:(NSZone *)zone;
@end

@interface PCOSShortArray : PCOSBasicArray
-(id) copyWithZone:(NSZone *)zone;
@end

@interface PCOSLongArray : PCOSBasicArray
-(id) copyWithZone:(NSZone *)zone;
@end

@interface PCOSBlock : PCOSCompositeType
@property (nonatomic, strong) NSMutableDictionary * lookup;
-(id) copyWithZone:(NSZone *)zone;
-(void) addField:(PCOSBaseType *)field withName:(NSString*) name;
@end

@interface PCOSEncryptedBlock : PCOSBlock
-(NSUInteger) encode:(PCOSRawData *)data;
-(NSUInteger) decode:(PCOSRawData *)data;
@end


@interface PCOSDataBlock : PCOSBaseType
@property (nonatomic, strong) NSData * data;
-(id) initWithData:(NSData *)data;
-(NSUInteger) encode:(PCOSRawData *)data;
-(NSUInteger) decode:(PCOSRawData *)data;
@end

