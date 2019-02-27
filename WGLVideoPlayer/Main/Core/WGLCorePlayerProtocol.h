//
//  WGLCorePlayerProtocol.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol WGLCorePlayerProtocol <NSObject>
@required

//视频渲染层view
- (UIView *)corePlayerView;

//开始播放
- (void)startPlay;

//播放
- (void)play;

//重播
- (void)replay;

//暂停
- (void)pause;

//结束播放
- (void)stopPlay;

@end
