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
#import "iflyMSC.framework/Headers/IFlyFaceSDK.h"
#import "IFlyFaceImage.h"
#import <CoreMotion/CMMotionManager.h>
#import "CanvasView.h"                  //人脸贴图
#import "IFlyFaceResultKeys.h"
#import "CalculatorTools.h"

@interface WJGPUImageCameraController ()<GPUImageVideoCameraDelegate>

@property (nonatomic,strong) WJGPUImageCameraView *cameraView;//视图

@property (nonatomic, strong) GPUImageStillCamera *videoCamera;         //相机
@property (nonatomic, strong) GPUImageFilterGroup *normalFilter;        //普通滤镜
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;         //视频录制操作
@property (nonatomic, strong) LFGPUImageBeautyFilter *leveBeautyFilter; //美颜滤镜
@property (nonatomic, strong) GPUImageView *outputView;                 //输出视图
@property (nonatomic, strong) IFlyFaceDetector *faceDetector;           //讯飞人脸检测
@property (nonatomic, strong) GPUImageUIElement *faceView;              //水印贴图
@property (nonatomic, strong) CanvasView *viewCanvas;                   //贴图的画布

@property (nonatomic) CMMotionManager *motionManager;
@property (nonatomic) UIInterfaceOrientation interfaceOrientation;

@end

@implementation WJGPUImageCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.faceDetector = [IFlyFaceDetector sharedInstance];
    if (self.faceDetector) {
        [self.faceDetector setParameter:@"1" forKey:@"detect"];
        [self.faceDetector setParameter:@"1" forKey:@"align"];
    }else {
        NSLog(@"没有人脸识别");
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.outputView];
    [self.view addSubview:self.cameraView];
    
    [self.videoCamera addTarget:self.leveBeautyFilter];
    [self.leveBeautyFilter addTarget:self.outputView];
    
    [self.videoCamera startCameraCapture];


   [self.view addSubview:self.viewCanvas];
}



#pragma mark - <GPUImageVideoCameraDelegate>

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {

    IFlyFaceImage* faceImage=[self faceImageFromSampleBuffer:sampleBuffer];

    //方向的问题，检测不了人脸
    NSString* strResult=[self.faceDetector trackFrame:faceImage.data withWidth:faceImage.width height:faceImage.height direction:1];
    NSLog(@"------%@",strResult);
    [self praseTrackResult:strResult OrignImage:faceImage];
    //此处清理图片数据，以防止因为不必要的图片数据的反复传递造成的内存卷积占用
    faceImage.data=nil;
    faceImage=nil;
}


#pragma mark - 人脸识别相关方法

/*
 人脸识别
 */
-(void)praseTrackResult:(NSString*)result OrignImage:(IFlyFaceImage*)faceImg{
    
    if(!result){
        return;
    }
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* faceDic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        resultData=nil;
        if(!faceDic){
            return;
        }
        
        NSString* faceRet=[faceDic objectForKey:KCIFlyFaceResultRet];
        //抓去面部数据
        NSArray* faceArray=[faceDic objectForKey:KCIFlyFaceResultFace];
        faceDic=nil;
        
        int ret=0;
        if(faceRet){
            ret=[faceRet intValue];
        }
        //没有检测到人脸或发生错误
        if (ret || !faceArray || [faceArray count]<1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideFace];
            } ) ;
            return;
        }
        
        //检测到人脸
        NSMutableArray *arrPersons = [NSMutableArray array] ;
        
        for(id faceInArr in faceArray){
            
            if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                
                //抓取得面部矩形区域
                NSDictionary* positionDic=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                
                //检测面部轮廓
                NSString* rectString=[self praseDetect:positionDic OrignImage: faceImg];
                positionDic=nil;
                
                //抓取面部表情
                NSDictionary* landmarkDic=[faceInArr objectForKey:KCIFlyFaceResultLandmark];
                
                //检测面部特征
                NSMutableArray* strPoints=[self praseAlign:landmarkDic OrignImage:faceImg];
                landmarkDic=nil;
                
                
                NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
                if(rectString){
                    [dicPerson setObject:rectString forKey:RECT_KEY];
                }
                if(strPoints){
                    [dicPerson setObject:strPoints forKey:POINTS_KEY];
                }
                
                strPoints=nil;
                
                [dicPerson setObject:@"0" forKey:RECT_ORI];
                [arrPersons addObject:dicPerson] ;
                
                dicPerson=nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
                } ) ;
            }
        }
        faceArray=nil;
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
}

