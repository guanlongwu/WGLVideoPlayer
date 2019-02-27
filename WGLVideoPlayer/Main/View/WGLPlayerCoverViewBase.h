//
//  WGLPlayerCoverViewBase.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGLPlayerCoverViewProtocol.h"
#import "WGLSlider.h"
@protocol WGLPlayerCoverViewDelegate;

@interface WGLPlayerCoverViewBase : UIView <WGLPlayerCoverViewProtocol>

@property (nonatomic, weak) id<WGLPlayerCoverViewDelegate> delegate;

@property (nonatomic, strong) UIButton *backBtn;    //返回按钮
@property (nonatomic, strong) UIButton *moreBtn;    //更多
@property (nonatomic, strong) UIButton *shareBtn;   //分享
@property (nonatomic, strong) UILabel *titleLabel;  //标题

@property (nonatomic, strong) UIButton *playBtn;    //播放器播放/暂停按钮
@property (nonatomic, strong) UILabel *lblCurrentTime;  //当前时间的label
@property (nonatomic, strong) UILabel *lblTotalTime;    //总时长的label
@property (nonatomic, strong) UIProgressView *progressView; //视频加载进度的控件
@property (nonatomic, strong) WGLSlider *sliderView;     //播放进度条的Slider控件
@property (nonatomic, strong) UIButton *fullScreenBtn;  //全屏/恢复按钮

@property (nonatomic, strong, nullable) UITapGestureRecognizer *tapGesture;//手势

@property (nonatomic, strong) UIImageView *avatarView;//头像
@property (nonatomic, strong) UIButton *nickLabel;//昵称
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nick;

@end


@protocol WGLPlayerCoverViewDelegate <NSObject>

- (void)addTimer:(WGLPlayerCoverViewBase *)coverView;       //添加定时器
- (void)removeTimer:(WGLPlayerCoverViewBase *)coverView;    //移除定时器
- (void)clickBack:(WGLPlayerCoverViewBase *)coverView;       //返回
- (void)clickFullScreen:(WGLPlayerCoverViewBase *)coverView; //全屏
- (void)clickQuiteFull:(WGLPlayerCoverViewBase *)coverView;  //退出全屏
- (void)tapCover:(WGLPlayerCoverViewBase *)coverView;        //屏幕点击
- (void)hideCover:(WGLPlayerCoverViewBase *)coverView;       //隐藏cover

@end

