//
//  WGLVideoLoadingView.m
//  WGLVideoLoadingView
//
//  Created by wugl on 2019/2/26.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLVideoLoadingView.h"

static CGFloat kAnimationDuration = 1.0f;

@interface WGLVideoLoadingView () <CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *loadingView;
@property (nonatomic, strong) NSDate *lastLoadingDate;
@property (nonatomic, assign) int loadingCount;
@property (nonatomic, assign) BOOL delayLoading;

@property (nonatomic, assign) CFTimeInterval beginTime;
@property (nonatomic, assign) CGFloat beginValue;

@end

@implementation WGLVideoLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        self.userInteractionEnabled = NO;
        
        [self reset];
        [self initContent];
    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)initContent {
    [self addSubview:self.loadingView];
    [self setLoadingAnimation];
}

- (void)resetLoadingAnimation {
    [self resetLoadingAnimation:YES];
}

- (void)resetLoadingAnimation:(BOOL)isNeedCheckAnimationKeys {
    //isNeedCheckAnimationKeys是否需要判断是否已存在动画
    if (isNeedCheckAnimationKeys && self.loadingView.layer.animationKeys) {
        return;
    }
    [self.loadingView.layer removeAllAnimations];
    
    CFTimeInterval durationTime = (CACurrentMediaTime() - self.beginTime) / kAnimationDuration;
    CGFloat number1 = durationTime * M_PI * 2 + self.beginValue;
    CGFloat number2 = M_PI * 2;
    CGFloat newFromValue = fmod(number1, number2);
    self.beginValue = newFromValue;
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @(newFromValue);
    rotateAnimation.toValue = @(M_PI * 2 + newFromValue);
    rotateAnimation.duration = kAnimationDuration;
    rotateAnimation.repeatCount = MAXFLOAT;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.delegate = self;
    [self.loadingView.layer addAnimation:rotateAnimation forKey:@"rotation"];
    
    self.beginTime = CACurrentMediaTime();
}

- (void)setLoadingAnimation {
    if (self.loadingView.layer.animationKeys) {
        return;
    }
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = 0;
    rotateAnimation.toValue = @(M_PI * 2);
    rotateAnimation.duration = kAnimationDuration;
    rotateAnimation.repeatCount = MAXFLOAT;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.delegate = self;
    [self.loadingView.layer addAnimation:rotateAnimation forKey:@"rotation"];
    
    self.beginTime = CACurrentMediaTime();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.loadingView.frame = CGRectMake(0, 0, 49, 49);
    self.loadingView.center = self.center;
}

- (UIImageView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIImageView alloc] init];
        _loadingView.image = [UIImage imageNamed:@"icon_player_loading"];
    }
    return _loadingView;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self resetLoadingAnimation:YES];
}

#pragma mark - 隐藏、显示

- (void)reset {
    self.videoPlaying = NO;
    self.delayLoading = NO;
    self.loadingCount = 0;
    self.lastLoadingDate = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)delayLoadingFinish {
    NSLog(@"[WGLVideoLoadingView] finist delay loading. playing = %d", self.videoPlaying);
    if (!self.videoPlaying) {
        self.delayLoading = NO;
        [self showAndStartAnimation];
    }
}

- (void)showAndStartAnimation {
    //如果在显示时，判断动画停止了，再次启动动画
    if (self.loadingView.layer.animationKeys.count == 0) {
        [self resetLoadingAnimation];
    }
    
    NSDate *date = [NSDate date];
    NSTimeInterval delay = 0.6;
    
    if (self.loadingCount == 1
        && self.lastLoadingDate != nil
        && delay > [date timeIntervalSinceDate:self.lastLoadingDate]) {
        if (!self.delayLoading) {
            NSLog(@"[WGLVideoLoadingView] start delay loading...");
            self.delayLoading = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(delayLoadingFinish) withObject:nil afterDelay:delay + 0.02];
        }
        return;
    }
    if (self.loadingCount == 0) {
        self.lastLoadingDate = date;
    } else {
        self.lastLoadingDate = nil;
    }
    
    self.loadingCount ++;
    self.hidden = NO;
}

- (void)hideAndStopAnimation {
    self.hidden = YES;
}

@end