/*
 检测面部特征点
 */

-(NSMutableArray*)praseAlign:(NSDictionary* )landmarkDic OrignImage:(IFlyFaceImage*)faceImg{
    if(!landmarkDic){
        return nil;
    }
    // 判断摄像头方向
    BOOL isFrontCamera = self.videoCamera.cameraPosition == AVCaptureDevicePositionFront;
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = self.view.frame.size.width / faceImg.height;
    CGFloat heightScaleBy = self.view.frame.size.height / faceImg.width;
    
    NSMutableArray *arrStrPoints = [NSMutableArray array] ;
    NSEnumerator* keys=[landmarkDic keyEnumerator];
    for(id key in keys){
        id attr=[landmarkDic objectForKey:key];
        if(attr && [attr isKindOfClass:[NSDictionary class]]){
            
            id attr=[landmarkDic objectForKey:key];
            CGFloat x=[[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
            CGFloat y=[[attr objectForKey:KCIFlyFaceResultPointY] floatValue];
            
            CGPoint p = CGPointMake(y,x);
            
            if(!isFrontCamera){
                p=pSwap(p);
                p=pRotate90(p, faceImg.height, faceImg.width);
            }
            
            p=pScale(p, widthScaleBy, heightScaleBy);
            
            [arrStrPoints addObject:NSStringFromCGPoint(p)];
            
        }
    }
    return arrStrPoints;
    
}

//检测到人脸
- (void) showFaceLandmarksAndFaceRectWithPersonsArray:(NSMutableArray *)arrPersons{
    if (self.viewCanvas.hidden) {
        self.viewCanvas.hidden = NO;
    }
    NSLog(@"%@",arrPersons);
    self.viewCanvas.arrPersons = arrPersons ;
    NSLog(@"update arr:检测到人脸，更新");
    [self.viewCanvas setNeedsDisplay];
}

//没有检测到人脸或发生错误
- (void) hideFace {
    if (!self.viewCanvas.hidden) {
        self.viewCanvas.hidden = YES ;
    }
}


/*
 检测脸部轮廓
 */
-(NSString*)praseDetect:(NSDictionary* )positionDic OrignImage:(IFlyFaceImage*)faceImg{
    
    if(!positionDic){
        return nil;
    }
    
    // 判断摄像头方向
    BOOL isFrontCamera = self.videoCamera.cameraPosition == AVCaptureDevicePositionFront;
    
    // scale coordinates so they fit in the preview box, which may be scaled
    
    //图片出来的时候是旋转了的么高度比宽度大
    CGFloat widthScaleBy = self.view.frame.size.width / faceImg.height;
    CGFloat heightScaleBy = self.view.frame.size.height / faceImg.width;
    
    CGFloat bottom =[[positionDic objectForKey:KCIFlyFaceResultBottom] floatValue];
    CGFloat top=[[positionDic objectForKey:KCIFlyFaceResultTop] floatValue];
    CGFloat left=[[positionDic objectForKey:KCIFlyFaceResultLeft] floatValue];
    CGFloat right=[[positionDic objectForKey:KCIFlyFaceResultRight] floatValue];
    
    float cx = (left+right)/2;      //人脸x中心点
    float cy = (top + bottom)/2;    //人脸y中心点
    float w = right - left;         //人脸宽度
    float h = bottom - top;         //人脸高度
    
    float ncx = cy ;
    float ncy = cx ;
    
    CGRect rectFace = CGRectMake(ncx-w/2 ,ncy-w/2 , w, h);//重新得出人脸矩形
    
    //如果是后置摄像后改变款高度并旋转90度
    if(!isFrontCamera){
        rectFace=rSwap(rectFace);
        rectFace=rRotate90(rectFace, faceImg.height, faceImg.width);
        
    }
    //按比例得出最新的矩形
    rectFace=rScale(rectFace, widthScaleBy, heightScaleBy);
    rectFace = CGRectMake(rectFace.origin.x, rectFace.origin.y, rectFace.size.width, rectFace.size.height);
    return NSStringFromCGRect(rectFace);
    
}


#pragma mark - others


- (IFlyFaceImage *) faceImageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    
    //获取灰度图像数据
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    uint8_t *lumaBuffer  = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer,0);
    size_t width  = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context=CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace,0);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    IFlyFaceDirectionType faceOrientation=[self faceImageOrientation];
    
    IFlyFaceImage* faceImage=[[IFlyFaceImage alloc] init];
    if(!faceImage){
        return nil;
    }
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    
    faceImage.data= (__bridge_transfer NSData*)CGDataProviderCopyData(provider);
    faceImage.width=width;
    faceImage.height=height;
    faceImage.direction=faceOrientation;
    
    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);
    
    
    
    return faceImage;
    
}
#pragma mark  - 判断当前设备的方向
- (void)updateAccelertionData:(CMAcceleration)acceleration{
    UIInterfaceOrientation orientationNew;
    
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIInterfaceOrientationPortraitUpsideDown;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == self.interfaceOrientation)
        return;
    
    self.interfaceOrientation = orientationNew;
}

