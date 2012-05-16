//
//  PCOSTypes.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCOSTypes.h"
#import "OpenSSLWrapper.h"

@implementation PCOSBaseType
-(NSUInteger) size { return 0; }
-(NSUInteger) encode:(PCOSRawData *)data { return 0; }
-(NSUInteger) decode:(PCOSRawData *)data { return 0; }
-(id) copyWithZone:(NSZone *)zone { return nil; }
@end

@implementation PCOSBasicType
@end

@implementation PCOSBool
@synthesize val;
-(NSUInteger) size { return 1; }

-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSBool alloc] initWithValue:self.val];
}

-(id) initWithValue:(BOOL)value
{
    self = [super init];
    if (self)
    {
        val = value;
    }
    return self;
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    return [data writeBytes:&val length:self.size];
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    return [data readBytes:&val length:self.size];
}

@end

@implementation PCOSByte
@synthesize val;
-(NSUInteger) size { return 1; }

-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSByte alloc] initWithValue:self.val];
}

-(id) initWithValue:(Byte)value
{
    self = [super init];
    if (self)
    {
        val = value;
    }
    return self;
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    return [data writeBytes:&val length:self.size];
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    return [data readBytes:&val length:self.size];
}

@end

@implementation PCOSChar
@synthesize val;
-(NSUInteger) size { return 1; }

-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSChar alloc] initWithValue:self.val];
}

-(id) initWithValue:(UTF8Char)value
{
    self = [super init];
    if (self)
    {
        val = value;
    }
    return self;
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    return [data writeBytes:&val length:self.size];
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    return [data readBytes:&val length:self.size];
}

@end

@implementation PCOSInt16
@synthesize val;
-(NSUInteger) size { return 2; }

-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSInt16 alloc] initWithValue:self.val];
}

-(id) initWithValue:(SInt16)value
{
    self = [super init];
    if (self)
    {
        val = value;
    }
    return self;
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    return [data writeBytes:&val length:self.size];
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    return [data readBytes:&val length:self.size];
}

@end

@implementation PCOSInt32
@synthesize val;
-(NSUInteger) size { return 4; }

-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSInt32 alloc] initWithValue:self.val];
}

-(id) initWithValue:(SInt32)value
{
    self = [super init];
    if (self)
    {
        val = value;
    }
    return self;
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    return [data writeBytes:&val length:self.size];
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    return [data readBytes:&val length:self.size];
}

@end

@implementation PCOSInt64
@synthesize val;
-(NSUInteger) size { return 8; }

-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSInt64 alloc] initWithValue:self.val];
}

-(id) initWithValue:(SInt64)value
{
    self = [super init];
    if (self)
    {
        val = value;
    }
    return self;
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    return [data writeBytes:&val length:self.size];
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    return [data readBytes:&val length:self.size];
}

@end

@implementation PCOSDouble
@synthesize val;
-(NSUInteger) size { return 8; }

-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSDouble alloc] initWithValue:self.val];
}

-(id) initWithValue:(Float64)value
{
    self = [super init];
    if (self)
    {
        val = value;
    }
    return self;
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    return [data writeBytes:&val length:self.size];
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    return [data readBytes:&val length:self.size];
}

@end

@implementation PCOSCompositeType
@synthesize val;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.val = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSUInteger) size
{
    NSUInteger total = 0;
    for (int i = 0; i < self.val.count; ++i)
        total += ((PCOSBaseType*)[self.val objectAtIndex:i]).size;
    return total;
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    NSUInteger total = 0;
    NSUInteger len = 0;
    PCOSBaseType * type;
    
    for (int i = 0; i < self.val.count; ++i)
    {
        type = [self.val objectAtIndex:i];
        total += (len = [type encode:data]);
    }
    return total;
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    NSUInteger total = 0;
    for (int i = 0; i < self.val.count; ++i)
        total += [[self.val objectAtIndex:i] decode:data];
    return total;
}

@end

@implementation PCOSBaseArray
@synthesize itemPrototype;

-(id) initWithItemPrototype:(PCOSBaseType const *)prototype
{
    self = [super init];
    if (self)
    {
        self.itemPrototype = [prototype copy];
        self.itemCount = 0;
    }
    return self;
}

-(id) initWithItemPrototype:(PCOSBaseType const *)prototype andCount:(NSUInteger)count
{
    self = [self initWithItemPrototype:prototype];
    if (self)
    {
        // Do not use setItemCount here as ti can be no-op for FixedArray
        for (int i = 0; i < count; ++i)
            [self.val addObject:[self.itemPrototype copy]];
    }
    return self;
}

-(void) setItemCount:(NSUInteger)count
{
    [self.val removeAllObjects];
    for (int i = 0; i < count; ++i)
        [self.val addObject:[self.itemPrototype copy]];
}

-(NSUInteger) itemCount
{
    return self.val.count;
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    return [super encode:data];
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    return [super decode:data];
}
@end

@implementation PCOSBasicArray

-(id) init
{
    self = [super init];
    if (self)
    {
        bytes_ = [[NSMutableData alloc] init];
        bytes_.length=0;
    }
    return self;
}

-(id) initWithItemPrototype:(PCOSBaseType const *)prototype
{
    self = [super initWithItemPrototype:prototype];
    if (self)
    {
        if ([self.itemPrototype isKindOfClass:[PCOSBasicType class]] == YES)
        {
            bytes_ = [[NSMutableData alloc] init];
            bytes_.length = 0;
        }
    }
    return self;
}

