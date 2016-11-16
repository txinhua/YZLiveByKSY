//
//  YZCaptureCfg.m
//  YZLiveApp
//
//  Created by VcaiTech on 2016/11/11.
//  Copyright © 2016年 yz. All rights reserved.
//

#import "YZCaptureCfg.h"
#import <GPUImage/GPUImage.h>

@implementation YZCaptureCfg
@dynamic capResolution;
@dynamic capResolutionSize;
@dynamic strResolutionSize;

-(instancetype)init{
    self = [super init];
    if (self) {

        self.frameRate = 15;
        self.capResolutionType = ZWLXCapResolutionType360;
        self.cameraPos = AVCaptureDevicePositionFront;
        self.gpuOutputPixelFmt = kCVPixelFormatType_32BGRA;
        
//        KSYVideoCodec_AUTO;
//        KSYVideoCodec_X264;
//        KSYVideoCodec_VT264;
//        KSYVideoCodec_QY265;
        self.videoCodec = KSYVideoCodec_AUTO;
        self.videoKbps  = 800;
//        KSYAudioCodec_AAC_HE;
//        KSYAudioCodec_AAC;
//        KSYAudioCodec_AT_AAC_HE;
//        KSYAudioCodec_AT_AAC;
        self.audioCodec= KSYAudioCodec_AAC_HE;
        self.audiokBPS = 32;
        self.bwEstimateMode = KSYBWEstMode_Default;
    }
    return self;
}


-(CGSize)capResolutionSize{
    
    CGSize defaultSize = CGSizeMake(640, 360);
    
    switch (self.capResolutionType) {
        case ZWLXCapResolutionType360:
            defaultSize = CGSizeMake(640, 360);
            break;
        case ZWLXCapResolutionType540:
            defaultSize = CGSizeMake(960, 540);
            break;
        case ZWLXCapResolutionType720:
            defaultSize = CGSizeMake(1280, 720);
            break;
        case ZWLXCapResolutionType480:
            defaultSize = CGSizeMake(640, 480);
            break;
            
        default:
            break;
    }
    return defaultSize;
}

-(CGSize)strResolutionSize{
    
    CGSize defaultSize = CGSizeMake(640, 360);
    
    switch (self.capResolutionType){
            
        case ZWLXCapResolutionType360:
            defaultSize = CGSizeMake(640, 360);
            break;
            
        case ZWLXCapResolutionType540:
            defaultSize = CGSizeMake(960, 540);
            break;
            
        case ZWLXCapResolutionType720:
            defaultSize = CGSizeMake(1280, 720);
            break;
            
        case ZWLXCapResolutionType480:
            defaultSize = CGSizeMake(640, 480);
            break;
            
        default:
            break;
    }
    
    return defaultSize;
    
}

-(NSString *)capResolution{
    
    NSString *capResolutionStr = AVCaptureSessionPreset640x480;
    
    switch (self.capResolutionType) {
            
        case ZWLXCapResolutionType360:
            capResolutionStr = AVCaptureSessionPreset640x480;
            break;
            
        case ZWLXCapResolutionType540:
            capResolutionStr = AVCaptureSessionPresetiFrame960x540;
            break;
            
        case ZWLXCapResolutionType720:
            capResolutionStr = AVCaptureSessionPreset1280x720;
            break;
            
        case ZWLXCapResolutionType480:
            capResolutionStr = AVCaptureSessionPreset640x480;
            break;
            
        default:
            break;
    }
    
    return capResolutionStr;
    
}



@end
