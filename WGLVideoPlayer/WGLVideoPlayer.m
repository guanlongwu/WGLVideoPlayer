//
//  WGLVideoPlayer.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLVideoPlayer.h"
#import "WGLCorePlayerBase.h"
#import "WGLCorePlayer.h"
#import "WGLVideoPlayerView.h"
#import "WGLURLProvider.h"
#import "WGLVideoPlayerOption.h"
#import "WGLPlayerDummy.h"
#import "WGLPlayerProgressCache.h"
#import "WGLCustomVolumnManager.h"

@interface WGLVideoPlayer ()
@property (nonatomic, strong) WGLCorePlayerBase *corePlayer;
@property (nonatomic, strong) WGLVideoPlayerView *playerView;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, strong) WGLPlayerDummy *playerDummy;
@end

@implementation WGLVideoPlayer

+ (WGLVideoPlayer *)sharedPlayer {
    static WGLVideoPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - UI

- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
        [self addObservers];
        //弹幕
//        [[VideoBarrageManager shareInstance] setDataSource:(id<VideoBarrageDataSource>)self];
    }
    return self;
}

- (void)setupUI {
    [self addCorePlayerView];
}

- (WGLVideoPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[WGLVideoPlayerView alloc] init];
        _playerView.dataSource = (id<WGLVideoPlayerViewDataSource>)self;
    }
    return _playerView;
}

- (WGLPlayerDummy *)playerDummy {
    if (!_playerDummy) {
        _playerDummy = [[WGLPlayerDummy alloc] init];
    }
    return _playerDummy;
}

#pragma mark - corePlayer

- (WGLCorePlayerBase *)corePlayer {
    if ([self.dataSource respondsToSelector:@selector(corePlayerForPlayer:)]) {
        _corePlayer = [self.dataSource corePlayerForPlayer:self];
    }
    if (!_corePlayer) {
        _corePlayer = [[WGLCorePlayer alloc] init];
    }
    return _corePlayer;
}

- (void)addCorePlayerView {
    UIView *view = self.corePlayer.corePlayerView;
    if (view) {
        view.backgroundColor = [UIColor clearColor];
        [self.playerView addCorePlayerView:view];
    }
}

#pragma mark - player action

//添加播放器
- (BOOL)showInView:(UIView *)aView url:(NSString *)url {
    NSLog(@"[WGLVideoPlayer] showInView :%@, url:%@", aView, url);
    
    if (nil == aView || nil == url) {
        return NO;
    }
    
    BOOL isChangeSuperView = (NO == [self judgeIsParentView:aView]);
    if (isChangeSuperView) {
        //切换 播放器承载view
        
        self.parentView = aView;
        self.playerView.parentView = aView;
        if (self.playerView.superview) {
            [self.playerView removeFromSuperview];
        }
        [self.parentView addSubview:self.playerView];
        
        [self.playerView setDefaultUI];
    }
    
    BOOL isChangeUrl = (NO == [self judgeIsPlayerUrl:url]);
    BOOL isCorePlayerInit = (YES == [self judgeIfCorePlayerInit]);
    if (isChangeUrl
        || NO == isCorePlayerInit) {
        //切换 播放地址url
        //或者 corePlayer尚未初始化
        
        [self stopPlay];
        
        [WGLURLProvider sharedProvider].url = url;
        
        [self startPlay];
    }
    
    //设置默认状态
    [self setDefaultData];
    
    return YES;
}

//播放
- (void)startPlay {
    [self startPlayIfRateChange:NO];
    
    //更新播放状态
    [self.playerView updatePlayStatus:YES];
}

//播放
- (void)play {
    if (NO == self.isPlaying) {
        [self.playerDummy resume];
//        [[VideoBarrageManager shareInstance] resumeBarrage];
    }
    
    [self.corePlayer play];
    
    //定时器启动
    [self.playerView addTimer];
    
    //更新播放状态
    [self.playerView updatePlayStatus:YES];
}

