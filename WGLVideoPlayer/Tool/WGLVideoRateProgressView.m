//
//  WGLVideoRateProgressView.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLVideoRateProgressView.h"

@interface WGLVideoRateProgressView ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *currentTimeLabel, *durationLabel;
@end

@implementation WGLVideoRateProgressView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self.bgView addSubview:self.currentTimeLabel];
    [self.bgView addSubview:self.durationLabel];
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
    }
    return _bgView;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont systemFontOfSize:15];
        _currentTimeLabel.textColor = [UIColor whiteColor];
    }
    return _currentTimeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont systemFontOfSize:15];
        _durationLabel.textColor = [UIColor whiteColor];
    }
    return _durationLabel;
}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.currentTimeLabel.frame = CGRectMake(10, self.center.y - self.currentTimeLabel.frame.size.height / 2, self.currentTimeLabel.frame.size.width, self.currentTimeLabel.frame.size.height);
    self.durationLabel.frame = CGRectMake(self.currentTimeLabel.frame.origin.x + self.currentTimeLabel.frame.size.width, self.center.y - self.durationLabel.frame.size.height / 2, self.durationLabel.frame.size.width, self.durationLabel.frame.size.height);
}

- (void)setCurrentTime:(NSString *)currentTime {
    _currentTime = currentTime;
    self.currentTimeLabel.text = currentTime;
}

- (void)setDuration:(NSString *)duration {
    _duration = duration;
    self.durationLabel.text = [NSString stringWithFormat:@"/%@", duration];
}

#pragma mark -

- (void)setCurrentTime:(NSString *)currentTime duration:(NSString *)duration {
    self.hidden = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCoverView) object:nil];
    [self performSelector:@selector(hideCoverView) withObject:nil afterDelay:1.0];
    
    self.currentTime = currentTime;
    self.duration = duration;
}

- (void)hideCoverView {
    self.hidden = YES;
}

@end
