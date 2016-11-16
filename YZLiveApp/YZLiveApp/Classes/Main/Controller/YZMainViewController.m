//
//  YZMainViewController.m
//  YZLiveApp
//
//  Created by yz on 16/8/29.
//  Copyright © 2016年 yz. All rights reserved.
//

#import "YZMainViewController.h"
#import "YZBroadcastListController.h"
#import "YZLiveViewController.h"
#import "YZLiveItem.h"
#import "YZCaptureViewController.h"

@interface YZMainViewController ()

@end

@implementation YZMainViewController

/**
 *  直播
 *
 */
- (IBAction)caputureVideo:(id)sender {
    
    YZCaptureViewController *caputureVC = [[YZCaptureViewController alloc] init];
    caputureVC.hostUrl = @"rtmp://wsrtmpdev.zaiwailiuxue.com/dev/131";
    [self presentViewController:caputureVC animated:YES completion:nil];
    
}

/**
 *  播放
 *
 */
- (IBAction)playVideo:(id)sender {
    YZBroadcastListController *broadcastVC = [[YZBroadcastListController alloc] init];
    [self.navigationController pushViewController:broadcastVC animated:YES];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"视频直播";
    
}


@end
