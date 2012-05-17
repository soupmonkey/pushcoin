//
//  PCOSMessage.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCOSMessage.h"

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

-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSBlockMetaBlock alloc] init];
}

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
    NSUInteger offset;
    for(int i = 0; i < self.block_meta.val.count; ++i)
    {
        key = [[self.block_meta.val objectAtIndex:i] block_id].string;
        block = [blocks valueForKey:key];
        offset = data.offset;
        
        total += (len = [block encode:data]);
        [[self.block_meta.val objectAtIndex:i] block_length].val = len;
        
        [self block:block withKey:key encodedToBytes:((char *) data.data.bytes + offset) withLength:len];
    }
    
    // Encode block meta
    [self.block_meta encode:copy];
    
    return total;
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    NSUInteger total = 0;
    total = [self.block_meta decode:data];
    
    for (int i = 0; i < self.block_meta.itemCount; ++i)
    {
        PCOSBlockMetaBlock * block = [self.block_meta.val objectAtIndex:i];
        NSString * key = block.block_id.string;
                                                            
        NSObject<PCOSSerializable> * type = [blocks valueForKey:key];
        NSMutableData * block_data = [[NSMutableData alloc] init];
        if (type != nil)
        {
            // Prepare block_data
            [block_data setLength:block.block_length.val];
            [data readData:block_data length:block.block_length.val];
            
            PCOSRawData * raw = [[PCOSRawData alloc] initWithData:block_data offset:0];
            [type decode:raw];
        }
        total += block.block_length.val;
    }
    return total;
}
@end
