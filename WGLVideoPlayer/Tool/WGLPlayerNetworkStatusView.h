//
//  WGLPlayerNetworkStatusView.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/26.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGLVideoPlayerUtil.h"
@protocol WGLPlayerNetworkStatusDataSource;

typedef void(^WGLPlayerNetworkTapHandler)(WGLVPNetStatus networkStatus);

@interface WGLPlayerNetworkStatusView : UIView

@property (nonatomic, weak) id <WGLPlayerNetworkStatusDataSource> dataSource;

@property (nonatomic, strong) UIButton *backBtn;    //返回按钮
@property (nonatomic, assign) WGLVPNetStatus netWorkStatus; //网络状态
@property (nonatomic, copy) WGLPlayerNetworkTapHandler tapHandler;

@end


@protocol WGLPlayerNetworkStatusDataSource <NSObject>

- (uint64_t)trafficForCurrentVideo:(WGLPlayerNetworkStatusView *)networkStatusView;

@end

