//
//  WGLVideoPlayer.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGLCorePlayerBase.h"
@protocol WGLVideoPlayerDataSource;

@interface WGLVideoPlayer : NSObject

@property (nonatomic, weak) id<WGLVideoPlayerDataSource> dataSource;
@property (nonatomic, strong, readonly) UIView *parentView; //播放器承载view
@property (nonatomic, copy, readonly) NSString *urlString; //播放地址url
@property (nonatomic, assign, readonly) BOOL isPlaying; //是否播放中
@property (nonatomic, assign) NSTimeInterval currentPlaybackTime;   //当前播放时间
@property (nonatomic, assign, readonly) NSTimeInterval duration; //视频总时长
@property (nonatomic, assign, readonly) NSTimeInterval playableDuration; //视频已缓冲时间
@property (nonatomic, assign) float playbackRate;   //播放速度

+ (WGLVideoPlayer *)sharedPlayer;

//添加播放器
- (BOOL)showInView:(UIView *)aView url:(NSString *)url;
//移除播放器
- (void)removeVideoPlayer;
//强制重启播放器
- (void)forceRestartPlayer;

//播放
- (void)play;
//重播
- (void)replay;
//暂停
- (void)pause;
//结束播放
- (void)stopPlay;

//判断是否播放器的承载view
- (BOOL)judgeIsParentView:(UIView *)aView;
//判断是否播放器的url
- (BOOL)judgeIsPlayerUrl:(NSString *)url;
//判断是否初始化了播放器corePlayer
- (BOOL)judgeIfCorePlayerInit;

//布局
- (void)layoutSubviews;
//视频层大小重设
- (void)resetCorePlayerViewFrame:(CGRect)videoFrame;
//显示Tip
- (void)aminationShowTip:(NSString *)name
                duration:(CGFloat)duration
                infoText:(NSString *)infoText
              actionText:(NSString *)actionText
                  action:(NSString *)action
         hideCloseButton:(BOOL)hideCloseButton;

@end

@protocol WGLVideoPlayerDataSource <NSObject>

//corePlayer
- (WGLCorePlayerBase *)corePlayerForPlayer:(WGLVideoPlayer *)player;

@end
