//
//  NSObject+LZReusePool.m
//  LZObjcKit
//
//  Created by zhizi on 2019/6/3.
//  Copyright © 2019 zlh. All rights reserved.
//

#import "NSObject+LZReusePool.h"
#import <objc/runtime.h>

@implementation NSObject (LZReusePool)

- (void)setLz_reuseIdentifier:(NSString *)lz_reuseIdentifier
{
    objc_setAssociatedObject(self, @"lz_reuseIdentifier", lz_reuseIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)lz_reuseIdentifier
{
    return objc_getAssociatedObject(self, @"lz_reuseIdentifier");
}

- (void)setLz_section:(NSNumber *)lz_section
{
    objc_setAssociatedObject(self, @"lz_section", lz_section, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)lz_section
{
    return objc_getAssociatedObject(self, @"lz_section");
}

- (void)setLz_index:(NSNumber *)lz_index
{
    objc_setAssociatedObject(self, @"lz_index", lz_index, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)lz_index
{
    return objc_getAssociatedObject(self, @"lz_index");
}
@end
