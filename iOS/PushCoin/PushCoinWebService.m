//
//  PushCoinWebService.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PushCoinWebService.h"
#import "PushCoinConfig.h"

@implementation PushCoinWebService

-(id) init
{
    self = [super init];
    if (self == nil)
        return self;
    
    receivedData = [[NSMutableData alloc] init];
    return self;
}

-(id) initWithDelegate:(id<PushCoinWebServiceDelegate>) recv
{
    self = [self init];
    if (self == nil)
        return self;
    
    delegate = recv;
    return self;
}

-(void) sendMessage:(NSData *) message
{
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:PushCoinWebServicePath] 
                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                    timeoutInterval:60.0];
    
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/pcos" forHTTPHeaderField:@"content-type"];
    [req setHTTPBody:message];
    
    receivedContentType = @"";
    receivedStatusCode = 0;
    [receivedData setLength:0];    
    [NSURLConnection connectionWithRequest:req delegate:self];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace 
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge 
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response respondsToSelector:@selector(statusCode)])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        receivedStatusCode = [httpResponse statusCode];
        receivedContentType = [httpResponse.allHeaderFields objectForKey:@"content-type"];
    }
}

- (void)connection:(NSURLConnection *) connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *) connection didFailWithError:(NSError *)error
{
    [delegate webService:self didFailWithStatusCode:-1 andDescription:error.description];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (receivedStatusCode != 200 || ![receivedContentType isEqualToString:@"application/pcos"])
    {
        [delegate webService:self didFailWithStatusCode:receivedStatusCode
              andDescription:@"Invalid Response"];
    }
    else
    {
        [delegate webService:self didReceiveMessage:receivedData];
    }
}

@end
