//
//  WGLPlayerProgressCache.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLPlayerProgressCache.h"

NSString *const kProgressCacheKey = @"kProgressCacheKey";
const int kProgressCacheSize = 50;

#pragma mark - HYProgressCacheItem

@implementation HYProgressCacheItem

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.time forKey:@"time"];
    [aCoder encodeObject:self.videoId forKey:@"videoId"];
    [aCoder encodeObject:self.date forKey:@"date"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.time = [aDecoder decodeDoubleForKey:@"time"];
        self.videoId = [aDecoder decodeObjectForKey:@"videoId"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    HYProgressCacheItem *instance = [[[self class] alloc] init];
    
    instance.videoId = [self.videoId copy];
    instance.time = self.time;
    instance.date = [self.date copy];
    
    return instance;
}

+ (instancetype)createItem:(NSString *)videoId time:(NSTimeInterval)time {
    HYProgressCacheItem *instance = [[[self class] alloc] init];
    instance.videoId = videoId;
    instance.time = time;
    instance.date = [NSDate date];
    
    return instance;
}

@end


@interface WGLPlayerProgressCache ()

@property (nonatomic, strong) NSMutableArray *caches;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSCache *memCache;

- (void)storageProgressCaches;
- (void)loadProgressCaches;
- (void)removeHistory:(HYProgressCacheItem *)item;

@end

@implementation WGLPlayerProgressCache

+ (instancetype)sharedInstacne {
    static WGLPlayerProgressCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WGLPlayerProgressCache alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _caches = [NSMutableArray array];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.qualityOfService = NSQualityOfServiceBackground;
        _operationQueue.maxConcurrentOperationCount = 1;
        _memCache = [[NSCache alloc] init];
        
        [self loadProgressCaches];
    }
    return self;
}

- (void)saveProgressCache:(HYProgressCacheItem *)item {
    [self clearProcessCache:item.videoId];
    
    // Fit the caches.
    while (self.caches.count >= kProgressCacheSize) {
        [self.caches removeObjectAtIndex:0];
    }
    
    [self.caches addObject:item];
    [self storageProgressCaches];
}

- (void)clearProcessCache:(NSString *)videoId {
    // Clear all repeated caches.
    __block NSMutableArray *findCaches = [NSMutableArray array];
    [self.caches enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HYProgressCacheItem *cacheItem = obj;
        if ([cacheItem.videoId isEqualToString:videoId]) {
            [findCaches addObject:cacheItem];
        }
    }];
    [self.caches removeObjectsInArray:findCaches];
}

- (void)removeHistory:(id)item {
    [self.caches removeObject:item];
    [self storageProgressCaches];
}

- (HYProgressCacheItem *)progressCacheForVideoId:(NSString *)videoId {
    __block HYProgressCacheItem *findItem = nil;
    [self.caches enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HYProgressCacheItem *item = obj;
        if ([item.videoId isEqualToString:videoId]) {
            findItem = item;
            *stop = YES;
        }
    }];
    if (findItem) {
        findItem = [findItem copy];
    }
    return findItem;
}

- (void)storageProgressCaches {
    if (self.caches == nil || self.caches.count == 0) {
        return;
    }
    NSArray *caches = [NSArray arrayWithArray:self.caches];
    [self.operationQueue addOperationWithBlock:^{
        [self.memCache setObject:caches forKey:kProgressCacheKey];
    }];
}

- (void)loadProgressCaches {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSArray *caches = [self.memCache objectForKey:kProgressCacheKey];
        if (caches && caches.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.caches addObjectsFromArray:caches];
            });
        }
    }];
}

@end
