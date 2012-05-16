//
//  PCOS.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCOS.h"

@implementation PCOSRawData
@synthesize data;
@synthesize offset;

-(id) initWithData:(NSMutableData *)dt offset:(NSUInteger)offst 
{
    self = [super init];
    if (self)
    {
        self.data = dt;
        self.offset = offst;
    }
    return self;
}

-(id) initWithData:(NSMutableData *)dt
{
    return [self initWithData:dt offset:0];
}

-(id) initWithRawData:(PCOSRawData *)other
{
    return [self initWithData:other.data offset:other.offset];
}

-(id) copyWithZone:(NSZone*)zone
{
    // will not copy the actual data.
    return [[PCOSRawData alloc] initWithRawData:self];
}

-(NSData *) consumedData
{
    return [NSData dataWithBytes:self.data.bytes length:offset];
}

-(NSUInteger) length
{
    if (data.length > self.offset)
        return data.length - self.offset;
    return 0;
}

-(NSUInteger) writeBytes:(const void *)bytes length:(NSUInteger)len
{
    if (self.length < len)
        [NSException raise:@"insufficient memory" format:@"write bytes out of memory"];
    
    NSRange range;
    range.length = len;
    range.location = offset;
 
    [self.data replaceBytesInRange:range withBytes:bytes length:len];
    [self consume:len];    
    
    return len;
}

-(NSUInteger) readBytes:(void *)bytes length:(NSUInteger)len
{
    memcpy(bytes, self.data.bytes + self.offset, len);
    [self consume:len];
    return len;
}

-(NSUInteger) readData:(NSMutableData *)bytes length:(NSUInteger)len
{
    NSRange range;
    range.length = len;
    range.location = 0;
    
    [bytes replaceBytesInRange:range withBytes:(self.data.bytes+self.offset) length:len];
    [self consume:len];
    return len;
}


-(void) consume:(NSUInteger)nBytes
{
    self.offset += nBytes;
}

@end
