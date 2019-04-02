//
//  WGLVideoPlayerView.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/26.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLVideoPlayerView.h"
#import "WGLVideoPlayer.h"
#import "WGLURLProvider.h"
#import "WGLVideoPlayerOption.h"

#import <MediaPlayer/MediaPlayer.h>
#import "WGLPlayerCoverView.h"
#import "WGLPlayerCoverFullScreenView.h"
#import "WGLVideoLoadingView.h"
#import "WGLPlayerNetworkStatusView.h"
#import "WGLVolumeProgressView.h"
#import "WGLVideoPlayerGesturer.h"
#import "WGLBrightnessProgressView.h"
#import "WGLVideoRateProgressView.h"
#import "WGLPlayerTipView.h"

@interface WGLVideoPlayerView ()

@property (nonatomic, strong) NSTimer *updateUITimer; //定时器
@property (nonatomic, assign) BOOL isStopTimer;//停止定时器的标识

@property (nonatomic, strong) WGLPlayerCoverViewBase *coverView;
@property (nonatomic, strong) WGLPlayerCoverViewBase *fullCoverView;
@property (nonatomic, strong) UIProgressView *playbackProgressView;//底部播放进度2
@property (nonatomic, strong) UIButton *resumePlayBtn;//恢复播放
@property (nonatomic, strong) WGLPlayerTipView *tipView;

@property (nonatomic, strong) WGLVideoLoadingView *loadingView; //加载中
@property (nonatomic, strong) WGLPlayerNetworkStatusView *netShowView; //网络提示
//@property (nonatomic, strong) HYVideoPlayerFinishView *finishView;
//@property (nonatomic, strong) HYBarrageView *barrageView;//弹幕的view

//用于防止系统弹出音量浮层图标
@property (nonatomic, strong) MPVolumeView *hiddenVolumeView;
@property (nonatomic, strong) WGLVolumeProgressView *volumeView;//音量浮层
@property (nonatomic, strong) WGLBrightnessProgressView *brightnessView;//亮度浮层
@property (nonatomic, strong) WGLVideoRateProgressView *rateView;//进度浮层

//手势
@property (nonatomic, strong) WGLVideoPlayerGesturer *gestureHelper;

@end

@implementation WGLVideoPlayerView

#pragma mark - UI

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self addGestures];//添加手势
        [self addObserver];
    }
    return self;
}

- (void)setupUI {
//    [self addSubview:self.barrageView];  //弹幕
    
    [self addSubview:self.coverView];
    [self addSubview:self.fullCoverView];
    [self addSubview:self.playbackProgressView];
    [self addSubview:self.resumePlayBtn];//恢复播放按钮
    [self addSubview:self.tipView];
    
    [self addSubview:self.loadingView];  //加载中提示
//    [self addSubview:self.finishView];   //播放结束提示页
    [self addSubview:self.netShowView];  //网络状态提示
    
    //隐藏系统音量提示框
    [self addSubview:self.hiddenVolumeView];
    [self addSubview:self.volumeView];
    [self addSubview:self.brightnessView];
    [self addSubview:self.rateView];
    
}

//播放前的默认设置
- (void)setDefaultUI {
//    self.finishView.hidden = YES;
    self.resumePlayBtn.hidden = YES;
    self.playbackProgressView.hidden = YES;
    [self.playbackProgressView setProgress:0 animated:NO];
    if (YES == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
        [self rightnowShowFullScreenCoverView];
    }
    else {
        [self rightnowShowCoverView];
    }
    [self.tipView aminationDismiss:NO];
}

//添加视频渲染view
- (void)addCorePlayerView:(UIView *)corePlayerView {
    if (corePlayerView.superview) {
        [corePlayerView removeFromSuperview];
    }
    [self addSubview:corePlayerView];
    [self sendSubviewToBack:corePlayerView];
}

//竖屏cover
- (WGLPlayerCoverViewBase *)coverView {
    if ([self.dataSource respondsToSelector:@selector(coverViewForPlayerView:)]) {
        _coverView = [self.dataSource coverViewForPlayerView:self];
    }
    if (!_coverView) {
        _coverView = [[WGLPlayerCoverView alloc] init];
    }
    _coverView.delegate = (id<WGLPlayerCoverViewDelegate>)self;
    return _coverView;
}

