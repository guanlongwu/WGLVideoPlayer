//
//  WGLPlayerTipView.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLPlayerTipView.h"
#import "WGLVideoPlayerCommon.h"

@interface WGLPlayerTipView ()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *name;
@end

@implementation WGLPlayerTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configSubViews];
    }
    return self;
}

- (void)configSubViews {
    self.layer.cornerRadius = 5;
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.clipsToBounds = YES;
    
    _closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _actionButton = [[UIButton alloc] initWithFrame:CGRectZero];
    
    [_closeButton setImage:[UIImage imageNamed:@"icon_playertip_close_normal"] forState:UIControlStateNormal];
    [_closeButton setImage:[UIImage imageNamed:@"icon_playertip_close_selected"] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(onCloseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_actionButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_actionButton addTarget:self action:@selector(onActionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _actionButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _infoLabel.textColor = [UIColor whiteColor];
    _infoLabel.font = [UIFont systemFontOfSize:12];
    
    [self addSubview:_closeButton];
    [self addSubview:_infoLabel];
    [self addSubview:_actionButton];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)aminationShow:(NSString *)name
             duration:(CGFloat)duration
             infoText:(NSString *)infoText
           actionText:(NSString *)actionText
               action:(NSString *)action
      hideCloseButton:(BOOL)hideCloseButton {
    self.name = name;
    self.action = action;
    self.closeButton.hidden = hideCloseButton;
    [self.actionButton setTitle:actionText forState:UIControlStateNormal];
    [self.infoLabel setText:infoText];
    
    [self layout];
    [self aminationShow:duration];
}

- (void)layout {
    CGFloat space0 = 9;
    CGFloat space1 = 6;
    CGFloat space2 = 12;
    CGFloat space3 = 15;
    CGFloat height = 36;
    CGFloat buttonSize = 20;
    CGFloat xoffset = 0;
    
    if (self.closeButton.hidden) {
        xoffset = space3;
    } else {
        self.closeButton.frame = CGRectMake(space0, space0, buttonSize, buttonSize);
        xoffset = self.closeButton.frame.origin.x + self.closeButton.frame.size.width + space1;
    }
    
    [self.infoLabel sizeToFit];
    self.infoLabel.frame = CGRectMake(xoffset, 0, self.infoLabel.frame.size.width, height);
    
    NSString *actionText = [self.actionButton titleForState:UIControlStateNormal];
    BOOL hideAction = actionText == nil || [actionText isEqualToString:@""];
    if (!hideAction) {
        xoffset = self.infoLabel.frame.origin.x + self.infoLabel.frame.size.width + space2;
        [self.actionButton sizeToFit];
        self.actionButton.frame = CGRectMake(xoffset, 0, self.actionButton.frame.size.width, height);
        xoffset = self.actionButton.frame.origin.x + self.actionButton.frame.size.width + space3;
    } else {
        xoffset = self.infoLabel.frame.origin.x + self.infoLabel.frame.size.width + space3;
    }
    
    self.preferredSize = CGSizeMake(xoffset, height);
}

- (void)onCloseButtonClick:(UIButton *)sender {
    [self aminationDismiss];
    [self postNotificationForName:kVideoPlayerTipDidCloseClickNotification];
}

- (void)onActionButtonClick:(UIButton *)sender {
    [self aminationDismiss];
    [self postNotificationForName:kVideoPlayerTipDidActionNotification];
}

- (void)aminationShow:(CGFloat)duration {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.layer removeAllAnimations];
    
    self.hidden = NO;
    self.alpha = 0.0;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.alpha = 1.0;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf performSelector:@selector(aminationDismiss) withObject:nil afterDelay:duration];
    }];
}

- (void)aminationDismiss {
    [self aminationDismiss:YES];
}

- (void)aminationDismiss:(BOOL)amimated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.layer removeAllAnimations];
    
    if (amimated) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.alpha = 0.0;
        } completion:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (finished) {
                [strongSelf setHidden:YES];
                [strongSelf postNotificationForName:kVideoPlayerTipDidDismissNotification];
            }
        }];
    } else {
        [self setHidden:YES];
        [self postNotificationForName:kVideoPlayerTipDidDismissNotification];
    }
}

- (void)postNotificationForName:(NSString *)notificationName {
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:[self notificationUserInfo]];
}

- (NSDictionary *)notificationUserInfo {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.name) {
        [userInfo setObject:self.name forKey:kVideoPlayerTipNameKey];
    }
    if (self.action) {
        [userInfo setObject:self.action forKey:kVideoPlayerTipActionKey];
    }
    
    return userInfo;
}
@end
