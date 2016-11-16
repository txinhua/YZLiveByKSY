//
//  YZCaputureViewController.m
//  YZLiveApp
//
//  Created by yz on 16/9/2.
//  Copyright © 2016年 yz. All rights reserved.
//

#import "YZCaptureViewController.h"
#import <GPUImage/GPUImage.h>
#import <libksygpulive/libksygpuimage.h>
#import "KSYGPUStreamerKit.h"
#import "YZLiveShowFilter.h"
#import "YZCaptureCfg.h"

@interface YZCaptureViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableDictionary *_obsDict;
    NSURL *_pushUrl;
}

@property (nonatomic, strong) GPUImageFilterGroup<GPUImageInput>* curFilter;
@property (nonatomic, strong) KSYGPUStreamerKit * kit;
@property (nonatomic, strong) YZLiveShowFilter *filter;
@property (nonatomic, strong) YZCaptureCfg *captureCfg;
@property (nonatomic, strong) KSYStreamerBase        *streamerBase;
@end

@implementation YZCaptureViewController

-(void)initConfigInfo{
    
    _pushUrl =[NSURL URLWithString:_hostUrl];
    
    self.filter = [[YZLiveShowFilter alloc]init];
    
    [self initCaptureCfg];
    
    [self setFilerValue];
    
    [self initObservers];
}

-(void)initCaptureCfg{
    
    self.captureCfg = [[YZCaptureCfg alloc]init];
    
}

-(void)initStreamerBase{
    self.streamerBase =[[KSYStreamerBase alloc]initWithDefaultCfg];
}


-(void)setFilerValue{
    
    // 构造美颜滤镜 和  特效滤镜
    KSYBeautifyFaceFilter    * bf = [[KSYBeautifyFaceFilter alloc] init];
    KSYBuildInSpecialEffects * sf = [[KSYBuildInSpecialEffects alloc] initWithIdx:1];
    bf.grindRatio  = self.filter.grindRatio;
    bf.whitenRatio = self.filter.whitenRatio;
    sf.intensity   = self.filter.intensity;
//    bf.ruddyRatio  = self.filter.ruddyRatio;
    [bf addTarget:sf];
    // 用滤镜组 将 滤镜 串联成整体
    GPUImageFilterGroup * fg = [[GPUImageFilterGroup alloc] init];
    [fg addFilter:bf];
    [fg addFilter:sf];
    [fg setInitialFilters:[NSArray arrayWithObject:bf]];
    [fg setTerminalFilter:sf];
    _curFilter = fg;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initConfigInfo];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _kit = [[KSYGPUStreamerKit alloc] initWithDefaultCfg];
    // 采集相关设置初始化
    [self setCaptureCfg];
    
    //推流相关设置初始化
    [self setStreamerCfg];
    
    // 打印版本号信息
    NSLog(@"version: %@", [_kit getKSYVersion]);
    if (_kit) { // init with default filter
        
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        [_kit setupFilter:self.curFilter];

        [_kit startPreview:self.view];
    }
}


#define SEL_VALUE(SEL_NAME) [NSValue valueWithPointer:@selector(SEL_NAME)]

- (void) initObservers{
    
    _obsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                SEL_VALUE(onCaptureStateChange:) ,  KSYCaptureStateDidChangeNotification,
                SEL_VALUE(onStreamStateChange:) ,   KSYStreamStateDidChangeNotification,
                SEL_VALUE(onNetStateEvent:) ,       KSYNetStateEventNotification,
                SEL_VALUE(onBgmPlayerStateChange:) ,KSYAudioStateDidChangeNotification,
                SEL_VALUE(enterBg:) ,           UIApplicationDidEnterBackgroundNotification,
                SEL_VALUE(becameActive:) ,      UIApplicationDidBecomeActiveNotification,
                nil];
    
}


- (void)addObservers {
    
    //KSYStreamer state changes
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    for (NSString* key in _obsDict) {
        SEL aSel = [[_obsDict objectForKey:key] pointerValue];
        [dc addObserver:self
               selector:aSel
                   name:key
                 object:nil];
    }
}