//全屏cover
- (WGLPlayerCoverViewBase *)fullCoverView {
    if ([self.dataSource respondsToSelector:@selector(fullCoverViewForPlayerView:)]) {
        _fullCoverView = [self.dataSource fullCoverViewForPlayerView:self];
    }
    if (!_fullCoverView) {
        _fullCoverView = [[WGLPlayerCoverFullScreenView alloc] init];
    }
    _fullCoverView.delegate = (id<WGLPlayerCoverViewDelegate>)self;
    _fullCoverView.hidden = YES;
    return _fullCoverView;
}

//弹幕UI
//- (HYBarrageView *)barrageView {
//    if(!_barrageView){
//        _barrageView = [[HYBarrageView alloc] init];
//    }
//    return _barrageView;
//}

//底部播放进度条
- (UIProgressView *)playbackProgressView {
    if (!_playbackProgressView) {
        _playbackProgressView = [[UIProgressView alloc] init];
        _playbackProgressView.trackTintColor = [UIColor clearColor];
        _playbackProgressView.progressTintColor = [UIColor grayColor];
        [_playbackProgressView setProgress:0];
    }
    return _playbackProgressView;
}

- (UIButton *)resumePlayBtn {
    if (!_resumePlayBtn) {
        _resumePlayBtn = [[UIButton alloc] init];
        [_resumePlayBtn setImage:[UIImage imageNamed:@"icon_home_video_play"] forState:UIControlStateNormal];
        [_resumePlayBtn addTarget:self action:@selector(p_resumePlay) forControlEvents:UIControlEventTouchUpInside];
        _resumePlayBtn.hidden = YES;
    }
    return _resumePlayBtn;
}

//隐藏系统音量
- (MPVolumeView *)hiddenVolumeView {
    if (!_hiddenVolumeView) {
        _hiddenVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-50.0f, -50.0f, 0.f, 0.f)];
        _hiddenVolumeView.alpha = 0.01f;
    }
    return _hiddenVolumeView;
}

- (WGLVolumeProgressView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[WGLVolumeProgressView alloc] init];
        _volumeView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _volumeView.layer.cornerRadius = 5;
        _volumeView.hidden = YES;
    }
    return _volumeView;
}

- (WGLBrightnessProgressView *)brightnessView {
    if (!_brightnessView) {
        _brightnessView = [[WGLBrightnessProgressView alloc] init];
        _brightnessView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _brightnessView.layer.cornerRadius = 5;
        _brightnessView.hidden = YES;
    }
    return _brightnessView;
}

- (WGLVideoRateProgressView *)rateView {
    if (!_rateView) {
        _rateView = [[WGLVideoRateProgressView alloc] init];
        _rateView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _rateView.layer.cornerRadius = 5;
        _rateView.hidden = YES;
    }
    return _rateView;
}

- (WGLVideoLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[WGLVideoLoadingView alloc] init];
    }
    return _loadingView;
}

//- (HYVideoPlayerFinishView *)finishView {
//    if (!_finishView) {
//        _finishView = [[HYVideoPlayerFinishView alloc] initWithFrame:CGRectZero];
//        @weakify(self)
//        _finishView.clickBlock = ^(HYAVPlayerShareType type) {
//            @strongify(self)
//            [self p_clickFinishWithType:type];
//        };
//        _finishView.backHandler = ^{
//            @strongify(self)
//            if (YES == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
//                [self fullOrQuiteFullAction];
//            }
//            else {
//                [self backAction];
//            }
//        };
//        _finishView.shareHandler = ^{
//            @strongify(self)
//            if (YES == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
//                //全屏分享
//                [HYHorizontalShareView showInSuperView:self];
//            }
//            else {
//                //竖屏分享
//                [self clickCoverShare];
//            }
//        };
//        _finishView.moreHandler = ^{
//            @strongify(self)
//            if (YES == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
//                //显示设置
//                [self showSpeedSetting];
//            }
//            else {
//                //竖屏分享
//                [self clickCoverShare];
//            }
//        };
//
//        _finishView.hidden = YES;
//    }
//    return _finishView;
//}

- (WGLPlayerNetworkStatusView *)netShowView {
    if (!_netShowView) {
        _netShowView = [[WGLPlayerNetworkStatusView alloc] initWithFrame:CGRectZero];
        _netShowView.hidden = YES;
        _netShowView.dataSource = (id<WGLPlayerNetworkStatusDataSource>)self;
        __weak typeof(self) weakSelf = self;
        _netShowView.tapHandler = ^(WGLVPNetStatus networkStatus) {
            [weakSelf p_clickNetwork:networkStatus];
        };
    }
    return _netShowView;
}

