//
//  YZLiveShowFilter.h
//  YZLiveApp
//
//  Created by VcaiTech on 2016/11/11.
//  Copyright © 2016年 yz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSInteger, ZWLXSpecialEffects){
    ZWLXSpecialEffectsNone      = 0,//无
    ZWLXSpecialEffectsFresh     = 1,//小清新
    ZWLXSpecialEffectsPretty    = 2,//靓丽
    ZWLXSpecialEffectsSweet     = 3,//甜美可人
    ZWLXSpecialEffectsNostalgic = 4,//怀旧
    ZWLXSpecialEffectsBlues     = 5,//蓝调
    ZWLXSpecialEffectsOld       = 6 //老照片
    
}NS_ENUM_AVAILABLE_IOS(6_0);


@interface YZLiveShowFilter : NSObject

//特效效果
@property(nonatomic,assign)ZWLXSpecialEffects specialEffects;
//特效参数

@property(readwrite, nonatomic)CGFloat intensity;

//磨皮
@property(readwrite,nonatomic) CGFloat grindRatio;

//美白
@property(readwrite,nonatomic) CGFloat whitenRatio;

//红润
@property(readwrite,nonatomic) CGFloat ruddyRatio;

@end
