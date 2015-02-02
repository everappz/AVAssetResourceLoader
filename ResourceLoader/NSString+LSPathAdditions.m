//
//  NSString+LSPathAdditions.m
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import "NSString+LSPathAdditions.h"
#import <MobileCoreServices/MobileCoreServices.h>


@implementation NSString (LSPathAdditions)

+ (NSString *)uuidString {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidStr;
}

- (NSString *)mimeTypeForPathExtension{
    NSString *extension = [self pathExtension];
    CFStringRef fileExtension = (__bridge  CFStringRef)extension;
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL){
        CFRelease(type);
    }
    if(!mimeType){
        mimeType = @"application/octet-stream";
    }
    return mimeType;
}

@end
