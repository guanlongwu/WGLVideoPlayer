//
//  WGLSlider.h
//  WGLSlider
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//
/**
 正常情况下，我们自定义的滑动区域都不会太大，否则UI不美观，但是这样，又会手势不灵敏，用户体验变差。
 
 解决方案：封装一个继承UISlider的自定义类，重写thumbRectForBounds方法，原理就是对thumb区域rect进行放大处理。
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WGLSlider : UISlider

@property (copy, nonatomic) void(^endTrackingHandler) (UITouch *touch, UIEvent *event);

@end
