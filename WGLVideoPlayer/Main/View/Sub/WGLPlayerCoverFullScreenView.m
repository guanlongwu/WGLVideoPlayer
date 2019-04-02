//
//  WGLPlayerCoverFullScreenView.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLPlayerCoverFullScreenView.h"
#import "WGLVideoPlayer.h"
#import "WGLVideoPlayerOption.h"
#import "WGLURLProvider.h"

@interface WGLPlayerCoverFullScreenView ()
@property (nonatomic, strong) UIView *topGrView, *bottomGrView;
@end

@implementation WGLPlayerCoverFullScreenView
@synthesize backBtn = _backBtn;
@synthesize moreBtn = _moreBtn;
@synthesize shareBtn = _shareBtn;
@synthesize titleLabel = _titleLabel;
@synthesize playBtn = _playBtn;
@synthesize fullScreenBtn = _fullScreenBtn;
@synthesize lblTotalTime = _lblTotalTime;
@synthesize lblCurrentTime = _lblCurrentTime;
@synthesize progressView = _progressView;
//@synthesize sliderView = _sliderView;
@synthesize tapGesture = _tapGesture;
@synthesize avatarView = _avatarView;
@synthesize nickLabel = _nickLabel;
@synthesize nick = _nick;
@synthesize avatar = _avatar;



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self addGestures];//添加手势
    }
    return self;
}

- (void)setupUI {
    
    //阻挡手势的view
    [self addSubview:self.topGrView];
    [self addSubview:self.bottomGrView];
    
    //阴影
    [self addSubview:self.topShadowBgView];
    [self addSubview:self.bottomShadowBgView];
    
    [self addSubview:self.backBtn];//返回
    [self addSubview:self.moreBtn];//更多
    [self addSubview:self.shareBtn];//分享
    [self addSubview:self.titleLabel];//标题
    
    [self addSubview:self.lblCurrentTime];//当前播放时间
    [self addSubview:self.lblTotalTime];  //视频总时长
    [self addSubview:self.progressView];  //缓冲进度条
//    [self addSubview:self.sliderView];    //播放进度条
    [self addSubview:self.playBtn];//播放、暂停
    
    [self addSubview:self.barrageShieldingBtn];//屏蔽弹幕
    [self addSubview:self.barrageSettingBtn];//设置弹幕
    [self addSubview:self.barrageSenderBtn];//发送弹幕
    
    [self addSubview:self.qualityLabel];    //清晰度
    [self addSubview:self.qualityBtn];
    
    [self addSubview:self.lockBtn]; //屏幕锁定
    
    [self addSubview:self.nickLabel];
    [self addSubview:self.avatarView];
}

- (UIView *)topGrView {
    if (!_topGrView) {
        _topGrView = [[UIView alloc] init];
    }
    return _topGrView;
}

- (UIView *)bottomGrView {
    if (!_bottomGrView) {
        _bottomGrView = [[UIView alloc] init];
    }
    return _bottomGrView;
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
        _backBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_backBtn addTarget:self action:@selector(p_back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] init];
        [_moreBtn setImage:[UIImage imageNamed:@"icon_player_more_normal"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"icon_player_more_selected"] forState:UIControlStateHighlighted];
        _moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _moreBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    return _moreBtn;
}

- (UIButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [[UIButton alloc] init];
        [_shareBtn setImage:[UIImage imageNamed:@"icon_player_share_normal"] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"icon_player_share_selected"] forState:UIControlStateHighlighted];
        _shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _shareBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    return _shareBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
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

//- (WGLSlider *)sliderView {
//    if (!_sliderView) {
//        _sliderView = [[WGLSlider alloc] init];
//        _sliderView.userInteractionEnabled = YES;
//        _sliderView.continuous = NO;//设置为NO,只有在手指离开的时候调用valueChange
//        _sliderView.minimumTrackTintColor = [UIColor grayColor];
//        _sliderView.maximumTrackTintColor = [UIColor clearColor];
//        _sliderView.thumbTintColor = [UIColor grayColor];
//        _sliderView.minimumValue = 0;
//        _sliderView.maximumValue = 1;
//        _sliderView.enabled = YES;
//        [_sliderView setThumbImage:[UIImage imageNamed:@"icon_player_slider_thumb"] forState:UIControlStateNormal];
//        [_sliderView setThumbImage:[UIImage imageNamed:@"icon_player_slider_thumb"] forState:UIControlStateHighlighted];
//
//        [_sliderView addTarget:self action:@selector(sliderTouchDownEvent:) forControlEvents:UIControlEventTouchDown];
//        [_sliderView addTarget:self action:@selector(sliderValuechange:) forControlEvents:UIControlEventValueChanged];
//        [_sliderView addTarget:self action:@selector(sliderTouchUpEvent:) forControlEvents:UIControlEventTouchUpInside];
//        [_sliderView addTarget:self action:@selector(sliderTouchUpEvent:) forControlEvents:UIControlEventTouchUpOutside];
//
//        [_sliderView addGestureRecognizer:self.tapGesture];
//
//    }
//    return _sliderView;
//}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTap:)];
    }
    return _tapGesture;
}

