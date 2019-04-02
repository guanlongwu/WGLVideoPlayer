//
//  WGLPlayerCoverView.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLPlayerCoverView.h"
#import "WGLVideoPlayer.h"
#import "WGLURLProvider.h"
#import "WGLVideoPlayerOption.h"

@interface WGLPlayerCoverView ()

@end

@implementation WGLPlayerCoverView
@synthesize backBtn = _backBtn;
@synthesize moreBtn = _moreBtn;
@synthesize shareBtn = _shareBtn;
@synthesize titleLabel = _titleLabel;
@synthesize playBtn = _playBtn;
@synthesize fullScreenBtn = _fullScreenBtn;
@synthesize lblTotalTime = _lblTotalTime;
@synthesize lblCurrentTime = _lblCurrentTime;
@synthesize progressView = _progressView;
@synthesize sliderView = _sliderView;
@synthesize tapGesture = _tapGesture;
@synthesize avatarView = _avatarView;
@synthesize nickLabel = _nickLabel;
@synthesize nick = _nick;
@synthesize avatar = _avatar;

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self addGestures];//添加手势监听
    }
    return self;
}

//添加手势
- (void)addGestures {
    //添加手势监听
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gr_singleTap:)];
    singleTap.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gr_doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)setupUI {
    
    //阻挡手势的view
    [self addSubview:self.topBgView];
    [self addSubview:self.bottomBgView];
    
    //阴影
    [self.topBgView addSubview:self.topShadowBgView];
    [self.bottomBgView addSubview:self.bottomShadowBgView];
    
    [self.topBgView addSubview:self.backBtn];//返回
    [self.topBgView addSubview:self.moreBtn];//更多
    [self addSubview:self.titleLabel];//标题
    
    [self.bottomBgView addSubview:self.fullScreenBtn];//全屏
    [self.bottomBgView addSubview:self.lblCurrentTime];//当前播放时间
    [self.bottomBgView addSubview:self.lblTotalTime];  //视频总时长
    [self.bottomBgView addSubview:self.progressView];  //缓冲进度条
    [self.bottomBgView addSubview:self.sliderView];    //播放进度条
    [self.bottomBgView addSubview:self.playBtn];//播放、暂停
    [self.bottomBgView addSubview:self.barrageShieldingBtn];//屏蔽弹幕
    
    [self addSubview:self.nickLabel];
    [self addSubview:self.avatarView];
}

- (UIView *)topBgView {
    if (!_topBgView) {
        _topBgView = [[UIView alloc] init];
    }
    return _topBgView;
}

- (UIView *)bottomBgView {
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc] init];
    }
    return _bottomBgView;
}

- (UIImageView *)topShadowBgView {
    if (!_topShadowBgView) {
        _topShadowBgView = [[UIImageView alloc] init];
        _topShadowBgView.image = [UIImage imageNamed:@"bg_player_top_shadow"];
    }
    return _topShadowBgView;
}

- (UIImageView *)bottomShadowBgView {
    if (!_bottomShadowBgView) {
        _bottomShadowBgView = [[UIImageView alloc] init];
        _bottomShadowBgView.image = [UIImage imageNamed:@"bg_player_bottom_shadow"];
    }
    return _bottomShadowBgView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"icon_player_back_normal"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"icon_player_back_selected"] forState:UIControlStateHighlighted];
        _backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [_backBtn addTarget:self action:@selector(p_back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] init];
        [_moreBtn setImage:[UIImage imageNamed:@"icon_player_more_normal"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"icon_player_more_selected"] forState:UIControlStateHighlighted];
        _moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _moreBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    }
    return _moreBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [[UIButton alloc] init];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"icon_player_fullScreen_normal"] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"icon_player_fullScreen_selected"] forState:UIControlStateHighlighted];
        _fullScreenBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _fullScreenBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_fullScreenBtn addTarget:self action:@selector(p_fullScreen) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"icon_player_pause"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"icon_player_play"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(p_playOption) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UILabel *)lblCurrentTime {
    if (!_lblCurrentTime) {
        _lblCurrentTime = [[UILabel alloc] init];
        _lblCurrentTime.font = [UIFont systemFontOfSize:15];
        _lblCurrentTime.textAlignment = NSTextAlignmentLeft;
        _lblCurrentTime.textColor = [UIColor whiteColor];
    }
    return _lblCurrentTime;
}

