//
//  NSString+LSPathAdditions.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSString (LSPathAdditions)

+ (NSString *)uuidString;

- (NSString *)mimeTypeForPathExtension;

@end
