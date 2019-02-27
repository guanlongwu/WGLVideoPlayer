//
//  WGLPlayerTipMgr.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WGLPlayerTipMgr : NSObject

@property (nonatomic, assign) BOOL needToShowRateTip;

+ (instancetype)shareInstance;

- (void)showSeekTipIfNeed;
- (void)showRateTipIfNeed;

@end
