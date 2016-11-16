//
//  YZLiveShowFilter.m
//  YZLiveApp
//
//  Created by VcaiTech on 2016/11/11.
//  Copyright © 2016年 yz. All rights reserved.
//

#import "YZLiveShowFilter.h"

@implementation YZLiveShowFilter
-(instancetype)init{
    self =[super init];
    if (self) {
        self.specialEffects = ZWLXSpecialEffectsFresh;
        self.grindRatio  = 0.7;
        self.whitenRatio = 0.7;
        self.intensity   = 0.7;
        self.ruddyRatio  = 0.5;
    }
    return self;
}
@end
