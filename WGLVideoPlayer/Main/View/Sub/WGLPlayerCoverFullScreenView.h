//
//  WGLPlayerCoverFullScreenView.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLPlayerCoverViewBase.h"

@interface WGLPlayerCoverFullScreenView : WGLPlayerCoverViewBase

@property (nonatomic, strong) UIImageView *topShadowBgView, *bottomShadowBgView;//控制条背景
@property (nonatomic, strong) UIButton *barrageShieldingBtn;//屏蔽弹幕
@property (nonatomic, strong) UIButton *barrageSettingBtn;//设置弹幕
@property (nonatomic, strong) UIButton *barrageSenderBtn;//发送弹幕

@property (nonatomic, strong) UIButton *qualityBtn; //清晰度切换
@property (nonatomic, strong) UILabel *qualityLabel;

@property (nonatomic, strong) UIButton *lockBtn; //锁定

@end
