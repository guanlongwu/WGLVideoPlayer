//
//  WGLURLProvider.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLURLProvider.h"
#import "WGLVideoPlayer.h"

@interface WGLURLProvider ()
@property (nonatomic, assign) uint64_t videoId;
@property (nonatomic, assign) uint64_t lastVideoId; //上一个播放的视频id
@end

@implementation WGLURLProvider

+ (WGLURLProvider *)sharedProvider {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - 初始化

- (void)setParamsBeforePlayWithVideoId:(uint64_t)videoId quality:(uint64_t)quality urlInfo:(WGLURLEntity *)urlInfo {
    
    //将当前视频id赋给lastVideoId
    [self setParamsBeforePlayWithVideoId:videoId];
    
    self.selectedQuality = quality;
    self.urlInfo = urlInfo;
}

- (void)setParamsBeforePlayWithVideoId:(uint64_t)videoId {
    self.lastVideoId = self.videoId;
    if (0 == self.lastVideoId) {
        //第一次赋值
        self.lastVideoId = videoId;
    }
    self.videoId = videoId;
}

//是否切换了视频
- (BOOL)judgeIsChangeVideo:(uint64_t)videoId {
    return self.lastVideoId != videoId;
}

//清除数据
- (void)clearData {
    self.lastVideoId = self.videoId;
}

#pragma mark - 获取清晰度quality对应的播放url

//前提是urlInfo和videoId已经赋值
- (void)getPlayUrlForQuality:(uint64_t)quality completion:(void(^)(NSString *url, uint64_t finalQuality))completion {
    if (nil == self.urlInfo || 0 == self.videoId) {
        NSLog(@"参数错误");
        return;
    }
    
    [self createPlayUrl:self.urlInfo quality:quality videoId:self.videoId completion:^(NSString * _Nonnull url, uint64_t quality) {
        if (completion) {
            completion(url, quality);
        }
    }];
}

/**
 不传清晰度，则根据网络情况选择相应清晰度对应url。
 相应根据网络状态取(WiFi取最高，移动网络取最低)
 */
- (void)getPlayUrlForDefaultQualityWithCompletion:(void(^)(NSString *url, uint64_t finalQuality))completion {
    if (nil == self.urlInfo || 0 == self.videoId) {
        NSLog(@"参数错误");
        return;
    }
    
    //quality传0则内部会根据网络情况，选择
    [self createPlayUrl:self.urlInfo quality:0 videoId:self.videoId completion:^(NSString * _Nonnull url, uint64_t quality) {
        if (completion) {
            completion(url, quality);
        }
    }];
}

#pragma mark - 卡顿：获取比指定分辨率低一点的分辨率

- (void)getPlayUrlWhenCatonForQuality:(uint64_t)quality completion:(void(^)(NSString *url, uint64_t finalQuality))completion {
    if (nil == self.urlInfo || 0 == self.videoId) {
        NSLog(@"参数错误");
        return;
    }
    
    WGLURLListItemEntity *lessThanUrlInfo = [self durlsForLessThanQuality:quality withUrlInfo:self.urlInfo];
    NSString *url = [self urlForUrlInfo:lessThanUrlInfo quality:quality videoId:self.videoId];
    if (completion) {
        completion(url, lessThanUrlInfo.quality);
    }
}

/**
 根据播放协议urlInfo构造播放url
 核心函数core
 */
- (void)createPlayUrl:(WGLURLEntity *)urlInfo quality:(uint64_t)quality videoId:(uint64_t)videoId completion:(void(^)(NSString *url, uint64_t finalQuality))completion {
    
    if (nil == urlInfo) {
        if (completion) {
            completion(nil, quality);
        }
        return;
    }
    else if (urlInfo.videoList.count == 0) {
        if (completion) {
            completion(nil, quality);
        }
        return;
    }
    
    //接下来，查找合适的播放urlInfo
    WGLURLListItemEntity *listEn = nil;
    
    if (0 == quality) {
        //1、如果没有指定清晰度，则相应根据网络状态取(WiFi取最高，移动网络取最低)
        
        listEn = [self urlListEnForNetworkTypeWithUrlInfo:urlInfo];
    }
    else {
        //2、获取清晰度对应的播放urlInfo
        
        listEn = [self urlListEnForQuality:quality withUrlInfo:urlInfo];
    }
    
    if (nil == listEn) {
        /**
         3、没有对应清晰度的播放urlInfo
         1）WiFi：获取比指定清晰度大一点的
         2）移动网络：获取比指定清晰度小一点的
         */
        
        if ([self isWifi]) {    //wifi
            listEn = [self durlsForMoreThanQuality:quality withUrlInfo:urlInfo];
        }
        else {   //移动网络
            listEn = [self durlsForLessThanQuality:quality withUrlInfo:urlInfo];
        }
    }
    if (nil == listEn) {
        //最后还是没有，则说明urlInfo中的清晰度列表 为空，返回获取url失败
        if (completion) {
            completion(nil, quality);
        }
        return;
    }
    
    self.selectedQuality = listEn.quality;
    
    //上面找到了合适的播放urlInfo -> listEn
    
    NSLog(@"[HYPlayerURLManager] selectedListInfo:%@, quality:%llu, videoId:%llu", listEn, listEn.quality, videoId);
    
    /**
     构造url
     1、只有一段，则返回视频url
     2、如果是多段，则 本地生成concatFile文件，返回concatFile文件本地地址，实现 分段播放 功能
     */
    NSString *url = [self urlForUrlInfo:listEn quality:listEn.quality videoId:videoId];
    
    if (completion) {
        completion(url, listEn.quality);
    }
}

/**
 返回播放url
 1、如果视频只有一段，则直接返回播放url
 2、视频有多段，则实现分段播放，通过本地生成concatFile文件实现
 */
- (NSString *)urlForUrlInfo:(WGLURLListItemEntity *)listEn quality:(uint64_t)quality videoId:(uint64_t)videoId {
    if (listEn.durl.count == 0) {
        //没有对应分辨率
        return nil;
    }
    
    if (listEn.durl.count == 1) {
        //视频只有一段，返回对应的url即可
        
        NSString *prefix = listEn.prefix;
        NSArray<WGLURLSegmentEntity *> *durl = listEn.durl;
        WGLURLSegmentEntity *durlInfo = durl[0];
        NSString *url = durlInfo.url;
        NSString *totalUrl = [NSString stringWithFormat:@"%@%@", prefix, url];
        
        return totalUrl;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //目录
    NSString *directryPath = [[self cachePath] stringByAppendingPathComponent:@"videoPlayConcatFiles"];
    
    //文件名
    NSString *concatFileName = [NSString stringWithFormat:@"ffconcat_%lld_%lld.ffconcat", videoId, quality];
    
    //内容
    NSString *concatFileContent = [self videoConcatContent:listEn];
    if (nil == concatFileContent) {
        return nil;
    }
    
    //完整路径
    NSString *concatFilePath = [directryPath stringByAppendingPathComponent:concatFileName];
    
    //判断文件是否存在
    if (![fileManager fileExistsAtPath:concatFilePath]) {
        
        //创建目录
        NSError *error = nil;
        BOOL dirResult = [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:&error];
        [self logForFileCreate:dirResult error:error];
        
        //创建文件
        BOOL fileResult = [fileManager createFileAtPath:concatFilePath contents:nil attributes:nil];
        
        NSLog(@"[HYPlayerURLManager] createPlayUrl dirResult:%d, fileResult:%d, error : %@", dirResult, fileResult, error);
    }
    
    //判断内容是否符合
    if (listEn.durl.count) {
        
        //写文件
        NSError *error = nil;
        BOOL isSuccess = [concatFileContent writeToFile:concatFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        [self logForFileCreate:isSuccess error:error];
        
        NSLog(@"[VideoConcatFileCreate] writeContentToConcatFile result:%d, error:%@", isSuccess, error);
    }
    else {
        NSLog(@"[VideoConcatFileCreate] writeContentToConcatFile fail");
    }
    return concatFilePath;
}

//concat文件内容
- (NSString *)videoConcatContent:(WGLURLListItemEntity *)listEn {
    if (listEn.durl.count == 0) {
        return nil;
    }
    
    NSString *prefix = listEn.prefix;
    NSArray<WGLURLSegmentEntity *> *durl = listEn.durl;
    NSMutableString *content = [NSMutableString stringWithFormat:@"ffconcat version 1.0"];
    [durl enumerateObjectsUsingBlock:^(WGLURLSegmentEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *segmentUrl = obj.url;
        NSString *totalUrl = [NSString stringWithFormat:@"%@%@", prefix, segmentUrl];
        
        NSString *lenSize = obj.lengthSize;
        NSArray *lenSizes = [lenSize componentsSeparatedByString:@","];
        uint64_t duration = 0;
        if (lenSizes.count >= 1) {
            NSString *len = [lenSizes objectAtIndex:0];
            duration = len.longLongValue;
        }
        if (totalUrl.length) {
            [content appendString:[NSString stringWithFormat:@"\nfile %@", totalUrl]];
        }
        NSString *durationStr = [NSString stringWithFormat:@"%f", duration / 1000.0f];
        [content appendString:[NSString stringWithFormat:@"\nduration %@", durationStr]];
    }];
    NSLog(@"[HYPlayerURLManager] videoConcatContent : %@", content);
    return content;
}

#pragma mark - 切换清晰度

/**
 卡顿时，自动切换清晰度(比当前清晰度低一级的清晰度)，并自动播放
 */
- (void)autoChangeQualityAndPlayWhenCaton {
    
    //1、获取比当前清晰度 低一级的 清晰度 及其 对应 url
    uint64_t currentQuality = self.selectedQuality;
    [self getPlayUrlWhenCatonForQuality:currentQuality completion:^(NSString * _Nonnull url, uint64_t finalQuality) {
        
        //2、根据清晰度及其url进行视频切换
        [self changeQualityAndPlayWithUrl:url quality:finalQuality];
    }];
}

/**
 切换指定清晰度，并播放
 */
- (void)changeQualityAndPlayWithQuality:(uint64_t)quality {
    [self getPlayUrlForQuality:quality completion:^(NSString * _Nonnull url, uint64_t finalQuality) {
        [self changeQualityAndPlayWithUrl:url quality:finalQuality];
    }];
}

/**
 切换：指定清晰度和url
 切换成功后，自动播放
 */
- (void)changeQualityAndPlayWithUrl:(NSString *)url quality:(uint64_t)quality {
    self.selectedQuality = quality;
    
    //切换成功，提示
    [self getShowNameForQuality:quality completion:^(NSString * _Nonnull englishName, NSString * _Nonnull chineseName) {
        //TODO:
//        NSString *infoText = [NSString stringWithFormat:@"已切换至 %@", englishName];
//        [[WGLVideoPlayer sharedPlayer] aminationShowTip:@"" duration:5.0 infoText:infoText actionText:nil action:nil hideCloseButton:YES];
    }];
}

#pragma mark - Internal Method

/**
 获取清晰度对应的播放urlInfo
 */
- (WGLURLListItemEntity *)urlListEnForQuality:(uint64_t)quality withUrlInfo:(WGLURLEntity *)urlInfo {
    __block WGLURLListItemEntity *urlListEn = nil;
    NSArray<WGLURLListItemEntity *> *videoList = urlInfo.videoList;
    [videoList enumerateObjectsUsingBlock:^(WGLURLListItemEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        uint64_t _qua = obj.quality;
        if (_qua == quality) {
            //选择对应分辨率
            
            urlListEn = obj;
            *stop = YES;
        }
    }];
    return urlListEn;
}

/**
 根据网络情况获取对应的播放urlInfo
 1、WiFi情况下：获取最高分辨率
 2、移动网络：获取最低分辨率
 */
- (WGLURLListItemEntity *)urlListEnForNetworkTypeWithUrlInfo:(WGLURLEntity *)urlInfo {
    
    //获取最高和最低分辨率
    __block uint64_t maxQuality = 0;
    __block uint64_t minQuality = 0;
    NSArray<WGLURLListItemEntity *> *videoList = urlInfo.videoList;
    [videoList enumerateObjectsUsingBlock:^(WGLURLListItemEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        uint64_t _qua = obj.quality;
        maxQuality = MAX(maxQuality, _qua);
        minQuality = MIN(minQuality, _qua);
        
        if (maxQuality == 0) {
            maxQuality = _qua;
        }
        if (minQuality == 0) {
            minQuality = _qua;
        }
    }];
    
    __block WGLURLListItemEntity *urlListEn = nil;
    if ([self isWifi]) {    //wifi
        urlListEn = [self urlListEnForQuality:maxQuality withUrlInfo:urlInfo];
    }
    else {   //移动网络
        urlListEn = [self urlListEnForQuality:minQuality withUrlInfo:urlInfo];
    }
    return urlListEn;
}

/**
 获取比quality小一点分辨率的播放urlInfo
 比如，目前分辨率1080P，则往下查询比1080P（超清）低一点的分辨率，如720P（高清）的播放urlInfo，以此递推，找不到用最低分辨率
 使用场景：播放卡顿/网络很差
 */
- (WGLURLListItemEntity *)durlsForLessThanQuality:(uint64_t)quality withUrlInfo:(WGLURLEntity *)urlInfo {
    
    //获取提供的所有分辨率
    __block NSMutableArray <NSNumber *>* qualitys = [NSMutableArray array];
    NSArray<WGLURLListItemEntity *> *videoList = urlInfo.videoList;
    [videoList enumerateObjectsUsingBlock:^(WGLURLListItemEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        uint64_t _qua = obj.quality;
        [qualitys addObject:@(_qua)];
    }];
    
    __block uint64_t resultQuality = 0;
    //对所有分辨率 降序 排序
    qualitys = [NSMutableArray arrayWithArray:[qualitys arraySortDESC]];
    [qualitys enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        uint64_t _qua = obj.longLongValue;
        if (quality > _qua) {
            //指定的分辨率 刚好大于 这个分辨率，则卡顿切换到这个 分辨率
            resultQuality = _qua;
            *stop = YES;
        }
    }];
    if (0 == resultQuality && qualitys.count) {
        //如果指定 分辨率 比 所有分辨率都低，则取 所有分辨率中最低的（360P）
        NSNumber *quaNum = [qualitys lastObject];
        resultQuality = quaNum.longLongValue;
    }
    
    __block WGLURLListItemEntity *urlListEn = nil;
    urlListEn = [self urlListEnForQuality:resultQuality withUrlInfo:urlInfo];
    return urlListEn;
}

/**
 获取比quality大一点分辨率的播放urlInfo
 比如，目前分辨率720P，则往下查询比720P（高清）高一点的分辨率，如1080P（超清）的播放urlInfo，以此递推，找不到用最大分辨率
 使用场景：播放很流畅/网络状态很好
 */
- (WGLURLListItemEntity *)durlsForMoreThanQuality:(uint64_t)quality withUrlInfo:(WGLURLEntity *)urlInfo {
    
    //获取提供的所有分辨率
    __block NSMutableArray <NSNumber *>* qualitys = [NSMutableArray array];
    NSArray<WGLURLListItemEntity *> *videoList = urlInfo.videoList;
    [videoList enumerateObjectsUsingBlock:^(WGLURLListItemEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        uint64_t _qua = obj.quality;
        [qualitys addObject:@(_qua)];
    }];
    
    __block uint64_t resultQuality = 0;
    //对所有分辨率 升序 排序
    [qualitys sortUsingSelector:@selector(compare:)];
    NSEnumerator *enumerator = [qualitys reverseObjectEnumerator];
    qualitys = [[NSMutableArray alloc] initWithArray:[enumerator allObjects]];
    [qualitys enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        uint64_t _qua = obj.longLongValue;
        if (resultQuality <= _qua) {
            resultQuality = _qua;
            *stop = YES;
        }
    }];
    if (0 == resultQuality && qualitys.count) {
        //如果指定 分辨率 比 所有分辨率都高，则取 所有分辨率中最高的（1080P）
        NSNumber *quaNum = [qualitys lastObject];
        resultQuality = quaNum.longLongValue;
    }
    __block WGLURLListItemEntity *urlListEn = nil;
    urlListEn = [self urlListEnForQuality:resultQuality withUrlInfo:urlInfo];
    
    return urlListEn;
}

#pragma mark - 流量

/**
 当前视频的流量
 */
- (uint64_t)trafficForCurrentVideo {
    uint64_t traffic = [self trafficForQuality:self.selectedQuality];
    
    return traffic;
}

/**
 获取指定清晰度quality的流量
 */
- (uint64_t)trafficForQuality:(uint64_t)quality {
    __block uint64_t traffic = 0;
    if (self.urlInfo) {
        //获取指定 quality的播放info
        
        __block WGLURLListItemEntity *durlEn = nil;
        NSArray<WGLURLListItemEntity *> *videoList = self.urlInfo.videoList;
        [videoList enumerateObjectsUsingBlock:^(WGLURLListItemEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.quality == quality) {
                durlEn = obj;
            }
        }];
        if (nil == durlEn) {
            //如果没有命中 指定 quality的播放info，则取第一个
            
            if (videoList.count > 0) {
                durlEn = videoList[0];
            }
        }
        
        //遍历 视频分段的 流量大小，总和就是 视频的流量
        NSArray<WGLURLSegmentEntity *> *durl = durlEn.durl;
        [durl enumerateObjectsUsingBlock:^(WGLURLSegmentEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *lengthSize = obj.lengthSize;
            NSArray *params = [lengthSize componentsSeparatedByString:@","];
            if (params.count >= 2) {
                //流量
                NSString *size = params[1];
                uint64_t sizeNum = size.longLongValue;
                traffic += sizeNum;
            }
        }];
    }
    return traffic;
}