- (UILabel *)lblTotalTime {
    if (!_lblTotalTime) {
        _lblTotalTime = [[UILabel alloc] init];
        _lblTotalTime.font = [UIFont systemFontOfSize:15];
        _lblTotalTime.textAlignment = NSTextAlignmentRight;
        _lblTotalTime.textColor = [UIColor whiteColor];
    }
    return _lblTotalTime;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.trackTintColor = [UIColor grayColor];
        _progressView.progressTintColor = [UIColor whiteColor];
        [_progressView setProgress:0];
    }
    return _progressView;
}

- (WGLSlider *)sliderView {
    if (!_sliderView) {
        _sliderView = [[WGLSlider alloc] init];
        _sliderView.userInteractionEnabled = YES;
        _sliderView.continuous = NO;//设置为NO,只有在手指离开的时候调用valueChange
        _sliderView.minimumTrackTintColor = [UIColor grayColor];
        _sliderView.maximumTrackTintColor = [UIColor clearColor];
        _sliderView.thumbTintColor = [UIColor grayColor];
        _sliderView.minimumValue = 0;
        _sliderView.maximumValue = 1;
        _sliderView.enabled = YES;
        [_sliderView setThumbImage:[UIImage imageNamed:@"icon_player_slider_thumb"] forState:UIControlStateNormal];
        [_sliderView setThumbImage:[UIImage imageNamed:@"icon_player_slider_thumb"] forState:UIControlStateHighlighted];

        [_sliderView addTarget:self action:@selector(sliderTouchDownEvent:) forControlEvents:UIControlEventTouchDown];
        [_sliderView addTarget:self action:@selector(sliderValuechange:) forControlEvents:UIControlEventValueChanged];
        [_sliderView addTarget:self action:@selector(sliderTouchUpEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_sliderView addTarget:self action:@selector(sliderTouchUpEvent:) forControlEvents:UIControlEventTouchUpOutside];

        [_sliderView addGestureRecognizer:self.tapGesture];

    }
    return _sliderView;
}

- (UIButton *)barrageShieldingBtn {
    if (!_barrageShieldingBtn) {
        _barrageShieldingBtn = [[UIButton alloc] init];
        [_barrageShieldingBtn setImage:[UIImage imageNamed:@"icon_vplayer_barrage_shielding_normal"] forState:UIControlStateNormal];
        [_barrageShieldingBtn setImage:[UIImage imageNamed:@"icon_vplayer_barrage_shielding_selected"] forState:UIControlStateSelected];
    }
    return _barrageShieldingBtn;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTap:)];
    }
    return _tapGesture;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.clipsToBounds = YES;
    }
    return _avatarView;
}

