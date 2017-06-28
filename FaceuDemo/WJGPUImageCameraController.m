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
    [self.view addSubview:self.outputView];
    [self.view addSubview:self.cameraView];
    
    [self.videoCamera addTarget:self.leveBeautyFilter];
    [self.leveBeautyFilter addTarget:self.outputView];
    [self.videoCamera startCameraCapture];

}

- (void)viewWillLayoutSubviews {
    
    self.outputView.frame = self.view.bounds;
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


- (GPUImageStillCamera *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    }
    return _videoCamera;
}

- (GPUImageFilterGroup *)normalFilter {
    if (!_normalFilter) {
        GPUImageFilter *filter = [[GPUImageFilter alloc] init]; //默认
        _normalFilter = [[GPUImageFilterGroup alloc] init];
        [(GPUImageFilterGroup *) _normalFilter setInitialFilters:[NSArray arrayWithObject: filter]];
        [(GPUImageFilterGroup *) _normalFilter setTerminalFilter:filter];
    }
    return _normalFilter;
}


- (LFGPUImageBeautyFilter *)leveBeautyFilter {
    if (!_leveBeautyFilter) {
        _leveBeautyFilter = [[LFGPUImageBeautyFilter alloc] init];
    }
    return _leveBeautyFilter;
}

@end
