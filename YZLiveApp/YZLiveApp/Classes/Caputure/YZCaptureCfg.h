//
//  YZCaptureCfg.h
//  YZLiveApp
//
//  Created by VcaiTech on 2016/11/11.
//  Copyright © 2016年 yz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import "KSYTypeDef.h"
typedef NS_ENUM(NSInteger, ZWLXCapResolutionType){
    ZWLXCapResolutionType360      = 0,
    ZWLXCapResolutionType540      = 1,
    ZWLXCapResolutionType720      = 2,
    ZWLXCapResolutionType480      = 3
}NS_ENUM_AVAILABLE_IOS(6_0);

@interface YZCaptureCfg : NSObject
@property(nonatomic,assign)ZWLXCapResolutionType capResolutionType;
@property(nonatomic,assign)int frameRate;
@property(nonatomic,assign)AVCaptureDevicePosition cameraPos;
@property(nonatomic,assign)OSType gpuOutputPixelFmt;

@property(nonatomic,assign)KSYVideoCodec videoCodec;
@property(nonatomic,assign)int videoKbps;
@property (nonatomic, assign)KSYAudioCodec audioCodec;
@property (nonatomic, assign)int  audiokBPS;
@property (nonatomic, assign) KSYBWEstimateMode bwEstimateMode;
@property(nonatomic,strong,readonly)NSString* capResolution;
@property(nonatomic,readonly)CGSize capResolutionSize;
@property(nonatomic,readonly)CGSize strResolutionSize;

@end