//重播
- (void)replay {
    [self.playerDummy play:YES fromRateChange:NO];
//    NSString *vid = [NSString stringWithFormat:@"%llu", [WGLURLProvider sharedProvider].videoId];
//    [[VideoBarrageManager shareInstance] startBarrage:vid];
    
    [self.corePlayer play];
    
    //定时器启动
    [self.playerView addTimer];
    
    //更新播放状态
    [self.playerView updatePlayStatus:YES];
}

//暂停
- (void)pause {
//    [[VideoBarrageManager shareInstance] pauseBarrage];
    [self.playerDummy pause];
    
    [self.corePlayer pause];
    
    //定时器关闭
    [self.playerView removeTimer];
    
    //更新播放状态
    [self.playerView updatePlayStatus:NO];
}

//结束播放
- (void)stopPlay {
    //视频播放记录
    [self videoPlayRecord];
    
    [self.corePlayer stopPlay];
    
    //定时器关闭
    [self.playerView removeTimer];
    
    //更新播放状态
    [self.playerView updatePlayStatus:NO];
}

//移除播放器
- (void)removeVideoPlayer {
    //结束播放
    [self stopPlay];
    
    //数据清除
    [self clearData];
    
    //UI移除
    if (self.playerView.superview) {
        [self.playerView removeFromSuperview];
    }
}

//切换清晰度
- (void)changeVideoPlayUrl:(NSString *)url videoId:(uint64_t)videoId {
    //由videoId来判断是否同一个视频
    BOOL isChangeVideo = [[WGLURLProvider sharedProvider] judgeIsChangeVideo:videoId];
    
    //设置新的播放id
    [[WGLURLProvider sharedProvider] setParamsBeforePlayWithVideoId:videoId];
    
    BOOL isChangeUrl = (NO == [self judgeIsPlayerUrl:url]);
    BOOL isCorePlayerInit = (YES == [self judgeIfCorePlayerInit]);
    if (isChangeUrl
        || NO == isCorePlayerInit) {
        //切换 播放地址url
        //或者 corePlayer尚未初始化
        
        [self stopPlay];
        
        [WGLURLProvider sharedProvider].url = url;
        
        [self startPlayIfRateChange:isChangeVideo];
        
        [self.playerView setDefaultUI];
    }
    
    //定时器启动
    [self.playerView addTimer];
    
}

//强制重启播放器
- (void)forceRestartPlayer {
    [self stopPlay];
    [self startPlay];
}

#pragma mark - player property

//是否播放中
- (BOOL)isPlaying {
    return self.corePlayer.isPlaying;
}

//播放地址url
- (NSString *)urlString {
    return self.corePlayer.urlString;
}

//当前播放时间
- (NSTimeInterval)currentPlaybackTime {
    return self.corePlayer.currentPlaybackTime;
}

//调整播放进度
- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    self.corePlayer.currentPlaybackTime = currentPlaybackTime;
}

//视频总时长
- (NSTimeInterval)duration {
    return self.corePlayer.duration;
}

//视频已缓冲时间
- (NSTimeInterval)playableDuration {
    return self.corePlayer.playableDuration;
}

//播放速度
- (float)playbackRate {
    return self.corePlayer.playbackRate;
}

//设置播放速度
- (void)setPlaybackRate:(float)playbackRate {
    [WGLVideoPlayerOption sharedOption].speed = [NSString stringWithFormat:@"%.1f", playbackRate];
    self.corePlayer.playbackRate = playbackRate;
}

#pragma mark - private

//播放
- (void)startPlayIfRateChange:(BOOL)rateChange {
    self.corePlayer.urlString = [WGLURLProvider sharedProvider].url;
    [self.corePlayer startPlay];
    
    //添加视频渲染view
    [self addCorePlayerView];
    [self layoutSubviews];
    
    [self.playerDummy play:NO fromRateChange:rateChange];
    [self.playerDummy startLoading];
    [self.playerDummy startBuffering];
    
    //定时器启动
    [self.playerView addTimer];
}

#pragma mark - player extra

//判断是否播放器的承载view
- (BOOL)judgeIsParentView:(UIView *)aView {
    return self.parentView != nil && aView != nil && self.parentView == aView;
}

//判断是否播放器的url
- (BOOL)judgeIsPlayerUrl:(NSString *)url {
    return url != nil && [[WGLURLProvider sharedProvider].url isEqualToString:url];
}

