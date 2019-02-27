//
//  WGLCorePlayerBase.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGLCorePlayerProtocol.h"

@interface WGLCorePlayerBase : NSObject <WGLCorePlayerProtocol>

//核心
@property (nonatomic, strong) NSObject *core;

//播放地址url
@property (nonatomic, copy) NSString *urlString;

//当前播放时间
@property (nonatomic) NSTimeInterval currentPlaybackTime;

//视频总时长
@property (nonatomic, readonly) NSTimeInterval duration;

//视频已缓冲时间
@property (nonatomic, readonly) NSTimeInterval playableDuration;

//播放速度
@property (nonatomic) float playbackRate;

//加载状态
@property(nonatomic, readonly) int loadState;

//播放状态
@property(nonatomic, readonly) int playbackState;

//是否播放中
@property (nonatomic, assign) BOOL isPlaying;

@end
