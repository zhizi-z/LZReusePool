//
//  LZReusePool.m
//  LZObjcKit
//
//  Created by zhizi on 2019/6/3.
//  Copyright © 2019 zlh. All rights reserved.
//

#import "LZReusePool.h"

@interface LZReusePool()

@property (nonatomic, strong) NSMutableArray *usableObj;//正在使用中的对象
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *reusableObj;//可使用的对象
@end

@implementation LZReusePool

+ (instancetype)defaultPool
{
    static dispatch_once_t onceToken;
    static LZReusePool *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (instancetype)smallPool
{
    return [[self alloc] init];
}

- (instancetype)init
{
    if (self = [super init])
    {
        _usableObj = [NSMutableArray new];
        _reusableObj = [NSMutableDictionary new];
    }
    return self;
}

- (id)dequeueReusableObjectWithIdentifier:( NSString *)identifier objectType:(Class)type isFirst:(BOOL)isFirst
{
#ifdef DEBUG
    NSAssert(identifier != nil, @"identifier should be set.");
    NSAssert(type != nil, @"type should be set.");
#else
    if (identifier == nil || type == nil) return nil;
#endif
    NSMutableArray *reusableObjects = [self.reusableObj objectForKey:identifier];
    if (reusableObjects == nil)
    {
        reusableObjects = [NSMutableArray new];
        [self.reusableObj setObject:reusableObjects forKey:identifier];
    }
    NSObject *object = [[type alloc] init];
    if (reusableObjects.count == 0)
    {
        object.lz_reuseIdentifier = identifier;
    }
    else {
        object = reusableObjects.firstObject;
        [reusableObjects removeObject:object];
    }
    if (isFirst)
    {
        [self.usableObj insertObject:object atIndex:0];
    }
    else {
        [self.usableObj addObject:object];
    }
    return object;
}

- (void)moveUsableObject:(NSObject *)object
{
    if (object == nil) return;
    if (object.lz_reuseIdentifier == nil)
    {
        [self.usableObj removeObject:object];
        return;
    }
    NSMutableArray *reusableObjects = [self.reusableObj objectForKey:object.lz_reuseIdentifier];
    if (reusableObjects == nil)
    {
        reusableObjects = [NSMutableArray new];
        [self.reusableObj setObject:reusableObjects forKey:object.lz_reuseIdentifier];
    }
    [reusableObjects addObject:object];
    [self.usableObj removeObject:object];
}

- (void)moveUsableObjects
{
    [[self.usableObj copy] enumerateObjectsUsingBlock:^(NSObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self moveUsableObject:obj];
    }];
}

- (NSArray *)usableObjects
{
    return [self.usableObj copy];
}
@end
