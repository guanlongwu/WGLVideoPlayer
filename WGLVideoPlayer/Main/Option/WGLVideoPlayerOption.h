//
//  WGLVideoPlayerOption.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//
/**
 存放视频播放器的属性信息，主要包括：
 屏幕方向、
 是否是正在播放状态、
 当前的播放进度、
 当前的播放时间、
 视频的总时长、
 当前视频是否处于可见位置、
 当前视频所在界面是否处于活跃状态
 */

#import <Foundation/Foundation.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

//视频播放器方向
typedef NS_ENUM(NSInteger, HYInterfaceOrientationType) {
    
    HYInterfaceOrientationPortrait           = 0,//home键在下面
    HYInterfaceOrientationLandscapeLeft      = 1,//home键在左边
    HYInterfaceOrientationLandscapeRight     = 2,//home键在右边
    HYInterfaceOrientationUnknown            = 3,//未知方向
    HYInterfaceOrientationPortraitUpsideDown = 4,//home键在上面
};

//播放方式
typedef NS_ENUM(NSInteger, EHYSettingPlayStyle) {
    EHYSettingPlayStyleEndStop = 0, //播完暂停
    EHYSettingPlayStyleCircle,      //单部循环
};

//视频展示来源
typedef NS_ENUM(NSInteger, HYVideoPlayerShowFrom) {
    HYVideoPlayerShowFrom_Unknow = 0,   //未知
    HYVideoPlayerShowFrom_VideoDetail,      //视频详情页
    HYVideoPlayerShowFrom_BangumiDetail,    //番剧详情页
};

@interface WGLVideoPlayerOption : NSObject

/**
 播放器的远程播放URL
 */
@property (nonatomic, copy) NSString *url;
/**
 播放器上一个播放URL
 */
@property (nonatomic, copy) NSString *oldUrl;
/**
 视频播放占位图
 */
@property (nonatomic, copy) NSString *placeHolderURL;
/**
 当前播放时间
 */
@property (nonatomic, assign) NSTimeInterval currentPlaybackTime;
/**
 视频的总时长
 */
@property (nonatomic, assign) NSTimeInterval duration;
/**
 已缓冲的时长
 */
@property (nonatomic, assign) NSTimeInterval playableDuration;

/**
 在被动暂停之前，是否播放状态
 */
@property (nonatomic, assign) BOOL isPlayingBeforePassivelyPause;

/**
 是否是正在播放状态
 */
@property (nonatomic, assign) BOOL isPlaying;
/**
 当前播放器处于被显示状态
 */
@property (nonatomic, assign) BOOL isBeingAppearState;
/**
 当前视频播放器是不是第一响应者状态
 */
@property (nonatomic, assign) BOOL isBeingActiveState;
/**
 当前视频是否允许移动网络下播放
 */
@property (nonatomic, assign) BOOL isAllowWWAN;


/**
 屏幕方向
 */
@property (nonatomic, assign) HYInterfaceOrientationType screenDirection;

@property (nonatomic, assign) BOOL isLockScreen;  //是否锁屏
@property (nonatomic, assign) BOOL isLockScreenBeforeEnterBackground;//进入后台之前，是否锁屏状态
@property (nonatomic, assign) BOOL isEnterBackground;
@property (nonatomic, assign) BOOL isEnterFullScreen;//是否全屏模式下
@property (nonatomic, assign) BOOL isAllowFullScreen;//是否允许全屏

@property (nonatomic, copy) NSString *speed;    //播放速度
@property (nonatomic, assign) EHYSettingPlayStyle playStyle;//播放方式
@property (nonatomic, assign) HYVideoPlayerShowFrom showFrom;//视频播放来源
@property (nonatomic, copy) NSString *title;//标题
@property (nonatomic, assign) BOOL isControlStatusBarHidden;//是否控制状态栏的隐藏显示


/**
 获取当前的屏幕方向
 */
- (HYInterfaceOrientationType)getCurrentScreenDirection;
/**
 播放器承载view
 */
//@property (nonatomic, weak) UIView *parentView;

@property (nonatomic, assign) CGRect videoFrame;

/**
 IJKPlayer播放器的核心
 */
@property (nonatomic, strong) IJKFFMoviePlayerController *corePlayer;

+ (WGLVideoPlayerOption *)sharedOption;

/**
 清理数据
 必须在所有的属性赋值之前调用
 */
- (void)clearData;

//实时更新数据
- (void)realTimeUpdateData;

//获取时间显示格式
+ (NSString *)timeformatFromSeconds:(NSInteger)seconds;

@end
