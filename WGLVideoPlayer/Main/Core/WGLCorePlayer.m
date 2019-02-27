//
//  WGLCorePlayer.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLCorePlayer.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "WGLURLProvider.h"

@interface WGLCorePlayer ()
@property (nonatomic, strong, nullable) IJKFFMoviePlayerController *ijkPlayer; //IJKplayer
@end

@implementation WGLCorePlayer

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

//核心
- (NSObject *)core {
    return self.ijkPlayer;
}

#pragma mark - protocol

//视频渲染层view
- (UIView *)corePlayerView {
    if (self.ijkPlayer) {
        return [self.ijkPlayer view];
    }
    return nil;
}

//播放
- (void)startPlay {
    [self initIJKPlayer];
    
    //开始播放
    [self.ijkPlayer prepareToPlay]; // Play will auto started after buffer is ready.
}

//播放
- (void)play {
    [self.ijkPlayer play];
}

//重播
- (void)replay {
    [self.ijkPlayer play];
}

//暂停
- (void)pause {
    [self.ijkPlayer pause];
}

//结束播放
- (void)stopPlay {
    if (self.ijkPlayer) {
        [self.corePlayerView removeFromSuperview];
        [self.ijkPlayer shutdown];
        self.ijkPlayer = nil;
    }
}

//是否播放中
- (BOOL)isPlaying {
    return self.ijkPlayer.isPlaying;
}

//当前播放时间
- (NSTimeInterval)currentPlaybackTime {
    return self.ijkPlayer.currentPlaybackTime;
}

//调整播放进度
- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    self.ijkPlayer.currentPlaybackTime = currentPlaybackTime;
}

//视频总时长
- (NSTimeInterval)duration {
    return self.ijkPlayer.duration;
}

//已缓存时长
- (NSTimeInterval)playableDuration {
    return self.ijkPlayer.playableDuration;
}

//播放速度
- (float)playbackRate {
    return self.ijkPlayer.playbackRate;
}

//调整播放速度
- (void)setPlaybackRate:(float)playbackRate {
    self.ijkPlayer.playbackRate = playbackRate;
}

//加载状态
- (int)loadState {
    return self.ijkPlayer.loadState;
}

//播放状态
- (int)playbackState {
    return self.ijkPlayer.playbackState;
}

#pragma mark - private

- (void)initIJKPlayer {
    //先把旧的ijkplayer停止并释放
    [self stopPlay];
    
    //初始化ijkplayer
    NSString *url = [WGLURLProvider sharedProvider].url;
    if (url) {
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        
        /**
         SeekTo设置优化:
         某些视频在SeekTo的时候，会跳回到拖动前的位置，这是因为视频的关键帧的问题，通俗一点就是FFMPEG不兼容，视频压缩过于厉害，seek只支持关键帧，出现这个情况就是原始的视频文件中i 帧比较少
         */
        [options setPlayerOptionIntValue:1 forKey:@"enable-accurate-seek"];
        
        /**
         是否开启预缓冲，一般直播项目会开启，达到秒开的效果，不过带来了播放丢帧卡顿的体验
         */
        //        [options setPlayerOptionIntValue:1 forKey:@"packet-buffering"];
        
        /**
         播放前的探测Size，默认是1M, 改小一点会出画面更快
         */
        //        [options setPlayerOptionIntValue:1024*10 forKey:@"probesize"];
        
        /**
         设置播放前的探测时间 1,达到首屏秒开效果
         */
        //        [options setPlayerOptionIntValue:1 forKey:@"analyzeduration"];
        
        /**
         safe 主要是为了指定允许一些不安全的路径，默认值是 1 ，会拒绝一些不安全的文件路径。
         那什么是安全路径？安全路径必须是一个相对路径，并且只不包含特殊符号。
         "https://"、"file://"、"./" 这种视频源路径，均会视为不安全路径。
         所以safe要设置为0，表示允许一些不安全的路径。
         */
        [options setFormatOptionValue:0 forKey:@"safe"];
        
        /**
         protocol_whitelist ： 协议白名单
         为了让 IJKPlayer 能支持 concat 协议，你需要将 concat 配置到它的白名单协议里，主要是为了添加 ffconcat 和 concat 两个。
         */
        [options setPlayerOptionValue:@"ffconcat,file,http,https" forKey:@"protocol_whitelist"];
        [options setFormatOptionValue:@"concat,http,tcp,https,tls,file" forKey:@"protocol_whitelist"];
        
        self.ijkPlayer = [[IJKFFMoviePlayerController alloc] initWithContentURLString:url withOptions:options];
        self.ijkPlayer.scalingMode = IJKMPMovieScalingModeAspectFit;
    }
}

@end
