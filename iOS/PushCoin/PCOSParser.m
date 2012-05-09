//
//  PCOSParser1.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCOSParser.h"


@implementation PCOSParser

-(id) init
{
    self = [super init];
    if (self)
    {
        messageClasses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) registerMessageClass:(Class)messageClass
{
    [messageClasses setObject:messageClass forKey:[messageClass messageID]];
}

-(NSUInteger) encodeMessage:(PCOSMessage *)msg to:(PCOSRawData *)data
{
    PCOSHeaderBlock * hdr = [[PCOSHeaderBlock alloc] init];
    PCOSRawData * copy = [data copy];
    
    [data consume:hdr.size];
    
    NSUInteger size = [msg encode:data];
    
    hdr.magic.string = @"PCOS";
    hdr.msg_id.string = [[msg class] messageID];
    hdr.msg_len.val = size;
    
    size += [hdr encode:copy];
    return size;
}

-(NSUInteger) decodeHeader:(PCOSHeaderBlock **)hdr from:(PCOSRawData *)data
{
    *hdr = [[PCOSHeaderBlock alloc] init];
    NSUInteger size = [(*hdr) decode:data];
    
    if ([(*hdr).magic.string compare:@"PCOS"] != NSOrderedSame)
        [NSException raise:@"invalid message received" format:@"magic not match"];
    
    return size;
}

-(NSUInteger) decodeMessage:(PCOSMessage **)msg andHeader:(PCOSHeaderBlock **)hdr from:(PCOSRawData *)data;
{
    NSUInteger size = [self decodeHeader:hdr from:data];
    
    *msg = [[[messageClasses valueForKey:(*hdr).msg_id.string] alloc] init];
    if (*msg)
        size += [(*msg) decode:data];
    return size;
}

@end