- (UIButton *)nickLabel {
    if (!_nickLabel) {
        _nickLabel = [[UIButton alloc] init];
        [_nickLabel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _nickLabel.titleLabel.font = [UIFont systemFontOfSize:10];
        _nickLabel.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        _nickLabel.layer.cornerRadius = 3;
    }
    return _nickLabel;
}

- (void)setAvatar:(NSString *)avatar {
    _avatar = avatar;
    //TODO:
//    [self.avatarView hy_setImageWithURL:avatar placeholder:kPlaceholderUserIcon];
}

- (void)setNick:(NSString *)nick {
    _nick = nick;
    [self.nickLabel setTitle:nick forState:UIControlStateNormal];
    [self layoutSubviews];
}

#pragma mark - layoutSubviews

- (void)layoutSubviews {
    [super layoutSubviews];
    //TODO:
//    [self.topBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.equalTo(self);
//        make.height.mas_equalTo(S(50));
//    }];
//
//    [self.bottomBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self);
//        make.height.mas_equalTo(S(40));
//    }];
//
//    [self.topShadowBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.equalTo(self);
//    }];
//
//    [self.bottomShadowBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self);
//    }];
//
//    [self.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.topBgView).offset(S(17.5));
//        make.top.equalTo(self.topBgView).offset(AspectStatusBarHeight - AspectStatusBarOffsetY + S(3));
//        make.size.mas_equalTo(CGSizeMake(S(50), S(30)));
//    }];
//
//    [self.moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.topBgView.mas_right).offset(-S(10));
//        make.top.equalTo(self.backBtn.mas_top);
//        make.size.mas_equalTo(CGSizeMake(S(50), S(30)));
//    }];
//
//    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(S(15));
//        make.right.equalTo(self.mas_right).offset(-S(15));
//        make.top.equalTo(self);
//        make.height.mas_equalTo(S(50));
//    }];
//
//    [self.playBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.bottomBgView).offset(S(13));
//        make.bottom.equalTo(self.bottomBgView.mas_bottom).offset(-S(6));
//    }];
//
//    [self.fullScreenBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.bottomBgView.mas_right).offset(-S(0));
//        make.centerY.equalTo(self.playBtn.mas_centerY);
//        make.size.mas_equalTo(CGSizeMake(S(40), S(40)));
//    }];
//
//    [self.barrageShieldingBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.fullScreenBtn.mas_left);
//        make.centerY.equalTo(self.playBtn.mas_centerY);
//        make.size.mas_equalTo(CGSizeMake(S(28), S(40)));
//    }];
//
//    [self.lblTotalTime sizeToFit];
//    [self.lblTotalTime mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.barrageShieldingBtn.mas_left).offset(-S(10));
//        make.centerY.equalTo(self.playBtn.mas_centerY);
//    }];
//
//    [self.lblCurrentTime sizeToFit];
//    [self.lblCurrentTime mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.lblTotalTime.mas_left);
//        make.centerY.equalTo(self.playBtn.mas_centerY);
//    }];
//
//    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.playBtn.mas_right).offset(S(5));
//        make.right.equalTo(self.lblCurrentTime.mas_left).offset(-S(12));
//        make.centerY.equalTo(self.playBtn.mas_centerY);
//    }];
//
//    [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.progressView);
//        make.centerY.equalTo(self.progressView).offset(-S(1));
//        make.height.mas_equalTo(S(40));
//    }];
//
//    CGFloat nickW = [YYStringUtils sizeOfString:self.nickLabel.titleLabel.text font:self.nickLabel.titleLabel.font maxwidth:S(80)].width + S(15) + S(10);
//    [self.nickLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.mas_right).offset(-S(15));
//        make.bottom.equalTo(self.bottomBgView.mas_top).offset(-S(10));
//        make.height.mas_equalTo(S(22));
//        make.width.mas_equalTo(@(nickW));
//    }];
//    self.nickLabel.titleEdgeInsets = UIEdgeInsetsMake(0, S(15), 0, S(5));
//
//    [self.avatarView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.nickLabel.mas_left).offset(S(10));
//        make.centerY.equalTo(self.nickLabel.mas_centerY);
//        make.size.mas_equalTo(CGSizeMake(S(34), S(34)));
//    }];
//    self.avatarView.layer.cornerRadius = S(34) / 2;
    
}

#pragma mark - 播放进度条event

//滑块的touchDown方法
- (void)sliderTouchDownEvent:(UISlider *)sender {
    NSLog(@"[HYVideoPlayerCoverView] sliderTouchDownEvent sender.value:%f", sender.value);
    
    [self removeTimer];
}

//滑块的touchUp方法
- (void)sliderTouchUpEvent:(UISlider *)sender {
    NSTimeInterval duration = [WGLVideoPlayer sharedPlayer].duration;
    NSLog(@"[HYVideoPlayerCoverView] sliderTouchUpEvent sender.value:%f, player.duration:%f", sender.value, duration);
    
    double value = sender.value * duration;
    
    BOOL isFinish = NO;
    if (value == duration) {
        isFinish = YES;
        if (duration > 5.00) {
            value = duration - 1.0;
        }
        else if (duration <= 5.0) {
            value = duration * 0.8;
        }
    }
    
    self.tapGesture.enabled = YES;
    //调整播放进度
    [WGLVideoPlayer sharedPlayer].currentPlaybackTime = value;
    
    if ([WGLVideoPlayer sharedPlayer].isPlaying) {
        [[WGLVideoPlayer sharedPlayer] play];
        
#ifdef VIDEOPLAYER_MONITOR
        [[VideoPlayerMonitor defaultMonitor] mediaSeekStart];
#endif
    }
    
    self.lblCurrentTime.text =
    [WGLVideoPlayerOption timeformatFromSeconds:value];
    
    if (isFinish) {
        [self removeTimer];
        [self.sliderView setValue:1 animated:NO];
    }
    else {
        [self addTimer];
    }
}

//滑块的值发生改变
- (void)sliderValuechange:(UISlider *)sender {
    [self hideCoverView];
}

//点击滑块操作
- (void)sliderTap:(UITapGestureRecognizer *)tap {
    UISlider *slider = (UISlider *)tap.view;
    CGPoint point = [tap locationInView:self.sliderView];
    double value = point.x/self.sliderView.bounds.size.width*1;

    NSTimeInterval duration = [WGLVideoPlayer sharedPlayer].duration;
    NSLog(@"[HYVideoPlayerCoverView] sliderTap value:%f, player.duration:%f", value, duration);

    if (value == duration) {
        if (duration > 5.00) {
            value = duration - 1.0;
        }
        else if (duration <= 5.0) {
            value = duration * 0.8;
        }
        [self removeTimer];
        [self.sliderView setValue:1 animated:NO];
    }
    else {
        [self addTimer];
    }

    [self.sliderView setValue:value animated:YES];
    self.lblCurrentTime.text = [WGLVideoPlayerOption timeformatFromSeconds:value];

    NSTimeInterval currentTime = slider.value * duration;
    [WGLVideoPlayer sharedPlayer].currentPlaybackTime = currentTime;

    if ([WGLVideoPlayer sharedPlayer].isPlaying) {
        [self play];

#ifdef VIDEOPLAYER_MONITOR
        [[VideoPlayerMonitor defaultMonitor] mediaSeekStart];
#endif
    }
    [self hideCoverView];
}

#pragma mark - 手势事件

- (void)gr_singleTap:(UITapGestureRecognizer *)tapGr {
    NSLog(@"[HYVideoPlayerCoverView] gr_singleTap");
    
    if ([self.delegate respondsToSelector:@selector(tapCover:)]) {
        [self.delegate tapCover:self];
    }
}

- (void)gr_doubleTap:(UITapGestureRecognizer *)tapGr {
    NSLog(@"[HYVideoPlayerCoverView] gr_doubleTap");
    [self p_playOption];
}

#pragma mark - events

//播放和暂停
- (void)p_playOption {
    NSLog(@"[HYVideoPlayerCoverView] playOption");
    self.playBtn.selected = !self.playBtn.selected;
    if (self.playBtn.selected) {
        //暂停
        [[WGLVideoPlayer sharedPlayer] pause];
        [self play];
    } else {
        //播放
        [[WGLVideoPlayer sharedPlayer] play];
    }
    [self hideCoverView];
}

//点击屏蔽弹幕
- (void)shieldingBarrageClick:(BOOL)isSelectd
{
    self.barrageShieldingBtn.selected = isSelectd;
}

- (void)p_back {
    NSLog(@"[HYVideoPlayerCoverView] p_clickBack");
    if ([self.delegate respondsToSelector:@selector(clickBack:)]) {
        [self.delegate clickBack:self];
    }
}

- (void)p_fullScreen {
    NSLog(@"[HYVideoPlayerCoverView] fullScreen");
    self.fullScreenBtn.selected = !self.fullScreenBtn.selected;
    if ([self.delegate respondsToSelector:@selector(clickFullScreen:)]) {
        [self.delegate clickFullScreen:self];
    }
}

#pragma mark - protocol

//播放
- (void)play {
    
}

//暂停
- (void)pause {
    
}

//重播
- (void)replay {
    
}

//更新播放状态
- (void)updatePlayStatus:(BOOL)isPlay {
    //播放按钮update
    self.playBtn.selected = isPlay == YES ? NO : YES;
    
    //进度update
    CGFloat current = [WGLVideoPlayer sharedPlayer].currentPlaybackTime;
    CGFloat total = [WGLVideoPlayer sharedPlayer].duration;
    CGFloat able = [WGLVideoPlayer sharedPlayer].playableDuration;
    if (isPlay) {
        self.lblCurrentTime.text = [WGLVideoPlayerOption timeformatFromSeconds:current];
        self.lblTotalTime.text = [NSString stringWithFormat:@"/%@", [WGLVideoPlayerOption timeformatFromSeconds:total]];
        
        float currentValue = current/total;
        float progressValue = able/total > 0.9 ? 1.0 : able/total;//缓冲结束，able偶尔会比total的值小一点
        
        [self.sliderView setValue:currentValue animated:NO];
        [self.progressView setProgress:progressValue animated:NO];
    }
}

#pragma mark - 回调

//添加定时器
- (void)addTimer {
    if ([self.delegate respondsToSelector:@selector(addTimer:)]) {
        [self.delegate addTimer:self];
    }
}

//移除定时器
- (void)removeTimer {
    if ([self.delegate respondsToSelector:@selector(removeTimer:)]) {
        [self.delegate removeTimer:self];
    }
}

//隐藏方法
- (void)hideCoverView {
    if ([self.delegate respondsToSelector:@selector(hideCover:)]) {
        [self.delegate hideCover:self];
    }
}

@end