- (WGLPlayerTipView *)tipView {
    if (_tipView == nil) {
        _tipView = [[WGLPlayerTipView alloc] initWithFrame:CGRectZero];
    }
    return _tipView;
}

#pragma mark - coverView delegate

//添加定时器
- (void)addTimer:(WGLPlayerCoverViewBase *)coverView {
    [self addTimer];
}

//移除定时器
- (void)removeTimer:(WGLPlayerCoverViewBase *)coverView {
    [self removeTimer];
}

//返回
- (void)clickBack:(WGLPlayerCoverViewBase *)coverView {
    [self backAction];
}

- (void)backAction {
    
}

//全屏
- (void)clickFullScreen:(WGLPlayerCoverViewBase *)coverView {
    [self fullOrQuiteFullAction];
}

//退出全屏
- (void)clickQuiteFull:(WGLPlayerCoverViewBase *)coverView {
    [self fullOrQuiteFullAction];
}

//屏幕点击
- (void)tapCover:(WGLPlayerCoverViewBase *)coverView {
    if ([WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
        if (YES == self.fullCoverView.isHidden) {
            [self rightnowShowFullScreenCoverView];
        }
        else {
            [self rightnowHideFullScreenCoverView];
        }
    }
    else {
        if (YES == self.coverView.isHidden) {
            [self rightnowShowCoverView];
            [self delayHideCoverView];
        }
        else {
            [self rightnowHideCoverView];
        }
    }
}

//隐藏cover
- (void)hideCover:(WGLPlayerCoverViewBase *)coverView {
    if (YES == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
        [self delayHideFullScreenCoverView];
    }
    else {
        [self delayHideCoverView];
    }
}

#pragma mark - 播放状态设置

//更新播放状态
- (void)updatePlayStatus:(BOOL)isPlay {
    [self.coverView updatePlayStatus:isPlay];
    [self.fullCoverView updatePlayStatus:isPlay];
    
    if (isPlay) {
//        self.finishView.hidden = YES;
        self.resumePlayBtn.hidden = YES;
    }
    else {
        //已播放结束，则不显示恢复播放按钮，否则显示
//        BOOL isFinish = self.finishView.hidden == NO;
//        self.resumePlayBtn.hidden = isFinish;
    }
}

//开始缓冲
- (void)startBuffering {
    NSLog(@"[WGLVideoPlayerView] showLoading");
    self.loadingView.videoPlaying = NO;
    [self.loadingView showAndStartAnimation];
}

//结束缓冲
- (void)stopBuffering {
    NSLog(@"[WGLVideoPlayerView] hideLoading");
    self.loadingView.videoPlaying = YES;
    [self.loadingView hideAndStopAnimation];
    
    //隐藏网络提示
    [self showNetworkStatus:WGLVPNetStatus_None];
}

//显示网络状态
- (void)showNetworkStatus:(WGLVPNetStatus)status {
    self.netShowView.netWorkStatus = status;
}

//显示播放结束
- (void)showFinishView {
    NSLog(@"[WGLVideoPlayerView] showFinishView");
    [self rightnowHideCoverView];
    [self rightnowHideFullScreenCoverView];
    
//    self.finishView.hidden = NO;
//    [self bringSubviewToFront:self.finishView];
    
    [self setFinishUI];
    
    self.playbackProgressView.progress = 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    });
}

- (void)setFinishUI {
    BOOL isFull = [WGLVideoPlayerOption sharedOption].isEnterFullScreen;
    //竖屏，分享按钮隐藏
//    self.finishView.shareBtn.hidden = (NO == isFull);
    
    //竖屏，是否显示状态栏
//    BOOL isHideToolForCover = ((NO == isFull) && (YES == self.finishView.isHideToolForCover));
//    self.finishView.topBgView.hidden = isHideToolForCover;
    
    //隐藏所有弹出面板
    //    [HYVideoQualityManagerView dismiss];
    //    [HYVideoSettingManagerView dismiss];
    //    [VideoBarrageManagerView dismiss];
    //    [HYHorizontalShareView dismiss];
    //    [VDReportVideoView dismiss];
    //    [VDReportBarrageView dismiss];
}

- (void)aminationShowTip:(NSString *)name
                duration:(CGFloat)duration
                infoText:(NSString *)infoText
              actionText:(NSString *)actionText
                  action:(NSString *)action
         hideCloseButton:(BOOL)hideCloseButton
{
    [self.tipView aminationShow:name duration:duration infoText:infoText actionText:actionText action:action hideCloseButton:hideCloseButton];
    [self layoutTipView];
}