- (UIButton *)barrageShieldingBtn {
    if (!_barrageShieldingBtn) {
        _barrageShieldingBtn = [[UIButton alloc] init];
        [_barrageShieldingBtn setImage:[UIImage imageNamed:@"icon_player_barrage_shielding_normal"] forState:UIControlStateNormal];
        [_barrageShieldingBtn setImage:[UIImage imageNamed:@"button_barrage_scroll_selected"] forState:UIControlStateSelected];
    }
    return _barrageShieldingBtn;
}

- (UIButton *)barrageSettingBtn {
    if (!_barrageSettingBtn) {
        _barrageSettingBtn = [[UIButton alloc] init];
        [_barrageSettingBtn setImage:[UIImage imageNamed:@"icon_player_barrage_setting"] forState:UIControlStateNormal];
    }
    return _barrageSettingBtn;
}

- (UIButton *)lockBtn {
    if (!_lockBtn) {
        _lockBtn = [[UIButton alloc] init];
        [_lockBtn setImage:[UIImage imageNamed:@"icon_player_lock"] forState:UIControlStateNormal];
        [_lockBtn addTarget:self action:@selector(p_lock) forControlEvents:UIControlEventTouchUpInside];
        _lockBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _lockBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _lockBtn.layer.cornerRadius = 5;
    }
    return _lockBtn;
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
        _nickLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        _nickLabel.layer.cornerRadius = 3;
    }
    return _nickLabel;
}

