
//
//  YZLiveViewController.m
//  YZLiveApp
//
//  Created by yz on 16/8/29.
//  Copyright © 2016年 yz. All rights reserved.
//

#import "YZLiveViewController.h"
#import "YZLiveItem.h"
#import "YZCreatorItem.h"
#import "UIImageView+WebCache.h"

@interface YZLiveViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) KSYMoviePlayerController *player;
@end

@implementation YZLiveViewController
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置直播占位图片
    NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",_live.creator.portrait]];
    [self.imageView sd_setImageWithURL:imageUrl placeholderImage:nil];
    
    // 拉流地址
    NSURL *url = [NSURL URLWithString:_live.stream_addr];
    // 创建MoviePlayerController：专门用来直播，传入拉流地址就好了
    KSYMoviePlayerController *playerVc = [[KSYMoviePlayerController alloc] initWithContentURL:url];
    [self setupObservers];
    playerVc.logBlock = ^(NSString *logJson){
        NSLog(@"logJson is %@",logJson);
    };
    playerVc.view.frame = [UIScreen mainScreen].bounds;
    playerVc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    playerVc.shouldAutoplay = TRUE;
    playerVc.shouldEnableVideoPostProcessing = TRUE;
    playerVc.videoDecoderMode = MPMovieVideoDecoderMode_AUTO;
    playerVc.shouldMute = NO;
    playerVc.shouldEnableKSYStatModule = NO;
    playerVc.deinterlaceMode = MPMovieVideoDeinterlaceMode_Auto;
    [playerVc setTimeout:10 readTimeout:60];
    
    NSKeyValueObservingOptions opts = NSKeyValueObservingOptionNew;
    [playerVc addObserver:self forKeyPath:@"currentPlaybackTime" options:opts context:nil];
    [playerVc addObserver:self forKeyPath:@"clientIP" options:opts context:nil];
    [playerVc addObserver:self forKeyPath:@"localDNSIP" options:opts context:nil];
    [playerVc prepareToPlay];
    // 强引用，反正被销毁
    _player = playerVc;
    [self.view insertSubview:playerVc.view atIndex:1];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 界面消失，一定要记得停止播放
    [self releaseObservers];
    [_player pause];
    [_player stop];
}


-(void)handlePlayerNotify:(NSNotification*)notify
{
    if (!_player) {
        return;
    }
    if (MPMoviePlayerFirstVideoFrameRenderedNotification == notify.name)
    {
        
    }
    
    if (MPMoviePlayerFirstAudioFrameRenderedNotification == notify.name)
    {
        
    }
    
    if (MPMoviePlayerSuggestReloadNotification == notify.name)
    {
        NSLog(@"suggest using reload function!\n");
    }
    
    if(MPMoviePlayerPlaybackStatusNotification == notify.name)
    {
        int status = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackStatusUserInfoKey] intValue];
        if(MPMovieStatusVideoDecodeWrong == status)
        {
            NSLog(@"Video Decode Wrong!\n");
        }
        else if(MPMovieStatusAudioDecodeWrong == status)
        {
            NSLog(@"Audio Decode Wrong!\n");
        }
        else if (MPMovieStatusHWCodecUsed == status )
        {
            NSLog(@"Hardware Codec used\n");
        }
        else if (MPMovieStatusSWCodecUsed == status )
        {
            NSLog(@"Software Codec used\n");
        }
    }
}

- (void)setupObservers
{
    
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(handlePlayerNotify:)
//                                                name:(MPMediaPlaybackIsPreparedToPlayDidChangeNotification)
//                                              object:_player];
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(handlePlayerNotify:)
//                                                name:(MPMoviePlayerPlaybackStateDidChangeNotification)
//                                              object:_player];
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(handlePlayerNotify:)
//                                                name:(MPMoviePlayerPlaybackDidFinishNotification)
//                                              object:_player];
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(handlePlayerNotify:)
//                                                name:(MPMoviePlayerLoadStateDidChangeNotification)
//                                              object:_player];
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(handlePlayerNotify:)
//                                                name:(MPMovieNaturalSizeAvailableNotification)
//                                              object:_player];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerFirstVideoFrameRenderedNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerFirstAudioFrameRenderedNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerSuggestReloadNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackStatusNotification)
                                              object:_player];
}

- (void)releaseObservers
{
//    [[NSNotificationCenter defaultCenter]removeObserver:self
//                                                   name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
//                                                 object:_player];
//    [[NSNotificationCenter defaultCenter]removeObserver:self
//                                                   name:MPMoviePlayerPlaybackStateDidChangeNotification
//                                                 object:_player];
//    [[NSNotificationCenter defaultCenter]removeObserver:self
//                                                   name:MPMoviePlayerPlaybackDidFinishNotification
//                                                 object:_player];
//    [[NSNotificationCenter defaultCenter]removeObserver:self
//                                                   name:MPMoviePlayerLoadStateDidChangeNotification
//                                                 object:_player];
//    [[NSNotificationCenter defaultCenter]removeObserver:self
//                                                   name:MPMovieNaturalSizeAvailableNotification
//                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerFirstVideoFrameRenderedNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerFirstAudioFrameRenderedNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerSuggestReloadNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackStatusNotification
                                                 object:_player];
    [_player removeObserver:self forKeyPath:@"currentPlaybackTime"];
    [_player removeObserver:self forKeyPath:@"clientIP"];
    [_player removeObserver:self forKeyPath:@"localDNSIP"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if([keyPath isEqual:@"currentPlaybackTime"])
    {
        
    }
    else if([keyPath isEqual:@"clientIP"])
    {
        NSLog(@"client IP is %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
    }
    else if([keyPath isEqual:@"localDNSIP"])
    {
        NSLog(@"local DNS IP is %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
    }
    else if ([keyPath isEqualToString:@"player"]) {
        if (_player) {
            
        } else {
            
        }
    }
}


@end
