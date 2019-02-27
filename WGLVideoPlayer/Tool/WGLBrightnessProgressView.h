//
//  WGLBrightnessProgressView.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGLBrightnessProgressView : UIView

@property (nonatomic, assign) CGFloat brightnessValue;

- (void)setBrightnessValue:(CGFloat)brightnessValue animated:(BOOL)animated;

@end
