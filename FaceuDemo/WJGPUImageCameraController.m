//
//  WJGPUImageCameraController.m
//  FaceuDemo
//
//  Created by tqh on 2017/6/27.
//  Copyright © 2017年 tqh. All rights reserved.
//

#import "WJGPUImageCameraController.h"
#import "WJGPUImageCameraView.h"
#import <GPUImage.h>
#import "LFGPUImageBeautyFilter.h"

@interface WJGPUImageCameraController ()

@property (nonatomic,strong) WJGPUImageCameraView *cameraView;//视图

@property (nonatomic, strong) GPUImageStillCamera *videoCamera;         //相机
@property (nonatomic, strong) GPUImageFilterGroup *normalFilter;        //普通滤镜
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;         //视频录制操作
@property (nonatomic, strong) LFGPUImageBeautyFilter *leveBeautyFilter; //美颜滤镜
@property (nonatomic, strong) GPUImageView *outputView;                 //输出视图

@end

@implementation WJGPUImageCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.cameraView];

}

- (void)viewWillLayoutSubviews {
    
}



#pragma mark - 懒加载

- (WJGPUImageCameraView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[WJGPUImageCameraView alloc]initWithFrame:self.view.bounds];
    }
    return _cameraView;
}

- (GPUImageView *)outputView {
    if (!_outputView) {
        _outputView = [GPUImageView new];
        [_outputView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    }
    return _outputView;
}

@end