//判断是否初始化了播放器corePlayer
- (BOOL)judgeIfCorePlayerInit {
    return self.corePlayer.corePlayerView != nil;
}

#pragma mark - 播放记录

- (void)videoPlayRecord {
    //不正常结束，缓存播放位置
    NSTimeInterval currentTime = self.currentPlaybackTime;
    NSTimeInterval duration = self.duration;
    NSTimeInterval minTime  = 10.0;
    uint64_t lastVideoId = [WGLURLProvider sharedProvider].lastVideoId;
    
    if (self.corePlayer) {
        
        NSString *videoId = [NSString stringWithFormat:@"%lld", lastVideoId];
        if (duration - currentTime > minTime
            && currentTime > minTime
            && lastVideoId > 0)
        {
            HYProgressCacheItem *item = [HYProgressCacheItem createItem:videoId time:currentTime];
            [[WGLPlayerProgressCache sharedInstacne] saveProgressCache:item];
        } else {
            [[WGLPlayerProgressCache sharedInstacne] clearProcessCache:videoId];
        }
    }
}

#pragma mark - 数据

- (void)setDefaultData {
    //开启屏幕旋转
    [WGLVideoPlayerOption sharedOption].isAllowFullScreen = YES;
    //注册音量
    [[WGLCustomVolumnManager sharedManager] registerVolumnChangeNotify];
}

- (void)clearData {
    self.parentView = nil;
    
    //url管理器数据 清除
    [[WGLURLProvider sharedProvider] clearData];
    
    //清理播放状态数据
    [[WGLVideoPlayerOption sharedOption] clearData];
}

#pragma mark - UI layoutSubviews

//布局
- (void)layoutSubviews {
    CGRect videoFrame = self.parentView.bounds;
    self.playerView.frame = videoFrame;
    [self resetCorePlayerViewFrame:videoFrame];
}

//视频层大小重设
- (void)resetCorePlayerViewFrame:(CGRect)videoFrame {
    if (nil != self.corePlayer.corePlayerView) {
        self.corePlayer.corePlayerView.frame = videoFrame;
    }
}

#pragma mark - VideoBarrageDataSource

- (int64_t)barrage_videoCurrentPlayTimeStamp
{
    return (int64_t)(self.currentPlaybackTime * 1000);
}

- (int64_t)barrage_videoTimeStampUnit
{
    return 0;
//    return [HYAppConfigureManager sharedObject].danmakuDuration;
}

- (int64_t)barrage_videoDuration
{
    return self.duration * 1000;
}

- (NSString *)videoIdForBarrage
{
    return [NSString stringWithFormat:@"%llu", [WGLURLProvider sharedProvider].videoId];
}

- (void)seekToTime:(NSTimeInterval)time
{
    self.corePlayer.currentPlaybackTime = time;
}

//显示Tip
- (void)aminationShowTip:(NSString *)name
                duration:(CGFloat)duration
                infoText:(NSString *)infoText
              actionText:(NSString *)actionText
                  action:(NSString *)action
         hideCloseButton:(BOOL)hideCloseButton
{
    if (self.playerView == nil) {
        return;
    }
    
    [self.playerView aminationShowTip:name duration:duration infoText:infoText actionText:actionText action:action hideCloseButton:hideCloseButton];
}

#pragma mark - 通知

