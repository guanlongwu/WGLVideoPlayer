//
//  WGLPlayerNetworkStatusView.m
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/26.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLPlayerNetworkStatusView.h"

@interface WGLPlayerNetworkStatusView ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *showLabel;
@property (nonatomic, strong) UIButton *flowBtn;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) UIButton *retryBtn;
@end

@implementation WGLPlayerNetworkStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        [self initContent];
    }
    return self;
}

- (void)initContent {
    [self addSubview:self.bgView];
    [self addSubview:self.showLabel];
    [self addSubview:self.flowBtn];
    [self addSubview:self.selectBtn];
    [self addSubview:self.retryBtn];
    [self addSubview:self.backBtn];//返回
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgView.frame = self.bounds;
    
    self.backBtn.frame = CGRectMake(17, 45, 50, 40);
    
    [self.showLabel sizeToFit];
    self.showLabel.center = CGPointMake(self.center.x, self.center.y - self.showLabel.frame.size.height * 3.0 / 2.0);
    
    self.flowBtn.frame = CGRectMake(self.center.x - 170.0 / 2.0,
                                    self.showLabel.frame.origin.y + self.showLabel.frame.size.height + 20,
                                    170,
                                    40);
    
    self.selectBtn.frame = CGRectMake(self.center.x - 80.0 / 2.0,
                                      self.showLabel.frame.origin.y + self.showLabel.frame.size.height + 15,
                                      80,
                                      30);
    self.selectBtn.layer.cornerRadius = 15;
    
    self.retryBtn.frame = CGRectMake(self.center.x - 80.0 / 2.0,
                                     self.showLabel.frame.origin.y + self.showLabel.frame.size.height + 15,
                                     80,
                                     80);
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"icon_player_back_normal"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"icon_player_back_selected"] forState:UIControlStateHighlighted];
        _backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    return _backBtn;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor blackColor];
    }
    return _bgView;
}

- (UILabel *)showLabel {
    if (!_showLabel) {
        _showLabel = [[UILabel alloc] init];
        _showLabel.textAlignment = NSTextAlignmentCenter;
        _showLabel.textColor = [UIColor whiteColor];
        _showLabel.font = [UIFont systemFontOfSize:16];
    }
    return _showLabel;
}

- (UIButton *)flowBtn {
    if (!_flowBtn) {
        _flowBtn = [[UIButton alloc] init];
        _flowBtn.backgroundColor = [UIColor grayColor];
        _flowBtn.clipsToBounds = YES;
        _flowBtn.layer.cornerRadius = 5;
        _flowBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_flowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flowBtn setImage:[UIImage imageNamed:@"icon_player_play"] forState:UIControlStateNormal];
        [_flowBtn setTitle:@"5.6M" forState:UIControlStateNormal];
        _flowBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        _flowBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        [_flowBtn addTarget:self action:@selector(p_clickFlow) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flowBtn;
}

- (UIButton *)retryBtn {
    if (!_retryBtn) {
        _retryBtn = [[UIButton alloc] init];
        [_retryBtn setImage:[UIImage imageNamed:@"icon_player_retry_normal"] forState:UIControlStateNormal];
        [_retryBtn setImage:[UIImage imageNamed:@"icon_player_retry_selected"] forState:UIControlStateHighlighted];
        _retryBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _retryBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [_retryBtn addTarget:self action:@selector(p_clickRetry) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryBtn;
}

#pragma mark - 更新网络

- (void)setNetWorkStatus:(WGLVPNetStatus)netWorkStatus {
    _netWorkStatus = netWorkStatus;
    switch (netWorkStatus) {
        case WGLVPNetStatus_Wifi: {
            self.hidden = YES;
        }
            break;
            
        case WGLVPNetStatus_WWan: {
            self.showLabel.text = @"数据流量环境，播放将产生流量费用";
            
            self.retryBtn.hidden = YES;
            self.flowBtn.hidden = NO;
            self.flowBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
            self.flowBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
            [self.flowBtn setImage:[UIImage imageNamed:@"icon_player_play"] forState:UIControlStateNormal];
            NSString *flow = [self flowForVideo];
            [self.flowBtn setTitle:flow forState:UIControlStateNormal];
            
            self.hidden = NO;
        }
            break;
            
        case WGLVPNetStatus_None: {
            self.showLabel.text = @"加载失败，请重新加载";
            
            self.retryBtn.hidden = NO;
            self.flowBtn.hidden = YES;
            
            self.hidden = NO;
        }
            break;
            
        case WGLVPNetStatus_Error: {
            self.showLabel.text = @"加载失败，请重新加载";
            
            self.retryBtn.hidden = NO;
            self.flowBtn.hidden = YES;
            
            self.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

- (NSString *)flowForVideo {
    uint64_t traffic = 0;
    if ([self.dataSource respondsToSelector:@selector(trafficForCurrentVideo:)]) {
        traffic = [self.dataSource trafficForCurrentVideo:self];
    }
    NSString *flow = [NSString stringWithFormat:@"%.1fM", traffic / 1024.0 / 1024.0];
    return flow;
}

#pragma mark - event

- (void)p_clickFlow {
    self.hidden = YES;
    if (self.tapHandler) {
        self.tapHandler(self.netWorkStatus);
    }
}

- (void)p_clickRetry {
    self.hidden = YES;
    if (self.tapHandler) {
        self.tapHandler(self.netWorkStatus);
    }
}


@end
