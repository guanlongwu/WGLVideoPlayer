//
//  WGLPlayerDummy.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLPlayerDummy.h"
#import "WGLPlayerTipMgr.h"

#ifdef DEBUG
#define PLAYER_DUMMY_DEBUG
#endif

#ifdef PLAYER_DUMMY_DEBUG
#define PLAYER_DUMMY_LOG(frmt, ...) NSLog((frmt), ##__VA_ARGS__);
#else
#define PLAYER_DUMMY_LOG(frmt, ...)
#endif

@interface HYBufferingTimeStampItem : NSObject
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;
@end

@implementation HYBufferingTimeStampItem

@end

@interface WGLPlayerDummy ()
@property (nonatomic, strong) NSMutableArray *bufferingTimeStamps;
@end

@implementation WGLPlayerDummy

- (instancetype)init{
    self = [super init];
    if (self) {
        _bufferingTimeStamps = [NSMutableArray array];
    }
    return self;
}

- (void)play:(BOOL)replay fromRateChange:(BOOL)fromRateChange {
    PLAYER_DUMMY_LOG(@"%s replay = %d", __FUNCTION__, replay);
    [self.bufferingTimeStamps removeAllObjects];
    [WGLPlayerTipMgr shareInstance].needToShowRateTip = YES;
    
    if (!fromRateChange && !replay) {
        [[WGLPlayerTipMgr shareInstance] showSeekTipIfNeed];
    }
}

- (void)resume {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
    [self.bufferingTimeStamps removeAllObjects];
}

- (void)stop:(HYMovieFinishReason)reason {
    PLAYER_DUMMY_LOG(@"%s reason = %d", __FUNCTION__, (int)reason);
    [self.bufferingTimeStamps removeAllObjects];
}

- (void)pause {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
}

- (void)startLoading {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
}

- (void)stopLoading {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
    
    // Remove buffering records after loading.
    [self.bufferingTimeStamps removeAllObjects];
}

- (void)startPlaying {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
}

- (void)startBuffering {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
    
    HYBufferingTimeStampItem *item = [[HYBufferingTimeStampItem alloc] init];
    item.start = [NSDate date];
    
    while (self.bufferingTimeStamps.count > 10) {
        [self.bufferingTimeStamps removeObjectAtIndex:0];
    };
    
    [self.bufferingTimeStamps addObject:item];
    
    if ([self blockOccurred]) {
        [[WGLPlayerTipMgr shareInstance] showRateTipIfNeed];
    }
}

- (void)stopBuffering {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
    
    if (self.bufferingTimeStamps.count > 0) {
        HYBufferingTimeStampItem *item = self.bufferingTimeStamps.lastObject;
        item.end = [NSDate date];
    }
}

- (void)firstVideoFrameRendered {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
}

- (void)firstAudioFrameRendered {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
}

- (void)firstVideoFrameDecoded {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
}

- (void)firstAudioFrameDecoded {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
}

- (void)firstSeekVideoFrameRender {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
}

- (void)seekCompleted {
    PLAYER_DUMMY_LOG(@"%s", __FUNCTION__);
    
#ifndef PLAYER_DUMMY_DEBUG // 方便调试卡顿
    [self.bufferingTimeStamps removeAllObjects];
#endif
}

//
- (BOOL)blockOccurred {
    if (self.bufferingTimeStamps.count < 3) {
        return NO;
    }
    BOOL blockState = NO;
    NSUInteger count = self.bufferingTimeStamps.count;
    HYBufferingTimeStampItem *startItem = [self.bufferingTimeStamps objectAtIndex:count - 3];
    HYBufferingTimeStampItem *endItem = [self.bufferingTimeStamps lastObject];
    
    if (startItem.start && endItem.start) {
        NSTimeInterval duration = [endItem.start timeIntervalSinceDate:startItem.start];
        if (duration > 0.01 && duration < 60.0) {
            blockState = YES;
        }
    }
    return blockState;
}

@end
