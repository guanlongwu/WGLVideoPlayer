//
//  WGLCorePlayer.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//
/**
 播放器秒开优化：
 int avformat_find_stream_info(AVFormatContext *ic, AVDictionary **options);
 函数可以读取一部分视音频数据并且获得一些相关的信息。
 函数正常执行后返回值大于等于0。
 ic：输入的AVFormatContext。
 options：额外的选项，目前没有深入研究过。
 
 该函数上下文部分是调节起播延迟效果最明显的地方。
 函数分析流的时间主要由传入的AVFormatContext的probesize 和 max_analyze_duration两个属性决定，
 1、probesize是探测读入大小，默认值为32K；
 2、max_analyze_duration默认值为5S。
 在网络状况比较好的情况下可分别设置4K和1S，也可根据具体情况在起播画面效果、起播延迟、分析成功率等因素间取舍。
 这两个参数的设置在avformat_open_input()函数对结构体AVFormatContext处理完成后进行设置。
 */

#import "WGLCorePlayerBase.h"

@interface WGLCorePlayer : WGLCorePlayerBase

@end