#pragma mark - 定时器

//开启定时器
- (void)addTimer {
    if ([self.updateUITimer isValid]) {
        return;
    }
    [self removeTimer];
    self.isStopTimer = NO;
    
    self.updateUITimer =
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(updateUI)
                                   userInfo:nil
                                    repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.updateUITimer forMode:NSRunLoopCommonModes];
}

//停止定时器
- (void)removeTimer {
    self.isStopTimer = YES;
    if (self.updateUITimer == nil) {
        return;
    }
    if ([self.updateUITimer isValid]) {
        [self.updateUITimer invalidate];
    }
    self.updateUITimer = nil;
}

//定时更新UI
- (void)updateUI {
    if (self.isStopTimer) {
        return;
    }
    
    BOOL isPlaying = [WGLVideoPlayer sharedPlayer].isPlaying;
    [self.coverView updatePlayStatus:isPlaying];
    [self.fullCoverView updatePlayStatus:isPlaying];
    
    CGFloat current = [WGLVideoPlayer sharedPlayer].currentPlaybackTime;
    CGFloat total = [WGLVideoPlayer sharedPlayer].duration;
    
    if ([WGLVideoPlayer sharedPlayer].isPlaying) {
        float currentValue = current/total;
        [self.playbackProgressView setProgress:currentValue animated:NO];
    }
}

#pragma mark - layoutSubviews

- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverView.frame = self.bounds;
    self.fullCoverView.frame = self.bounds;
//    [self.playbackProgressView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self);
//        make.bottom.equalTo(self.mas_bottom);
//        make.height.mas_equalTo(S(2));
//    }];
//    [[WGLVideoPlayer sharedPlayer] resetCorePlayerViewFrame:self.bounds];
//
//    [self.barrageView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.equalTo(self);
//    }];
//    [self.finishView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.equalTo(self);
//    }];
//    [self.netShowView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.equalTo(self);
//    }];
//    [self.loadingView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.equalTo(self);
//    }];
//    [self.resumePlayBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self);
//        make.size.mas_equalTo(CGSizeMake(S(50), S(50)));
//    }];
//    [self.volumeView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self);
//        make.size.mas_equalTo(CGSizeMake(S(170), S(41)));
//    }];
//    [self.brightnessView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self);
//        make.size.mas_equalTo(CGSizeMake(S(170), S(41)));
//    }];
//    [self.rateView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self);
//        make.size.mas_equalTo(CGSizeMake(S(100), S(41)));
//    }];
    
    [self layoutTipView];
}

- (void)layoutTipView {
//    [self.tipView mas_updateConstraints:^(MASConstraintMaker *make) {
//        CGSize preferredSize = self.tipView.preferredSize;
//        int yoffset = [WGLVideoPlayerOption sharedOption].isEnterFullScreen ? S(80) : S(40);
//        make.left.equalTo(self).offset(S(13));
//        make.top.equalTo(self.mas_bottom).offset(- yoffset - preferredSize.height);
//        make.size.mas_equalTo(preferredSize);
//    }];
}

#pragma mark - 全屏切换

//点击全屏按钮所进行的处理逻辑
- (void)fullOrQuiteFullAction {
    
    //横竖屏切换
    HYInterfaceOrientationType directionType = [self switchOrientation];
    [WGLVideoPlayerOption sharedOption].screenDirection = directionType;
    [WGLVideoPlayerOption sharedOption].isLockScreen = NO;
    
    if (directionType == HYInterfaceOrientationLandscapeRight) {
        [self switchFullScreenOrQuite:YES];
    } else {
        [self switchFullScreenOrQuite:NO];
    }
}

