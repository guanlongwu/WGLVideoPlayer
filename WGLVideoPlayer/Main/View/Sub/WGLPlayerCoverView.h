//
//  WGLPlayerCoverView.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLPlayerCoverViewBase.h"

@interface WGLPlayerCoverView : WGLPlayerCoverViewBase

@property (nonatomic, strong) UIView *topBgView, *bottomBgView;
@property (nonatomic, strong) UIImageView *topShadowBgView, *bottomShadowBgView;//控制条背景
@property (nonatomic, strong) UIButton *barrageShieldingBtn;//屏蔽弹幕

@end
