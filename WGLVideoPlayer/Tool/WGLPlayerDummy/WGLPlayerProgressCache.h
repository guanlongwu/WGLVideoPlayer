//
//  WGLPlayerProgressCache.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYProgressCacheItem <NSCoding, NSCopying> : NSObject

@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, strong) NSDate *date;

+ (instancetype)createItem:(NSString *)videoId time:(NSTimeInterval)time;

@end

@interface WGLPlayerProgressCache : NSObject

+ (instancetype)sharedInstacne;

- (void)saveProgressCache:(HYProgressCacheItem *)item;
- (void)clearProcessCache:(NSString *)videoId;
- (HYProgressCacheItem *)progressCacheForVideoId:(NSString *)videoId;

@end
