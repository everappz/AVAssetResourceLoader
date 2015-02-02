//
//  NSString+LSFormatAdditions.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSString (LSFormatAdditions)

+ (NSString *)stringFormattedTimeFromSeconds:(double *)seconds;

@end
