//
//  NSObject+LSAdditions.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <Foundation/Foundation.h>

typedef void (^NSObjectVoidBlock)(void);

@interface NSObject (LSAdditions)

- (void)performBlockOnMainThreadSync:(NSObjectVoidBlock)block;

- (void)performBlockOnMainThreadAsync:(NSObjectVoidBlock)block;

- (void)performBlockOnBackgroundThreadAsync:(NSObjectVoidBlock)block;

@end
