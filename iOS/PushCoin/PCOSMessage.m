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
@synthesize msg_id;
@synthesize msg_len;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.magic = [[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:4];
        self.msg_id =[[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:2]; 
        self.msg_len = [[PCOSInt16 alloc] initWithValue:0];
        
        [self addField:self.magic withName:@"magic"];
        [self addField:self.msg_id withName:@"msg_id"];
        [self addField:self.msg_len withName:@"msg_len"];
    }
    return self;
    
}
@end

@implementation PCOSBlockMetaBlock
@synthesize block_name;
@synthesize block_len;

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
        self.block_name = [[PCOSFixedArray alloc] initWithItemPrototype:protoChar andCount:2];
        self.block_len = [[PCOSInt16 alloc] initWithValue:0];
        
        [self addField:self.block_name withName:@"block_name"];
        [self addField:self.block_len withName:@"block_len"];
    }
    return self;
    
}
@end


@implementation PCOSMessage
@synthesize block_enum;
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
        copy.block_enum = [self.block_enum copyWithZone:zone];
        copy.blocks = [self.blocks copyWithZone:zone];
    }
    return copy;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        self.block_enum = [[PCOSLongArray alloc] 
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
    [meta.block_name setString:name];
    
    [self.block_enum.val addObject:meta];
    [self.blocks setObject:block 
                    forKey:name];
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    // Skip block meta for now.
    PCOSRawData * copy = [data copy];
    NSUInteger hdr_len = self.block_enum.size;
    [data consume:hdr_len];
    
    // Encode Blocks
    NSUInteger total = hdr_len;
    NSUInteger len = 0;
    for(int i = 0; i < self.block_enum.val.count; ++i)
    {
        NSString * key = [[self.block_enum.val objectAtIndex:i] block_name].string;
        total += (len = [[blocks valueForKey:key] encode:data]);
        [[self.block_enum.val objectAtIndex:i] block_len].val = len;
    }
    
    // Encode block meta
    [self.block_enum encode:copy];
    
    return total;
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    NSUInteger total = 0;
    total += [self.block_enum decode:data];
    
    for (int i = 0; i < self.block_enum.itemCount; ++i)
    {
#ifdef METABLOCK_IS_NSCOPYING
        PCOSBlockMetaBlock * block = [self.block_enum.val objectAtIndex:i];
        NSString * key = [[block block_name] string];
#else
        PCOSBlock * block = [self.block_enum.val objectAtIndex:i];
        NSString * key = [[block.lookup valueForKey:@"block_name"] string];
#endif
        
        PCOSBaseType * type = [blocks valueForKey:key];
        if (type != nil)
            total += [type decode:data];
    }
    return total;
}
@end
