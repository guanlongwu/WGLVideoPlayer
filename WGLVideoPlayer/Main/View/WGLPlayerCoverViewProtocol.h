//
//  WGLPlayerCoverViewProtocol.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WGLPlayerCoverViewProtocol <NSObject>
@required
- (void)play;   //播放
- (void)pause;  //暂停
- (void)replay; //重播
- (void)updatePlayStatus:(BOOL)isPlay;//更新播放状态
@end
