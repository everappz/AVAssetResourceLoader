//
//  UIImage+LSAdditions.m
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import "UIImage+LSAdditions.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIImage (LSAdditions)

+ (UIImage *)imageWithColor:(UIColor *)bgColor size:(CGSize)imageSize{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, imageSize.width,imageSize.height)];
    view.backgroundColor = bgColor;
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)templateImageNamed:(NSString *)name{
    return [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIImage*)stretchableImage{
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(self.size.height/2, self.size.width/2, self.size.height/2, self.size.width/2)
                                resizingMode:UIImageResizingModeStretch];
}

@end
