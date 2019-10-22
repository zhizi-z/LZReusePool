//
//  LZReusePool.h
//  LZObjcKit
//
//  Created by zhizi on 2019/6/3.
//  Copyright © 2019 zlh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+LZReusePool.h"

NS_ASSUME_NONNULL_BEGIN

@interface LZReusePool : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

//单例
+ (instancetype)defaultPool;
//初始化一个新的重用池
+ (instancetype)smallPool;
//根据identifier从重用池里取出type类的一个对象,如果重用池里没有对象,则创建一个type类的对象并返回
- (id)dequeueReusableObjectWithIdentifier:( NSString *)identifier objectType:(Class)type isFirst:(BOOL)isFirst;
//将object放到重用池里
- (void)moveUsableObject:(NSObject *)object;
//将所有使用中的对象放到重用池里去
- (void)moveUsableObjects;

- (NSArray *)usableObjects;
@end

NS_ASSUME_NONNULL_END
