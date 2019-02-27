//
//  WGLVideoRateProgressView.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGLVideoRateProgressView : UIView

@property (nonatomic, copy) NSString *currentTime;
@property (nonatomic, copy) NSString *duration;

- (void)setCurrentTime:(NSString *)currentTime duration:(NSString *)duration;

@end
