//
//  WGLPlayerDummy.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HYMovieFinishReason) {
    HYMovieFinishReasonPlaybackEnded,
    HYMovieFinishReasonPlaybackError,
    HYMovieFinishReasonUserExited,
    HYMovieFinishReasonUnknown
};

@interface WGLPlayerDummy : NSObject

- (void)play:(BOOL)replay fromRateChange:(BOOL)fromRateChange;
- (void)stop:(HYMovieFinishReason)reason;
- (void)pause;
- (void)resume;

- (void)startLoading;              //开始加载(第一次)
- (void)stopLoading;               //停止加载(第一次)
- (void)startPlaying;              //开始播放(第一次)

- (void)startBuffering;            //开始缓冲
- (void)stopBuffering;             //结束缓冲

- (void)firstVideoFrameRendered;   //视频第1帧显示
- (void)firstAudioFrameRendered;   //音频第1帧显示
- (void)firstVideoFrameDecoded;    //视频第1帧解码完成
- (void)firstAudioFrameDecoded;    //音频第1帧解码完成
- (void)firstSeekVideoFrameRender; //拖动定位完成（即拖动完开始显示第一帧）
- (void)seekCompleted;             //Seek完成

//
- (BOOL)blockOccurred;  //是否发生卡顿：1分钟之内，连续缓冲3次及以上

@end
