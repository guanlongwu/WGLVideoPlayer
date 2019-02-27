//
//  WGLPlayerTipMgr.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLPlayerTipMgr.h"
#import "WGLVideoPlayerCommon.h"
#import "WGLURLProvider.h"
#import "WGLVideoPlayer.h"
#import "WGLPlayerProgressCache.h"

#define kVideoPlayerTipSwitchRate @"kVideoPlayerTipSwitchRate"
#define kVideoPlayerTipSeek @"kVideoPlayerTipSeek"
#define kVideoPlayerOneDayDuration  24*60*60

@implementation WGLPlayerTipMgr

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoPlayerTipDidActionNotification:) name:kVideoPlayerTipDidActionNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showSeekTipIfNeed {
    int64_t videoId_t = [WGLURLProvider sharedProvider].videoId;
    NSDate *date = [NSDate date];
    NSString *videoId = [NSString stringWithFormat:@"%lld", videoId_t];
    HYProgressCacheItem *item = [[WGLPlayerProgressCache sharedInstacne] progressCacheForVideoId:videoId];
    
    if (item == nil
        || [date timeIntervalSinceDate:item.date] > 5 * kVideoPlayerOneDayDuration
        || item.time < 0.01 ) {
        return;
    }
    
    NSString *timeString = [self.class minuteStringBySeconds:item.time];
    NSString *infoText = [NSString stringWithFormat:@"上次播放至：%@", timeString];
    
    [[WGLVideoPlayer sharedPlayer] aminationShowTip:kVideoPlayerTipSeek duration:5.0 infoText:infoText actionText:@"立即跳转" action:videoId hideCloseButton:NO];
}

- (void)showRateTipIfNeed {
    if (!self.needToShowRateTip) {
        return;
    }
    self.needToShowRateTip = NO;
    
    uint64_t currentQuality = [WGLURLProvider sharedProvider].selectedQuality;
    [[WGLURLProvider sharedProvider] getPlayUrlWhenCatonForQuality:currentQuality completion:^(NSString * _Nonnull url, uint64_t finalQuality) {
        
        if (currentQuality == finalQuality) {
            return;
        }
        
        [[WGLURLProvider sharedProvider] getShowNameForQuality:finalQuality completion:^(NSString * _Nonnull englishName, NSString * _Nonnull chineseName) {
            
            NSString *qualityString = [NSString stringWithFormat:@"%lld", finalQuality];
            NSString *infoText = [NSString stringWithFormat:@"播放卡顿，试试%@", englishName];
            NSString *actionText = @"立即切换";
            [[WGLVideoPlayer sharedPlayer] aminationShowTip:kVideoPlayerTipSwitchRate duration:5.0 infoText:infoText actionText:actionText action:qualityString hideCloseButton:NO];
        }];
    }];
}

- (void)onVideoPlayerTipDidActionNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *name = [userInfo objectForKey:kVideoPlayerTipNameKey];
    NSString *action = [userInfo objectForKey:kVideoPlayerTipActionKey];
    
    if ([name isEqualToString:kVideoPlayerTipSeek]) {
        
        int64_t videoId_t = [WGLURLProvider sharedProvider].videoId;
        NSString *currentVideoId = [NSString stringWithFormat:@"%lld", videoId_t];
        NSString *videoId = action;
        if ([videoId isEqualToString:currentVideoId]) {
            HYProgressCacheItem *item = [[WGLPlayerProgressCache sharedInstacne] progressCacheForVideoId:videoId];
            if (item) {
                
            }
        }
    }
    else if ([name isEqualToString:kVideoPlayerTipSwitchRate]) {
        int64_t quality = action.longLongValue;
        [[WGLURLProvider sharedProvider] changeQualityAndPlayWithQuality:quality];
    }
}

+ (NSString *)minuteStringBySeconds:(NSInteger)sec {
    return [NSString stringWithFormat:@"%.2ld:%.2ld", (long)(sec / 60), (long)(sec % 60)];
}

@end
