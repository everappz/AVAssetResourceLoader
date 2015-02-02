//
//  LSDataResonse.m
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import "LSDataResonse.h"



@interface LSDataResonse()

@property (nonatomic, assign) unsigned long long requestedOffset;

@property (nonatomic, assign) unsigned long long requestedLength;

@property (nonatomic, assign) unsigned long long currentOffset;

@property (nonatomic, assign) unsigned long long dataOffset;

@property (nonatomic, assign) unsigned long long receivedDataLength;

@property (nonatomic, strong) NSData *data;

@end


@implementation LSDataResonse

- (instancetype)initWithRequestedOffset:(unsigned long long)requestedOffset
                        requestedLength:(unsigned long long)requestedLength
                     receivedDataLength:(unsigned long long)receivedDataLength
                                   data:(NSData *)data{
    self = [super init];
    if(self){
        self.requestedOffset = requestedOffset;
        self.requestedLength = requestedLength;
        self.receivedDataLength = receivedDataLength;
        self.data = data;
        self.dataOffset = self.requestedOffset+self.receivedDataLength-self.data.length;
        self.currentOffset = self.dataOffset+self.data.length;
    }
    return self;
}

+ (instancetype)responseWithRequestedOffset:(unsigned long long)requestedOffset
                            requestedLength:(unsigned long long)requestedLength
                         receivedDataLength:(unsigned long long)receivedDataLength
                                       data:(NSData *)data{
    LSDataResonse *resp = [[[self class] alloc] initWithRequestedOffset:requestedOffset
                                                        requestedLength:requestedLength
                                                     receivedDataLength:receivedDataLength
                                                                   data:data];
    return resp;
}

@end
