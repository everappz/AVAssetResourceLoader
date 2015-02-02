//
//  LSContentInformation.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <Foundation/Foundation.h>

@interface LSContentInformation : NSObject

@property (nonatomic,assign)unsigned long long contentLength;

@property (nonatomic,copy) NSString *contentType;

@property (nonatomic,assign) BOOL byteRangeAccessSupported;

@end