- (void) rmObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enterBg:(NSNotification *)not{
    //app will resigned
    // 进入后台时, 将预览从图像混合器中脱离, 避免后台OpenGL渲染崩溃
    [_kit.vPreviewMixer removeAllTargets];
    [_kit.vStreamMixer removeAllTargets];
    
}

- (void) becameActive:(NSNotification *)not{ //app becameAction
    // 回到前台, 重新连接预览
    [_kit setupFilter:self.curFilter];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Capture & stream setup
- (void) setCaptureCfg {
    
    _kit.capPreset        = [self.captureCfg capResolution];
    _kit.previewDimension = [self.captureCfg capResolutionSize];
    _kit.streamDimension  = [self.captureCfg strResolutionSize];
    _kit.videoFPS         = [self.captureCfg frameRate];
    _kit.cameraPosition = [self.captureCfg cameraPos];
    _kit.gpuOutputPixelFormat = [self.captureCfg gpuOutputPixelFmt];
    _kit.videoProcessingCallback = ^(CMSampleBufferRef buf){

    };
    
}

- (void) defaultStramCfg{
    // stream default settings
    _kit.streamerBase.videoCodec = KSYVideoCodec_AUTO;
    _kit.streamerBase.videoInitBitrate =  800;
    _kit.streamerBase.videoMaxBitrate  = 1000;
    _kit.streamerBase.videoMinBitrate  =    0;
    _kit.streamerBase.audiokBPS        =   48;
    _kit.streamerBase.shouldEnableKSYStatModule = YES;
    _kit.streamerBase.videoFPS = 15;
    _kit.streamerBase.logBlock = ^(NSString* str){
        
    };
    _pushUrl = [NSURL URLWithString:@"rtmp://wsrtmpdev.zaiwailiuxue.com/dev/132"];
    
}
- (void) setStreamerCfg { // must set after capture
    if (_kit.streamerBase == nil) {
        return;
    }
    if (self.captureCfg){ // cfg from presetcfgview
        
        _kit.streamerBase.videoCodec       = [self.captureCfg videoCodec];
        _kit.streamerBase.videoInitBitrate = [self.captureCfg videoKbps]*6/10;//60%
        _kit.streamerBase.videoMaxBitrate  = [self.captureCfg videoKbps];
        _kit.streamerBase.videoMinBitrate  = 0; //
        _kit.streamerBase.audioCodec       = [self.captureCfg audioCodec];
        _kit.streamerBase.audiokBPS        = [self.captureCfg audiokBPS];
        _kit.streamerBase.videoFPS         = [self.captureCfg frameRate];
        _kit.streamerBase.bwEstimateMode   = [self.captureCfg bwEstimateMode];
        _kit.streamerBase.shouldEnableKSYStatModule = NO;
        _kit.streamerBase.logBlock = ^(NSString* str){
            //NSLog(@"%@", str);
        };
        _pushUrl = [NSURL URLWithString:@"rtmp://wsrtmpdev.zaiwailiuxue.com/dev/132"];
    }
    else {
        [self defaultStramCfg];
    }
}

//改变Stream后
- (void) updateStreamCfg: (BOOL) bStart {
    
    _kit.streamerBase.liveScene       =  self.streamerBase.liveScene;
    
    _kit.streamerBase.videoEncodePerf =  self.streamerBase.videoEncodePerf;
    
    _kit.streamerBase.bWithVideo      =  self.streamerBase.bWithVideo;
    
}

#pragma mark -  state change
- (void) onCaptureStateChange:(NSNotification *)notification{
    NSLog(@"new capStat: %@", _kit.getCurCaptureStateName );
}


- (void) onNetStateEvent     :(NSNotification *)notification{
    switch (_kit.streamerBase.netStateCode) {
        case KSYNetStateCode_SEND_PACKET_SLOW: {
            
            break;
        }
        case KSYNetStateCode_EST_BW_RAISE: {
        
            break;
        }
        case KSYNetStateCode_EST_BW_DROP: {
           
            break;
        }
        default:break;
    }
}


- (void) onBgmPlayerStateChange  :(NSNotification *)notification{
    NSString * st = [_kit.bgmPlayer getCurBgmStateName];
    NSLog(@"%@",st);
}

- (void) onStreamStateChange :(NSNotification *)notification{
    if (_kit.streamerBase){
        NSLog(@"stream State %@", [_kit.streamerBase getCurStreamStateName]);
    }
    if(_kit.streamerBase.streamState == KSYStreamStateError) {
        [self onStreamError:_kit.streamerBase.streamErrorCode];
    }
    else if (_kit.streamerBase.streamState == KSYStreamStateConnecting) {
//        [_ctrlView.lblStat initStreamStat]; // 尝试开始连接时,重置统计数据
    }
    else if (_kit.streamerBase.streamState == KSYStreamStateConnected) {
        
        //这个可以关掉视频，只上传音频
//        if ([self.audioView.swAudioOnly isOn] ){
//            _kit.streamerBase.bWithVideo = NO;
//        }
        
    }
}

- (void) onStreamError:(KSYStreamErrorCode) errCode{
    
    if (errCode == KSYStreamErrorCode_CONNECT_BREAK) {
        // Reconnect
        [self tryReconnect];
    }
    else if (errCode == KSYStreamErrorCode_AV_SYNC_ERROR) {
        NSLog(@"audio video is not synced, please check timestamp");
        [self tryReconnect];
    }
    else if (errCode == KSYStreamErrorCode_CODEC_OPEN_FAILED) {
        NSLog(@"video codec open failed, try software codec");
        _kit.streamerBase.videoCodec = KSYVideoCodec_X264;
        [self tryReconnect];
    }
}
- (void) tryReconnect {
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        NSLog(@"try again");
        _kit.streamerBase.bWithVideo = YES;
        [_kit.streamerBase startStream:_pushUrl];
    });
}
//
//#pragma mark - timer respond per second
//- (void)onTimer:(NSTimer *)theTimer{
//    
////    if (_kit.streamerBase.streamState == KSYStreamStateConnected ) {
////        [_ctrlView.lblStat updateState: _kit.streamerBase];
////    }
////    if (_kit.bgmPlayer && _kit.bgmPlayer.bgmPlayerState ==KSYBgmPlayerStatePlaying ) {
////        _ksyBgmView.progressV.progress = _kit.bgmPlayer.bgmProcess;
////    }
//    
//}
//
//#pragma mark - UI respond
////ctrView control (for basic ctrl)
//- (void) onBasicCtrl: (id) btn {
////    if (btn == _ctrlView.btnFlash){
////        [self onFlash];
////    }
////    else if (btn == _ctrlView.btnCameraToggle){
////        [self onCameraToggle];
////    }
////    else if (btn == _ctrlView.btnQuit){
////        [self onQuit];
////    }
////    else if(btn == _ctrlView.btnCapture){
////        [self onCapture];
////    }
////    else if(btn == _ctrlView.btnStream){
////        [self onStream];
////    }
////    else { // other btns
////        [self onMenuBtnPress:btn];
////    }
//}
//
////menuView control
//- (void)onMenuBtnPress:(UIButton *)btn{
//    
////    KSYUIView * view = nil;
////    if (btn == _ctrlView.bgmBtn ){
////        view = _ksyBgmView; // 背景音乐播放相关
////    }
////    else if (btn == _ctrlView.filterBtn ){
////        view = _ksyFilterView; // 美颜滤镜相关
////    }
////    else if (btn == _ctrlView.mixBtn ){
////        view = _audioView;    // 混音控制台
////        _audioView.micType = _kit.avAudioSession.currentMicType;
////        [_audioView initMicInput];
////    }
////    else if (btn == _ctrlView.miscBtn ){
////        view = _miscView;
////    }
////    // 将菜单的按钮隐藏, 将触发二级菜单的view显示
////    if (view){
////        [_ctrlView showSubMenuView:view];
////    }
//}
//
//#pragma mark - subviews: bgmview
//- (void)onBgmCtrSle:(UISegmentedControl*)sender {
//    
////    if ( sender == _ksyBgmView.loopType){
////        __weak KSYStreamerVC *weakself = self;
////        if ( sender.selectedSegmentIndex == 0) { // signal play
////            _kit.bgmPlayer.bgmFinishBlock = ^{};
////        }
////        else { // loop to next
////            _kit.bgmPlayer.bgmFinishBlock = ^{
////                [weakself.ksyBgmView loopNextBgmPath];
////                [weakself onBgmPlay];
////            };
////        }
////    }
//    
//}
////bgmView Control
//- (void)onBgmBtnPress:(UIButton *)btn{
//    
////    if (btn == _ksyBgmView.playBtn){
////        [self onBgmPlay];
////    }
////    else if (btn ==  _ksyBgmView.pauseBtn){
////        if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePlaying) {
////            [_kit.bgmPlayer pauseBgm];
////        }
////        else if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePaused){
////            [_kit.bgmPlayer resumeBgm];
////        }
////    }
////    else if (btn == _ksyBgmView.stopBtn){
////        [self onBgmStop];
////    }
////    else if (btn == _ksyBgmView.nextBtn){
////        [self.ksyBgmView nextBgmPath];
////        [self playNextBgm];
////    }
////    else if (btn == _ksyBgmView.previousBtn) {
////        [self.ksyBgmView previousBgmPath];
////        [self playNextBgm];
////    }
////    else if (btn == _ksyBgmView.muteBtn){
////        // 仅仅是静音了本地播放, 推流中仍然有音乐
////        _kit.bgmPlayer.bMutBgmPlay = !_kit.bgmPlayer.bMutBgmPlay;
////    }
//}
//- (void) playNextBgm {
//    if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePlaying) {
//        [_kit.bgmPlayer stopPlayBgm];
//        [self onBgmPlay];
//    }
//}
//- (void) onBgmPlay{
////    NSString* path = _ksyBgmView.bgmPath;
////    if (!path) {
////        [self onBgmStop];
////    }
////    [_kit.bgmPlayer startPlayBgm:path isLoop:NO];
//}
//
//- (void) onBgmStop{
//    if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePlaying) {
//        [_kit.bgmPlayer stopPlayBgm];
//    }
//}
//
//// 背景音乐音量调节
//- (void)onBgmVolume:(id )sl{
//    
////    if (sl == _ksyBgmView.volumSl){
////        _kit.bgmPlayer.bgmVolume = _ksyBgmView.volumSl.normalValue;
////    }
//    
//}
//
//#pragma mark - subviews: basic ctrl
//- (void) onFlash {
//    
//    [_kit toggleTorch];
//}
//
- (void) onCameraToggle{ // see kit or block
    
    [_kit switchCamera];
    
//    if (_kit.vCapDev && _kit.vCapDev.cameraPosition == AVCaptureDevicePositionBack) {
//        [_ctrlView.btnFlash setEnabled:YES];
//    }
//    else{
//        [_ctrlView.btnFlash setEnabled:NO];
//    }
    
}