//添加手势
- (void)addGestures {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gr_singleTap:)];
    singleTap.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gr_doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (UIButton *)barrageSenderBtn
{
    if(!_barrageSenderBtn){
        _barrageSenderBtn = [[UIButton alloc] init];
        _barrageSenderBtn.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        [_barrageSenderBtn setTitle:@"弹幕填装，发射！" forState:UIControlStateNormal];
        _barrageSenderBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_barrageSenderBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_barrageSenderBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        _barrageSenderBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _barrageSenderBtn;
}

- (UIButton *)qualityBtn {
    if (!_qualityBtn) {
        _qualityBtn = [[UIButton alloc] init];
    }
    return _qualityBtn;
}

- (UILabel *)qualityLabel {
    if (!_qualityLabel) {
        _qualityLabel = [[UILabel alloc] init];
        _qualityLabel.textColor = [UIColor whiteColor];
        _qualityLabel.font = [UIFont systemFontOfSize:13];
    }
    return _qualityLabel;
}

#pragma mark - UI布局

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    [self.topGrView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.equalTo(self);
//        make.height.mas_equalTo(S(80));
//    }];
//
//    [self.bottomGrView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self);
//        make.height.mas_equalTo(S(80));
//    }];
//
//    [self.topShadowBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.equalTo(self);
//    }];
//
//    [self.bottomShadowBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self);
//        make.height.mas_equalTo(S(60));
//    }];
//
//    [self.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(S(17.5));
//        make.top.equalTo(self).offset(AspectStatusBarHeight);
//        make.size.mas_equalTo(CGSizeMake(S(50), S(40)));
//    }];
//
//    [self.moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.mas_right).offset(-S(5));
//        make.top.equalTo(self.backBtn.mas_top);
//        make.size.mas_equalTo(CGSizeMake(S(50), S(40)));
//    }];
//
//    [self.shareBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.moreBtn.mas_left).offset(-S(15));
//        make.top.equalTo(self.backBtn.mas_top);
//        make.size.mas_equalTo(CGSizeMake(S(50), S(40)));
//    }];
//
//    CGFloat titleW = self.shareBtn.left - self.backBtn.right + S(15);
//    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.backBtn.mas_right).offset(-S(20));
//        make.width.mas_equalTo(titleW);
//        make.centerY.equalTo(self.backBtn.mas_centerY);
//    }];
//
//    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self);
//        make.right.equalTo(self);
//        make.bottom.equalTo(self.mas_bottom).offset(-S(49));
//    }];
//
//    CGFloat offsetY = IS_IPHONE_HEIGHT_OVER_736 ? 0 : -S(1);
//    [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.progressView);
//        make.centerY.equalTo(self.progressView).offset(offsetY);
//        make.height.mas_equalTo(S(16));
//    }];
//
//    [self.playBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(S(17.5));
//        make.bottom.equalTo(self.mas_bottom).offset(-S(12));
//    }];
//
//    [self.lblCurrentTime sizeToFit];
//    [self.lblCurrentTime mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.playBtn.mas_right).offset(S(25));
//        make.centerY.equalTo(self.playBtn.mas_centerY);
//    }];
//
//    [self.lblTotalTime sizeToFit];
//    [self.lblTotalTime mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.lblCurrentTime.mas_right);
//        make.centerY.equalTo(self.lblCurrentTime.mas_centerY);
//    }];
//
//    CGFloat barrageLeft = [self p_shieldBarrageLeft];
//    [self.barrageShieldingBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.lblCurrentTime.mas_left).offset(barrageLeft + S(22.5));
//        make.centerY.equalTo(self.playBtn.mas_centerY);
//    }];
//
//    [self.barrageSettingBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.barrageShieldingBtn.mas_right).offset(S(22.5));
//        make.centerY.equalTo(self.playBtn.mas_centerY);
//    }];
//
//    [self.qualityLabel sizeToFit];
//    [self.qualityLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.mas_right).offset(-S(22.5));
//        make.centerY.equalTo(self.playBtn.mas_centerY);
//    }];
//
//    [self.qualityBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.bottom.equalTo(self);
//        make.width.mas_equalTo(S(100));
//        make.top.equalTo(self.playBtn.mas_top);
//        make.bottom.equalTo(self.mas_bottom);
//    }];
//
//    CGFloat maxBarrageSenderW = self.qualityBtn.left - self.barrageSettingBtn.right - S(21);
//    CGFloat barrageSenderWidth = S(268);
//    if (maxBarrageSenderW < barrageSenderWidth) {
//        barrageSenderWidth = maxBarrageSenderW;
//    }
//    [self.barrageSenderBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.barrageSettingBtn.mas_right).offset(S(21));
//        make.centerY.equalTo(self.playBtn.mas_centerY);
//        make.size.mas_equalTo(CGSizeMake(barrageSenderWidth, S(30)));
//    }];
//
//    [self.lockBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.mas_right).offset(-S(8));
//        make.centerY.equalTo(self.mas_centerY);
//        make.size.mas_equalTo(CGSizeMake(S(44), S(44)));
//    }];
//
//    CGFloat nickW = [YYStringUtils sizeOfString:self.nickLabel.titleLabel.text font:self.nickLabel.titleLabel.font maxwidth:S(80)].width + S(15) + S(10);
//    [self.nickLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.mas_right).offset(-S(15));
//        make.bottom.equalTo(self.bottomGrView.mas_top).offset(-S(10));
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

- (CGFloat)p_shieldBarrageLeft {
    
    CGFloat width = 0.0f;
    static UILabel *tmpCurrentL = nil, *tmpTotalL = nil;
    if (!tmpCurrentL) {
        tmpCurrentL = [[UILabel alloc] init];
        tmpCurrentL.text = @"24:60";
        tmpCurrentL.font = self.lblCurrentTime.font;
    }
    if (!tmpTotalL) {
        tmpTotalL = [[UILabel alloc] init];
        tmpTotalL.text = @"24:60";
        tmpTotalL.font = self.lblTotalTime.font;
    }
    [tmpCurrentL sizeToFit];
    [tmpTotalL sizeToFit];
    width = tmpCurrentL.frame.size.width + tmpTotalL.frame.size.width;
    return width;
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
//        [self.sliderView setValue:1 animated:NO];
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
//    UISlider *slider = (UISlider *)tap.view;
//    CGPoint point = [tap locationInView:self.sliderView];
//    double value = point.x/self.sliderView.bounds.size.width*1;
//
//    NSTimeInterval duration = [WGLVideoPlayer sharedPlayer].duration;
//    NSLog(@"[HYVideoPlayerCoverView] sliderTap value:%f, player.duration:%f", value, duration);
//
//    if (value == duration) {
//        if (duration > 5.00) {
//            value = duration - 1.0;
//        }
//        else if (duration <= 5.0) {
//            value = duration * 0.8;
//        }
//        [self removeTimer];
//        [self.sliderView setValue:1 animated:NO];
//    }
//    else {
//        [self addTimer];
//    }
//
//    [self.sliderView setValue:value animated:YES];
//    self.lblCurrentTime.text = [WGLVideoPlayerOption timeformatFromSeconds:value];
//
//    NSTimeInterval currentTime = slider.value * duration;
//    [WGLVideoPlayer sharedPlayer].currentPlaybackTime = currentTime;
//
//    if ([WGLVideoPlayer sharedPlayer].isPlaying) {
//        [self play];
//
//#ifdef VIDEOPLAYER_MONITOR
//        [[VideoPlayerMonitor defaultMonitor] mediaSeekStart];
//#endif
//    }
//    [self hideCoverView];
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
    } else {
        //播放
        [[WGLVideoPlayer sharedPlayer] play];
    }
    [self hideCoverView];
}

//初始化弹幕设置按钮状态
- (void)setupShieldingBtn
{
    //TODO:
//    BOOL isBarrageRenderRangeNone = ([HYBarrageManager sharedObject].renderRangeStyle == HYBarrageRenderRangeNone);
//
//    self.barrageShieldingBtn.selected = isBarrageRenderRangeNone;
//    self.barrageSettingBtn.hidden = isBarrageRenderRangeNone;
//    self.barrageSenderBtn.hidden = isBarrageRenderRangeNone;
}

////屏蔽弹幕
//- (void)p_shieldingBarrage:(UIButton *)sender
//{
//    sender.selected = !sender.selected;
//    self.barrageSettingBtn.hidden = sender.selected;
//    self.barrageSenderBtn.hidden = sender.selected;
//
//    [HYBarrageManager sharedObject].renderRangeStyle = sender.selected? HYBarrageRenderRangeNone : HYBarrageRenderRangeGorgeous;
//}

//点击屏蔽弹幕
- (void)shieldingBarrageClick:(BOOL)isSelectd
{
    self.barrageShieldingBtn.selected = isSelectd;
    self.barrageSettingBtn.hidden =  isSelectd;
    self.barrageSenderBtn.hidden = isSelectd;
    
//    [HYBarrageManager sharedObject].renderRangeStyle = isSelectd? HYBarrageRenderRangeNone : HYBarrageRenderRangeGorgeous;
    
}

//初始化发送框
- (void)p_barrageSenderBtn
{
//    if([[HYLoginManager shareObject] isLogin]){
//        [self.barrageSenderBtn setTitle:@"弹幕填装，发射！" forState:UIControlStateNormal];
//        //        [_barrageSenderBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, S(-65), 0, S(65))];
//    }else{
//        [self.barrageSenderBtn setTitle:@"请先登录或注册，即可发送弹幕" forState:UIControlStateNormal];
//        //        [_barrageSenderBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, S(-28), 0, S(28))];
//    }
}

//设置弹幕
- (void)p_settingBarrage {
    
}

//屏幕锁定
- (void)p_lock {
    //    if (self.lockScreenHandler) {
    //        self.lockScreenHandler();
    //    }
}

- (void)p_back {
    NSLog(@"[HYVideoPlayerFullScreenCoverView] p_clickBack");
    //退出全屏
    if ([self.delegate respondsToSelector:@selector(clickQuiteFull:)]) {
        [self.delegate clickQuiteFull:self];
    }
}

#pragma mark - NOtification

- (void)addNotification
{
//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//
//    [center addObserver:self
//               selector:@selector(n_loginServerSuccess:)
//                   name:kNotificationLoginServerSuccess
//                 object:nil];
//
//    [center addObserver:self
//               selector:@selector(n_loginOutSuccess:)
//                   name:kNotificationLoginOutSuccess
//                 object:nil];
}

//登录成功通知
- (void)n_loginServerSuccess:(NSNotification *)notification
{
    [self p_barrageSenderBtn];
}

//退出登录通知
- (void)n_loginOutSuccess:(NSNotification *)notification
{
    [self p_barrageSenderBtn];
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
        
//        [self.sliderView setValue:currentValue animated:NO];
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