- (void)switchFullScreenOrQuite:(BOOL)isFull {
    if (isFull) {
        //小屏->全屏
        [self setInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
        [WGLVideoPlayerOption sharedOption].isEnterFullScreen = YES;
        
        //playerView移到window上
        if (self.superview) {
            [self removeFromSuperview];
        }
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        [self setIsFullScreen:YES];
        [self setUpLayoutAnimation:YES];
    }
    else {
        //全屏->小屏
        [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
        [WGLVideoPlayerOption sharedOption].isEnterFullScreen = NO;
        
        if (self.superview) {
            [self removeFromSuperview];
        }
        if (self.parentView) {
            [self.parentView addSubview:self];
        }
        [self setIsFullScreen:NO];
        [self setUpLayoutAnimation:YES];
    }
}

//切换屏幕方向(横竖屏切换)
- (HYInterfaceOrientationType)switchOrientation {
    HYInterfaceOrientationType directionType = [[WGLVideoPlayerOption sharedOption] getCurrentScreenDirection];
    if (directionType == HYInterfaceOrientationPortrait) {
        directionType = HYInterfaceOrientationLandscapeRight;
    }
    else if (directionType == HYInterfaceOrientationLandscapeRight) {
        directionType = HYInterfaceOrientationPortrait;
    }
    else if (directionType == HYInterfaceOrientationLandscapeLeft) {
        directionType = HYInterfaceOrientationPortrait;
    }
    else if ((directionType == HYInterfaceOrientationUnknown)
             || (directionType == HYInterfaceOrientationPortraitUpsideDown)) {
        directionType = HYInterfaceOrientationPortrait;
    }
    return directionType;
}

- (void)setUpLayoutAnimation:(BOOL)animation {
    UIView *superView = self.superview;
    
    if (superView) {
        if ([WGLVideoPlayerOption sharedOption].isEnterFullScreen == NO) {
            //非全屏模式
            
            self.backgroundColor = [UIColor clearColor];
            if (superView && self.parentView) {
                self.frame = self.parentView.bounds;
            }
        }
        else {
            //全屏模式
            
            self.backgroundColor = [UIColor blackColor];
            if (animation) {
                [UIView animateWithDuration:0.5 animations:^{
                    self.frame = superView.bounds;
                    self.center = CGPointMake(CGRectGetMidX(superView.bounds), CGRectGetMidY(superView.bounds));
                } completion:^(BOOL finished) {
                    
                }];
            }
            else {
                self.bounds = superView.bounds;
                self.center = CGPointMake(CGRectGetMidX(superView.bounds), CGRectGetMidY(superView.bounds));
            }
        }
    }
}

//强制转屏
- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        // 从2开始是因为前两个参数已经被selector和target占用
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
//    if (NO == self.finishView.hidden) {
//        //如果已经播放结束，则不显示cover
//        [self rightnowHideCoverView];
//        [self rightnowHideFullScreenCoverView];
//    }
//    else {
        if (isFullScreen) {
            [self rightnowHideCoverView];
            [self rightnowShowFullScreenCoverView];
        }
        else {
            [self rightnowHideFullScreenCoverView];
            [self rightnowShowCoverView];
        }
        
        if(NO == isFullScreen) {
            [self delayHideCoverView];
        }
//    }
    [self setFinishUI];
}

#pragma mark - 全屏coverView隐藏和显示

/**
 全屏 控制条 fullScreenCoverView
 延时5s 隐藏
 */
- (void)delayHideFullScreenCoverView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rightnowHideFullScreenCoverViewAnimation:) object:@(YES)];
    [self performSelector:@selector(rightnowHideFullScreenCoverViewAnimation:)
               withObject:@(YES)
               afterDelay:5.0f];
}

/**
 全屏 控制条 fullScreenCoverView
 即刻 隐藏
 */
- (void)rightnowHideFullScreenCoverView {
    [self rightnowHideFullScreenCoverViewAnimation:NO];
}

- (void)rightnowHideFullScreenCoverViewAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            self.fullCoverView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.fullCoverView.hidden = YES;
            self.playbackProgressView.hidden = YES;
            
            // 状态栏 和 控制条 同步隐藏显示
            if ([WGLVideoPlayerOption sharedOption].isControlStatusBarHidden) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES];
            }
        }];
    }
    else {
        self.fullCoverView.hidden = YES;
        self.playbackProgressView.hidden = YES;
        
        // 状态栏 和 控制条 同步隐藏显示
        if ([WGLVideoPlayerOption sharedOption].isControlStatusBarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
    }
}

/**
 全屏 控制条 fullScreenCoverView
 延时5s 显示
 */
- (void)delayShowFullScreenCoverView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rightnowShowFullScreenCoverViewAnimation:) object:@(YES)];
    [self performSelector:@selector(rightnowShowFullScreenCoverViewAnimation:)
               withObject:@(YES)
               afterDelay:5.0f];
}

/**
 全屏 控制条 fullScreenCoverView
 即刻 显示
 */
- (void)rightnowShowFullScreenCoverView {
    [self rightnowShowFullScreenCoverViewAnimation:NO];
}

