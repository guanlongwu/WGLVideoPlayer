//
//  WGLVideoURLPagesEntity.h
//  WGLVideoPlayer
//
//  Created by wugl on 2019/2/25.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WGLURLEntity, WGLURLListItemEntity, WGLURLSegmentEntity;

@interface WGLVideoURLPagesEntity : NSObject

@property (assign, nonatomic) int64_t pageId;
@property (assign, nonatomic) int64_t index;
@property (copy, nonatomic) NSString *origin;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *cover;
@property (nonatomic, assign) uint64_t duration;
@property (nonatomic, assign) uint64_t pubTime;
@property (strong, nonatomic) WGLURLEntity *video;

@end




@interface WGLURLEntity : NSObject

@property (copy, nonatomic) NSString *format;
@property (assign, nonatomic) int64_t duration;
@property (assign, nonatomic) int64_t expire;
@property (strong, nonatomic) NSArray<NSString *> *acceptClarityParams;
@property (nonatomic, copy) NSString *downloadUrl;
@property (strong, nonatomic) NSArray<WGLURLListItemEntity *> *videoList;

@end


@interface WGLURLListItemEntity : NSObject

@property (assign, nonatomic) uint64_t quality;
@property (copy, nonatomic) NSString *prefix;
@property (strong, nonatomic) NSArray<WGLURLSegmentEntity *> *durl;

@end


@interface WGLURLSegmentEntity : NSObject

@property (copy, nonatomic) NSString *order;
@property (copy, nonatomic) NSString *lengthSize;
@property (copy, nonatomic) NSString *url;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

@end
