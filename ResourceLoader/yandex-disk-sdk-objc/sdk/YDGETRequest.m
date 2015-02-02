//
//  YDGETRequest.m
//  sdk
//
//  Created by Artem Meleshko on 11/13/14.
//  Copyright (c) 2014 Yandex. All rights reserved.
//

#import "YDGETRequest.h"


@implementation YDGETRequest

- (void)prepareRequest:(NSMutableURLRequest *)request
{
    [super prepareRequest:request];
    
    [request setHTTPMethod:@"GET"];
}

- (BOOL)acceptResponseCode:(NSUInteger)statusCode
{
    // Accept only 200 code
    return (statusCode == 200);
}


@end