- (void)rightnowShowFullScreenCoverViewAnimation:(BOOL)animation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rightnowHideFullScreenCoverViewAnimation:) object:@(YES)];
    
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            self.fullCoverView.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.fullCoverView.hidden = NO;
            self.playbackProgressView.hidden = YES;
            
            // 状态栏 和 控制条 同步隐藏显示
            if ([WGLVideoPlayerOption sharedOption].isControlStatusBarHidden) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
            }
            
            //延时隐藏
            [self delayHideFullScreenCoverView];
        }];
    }
    else {
        self.fullCoverView.alpha = 1.0;
        self.fullCoverView.hidden = NO;
        self.playbackProgressView.hidden = YES;
        
        // 状态栏 和 控制条 同步隐藏显示
        if ([WGLVideoPlayerOption sharedOption].isControlStatusBarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
        
        //延时隐藏
        [self delayHideFullScreenCoverView];
    }
}

#pragma mark - 非 全屏 coverView 隐藏和显示

/**
 竖屏 控制条 coverView
 延时5s 隐藏
 */
- (void)delayHideCoverView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rightnowHideCoverViewAnimation:) object:@(YES)];
    [self performSelector:@selector(rightnowHideCoverViewAnimation:)
               withObject:@(YES)
               afterDelay:5.0f];
}

/**
 竖屏 控制条 coverView
 即刻 隐藏
 */
- (void)rightnowHideCoverView {
    [self rightnowHideCoverViewAnimation:NO];
}

- (void)rightnowHideCoverViewAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            self.coverView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.coverView.hidden = YES;
            if (NO == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
                //非全屏下，才需要显示底部进度条
                self.playbackProgressView.hidden = NO;
            }
            
            // 状态栏 和 控制条 同步隐藏显示
            if ([WGLVideoPlayerOption sharedOption].isControlStatusBarHidden) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES];
            }
        }];
    }
    else {
        self.coverView.hidden = YES;
        if (NO == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
            //非全屏下，才需要显示底部进度条
            self.playbackProgressView.hidden = NO;
        }
        // 状态栏 和 控制条 同步隐藏显示
        if ([WGLVideoPlayerOption sharedOption].isControlStatusBarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
    }
}

/**
 竖屏 控制条 coverView
 延时5s 显示
 */
- (void)delayShowCoverView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rightnowShowCoverViewAnimation:) object:@(YES)];
    [self performSelector:@selector(rightnowShowCoverViewAnimation:)
               withObject:@(YES)
               afterDelay:5.0f];
}

/**
 竖屏 控制条 coverView
 即刻 显示
 */
- (void)rightnowShowCoverView {
    [self rightnowShowCoverViewAnimation:NO];
}

- (void)rightnowShowCoverViewAnimation:(BOOL)animation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rightnowHideCoverViewAnimation:) object:@(YES)];
    
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            self.coverView.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.coverView.hidden = NO;
            self.playbackProgressView.hidden = YES;
            
            // 状态栏 和 控制条 同步隐藏显示
            if ([WGLVideoPlayerOption sharedOption].isControlStatusBarHidden) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
            }
            
            //延时隐藏
            [self delayHideCoverView];
        }];
    }
    else {
        self.coverView.alpha = 1.0;
        self.coverView.hidden = NO;
        self.playbackProgressView.hidden = YES;
        
        // 状态栏 和 控制条 同步隐藏显示
        if ([WGLVideoPlayerOption sharedOption].isControlStatusBarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
        
        //延时隐藏
        [self delayHideCoverView];
    }
}

#pragma mark - 手势事件

//添加手势
- (void)addGestures {
    //添加手势监听
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gr_singleTap:)];
    singleTap.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gr_doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)gr_singleTap:(UITapGestureRecognizer *)tapGr {
    NSLog(@"[WGLVideoPlayerView] gr_singleTap");
    
    [self playerViewDidTap];
}

- (void)gr_doubleTap:(UITapGestureRecognizer *)tapGr {
    NSLog(@"[WGLVideoPlayerView] gr_doubleTap");
    BOOL isPlaying = [WGLVideoPlayer sharedPlayer].isPlaying;
    if (isPlaying) {
        [[WGLVideoPlayer sharedPlayer] pause];
    }
    else {
        [[WGLVideoPlayer sharedPlayer] play];
    }
}

