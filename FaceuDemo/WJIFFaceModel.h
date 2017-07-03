//
//  WJIFFaceModel.h
//  FaceuDemo
//
//  Created by tqh on 2017/6/29.
//  Copyright © 2017年 tqh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WJIFFacePointModel;
/**
 讯飞的表情模型
 */
@interface WJIFFaceModel : NSObject

@property (nonatomic,assign) CGRect faceRect;               //面部区域

@property (nonatomic,strong) WJIFFacePointModel *left_eye_left_corner;  //
@property (nonatomic,strong) WJIFFacePointModel *left_eye_right_corner;  //
@property (nonatomic,strong) WJIFFacePointModel *left_eye_center;

@property (nonatomic,strong) WJIFFacePointModel *right_eye_left_corner;
@property (nonatomic,strong) WJIFFacePointModel *right_eye_right_corner;
@property (nonatomic,strong) WJIFFacePointModel *right_eye_center;

@property (nonatomic,strong) WJIFFacePointModel *right_eyebrow_left_corner;
@property (nonatomic,strong) WJIFFacePointModel *right_eyebrow_right_corner;
@property (nonatomic,strong) WJIFFacePointModel *right_eyebrow_middle;

@property (nonatomic,strong) WJIFFacePointModel *left_eyebrow_right_corner;
@property (nonatomic,strong) WJIFFacePointModel *left_eyebrow_left_corner;
@property (nonatomic,strong) WJIFFacePointModel *left_eyebrow_middle;

@property (nonatomic,strong) WJIFFacePointModel *nose_top;
@property (nonatomic,strong) WJIFFacePointModel *nose_left;
@property (nonatomic,strong) WJIFFacePointModel *nose_bottom;
@property (nonatomic,strong) WJIFFacePointModel *nose_right;

@property (nonatomic,strong) WJIFFacePointModel *mouth_left_corner;
@property (nonatomic,strong) WJIFFacePointModel *mouth_right_corner;
@property (nonatomic,strong) WJIFFacePointModel *mouth_middle;
@property (nonatomic,strong) WJIFFacePointModel *mouth_upper_lip_top;
@property (nonatomic,strong) WJIFFacePointModel *mouth_lower_lip_bottom;

@end

@interface WJIFFacePointModel : NSObject

@property (nonatomic,assign) CGFloat x;
@property (nonatomic,assign) CGFloat y;
@end
