//
//  WJGPUImageCameraView.m
//  FaceuDemo
//
//  Created by tqh on 2017/6/27.
//  Copyright © 2017年 tqh. All rights reserved.
//

#import "WJGPUImageCameraView.h"

#define kMARGap 20.0
#define kMARSwitchW 30
#define kLimitRecLen 15.0f
#define kCameraWidth 540.0f
#define kCameraHeight 960.0f
#define kRecordW 87

@interface WJGPUImageCameraView ()

@property (nonatomic, strong) UISlider *sliderView;         //进度
@property (nonatomic, strong) UIButton *flashSwitch;        //闪光灯
@property (nonatomic, strong) UIButton *filterSwitch;       //美颜滤镜
@property (nonatomic, strong) UIButton *cameraSwitch;       //前后摄像头
@property (nonatomic, strong) UIButton *recordButton;       //录制按钮
@property (nonatomic, strong) UIButton *downButton;         //下载按钮
@property (nonatomic, strong) UIButton *recaptureButton;    //
@property (nonatomic, strong) UIImageView *imageView;       //图片

@end

@implementation WJGPUImageCameraView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.sliderView];
        [self addSubview:self.flashSwitch];
        [self addSubview:self.filterSwitch];
        [self addSubview:self.cameraSwitch];
        [self addSubview:self.recaptureButton];
        [self addSubview:self.downButton];
        [self addSubview:self.recaptureButton];

    }
    return self;
}

- (void)layoutSubviews {
    
    self.cameraSwitch.frame = CGRectMake(self.frame.size.width - kMARSwitchW - kMARGap, 30, kMARSwitchW, kMARSwitchW);
    self.filterSwitch.frame = CGRectMake(CGRectGetMinX(self.cameraSwitch.frame) - kMARSwitchW - kMARGap, 30, kMARSwitchW, kMARSwitchW);
    self.flashSwitch.frame = CGRectMake(CGRectGetMinX(self.filterSwitch.frame) - kMARSwitchW - kMARGap, 30, kMARSwitchW, kMARSwitchW);
    self.recordButton.bounds = CGRectMake(0, 0, kRecordW, kRecordW);
    self.recordButton.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 50);
    self.downButton.center = self.recordButton.center;
    self.downButton.bounds = CGRectMake(0, 0, 55, 55);
    self.recaptureButton.center = CGPointMake(60, self.downButton.center.y);
    self.recaptureButton.bounds = CGRectMake(0, 0, 55, 55);
}

#pragma mark - 事件监听

- (void)flashAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cameraFlashAction:)]) {
        [_delegate cameraFlashAction:sender];
    }
}

- (void)filterAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cameraFilterAction:)]) {
        [_delegate cameraFilterAction:sender];
    }
}

- (void)cameraAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cameraTurnAction:)]) {
        [_delegate cameraTurnAction:sender];
    }
}

- (void)beginRecordAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cameraBeginRecordAction:)]) {
        [_delegate cameraBeginRecordAction:sender];
    }
}

- (void)endRecordAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cameraEndRecordAction:)]) {
        [_delegate cameraEndRecordAction:sender];
    }
}

- (void)downAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cameraDownAction:)]) {
        [_delegate cameraDownAction:sender];
    }
}

#pragma mark - 懒加载

- (UIButton *)flashSwitch {
    if (!_flashSwitch) {
        _flashSwitch = [UIButton new];
        [_flashSwitch setBackgroundImage:[UIImage imageNamed:@"record_light_off"] forState:UIControlStateNormal];
        [_flashSwitch setBackgroundImage:[UIImage imageNamed:@"record_light_on"] forState:UIControlStateSelected];
        [_flashSwitch addTarget:self action:@selector(flashAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashSwitch;
}

- (UIButton *)filterSwitch {
    if (!_filterSwitch) {
        _filterSwitch = [UIButton new];
        [_filterSwitch setBackgroundImage:[UIImage imageNamed:@"record_beauty_disable"] forState:UIControlStateNormal];
        [_filterSwitch setBackgroundImage:[UIImage imageNamed:@"record_beauty_enable"] forState:UIControlStateSelected];
        [_filterSwitch addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterSwitch;
}

- (UIButton *)cameraSwitch {
    if (!_cameraSwitch) {
        _cameraSwitch = [UIButton new];
        [_cameraSwitch setBackgroundImage:[UIImage imageNamed:@"record_changecamera_nomal"] forState:UIControlStateNormal];
        [_cameraSwitch setBackgroundImage:[UIImage imageNamed:@"record_changecamera_selected"] forState:UIControlStateSelected];
        [_cameraSwitch addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraSwitch;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [UIButton new];
        [_recordButton setBackgroundImage:[UIImage imageNamed:@"camera_btn_camera_normal_87x87_"] forState:UIControlStateNormal];
        [_recordButton setBackgroundImage:[UIImage imageNamed:@"camera_btn_camera_normal_87x87_"] forState:UIControlStateHighlighted];
        [_recordButton addTarget:self action:@selector(beginRecordAction:) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(endRecordAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    }
    return _recordButton;
}

- (UIButton *)downButton {
    if (!_downButton) {
        _downButton = [UIButton new];
        [_downButton setBackgroundImage:[UIImage imageNamed:@"camera_btn_download_normal_55x55_"] forState:UIControlStateNormal];
        [_downButton addTarget:self action:@selector(downAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downButton;
}

- (UIButton *)recaptureButton {
    if (!_recordButton) {
        _recordButton = [UIButton new];
        [_recordButton setBackgroundImage:[UIImage imageNamed:@"camera_btn_return_normal_55x55_"] forState:UIControlStateNormal];
    }
    return _recordButton;
}

@end