//点击视频画面
- (void)playerViewDidTap {
    NSLog(@"[WGLVideoPlayerView] playerViewDidTap");
    
    if (YES == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
        if (YES == self.fullCoverView.isHidden) {
            [self rightnowShowFullScreenCoverView];
        }
        else {
            [self rightnowHideFullScreenCoverView];
        }
    }
    else {
        if (YES == self.coverView.isHidden) {
            [self rightnowShowCoverView];
        }
        else {
            [self rightnowHideCoverView];
        }
    }
}

#pragma mark - touch事件

- (WGLVideoPlayerGesturer *)gestureHelper {
    if (!_gestureHelper) {
        _gestureHelper = [[WGLVideoPlayerGesturer alloc] init];
    }
    return _gestureHelper;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.gestureHelper touchesBegan:touches withEvent:event inView:self callback:^(WGLAjustType ajustType, CGFloat value) {
        
    }];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.gestureHelper touchesMoved:touches withEvent:event inView:self  callback:^(WGLAjustType ajustType, CGFloat value){
        switch (ajustType) {
            case WGLAjustTypeVolume: {
                //调节音量
                self.brightnessView.hidden = YES;
                [self.volumeView setVolumeValue:value animated:YES];
            }
                break;
            case WGLAjustTypeBrightness: {
                //调节亮度
                self.volumeView.hidden = YES;
                [self.brightnessView setBrightnessValue:value animated:YES];
            }
                break;
            case WGLAjustTypeVideoRate: {
                //调节进度
                CGFloat rate = self.gestureHelper.endVideoRate;
                NSTimeInterval duration = [WGLVideoPlayer sharedPlayer].duration;
                NSTimeInterval currentTime = duration * rate;
                
                NSString *currentStr = [WGLVideoPlayerOption timeformatFromSeconds:currentTime];
                NSString *durationStr = [WGLVideoPlayerOption timeformatFromSeconds:duration];
                [self.rateView setCurrentTime:currentStr duration:durationStr];
                
                if (YES == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
                    [self.fullCoverView.sliderView setValue:rate animated:YES];
                }
                else {
                    [self.coverView.sliderView setValue:rate animated:YES];
                }
                [self.playbackProgressView setProgress:rate animated:YES];
            }
                break;
            default:
                break;
        }
        
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.gestureHelper touchesEnded:touches withEvent:event inView:self callback:^{
        [self gestureEndAction];
    }];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self.gestureHelper touchesEnded:touches withEvent:event inView:self callback:^{
        [self gestureEndAction];
    }];
}

- (void)gestureEndAction {
    if (self.gestureHelper.direction == WGLGestureDirectionLeftOrRight) {
        NSLog(@"current : %f, duration : %f", [WGLVideoPlayer sharedPlayer].currentPlaybackTime, [WGLVideoPlayer sharedPlayer].duration);
        NSTimeInterval duration = [WGLVideoPlayer sharedPlayer].duration;
        NSTimeInterval currentTime = duration * self.gestureHelper.endVideoRate;
        [WGLVideoPlayer sharedPlayer].currentPlaybackTime = currentTime;
        [self addTimer];
    }
    if (YES == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
        [self delayHideFullScreenCoverView];
    }
    else {
        [self delayHideCoverView];
    }
}

#pragma mark - finish actions

//- (void)p_clickFinishWithType:(HYAVPlayerShareType)type {
//    NSLog(@"[WGLVideoPlayerView] p_clickFinishWithType type:%ld", type);
//
//    switch (type) {
//        case HYAVPlayerShareTypeReplay: {
//            //重播
//            [[WGLVideoPlayer sharedPlayer] replay];
//        }
//            break;
//        case HYAVPlayerShareTypeWechat: {
//            //微信分享
//        }
//            break;
//        case HYAVPlayerShareTypeQQ: {
//            //QQ分享
//        }
//            break;
//        case HYAVPlayerShareTypeSina: {
//            //新浪分享
//        }
//            break;
//        default:
//            break;
//    }
//}

#pragma mark - cover button actions

- (void)showSpeedSetting {
    NSString *speed = [WGLVideoPlayerOption sharedOption].speed ?: @"1.0";
//    [HYVideoSettingManagerView showInSuperView:self speed:speed];
}

- (void)clickCoverShare {
    
}

