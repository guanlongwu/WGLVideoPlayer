//
//  WGLVideoLoadingView.h
//  WGLVideoLoadingView
//
//  Created by wugl on 2019/2/26.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGLVideoLoadingView : UIView

@property (nonatomic, assign) BOOL videoPlaying;    //视频是否播放中

- (void)reset;

//开始显示加载动画
- (void)showAndStartAnimation;

//结束隐藏加载动画
- (void)hideAndStopAnimation;

//重置加载动画
- (void)resetLoadingAnimation;

@end