#pragma mark - private

- (BOOL)isWifi {
    //TODO:
    return YES;
}

//log
- (void)logForFileCreate:(BOOL)result error:(NSError *)error {
    if (result) {
        NSLog(@"[VideoConcatFileCreate] createConcatFile success");
    }else{
        NSLog(@"[VideoConcatFileCreate] createConcatFile fail");
    }
    if (error) {
        NSLog(@"[VideoConcatFileCreate] createConcatFile fail error : %@", error);
    }else{
        NSLog(@"[VideoConcatFileCreate] createConcatFile success");
    }
}

#pragma mark - 缓存

//缓存本地路径
- (NSString *)cachePath {
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cacheFolder stringByAppendingPathComponent:@"com.videoDetail.videoConcatFile"];
    return path;
}

#pragma mark - 根据清晰度值，获取清晰度 表示

/**
 根据清晰度值，获取 英文名称
 清晰度 15 ：英文名"360P"，中文名"流畅"
 清晰度 32 ：英文名"480P"，中文名"清晰"
 清晰度 64 ：英文名"720P"，中文名"高清"
 清晰度 80 ：英文名"1080P"，中文名"超清"
 */
- (NSString *)qualityNameForQuality:(uint64_t)quality {
    __block NSString *qualityName = @"";
    [self getShowNameForQuality:quality completion:^(NSString * _Nonnull englishName, NSString * _Nonnull chineseName) {
        qualityName = englishName;
    }];
    return qualityName;
}

