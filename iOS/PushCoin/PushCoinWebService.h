//
//  PushCoinWebService.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/25/12.
//  Copyright (c) 2012 PushCoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class PushCoinWebService;

@protocol PushCoinWebServiceDelegate <NSObject>

-(void)webService:(PushCoinWebService *) webService didReceiveMessage:(NSData *)message;
-(void)webService:(PushCoinWebService *) webService didFailWithStatusCode:(NSInteger)statusCode
   andDescription: (NSString *) description;

@end

@interface PushCoinWebService : NSObject<NSURLConnectionDelegate>
{
    NSMutableData * receivedData;
    int receivedStatusCode;
    NSString *receivedContentType;
    id<PushCoinWebServiceDelegate> delegate;
}

-(id) initWithDelegate:(id<PushCoinWebServiceDelegate>) recv;
-(void) sendMessage: (NSData *) message;


@end