- (void)addObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    NSObject *core = self.corePlayer.core;
    
    [center addObserver:self
               selector:@selector(n_loadStateDidChange:)
                   name:IJKMPMoviePlayerLoadStateDidChangeNotification
                 object:core];
    [center addObserver:self
               selector:@selector(n_playbackStateDidChange:)
                   name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                 object:core];
    [center addObserver:self
               selector:@selector(n_playbackDidFinish:)
                   name:IJKMPMoviePlayerPlaybackDidFinishNotification
                 object:core];
    [center addObserver:self
               selector:@selector(n_mediaIsPreparedToPlayDidChange:)
                   name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                 object:core];
    [center addObserver:self
               selector:@selector(n_seekCompletedEvent:)
                   name:IJKMPMoviePlayerDidSeekCompleteNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(mediaFirstVideoFrameRendered:)
                   name:IJKMPMoviePlayerFirstVideoFrameRenderedNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(mediaFirstAudioFrameRendered:)
                   name:IJKMPMoviePlayerFirstAudioFrameRenderedNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(mediaFirstVideoFrameDecoded:)
                   name:IJKMPMoviePlayerFirstVideoFrameDecodedNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(mediaFirstAudioFrameDecoded:)
                   name:IJKMPMoviePlayerFirstAudioFrameDecodedNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(mediaFirstSeekVideoFrameRendered:)
                   name:IJKMPMoviePlayerSeekVideoStartNotification
                 object:nil];
    //失去第一响应者之后的通知方法
    [center addObserver:self
               selector:@selector(n_willRegistActive:)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
    //变成第一响应者的时候的通知方法
    [center addObserver:self
               selector:@selector(n_didBecomeActive:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
}

//更新加载状态
- (void)n_loadStateDidChange:(NSNotification *)notification {
    IJKMPMovieLoadState loadState = self.corePlayer.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        //加载状态变成了已经缓存完成，如果设置了自动播放，这时会自动播放
        NSLog(@"[HYVideoPlayer] n_loadStateDidChange IJKMPMovieLoadStatePlaythroughOK");
        
        [self.playerView stopBuffering];
        [self.playerDummy stopBuffering];
    }
    if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        //加载状态变成了数据缓存已经停止，播放将暂停
        NSLog(@"[HYVideoPlayer] n_loadStateDidChange IJKMPMovieLoadStateStalled");
        
        [self.playerView startBuffering];
        [self.playerDummy startBuffering];
    }
    if((loadState & IJKMPMovieLoadStatePlayable) != 0) {
        //加载状态变成了缓存数据足够开始播放，但是视频并没有缓存完全
        NSLog(@"[HYVideoPlayer] n_loadStateDidChange IJKMPMovieLoadStatePlayable");
    }
    if ((loadState & IJKMPMovieLoadStateUnknown) != 0) {
        //加载状态变成了未知状态
        NSLog(@"[HYVideoPlayer] n_loadStateDidChange IJKMPMovieLoadStateUnknown");
    }
}

//视频播放器状态改变
- (void)n_playbackStateDidChange:(NSNotification *)notification {
    IJKMPMoviePlaybackState playbackState = self.corePlayer.playbackState;
    switch (playbackState) {
        case IJKMPMoviePlaybackStateStopped : {
            //播放器的播放状态变了，现在是停止状态
            NSLog(@"[HYVideoPlayer] n_playbackStateDidChange IJKMPMoviePlaybackStateStopped");
        }
            break;
        case IJKMPMoviePlaybackStatePlaying : {
            //播放器的播放状态变了，现在是播放状态
            NSLog(@"[HYVideoPlayer] n_playbackStateDidChange IJKMPMoviePlaybackStatePlaying");
        }
            break;
        case IJKMPMoviePlaybackStatePaused : {
            //播放器的播放状态变了，现在是暂停状态
            NSLog(@"[HYVideoPlayer] n_playbackStateDidChange IJKMPMoviePlaybackStatePaused");
            [self.playerView updatePlayStatus:NO];
        }
            break;
        case IJKMPMoviePlaybackStateInterrupted : {
            //播放器的播放状态变了，现在是中断状态
            NSLog(@"[HYVideoPlayer] n_playbackStateDidChange IJKMPMoviePlaybackStateInterrupted");
        }
            break;
        case IJKMPMoviePlaybackStateSeekingForward : {
            //播放器的播放状态变了，现在是向前拖动状态
            NSLog(@"[HYVideoPlayer] n_playbackStateDidChange IJKMPMoviePlaybackStateSeekingForward");
        }
            break;
        case IJKMPMoviePlaybackStateSeekingBackward : {
            //播放器的播放状态变了，现在是向后拖动状态
            NSLog(@"[HYVideoPlayer] n_playbackStateDidChange IJKMPMoviePlaybackStateSeekingBackward");
        }
            break;
        default: {
            //播放器的播放状态变了，现在是未知状态
            NSLog(@"[HYVideoPlayer] n_playbackStateDidChange unknow");
        }
            break;
    }
}

