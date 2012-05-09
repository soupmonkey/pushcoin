//
//  PCOSParser1.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCOSMessage.h"

@interface PCOSParser : NSObject
{
    NSMutableDictionary * messageClasses;
}

-(void) registerMessageClass:(Class)messageClass;
-(NSUInteger) encodeMessage:(PCOSMessage *)msg to:(PCOSRawData *)data;
-(NSUInteger) decodeHeader:(PCOSHeaderBlock **)hdr from:(PCOSRawData *)data;
-(NSUInteger) decodeMessage:(PCOSMessage **)msg andHeader:(PCOSHeaderBlock **)hdr from:(PCOSRawData *)data;
@end