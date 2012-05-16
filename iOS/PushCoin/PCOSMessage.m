//
//  PCOSMessage.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCOSMessage.h"
#define METABLOCK_IS_NSCOPYING

const PCOSByte   * protoByte;
const PCOSBool   * protoBool;
const PCOSChar   * protoChar;
const PCOSInt16  * protoInt16;
const PCOSInt32  * protoInt32;
const PCOSInt64  * protoInt64;
const PCOSDouble * protoDouble;

@implementation PCOSHeaderBlock
@synthesize magic;
@synthesize message_length;
@synthesize message_id;
@synthesize reserved;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.magic = [[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:4];
        self.message_length = [[PCOSInt32 alloc] initWithValue:0];
        self.message_id =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:2]; 
        self.reserved =[[PCOSFixedArray alloc] initWithItemPrototype:protoByte andCount:6];   
        
        [self addField:self.magic withName:@"magic"];
        [self addField:self.message_length withName:@"message_length"];
        [self addField:self.message_id withName:@"message_id"];
        [self addField:self.reserved withName:@"reserved"];
    }
    return self;
    
}
@end

@implementation PCOSBlockMetaBlock
@synthesize block_id;
@synthesize block_length;

#ifdef METABLOCK_IS_NSCOPYING
-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSBlockMetaBlock alloc] init];
}
#endif

-(id) init
{
    self = [super init];
    if (self)
    {
        self.block_id = [[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:2];
        self.block_length = [[PCOSInt16 alloc] initWithValue:0];
        
        [self addField:self.block_id withName:@"block_id"];
        [self addField:self.block_length withName:@"block_length"];
    }
    return self;
    
}
@end


@implementation PCOSMessage
@synthesize block_meta;
@synthesize blocks;

+(void) initialize
{
    protoByte = [[PCOSByte alloc] init];
    protoBool = [[PCOSBool alloc] init];
    protoChar = [[PCOSChar alloc] init];
    protoInt16 = [[PCOSInt16 alloc] init];
    protoInt32 = [[PCOSInt32 alloc] init];
    protoInt64 = [[PCOSInt64 alloc] init];
    protoDouble = [[PCOSDouble alloc] init];
}

-(id) copyWithZone:(NSZone *)zone
{
    PCOSMessage * copy = [[PCOSMessage alloc] init];
    if (copy)
    {
        copy.block_meta = [self.block_meta copyWithZone:zone];
        copy.blocks = [self.blocks copyWithZone:zone];
    }
    return copy;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        self.block_meta = [[PCOSLongArray alloc] 
                           initWithItemPrototype:[[PCOSBlockMetaBlock alloc] init] 
                                        andCount:0];
        self.blocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(NSString*) messageID { return nil; }

-(void) addBlock:(NSObject<PCOSSerializable> *)block withName:(NSString *)name
{
    PCOSBlockMetaBlock * meta = [[PCOSBlockMetaBlock alloc] init];
    [meta.block_id setString:name];
    
    [self.block_meta.val addObject:meta];
    [self.blocks setObject:block 
                    forKey:name];
}

-(void) block:(NSObject<PCOSSerializable> *)block withKey:(NSString *)key encodedToBytes:(void const *)bytes withLength:(NSUInteger)len
{
    
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    // Skip block meta for now.
    PCOSRawData * copy = [data copy];
    NSUInteger hdr_len = self.block_meta.size;
    [data consume:hdr_len];
    
    // Encode Blocks
    NSUInteger total = hdr_len;
    NSUInteger len = 0;
    NSObject<PCOSSerializable> * block;
    NSString * key;
    void const * writeBytes;
    for(int i = 0; i < self.block_meta.val.count; ++i)
    {
        key = [[self.block_meta.val objectAtIndex:i] block_id].string;
        block = [blocks valueForKey:key];
        writeBytes = data.data.bytes;
        
        total += (len = [block encode:data]);
        [[self.block_meta.val objectAtIndex:i] block_length].val = len;
        
        [self block:block withKey:key encodedToBytes:writeBytes withLength:len];
    }
    
    // Encode block meta
    [self.block_meta encode:copy];
    
    return total;
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    NSUInteger total = 0;
    total += [self.block_meta decode:data];
    
    for (int i = 0; i < self.block_meta.itemCount; ++i)
    {
#ifdef METABLOCK_IS_NSCOPYING
        PCOSBlockMetaBlock * block = [self.block_meta.val objectAtIndex:i];
        NSString * key = [[block block_id] string];
#else
        PCOSBlock * block = [self.block_enum.val objectAtIndex:i];
        NSString * key = [[block.lookup valueForKey:@"block_id"] string];
#endif
        PCOSRawData * raw = [[PCOSRawData alloc] initWithData:
                             [NSMutableData dataWithBytes:(void *)data.data.bytes + total length:block.size]];
                                                            
        NSObject<PCOSSerializable> * type = [blocks valueForKey:key];
        if (type != nil)
            total += [(PCOSBaseType *)type decode:raw];
        else
            total += block.size;
    }
    return total;
}
@end

@implementation PCOSDataBlock
@synthesize data;

-(id) initWithData:(NSMutableData *)d
{
    self = [super self];
    if (self)
    {
        data = [d copy];
    }
    return self;
}

-(NSUInteger) encode:(PCOSRawData *)raw
{
    [raw writeBytes:self.data.bytes length:self.data.length];
    return self.data.length;
}

-(NSUInteger) decode:(PCOSRawData *)raw
{
    data = [self.data initWithBytes:(raw.data.bytes+raw.offset) length:raw.data.length];
    return raw.data.length;
}

@end
