//
//  NSObject+LSAdditions.m
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import "NSObject+LSAdditions.h"


@implementation NSObject (LSAdditions)


- (void)performBlockOnMainThreadSync:(NSObjectVoidBlock)block{
    if(block){
        if([NSThread isMainThread]){
            block();
        }
        else{
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}

- (void)performBlockOnMainThreadAsync:(NSObjectVoidBlock)block{
    if(block){
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)performBlockOnBackgroundThreadAsync:(NSObjectVoidBlock)block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

@end
