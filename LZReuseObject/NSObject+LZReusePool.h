//
//  NSObject+LZReusePool.h
//  LZObjcKit
//
//  Created by zhizi on 2019/6/3.
//  Copyright © 2019 zlh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LZReusePool)

@property (nonatomic, copy) NSString *lz_reuseIdentifier;
@property (nonatomic, strong) NSNumber *lz_section;
@property (nonatomic, strong) NSNumber *lz_index;
@end

NS_ASSUME_NONNULL_END