#pragma mark - 判断视频帧方向
-(IFlyFaceDirectionType)faceImageOrientation {
    IFlyFaceDirectionType faceOrientation=IFlyFaceDirectionTypeLeft;
    BOOL isFrontCamera = self.videoCamera.cameraPosition == AVCaptureDevicePositionFront;
    switch (self.interfaceOrientation) {
        case UIDeviceOrientationPortrait:{//
            faceOrientation=IFlyFaceDirectionTypeLeft;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:{
            faceOrientation=IFlyFaceDirectionTypeRight;
        }
            break;
        case UIDeviceOrientationLandscapeRight:{
            faceOrientation=isFrontCamera?IFlyFaceDirectionTypeUp:IFlyFaceDirectionTypeDown;
        }
            break;
        default:{//
            faceOrientation=isFrontCamera?IFlyFaceDirectionTypeDown:IFlyFaceDirectionTypeUp;
        }
            break;
    }
    
    return faceOrientation;
}

#pragma mark - 懒加载

- (GPUImageUIElement *)faceView {
    if (!_faceView) {
        _faceView = [[GPUImageUIElement alloc] initWithView:self.viewCanvas];
    }
    return _faceView;
}

- (CanvasView *)viewCanvas {
    if (!_viewCanvas) {
        _viewCanvas = [[CanvasView alloc]initWithFrame:self.view.bounds];
        _viewCanvas.backgroundColor = [UIColor clearColor];
//        _viewCanvas.alpha = 0.3
        _viewCanvas.headMap = [UIImage imageNamed:@"Crown"];
//        _viewCanvas.eyesMap = [UIImage imageNamed:@"Crown"];
    }
    return _viewCanvas;
}

- (WJGPUImageCameraView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[WJGPUImageCameraView alloc]initWithFrame:self.view.bounds];
    }
    return _cameraView;
}

- (GPUImageView *)outputView {
    if (!_outputView) {
        _outputView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
        [_outputView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    }
    return _outputView;
}


- (GPUImageStillCamera *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
        _videoCamera.delegate = self;
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
