//
//  WGLPlayerTipView.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGLPlayerTipView : UIView

@property (nonatomic, assign) CGSize preferredSize;

- (void)aminationShow:(NSString *)name
             duration:(CGFloat)duration
             infoText:(NSString *)infoText
           actionText:(NSString *)actionText
               action:(NSString *)action
      hideCloseButton:(BOOL)hideCloseButton;

- (void)aminationDismiss:(BOOL)amimated;

@end