/**
 根据清晰度值，获取 名称
 清晰度 15 ：英文名"360P"，中文名"流畅"
 清晰度 32 ：英文名"480P"，中文名"清晰"
 清晰度 64 ：英文名"720P"，中文名"高清"
 清晰度 80 ：英文名"1080P"，中文名"超清"
 */
- (void)getShowNameForQuality:(uint64_t)quality completion:(void(^)(NSString *englishName, NSString *chineseName))completion {
    __block NSString *chiName = @"";
    __block NSString *engName = @"";
    if (self.urlInfo) {
        NSArray<NSString *> *acceptClarityParams = self.urlInfo.acceptClarityParams;
        [acceptClarityParams enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *params = [obj componentsSeparatedByString:@","];
            if (params.count >= 3) {
                //清晰度 值
                NSString *qualityStr = params[2];
                uint64_t _qua = qualityStr.longLongValue;
                
                //清晰度 chineseName
                NSString *_chiName = params[0];
                
                //清晰度 engName
                NSString *_engName = params[1];
                
                if (quality == _qua) {
                    chiName = _chiName;
                    engName = _engName;
                    *stop = YES;
                }
            }
            else {
                *stop = YES;
            }
        }];
    }
    if (completion) {
        completion(engName, chiName);
    }
}

//清晰度切换
- (void)n_changeQuality:(NSNotification *)noti {
    NSString *obj = noti.object;
    uint64_t quality = obj.longLongValue;
    if (self.selectedQuality != quality) {
        //切换了清晰度
        [self changeQualityAndPlayWithQuality:quality];
    }
}

@end

@implementation NSArray (HYUrlQualitySort)

//升序
- (NSArray *)arraySortASC {
    NSArray *result = [self sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        //        NSLog(@"%@~%@",obj1,obj2);
        return [obj1 compare:obj2];
    }];
    return result;
}

//降序
- (NSArray *)arraySortDESC {
    NSArray *result = [self sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        //        NSLog(@"%@~%@",obj1,obj2);
        return [obj2 compare:obj1]; //降序
    }];
    return result;
}

@end
