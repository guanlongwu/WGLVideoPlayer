//
//  WGLVideoPlayerView.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/26.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGLPlayerCoverViewBase.h"
#import "WGLVideoPlayerUtil.h"
@protocol WGLVideoPlayerViewDataSource;

@interface WGLVideoPlayerView : UIView

@property (nonatomic, weak) id<WGLVideoPlayerViewDataSource> dataSource;
@property (nonatomic, assign) UIView *parentView;


//播放前的默认设置
- (void)setDefaultUI;

//开启定时器
- (void)addTimer;

//停止定时器
- (void)removeTimer;

//添加视频渲染view
- (void)addCorePlayerView:(UIView *)corePlayerView;

//更新播放状态
- (void)updatePlayStatus:(BOOL)isPlay;

//开始缓冲
- (void)startBuffering;

//结束缓冲
- (void)stopBuffering;

//显示播放结束
- (void)showFinishView;

//网络状态改变的事件
- (void)networkChangeEventForNetType:(WGLVPNetStatus)netStatus;

//显示Tip
- (void)aminationShowTip:(NSString *)name
                duration:(CGFloat)duration
                infoText:(NSString *)infoText
              actionText:(NSString *)actionText
                  action:(NSString *)action
         hideCloseButton:(BOOL)hideCloseButton;

@end


@protocol WGLVideoPlayerViewDataSource <NSObject>

//竖屏cover
- (WGLPlayerCoverViewBase *)coverViewForPlayerView:(WGLVideoPlayerView *)playerView;

//全屏cover
- (WGLPlayerCoverViewBase *)fullCoverViewForPlayerView:(WGLVideoPlayerView *)playerView;

@end

