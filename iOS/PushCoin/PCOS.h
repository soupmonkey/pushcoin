//
//  PCOS.h
//  PushCoin
//
//  Created by Gilbert Cheung on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCOSRawData : NSObject
@property (nonatomic, strong) NSMutableData * data;
@property (nonatomic, assign) NSUInteger offset;
@property (readonly) NSData * consumedData;
-(id) initWithRawData: (PCOSRawData *)other;
-(id) initWithData:(NSMutableData *)dt;
-(id) initWithData:(NSMutableData *)dt offset:(NSUInteger)offst;
-(NSUInteger) writeBytes:(const void *)bytes length:(NSUInteger)len;
-(NSUInteger) readBytes:(void *)bytes length:(NSUInteger)len;
-(NSUInteger) readData:(NSMutableData *)bytes length:(NSUInteger)len;
-(void) consume:(NSUInteger)nBytes;
-(NSUInteger) length;
@end

@protocol PCOSSerializable
-(NSUInteger) encode:(PCOSRawData *)data;
-(NSUInteger) decode:(PCOSRawData *)data;
@end

@interface PCOSDataBlock : NSObject<PCOSSerializable>
@property (nonatomic, strong) NSMutableData * data;
-(id) initWithData:(NSMutableData *)data;
-(NSUInteger) encode:(PCOSRawData *)data;
-(NSUInteger) decode:(PCOSRawData *)data;
@end

