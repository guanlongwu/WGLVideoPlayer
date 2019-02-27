//
//  WGLBrightnessProgressView.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLBrightnessProgressView.h"

@interface WGLBrightnessProgressView ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation WGLBrightnessProgressView

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - UI

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.iconView];
    [self.bgView addSubview:self.progressView];
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
    }
    return _bgView;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.image = [UIImage imageNamed:@"icon_player_brightness"];
    }
    return _iconView;
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

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconView.frame = CGRectMake(20, self.center.y - self.iconView.frame.size.height / 2, self.iconView.frame.size.width, self.iconView.frame.size.height);
    self.progressView.frame = CGRectMake(14, self.center.y - self.progressView.frame.size.height / 2, self.progressView.frame.size.width, self.progressView.frame.size.height);
}

#pragma mark -

- (void)setBrightnessValue:(CGFloat)brightnessValue {
    _brightnessValue = brightnessValue;
    [self setBrightnessValue:brightnessValue animated:NO];
}

- (void)setBrightnessValue:(CGFloat)brightnessValue animated:(BOOL)animated {
    self.hidden = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCoverView) object:nil];
    [self performSelector:@selector(hideCoverView) withObject:nil afterDelay:1.0];
    
    [self.progressView setProgress:brightnessValue animated:animated];
}

- (void)hideCoverView {
    self.hidden = YES;
}
@end
