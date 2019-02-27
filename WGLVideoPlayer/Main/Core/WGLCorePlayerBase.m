//
//  WGLCorePlayerBase.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLCorePlayerBase.h"

@implementation WGLCorePlayerBase

#pragma mark - overwrite method

//核心
- (NSObject *)core {
    return nil;
}

//播放进度
- (NSTimeInterval)currentPlaybackTime {
    return 0;
}

//调整播放进度
- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    
}

//播放速度
- (float)playbackRate {
    return 0;
}

//调整播放速度
- (void)setPlaybackRate:(float)playbackRate {
    
}

//加载状态
- (int)loadState {
    return 0;
}

//播放状态
- (int)playbackState {
    return 0;
}

//是否播放中
- (BOOL)isPlaying {
    return NO;
}

#pragma mark - protocol

//视频渲染层view
- (UIView *)corePlayerView {
    return nil;
}

//播放
- (void)startPlay {
    
}

//播放
- (void)play {
    
}

//重播
- (void)replay {
    
}

//暂停
- (void)pause {
    
}

//结束播放
- (void)stopPlay {
    
}

@end