//播放结束的原因
- (void)n_playbackDidFinish:(NSNotification *)notification {
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    // 停止弹幕
//    [[VideoBarrageManager shareInstance] stopBarrage];
    
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded : {
            //播放状态改变了：现在是播放完毕的状态
            NSLog(@"[HYVideoPlayer] n_playbackDidFinish IJKMPMovieFinishReasonPlaybackEnded");
            [self.playerDummy stop:HYMovieFinishReasonPlaybackEnded];
            
            EHYSettingPlayStyle playStyle = [WGLVideoPlayerOption sharedOption].playStyle;
            if (playStyle == EHYSettingPlayStyleCircle) {
                //循环播放
                [self replay];
            }
            else {
                //播完结束
                [self.playerView showFinishView];
            }
        }
            break;
        case IJKMPMovieFinishReasonUserExited : {
            //播放状态改变了：现在是用户退出状态
            NSLog(@"[HYVideoPlayer] n_playbackDidFinish IJKMPMovieFinishReasonUserExited");
            [self.playerDummy stop:HYMovieFinishReasonUserExited];
        }
            break;
        case IJKMPMovieFinishReasonPlaybackError : {
            //播放状态改变了：现在是播放错误状态
            NSLog(@"[HYVideoPlayer] n_playbackDidFinish IJKMPMovieFinishReasonPlaybackError");
            [self.playerDummy stop:HYMovieFinishReasonPlaybackError];
            
            //无效网络、播放错误，显示网络异常
            [self.playerView networkChangeEventForNetType:WGLVPNetStatus_Error];
            
            //统计
            uint64_t videoId = [WGLURLProvider sharedProvider].videoId;
            NSNumber *arg1 = [[notification userInfo] valueForKey:@"error"];
            NSDictionary *map =
            @{
              @"vid" : @(videoId),
              @"what" : @(100),
              @"arg1" : arg1 ?: @(0),
              @"arg2" : @(0),
              @"device" : @""
              };
        }
            break;
        default: {
            NSLog(@"[HYVideoPlayer] n_playbackDidFinish unknow");
            [self.playerDummy stop:HYMovieFinishReasonUnknown];
        }
            break;
    }
}

- (void)n_mediaIsPreparedToPlayDidChange:(NSNotification *)notification {
    NSLog(@"[HYVideoPlayer] n_mediaIsPreparedToPlayDidChange");
    
    //    if (self.isPreparedToPlayDidChangeDelegate && [self.isPreparedToPlayDidChangeDelegate respondsToSelector:@selector(playerPlaybackIsPreparedToPlayDidChange:)]) {
    //        [self.isPreparedToPlayDidChangeDelegate playerPlaybackIsPreparedToPlayDidChange:self];
    //    }
    [self.playerDummy stopLoading];
    [self.playerDummy startPlaying];
    
#ifdef VIDEOPLAYER_MONITOR
    [[VideoPlayerMonitor defaultMonitor] mediaStopLoading];
    [[VideoPlayerMonitor defaultMonitor] mediaStartPlaying];
#endif
}

//加载完成的方法
- (void)n_seekCompletedEvent:(NSNotification *)notification {
    NSLog(@"[HYVideoPlayer] n_seekCompletedEvent");
    BOOL videoPlaying = self.isPlaying;
//    [[VideoBarrageManager shareInstance] seekBarrage:videoPlaying];
    [self.playerDummy seekCompleted];
}

- (void)mediaFirstVideoFrameRendered:(NSNotification *)n {
    NSLog(@"[HYVideoPlayer] mediaFirstVideoFrameRendered");
    [self checkNetworkStatus];
//    [[VideoBarrageManager shareInstance] startBarrage:[self videoIdForBarrage]];
    [self.playerDummy firstVideoFrameRendered];
    
#ifdef VIDEOPLAYER_MONITOR
    [[VideoPlayerMonitor defaultMonitor] mediaFirstVideoFrameRendered];
#endif
}