//点击网络状态
- (void)p_clickNetwork:(WGLVPNetStatus)status {
    NSLog(@"[WGLVideoPlayerView] p_clickNetwork:%ld", status);
    
    switch (status) {
        case WGLVPNetStatus_None: {
            //点击没网，则重试
            [[WGLVideoPlayer sharedPlayer] play];
        }
            break;
        case WGLVPNetStatus_WWan: {
            //点击 移动网络，则继续播放
            [[WGLVideoPlayer sharedPlayer] play];
            
            [WGLVideoPlayerOption sharedOption].isAllowWWAN = YES;
        }
            break;
        case WGLVPNetStatus_Error: {
            //播放出错
            [[WGLVideoPlayer sharedPlayer] forceRestartPlayer];
            self.netShowView.hidden = YES;
        }
            break;
        default:
            break;
    }
}

- (void)p_resumePlay {
    [[WGLVideoPlayer sharedPlayer] play];
}

#pragma mark - WGLPlayerNetworkStatusViewDataSource

- (uint64_t)trafficForCurrentVideo:(WGLPlayerNetworkStatusView *)networkStatusView {
    uint64_t traffic = [[WGLURLProvider sharedProvider] trafficForCurrentVideo];
    return traffic;
}

#pragma mark - 通知

- (void)addObserver {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //网络状态发生变化的时候的通知方法
//    [center addObserver:self
//               selector:@selector(n_netWorkStatesChange:)
//                   name:YYNetworkStatus_Changed
//                 object:nil];
    //转屏的通知方法
    [center addObserver:self
               selector:@selector(n_statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification
                 object:nil];
}

//网络状态发生变化通知方法
- (void)n_netWorkStatesChange:(NSNotification *)notification {
    NSDictionary *msgObject = notification.object;
//    if ([msgObject isKindOfClass:[NSDictionary class]]) {
//        YYNetStatus netStatus = [msgObject[@"YYNetStatus"] intValue];
//        NSLog(@"[WGLVideoPlayerView] n_netWorkStatesChange netStatus:%ld", netStatus);
//
//        [self networkChangeEventForNetType:netStatus];
//    }
}

//网络状态改变的事件
- (void)networkChangeEventForNetType:(WGLVPNetStatus)netStatus {
    [self bringSubviewToFront:self.netShowView];
    switch (netStatus) {
        case WGLVPNetStatus_None: {    //切换到 无网络
            if ([WGLVideoPlayerOption sharedOption].isBeingAppearState) {
                //显示无网界面
                self.netShowView.netWorkStatus = WGLVPNetStatus_None;
//                self.finishView.hidden = YES;
                
                //把视频暂停
                [[WGLVideoPlayer sharedPlayer] pause];
            }
        }
            break;
        case WGLVPNetStatus_WWan: {    //切换到流量状态，3G或者4G，反正用的是流量
            //显示流量提醒界面
            self.netShowView.netWorkStatus = WGLVPNetStatus_WWan;
//            self.finishView.hidden = YES;
            
            [[WGLVideoPlayer sharedPlayer] pause];
            //使用的时候，需要记录一下视频播放器的属性，这个已经在HYPlayerView里面做好了
            //先把视频暂停，虽然暂停了，但是这个时候要是有缓冲的
        }
            break;
        case WGLVPNetStatus_Wifi: {
            //网络切换成了WIFI状态：如果不是在可见界面，或者不是第一响应者，就不需要做任何处理
            self.netShowView.hidden = YES;
            [[WGLVideoPlayer sharedPlayer] play];
        }
            break;
        case WGLVPNetStatus_Error: {
            //无效网络
            self.netShowView.netWorkStatus = WGLVPNetStatus_Error;
//            self.finishView.hidden = YES;
        }
            break;
        default:
            break;
    }
}

//屏幕旋转的通知方法。
- (void)n_statusBarOrientationChange:(NSNotification *)notification {
    [self statusBarOrientationChange];
}

//屏幕旋转
- (void)statusBarOrientationChange {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSLog(@"[WGLVideoPlayerView] statusBarOrientationChange orientation:%ld", orientation);
    
    if (orientation == UIInterfaceOrientationLandscapeRight) { // home键靠右
        if (NO == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
            [self switchFullScreenOrQuite:YES];
        }
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft) {// home键靠左
        if (NO == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
            [self switchFullScreenOrQuite:YES];
        }
    }
    else if (orientation == UIInterfaceOrientationPortrait) {   //home键在下面
        if (YES == [WGLVideoPlayerOption sharedOption].isEnterFullScreen) {
            [self switchFullScreenOrQuite:NO];
        }
    }
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {//home键在上面
    }
    else if (orientation == UIInterfaceOrientationUnknown) {
    }
}

@end
