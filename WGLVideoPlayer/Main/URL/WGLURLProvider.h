//
//  WGLURLProvider.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//
/**
 功能包括：
 1、根据id、type、quality请求server获取播放地址info
 2、根据播放地址info，构造 播放地址url
 3、获取 指定 清晰度quality 对应的 播放地址url
 4、自动返回 播放地址url (内部根据网络自动选择合适的)
 5、卡顿时，切换低一点的 清晰度 和 url
 6、获取 对应清晰度 的名称（等级15 对应 “320P”）
 7、获取对应 播放url 对应的 流量traffic
 */

#import <Foundation/Foundation.h>
#import "WGLVideoURLPagesEntity.h"

@interface WGLURLProvider : NSObject

//videoId才是 视频唯一 标识
@property (nonatomic, assign, readonly) uint64_t videoId;
//上一个播放的视频id
@property (nonatomic, assign, readonly) uint64_t lastVideoId;
//播放器的远程播放URL
@property (nonatomic, copy) NSString *url;
//当前视频对应所支持的所有清晰度的urlInfo
@property (nonatomic, strong) WGLURLEntity *urlInfo;
//如果指定清晰度没有命中，则会内部根据网络情况返回相应的合适清晰度，并重新覆盖指定分辨率
@property (nonatomic, assign) uint64_t selectedQuality;


//管理器
+ (WGLURLProvider *)sharedProvider;

/**
 视频播放前，必须先初始化 播放参数
 */
- (void)setParamsBeforePlayWithVideoId:(uint64_t)videoId quality:(uint64_t)quality urlInfo:(WGLURLEntity *)urlInfo;

- (void)setParamsBeforePlayWithVideoId:(uint64_t)videoId;

//是否切换了视频
- (BOOL)judgeIsChangeVideo:(uint64_t)videoId;

/**
 清理数据
 在播放器释放的时候调用
 注意：切换视频A->B的时候，不能调用，只有结束视频播放的时候调用
 */
- (void)clearData;

/**
 构造播放url
 url由播放协议urlInfo生成
 */
- (void)createPlayUrl:(WGLURLEntity *)urlInfo quality:(uint64_t)quality videoId:(uint64_t)videoId completion:(void(^)(NSString *url, uint64_t finalQuality))completion;

/**
 获取指定清晰度对应的url
 注意：urlInfo和videoId必须都已经赋值
 */
- (void)getPlayUrlForQuality:(uint64_t)quality completion:(void(^)(NSString *url, uint64_t finalQuality))completion;

/**
 自动获取播放url
 获取逻辑：内部根据网络情况，选择相应清晰度对应的url(WiFi下取最高分辨率，移动网络下取最低分辨率)
 注意：urlInfo和videoId必须都已经赋值
 */
- (void)getPlayUrlForDefaultQualityWithCompletion:(void(^)(NSString *url, uint64_t finalQuality))completion;

/**
 卡顿：获取比指定分辨率低一点的分辨率
 返回：该视频支持的低一点的分辨率及其对应url
 */
- (void)getPlayUrlWhenCatonForQuality:(uint64_t)quality completion:(void(^)(NSString *url, uint64_t finalQuality))completion;

/**
 切换指定清晰度，并播放
 */
- (void)changeQualityAndPlayWithQuality:(uint64_t)quality;

/**
 根据清晰度值，获取 英文名称
 清晰度 15 ：英文名"360P"，中文名"流畅"
 清晰度 32 ：英文名"480P"，中文名"清晰"
 清晰度 64 ：英文名"720P"，中文名"高清"
 清晰度 80 ：英文名"1080P"，中文名"超清"
 */
- (NSString *)qualityNameForQuality:(uint64_t)quality;

/**
 根据清晰度值，获取 名称
 清晰度 15 ：英文名"360P"，中文名"流畅"
 清晰度 32 ：英文名"480P"，中文名"清晰"
 清晰度 64 ：英文名"720P"，中文名"高清"
 清晰度 80 ：英文名"1080P"，中文名"超清"
 */
- (void)getShowNameForQuality:(uint64_t)quality completion:(void(^)(NSString *englishName, NSString *chineseName))completion;

/**
 当前视频的流量
 */
- (uint64_t)trafficForCurrentVideo;

/**
 获取指定清晰度quality的流量
 */
- (uint64_t)trafficForQuality:(uint64_t)quality;


@end


@interface NSArray (HYUrlQualitySort)

- (NSArray *)arraySortASC;  //升序

- (NSArray *)arraySortDESC; //降序

@end
