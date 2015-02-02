//
//  UIImage+LSAdditions.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (LSAdditions)

+ (UIImage *)imageWithColor:(UIColor *)bgColor size:(CGSize)imageSize;

+ (UIImage *)templateImageNamed:(NSString *)name;

- (UIImage*)stretchableImage;

@end