-(id) initWithItemPrototype:(PCOSBaseType const *)prototype andCount:(NSUInteger)count
{
    self = [super initWithItemPrototype:prototype andCount:count];
    if (self)
    {
        if ([self.itemPrototype isKindOfClass:[PCOSBasicType class]] == YES)
        {
            bytes_ = [[NSMutableData alloc] init];
            bytes_.length=count;
        }
    }
    return self;
}

-(void) setData:(NSData *) data
{
    if ([self.itemPrototype isKindOfClass:[PCOSBasicType class]] == YES)
    {
        self.itemCount = data.length / self.itemPrototype.size;
    
        //itemCount may not be set if it is a fixedarray
        NSRange range;
        range.length = MIN(data.length, bytes_.length);
        range.location = 0;
    
        [bytes_ replaceBytesInRange:range withBytes:data.bytes length:range.length];
    }
}

-(NSData *) data
{
    if ([self.itemPrototype isKindOfClass:[PCOSBasicType class]] == YES)
        return [[NSData alloc] initWithData:bytes_];
    return nil;
}

-(NSUInteger) itemCount
{
    if ([self.itemPrototype isKindOfClass:[PCOSBasicType class]] == NO)
        return [super itemCount];
    
    return bytes_.length / self.itemPrototype.size;
}

-(void) setItemCount:(NSUInteger)count
{
    if ([self.itemPrototype isKindOfClass:[PCOSBasicType class]] == NO)
    {
        [super setItemCount:count];
        return;
    }
    bytes_.length = count * self.itemPrototype.size;
}

-(void) setString:(NSString *) str
{
    self.itemCount = str.length;
    [self setData:[str dataUsingEncoding:NSASCIIStringEncoding]];
}

-(NSString *) string
{
    return [[NSString alloc] initWithData:[self data] encoding:NSASCIIStringEncoding];
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    // Hijacking basic type serialization
    if ([self.itemPrototype isKindOfClass:[PCOSBasicType class]] == NO)
        return [super encode:data];
    
    PCOSBasicType * basicPrototype = (PCOSBasicType *) self.itemPrototype;
    return [data writeBytes:bytes_.bytes length:basicPrototype.size * self.itemCount];
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    // Hijacking basic type serialization
    if ([self.itemPrototype isKindOfClass:[PCOSBasicType class]] == NO)
        return [super decode:data];
    
    PCOSBasicType * basicPrototype = (PCOSBasicType *) self.itemPrototype;
    return [data readData:bytes_ length:basicPrototype.size * self.itemCount];
}
@end

@implementation  PCOSFixedArray
-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSFixedArray alloc] initWithItemPrototype:self.itemPrototype andCount:self.itemCount];
}

-(void) setItemCount:(NSUInteger)count
{
    // no-op - item count fixed
}

@end

@implementation  PCOSShortArray

-(NSUInteger) size
{
    return 1 + [super size];
}

-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSShortArray alloc] initWithItemPrototype:self.itemPrototype andCount:self.itemCount];
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    PCOSByte * count = [[PCOSByte alloc] initWithValue:self.itemCount];
    NSUInteger total = 0;
    
    total += [count encode:data];
    total += [super encode:data];
    return total;
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    PCOSByte * count = [[PCOSByte alloc] init];
    NSUInteger total = 0;
    
    total += [count decode:data];
    self.itemCount = count.val;
    
    total += [super decode:data];
    return total;
}
@end

@implementation  PCOSLongArray

-(NSUInteger) size
{
    return 2 + [super size];
}

-(id) copyWithZone:(NSZone *)zone
{
    return [[PCOSLongArray alloc] initWithItemPrototype:self.itemPrototype andCount:self.itemCount];
}

-(NSUInteger) encode:(PCOSRawData *)data
{
    PCOSInt16 * count = [[PCOSInt16 alloc] initWithValue:self.itemCount];
    NSUInteger total = 0;
    
    total += [count encode:data];
    total += [super encode:data];
    return total;
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    PCOSInt16 * count = [[PCOSInt16 alloc] init];
    NSUInteger total = 0;
    
    total += [count decode:data];
    self.itemCount = count.val;
    
    total += [super decode:data];
    return total;
}

@end

@implementation PCOSBlock
@synthesize lookup;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.lookup = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    PCOSBlock* copy = [[PCOSBlock alloc] init];
    if (copy)
    {
        copy.val = [self.val copyWithZone:zone];
        copy.lookup = [self.lookup copyWithZone:zone];
    }
    return copy;
}

-(void) addField:(PCOSBaseType *)field withName:(NSString *)name
{
    [self.val addObject:field];
    [self.lookup setObject:field forKey:name];
}
@end


@implementation PCOSEncryptedBlock

-(NSUInteger) size
{
    [NSException raise:@"operation not supported" format:@"size of and encrypted block is not supported"];
    return 0;
}


-(NSUInteger) encode:(PCOSRawData *)data
{
    OpenSSLWrapper * ssl = [OpenSSLWrapper instance];
    
    PCOSRawData * copy = [data copy];
    NSUInteger total = [super encode:data];
    
    NSData * encrypted = [ssl rsa_encryptData: [NSData dataWithBytes:data.data.bytes - total length:total]];
    [copy writeBytes:encrypted.bytes length:encrypted.length];
    
    data = copy;
    return encrypted.length;
}

-(NSUInteger) decode:(PCOSRawData *)data
{
    [NSException raise:@"operation not supported" format:@"decoding encrypted block is not supported"];
    return 0;
}


@end