- (void)mediaFirstSeekVideoFrameRendered:(NSNotification *)n
{
    NSLog(@"[HYVideoPlayer] mediaFirstSeekVideoFrameRendered");
    [self.playerDummy firstSeekVideoFrameRender];
    
#ifdef VIDEOPLAYER_MONITOR
    [[VideoPlayerMonitor defaultMonitor] mediaFirstSeekVideoFrameRender];
#endif
}

- (void)mediaFirstAudioFrameRendered:(NSNotification *)notice
{
    NSLog(@"[HYVideoPlayer] mediaFirstAudioFrameRendered");
    [self.playerDummy firstAudioFrameRendered];
    
#ifdef VIDEOPLAYER_MONITOR
    [[VideoPlayerMonitor defaultMonitor] mediaFirstAudioFrameRendered];
#endif
}

- (void)mediaFirstVideoFrameDecoded:(NSNotification *)notice
{
    NSLog(@"[HYVideoPlayer] mediaFirstVideoFrameDecoded");
    [self.playerDummy firstVideoFrameDecoded];
    
#ifdef VIDEOPLAYER_MONITOR
    [[VideoPlayerMonitor defaultMonitor] mediaFirstVideoFrameDecoded];
#endif
}

- (void)mediaFirstAudioFrameDecoded:(NSNotification *)notice
{
    NSLog(@"[HYVideoPlayer] mediaFirstAudioFrameDecoded");
    [self.playerDummy firstAudioFrameDecoded];
    
#ifdef VIDEOPLAYER_MONITOR
    [[VideoPlayerMonitor defaultMonitor] mediaFirstAudioFrameDecoded];
#endif
}

//播放器失去第一响应者(退后台)
- (void)n_willRegistActive:(NSNotification *)notification {
    NSLog(@"[HYVideoPlayer] n_willRegistActive");
    
    //先锁屏，不让屏幕旋转
    [WGLVideoPlayerOption sharedOption].isLockScreenBeforeEnterBackground = [WGLVideoPlayerOption sharedOption].isLockScreen;
    [WGLVideoPlayerOption sharedOption].isLockScreen = YES;
    [WGLVideoPlayerOption sharedOption].isEnterBackground = YES;
    
    //先把有关播放器的一些状态记录一下
    [WGLVideoPlayerOption sharedOption].isBeingActiveState = NO;
    
    [self.playerView removeTimer];
    
    //记录一下当前各视频播放器的属性
    [[WGLVideoPlayerOption sharedOption] realTimeUpdateData];
    
    //在这个代理方法执行出来之前，HYAVPlayerView已经记录了视频播放器的一些属性，只是简单暂停播放
    //    [self pauseWithoutChangePlayerOptions];
}

//播放器成为第一响应者(进前台)
- (void)n_didBecomeActive:(NSNotification *)notification {
    NSLog(@"[HYVideoPlayer] n_didBecomeActive");
    
    //恢复是否锁屏状态
    [WGLVideoPlayerOption sharedOption].isLockScreen = [WGLVideoPlayerOption sharedOption].isLockScreenBeforeEnterBackground;
    [WGLVideoPlayerOption sharedOption].isEnterBackground = NO;
    
    [WGLVideoPlayerOption sharedOption].isBeingActiveState = YES;
    
    [self.playerView addTimer];
    
    //成为了第一响应者之后，需要和变成可见界面的时候需要执行的方法是一样的,这个方法里面会有线管的处理和判断逻辑
    [self eventWithBecomeASctiveStateOrBecomeAppearState];
}

//当视频成为了第一响应者或者成为可见界面的时候需要通过该方法进行相关逻辑的处理（主要是播放器的创建和释放业务）能走到这个方法，说明一定是变成了第一响应者或者成为了可见页面。
- (void)eventWithBecomeASctiveStateOrBecomeAppearState {
    
    //判断退后台之前的播放状态，是暂停还是播放中
    if ([WGLVideoPlayerOption sharedOption].isPlaying) {
        [self play];
    }
}

- (void)checkNetworkStatus {
//    YYNetStatus netStatus = [YYFacadeApp sharedInstance].netWorkHelper.networkStatus;
//    if (netStatus != YYNetStatus_Wifi) {
//        //非WiFi则提示
//        [self.playerView networkChangeEventForNetType:netStatus];
//    }
}
@end
