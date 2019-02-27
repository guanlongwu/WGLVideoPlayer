//
//  WGLVideoPlayerUtil.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/26.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#ifndef WGLVideoPlayerUtil_h
#define WGLVideoPlayerUtil_h

// 下面枚举值不能修改
typedef NS_ENUM(NSInteger, WGLVPNetStatus) {
    WGLVPNetStatus_None = 0,
    WGLVPNetStatus_Wifi = 1,
    WGLVPNetStatus_WWan = 2,
    WGLVPNetStatus_Error = 3,   //无效网络出错
};


#endif /* WGLVideoPlayerUtil_h */
