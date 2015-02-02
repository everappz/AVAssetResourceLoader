//
//  LSDataResonse.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <Foundation/Foundation.h>

@interface LSDataResonse : NSObject

@property (nonatomic, readonly) unsigned long long requestedOffset;

@property (nonatomic, readonly) unsigned long long  requestedLength;

//currentOffset = dataOffset + data.length;
@property (nonatomic, readonly) unsigned long long currentOffset;

//dataOffset = requestedOffset + receivedDataLength - data.length;
@property (nonatomic, readonly) unsigned long long dataOffset;

@property (nonatomic, readonly) unsigned long long receivedDataLength;

@property (nonatomic, readonly, strong)NSData *data;

- (instancetype)initWithRequestedOffset:(unsigned long long)requestedOffset
                        requestedLength:(unsigned long long)requestedLength
                     receivedDataLength:(unsigned long long)receivedDataLength
                                   data:(NSData *)data;

+ (instancetype)responseWithRequestedOffset:(unsigned long long)requestedOffset
                            requestedLength:(unsigned long long)requestedLength
                         receivedDataLength:(unsigned long long)receivedDataLength
                                       data:(NSData *)data;

@end
