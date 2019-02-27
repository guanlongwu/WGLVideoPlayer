//
//  WGLVideoPlayerOption.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLVideoPlayerOption.h"

@implementation WGLVideoPlayerOption

+ (WGLVideoPlayerOption *)sharedOption {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _isAllowFullScreen = YES;
    }
    return self;
}

//清除数据
- (void)clearData {
    self.oldUrl = self.url;//将当前视频url赋给oldURL
    
    self.placeHolderURL = nil;
    self.currentPlaybackTime = 0.0f;
    self.duration = 0.0f;
    self.playableDuration = 0.0f;
    self.isPlaying = YES;
    self.isBeingAppearState = YES;
    self.isBeingActiveState = YES;
    self.screenDirection = HYInterfaceOrientationPortrait;
    self.videoFrame = CGRectZero;
    self.isAllowFullScreen = NO;
    
    self.speed = @"1.0";
    self.playStyle = EHYSettingPlayStyleEndStop;
    self.isLockScreen = NO;
}

//实时更新数据
- (void)realTimeUpdateData {
    if (!self.corePlayer) {
        return;
    }
    self.isPlaying = self.corePlayer.isPlaying;
    self.currentPlaybackTime = self.corePlayer.currentPlaybackTime;
    self.duration = self.corePlayer.duration;
    self.playableDuration = self.corePlayer.playableDuration;
}

//获取屏幕方向
- (HYInterfaceOrientationType)getCurrentScreenDirection {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight) {  // home键靠右
        return HYInterfaceOrientationLandscapeRight;
    }
    if (orientation ==UIInterfaceOrientationLandscapeLeft) {    // home键靠左
        return HYInterfaceOrientationLandscapeLeft;
    }
    if (orientation == UIInterfaceOrientationPortrait) {
        return HYInterfaceOrientationPortrait;
    }
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return HYInterfaceOrientationPortraitUpsideDown;
    }
    return HYInterfaceOrientationUnknown;
}

- (void)setIsAllowFullScreen:(BOOL)isAllowFullScreen {
    _isAllowFullScreen = isAllowFullScreen;
}

#pragma mark - 锁屏

- (void)setIsLockScreen:(BOOL)isLockScreen {
    if (NO == isLockScreen
        && NO == self.isEnterBackground) {
        _isLockScreen = isLockScreen;
    }
    else {
        _isLockScreen = isLockScreen;
    }
}

#pragma mark - 获取时间显示格式

//把时间转换成为时分秒
+ (NSString *)timeformatFromSeconds:(NSInteger)seconds {
    //format of hour
    //    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld", seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
    return format_time;
}

@end
