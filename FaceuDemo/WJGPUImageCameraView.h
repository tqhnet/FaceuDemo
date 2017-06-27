//
//  WJGPUImageCameraView.h
//  FaceuDemo
//
//  Created by tqh on 2017/6/27.
//  Copyright © 2017年 tqh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WJGPUImageCameraViewDelegate <NSObject>

/**
 闪光灯
 */
- (void)cameraFlashAction:(UIButton *)sender;

/**
 美颜滤镜
 */
- (void)cameraFilterAction:(UIButton *)sender;

/**
 前后摄像头
 */
- (void)cameraTurnAction:(UIButton *)sender;

/**
 开始录制
 */
- (void)cameraBeginRecordAction:(UIButton *)sender;
/**
 结束录制
 */
- (void)cameraEndRecordAction:(UIButton *)sender;

/**
 下载（保存）
 */
- (void)cameraDownAction:(UIButton *)sender;

@end

@interface WJGPUImageCameraView : UIView

@property (nonatomic,weak) id<WJGPUImageCameraViewDelegate>delegate;

@end