- (void) onCapture{
    if (!_kit.vCapDev.isRunning){
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit startPreview:self.view];
    }
    else {
        [_kit stopPreview];
    }
}

- (void) onStream{
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError) {
        
        [self updateStreamCfg:YES];
        NSLog(@"push URL:%@",self.hostUrl);
        [_kit.streamerBase startStream:_pushUrl];
        
    }
    else {
        [self updateStreamCfg:NO];
        [_kit.streamerBase stopStream];
    }
}
- (void) onQuit{
    [_kit stopPreview];
    _kit = nil;
    [self rmObservers];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

#pragma mark - UI respond : gpu filters
- (void) onFilterChange:(id)sender{
//    if (self.ksyFilterView.curFilter != _kit.filter){
//        // use a new filter
//        [_kit setupFilter:self.ksyFilterView.curFilter];
//    }
}

//- (void) onFilterBtn:(id)sender{
//    
//}

//- (void) onFilterSwitch:(id)sender{
//    UISwitch* sw = sender;
//    if (sw == self.ksyFilterView.swPrevewFlip){
//        [_kit setPreviewMirrored:sw.on];
//    }
//    else if (sw == self.ksyFilterView.swStreamFlip){
//        [_kit setStreamerMirrored:sw.on];
//    }
//}
//#pragma mark - UI respond : audio ctrl
//- (void)onAMixerSwitch:(UISwitch *)sw{
//    
////    if (sw == _audioView.muteStream){
////        // 静音推流(发送音量为0的数据)
////        BOOL mute = _audioView.muteStream.isOn;
////        [_kit.streamerBase muteStreame:mute];
////    }
////    else if (sw == _audioView.bgmMix){
////        // 背景音乐 是否 参与混音
////        [_kit.aMixer setTrack:_kit.bgmTrack enable: sw.isOn];
////    }
////    else if (sw == _audioView.swAudioOnly && _kit.streamerBase) {
////        if (sw.on == YES) {
////            // disable video, only stream with audio
////            _kit.streamerBase.bWithVideo = NO;
////        }else{
////            _kit.streamerBase.bWithVideo = YES;
////        }
////        // 如果修改bWithVideo属性失败, 开关状态恢复真实结果
////        sw.on = !_kit.streamerBase.bWithVideo;
////    }
////    else if (sw == _audioView.swPlayCapture){
////        if ( ![KSYAUAudioCapture isHeadsetPluggedIn] ) {
////            [KSYUIVC toast:@"没有耳机, 开启耳返会有刺耳的声音"];
////            sw.on = NO;
////            _kit.aCapDev.bPlayCapturedAudio = NO;
////            return;
////        }
////        _kit.aCapDev.bPlayCapturedAudio = sw.isOn;
////    }
//    
//}
//
//- (void)onAMixerSegCtrl:(UISegmentedControl *)seg{
//    
////    if (_kit && seg == _audioView.micInput) {
////        _kit.avAudioSession.currentMicType = _audioView.micType;
////    }
////    else if (seg == _audioView.reverbType){
////        int t = (int)seg.selectedSegmentIndex;
////        _kit.aCapDev.reverbType = t;
////        return;
////    }
//    
//}
//
////- (void)onAMixerSlider:(KSYNameSlider *)slider{
////    float val = 0.0;
////    if ([slider isKindOfClass:[KSYNameSlider class]]) {
////        val = slider.normalValue;
////    }
////    else {
////        return;
////    }
////    if ( slider == self.audioView.bgmVol){
////        [_kit.aMixer setMixVolume:val of: _kit.bgmTrack];
////    }
////    else if ( slider == self.audioView.micVol){
////        [_kit.aMixer setMixVolume:val of: _kit.micTrack];
////    }
////    else if (slider == self.audioView.playCapVol){
////        if (_kit.aCapDev){
////            _kit.aCapDev.micVolume = slider.normalValue;
////        }
////    }
////}
//
//#pragma mark - misc features
//- (void)onMiscBtns:(id)sender {
//    // 截图的三种方法:
//    if (sender == _miscView.btn0){
//        // 方法1: 开始预览后, 从streamer 直接将待编码的图片存为本地的文件
//        NSString* path =@"snapshot/c.jpg";
//        [_kit.streamerBase takePhotoWithQuality:1 fileName:path];
//        NSLog(@"Snapshot save to %@", path);
//    }
//    else if (sender == _miscView.btn1){
//        // 方法2: 开始预览后, 从streamer获取UIImage对象
//        [_kit.streamerBase getSnapshotWithCompletion:^(UIImage * img){
//            [KSYUIVC saveImage: img
//                            to: @"snap1.png" ];
//        }];
//    }
//    else if (sender == _miscView.btn2) {
//        // 方法3: 如果有美颜滤镜, 可以从滤镜上获取截图(UIImage)
//        GPUImageOutput * filter = self.ksyFilterView.curFilter;
//        if (filter){
//            [filter useNextFrameForImageCapture];
//            [KSYUIVC saveImage: filter.imageFromCurrentFramebuffer
//                            to: @"snap2.png" ];
//        }
//    }
//    else if (sender == _miscView.btn3) {
//        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
//        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//        picker.delegate = self;
//        [self presentViewController:picker animated:YES completion:nil];
//    }
//}
//
//- (void)onMiscSwitch:(UISwitch *)sw{  // see kit & block
//    
//}
//
//
//
//#pragma mark - ui rotate
//- (void) onViewRotate { // 重写父类的方法, 参考父类 KSYUIView.m 中对UI旋转的响应
//    [self layoutUI];
//    if (_kit == nil || !_ksyFilterView.swUiRotate.on) {
//        return;
//    }
//    [_kit rotatePreview];
//    if (_ksyFilterView.swStrRotate.on) {
//        [_kit rotateStream];
//    }
//}


@end
