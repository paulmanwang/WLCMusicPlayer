//
//  RootViewController.m
//  WLCMusicPlayer
//
//  Created by wanglichun on 15/9/24.
//  Copyright © 2015年 thunder. All rights reserved.
//

#import "RootViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface RootViewController ()<AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSArray *musicFiles;
@property (assign, nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) NSTimer *progressTimer;
@property (assign, nonatomic) NSInteger playedTotalSeconds;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.progressView.progress = 0;
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [self loadMusicFiles];
    
    NSDictionary *musicInfo = self.musicFiles[self.currentIndex];
    [self playMusic:musicInfo[@"url"]];
    [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)loadMusicFiles
{
    self.musicFiles = @[@{@"name":@"红豆", @"url":@"hongdou.mp3"},
                        @{@"name":@"笑忘书", @"url":@"xiaowangshu.mp3"},
                        @{@"name":@"因为爱情", @"url":@"yinweiaiqing.mp3"}];
}

- (void)playMusic:(NSString *)musicUrl
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:musicUrl withExtension:nil];
    self.audioPlayer = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    
    [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
    self.progressView.progress = 0;
    self.playedTotalSeconds = 0;
    [self stopTimer];
    [self startTimer];
}

- (void)playNextMusic
{
    if (self.currentIndex == self.musicFiles.count - 1) {
        self.currentIndex = 0;
    } else {
        self.currentIndex++;
    }
    
    NSDictionary *musicInfo = self.musicFiles[self.currentIndex];
    [self playMusic:musicInfo[@"url"]];
    self.musicNameLabel.text = musicInfo[@"name"];
}

- (void)playPreMusic
{
    if (self.currentIndex == 0) {
        self.currentIndex = self.musicFiles.count - 1;
    } else {
        self.currentIndex--;
    }
    
    NSDictionary *musicInfo = self.musicFiles[self.currentIndex];
    [self playMusic:musicInfo[@"url"]];
    self.musicNameLabel.text = musicInfo[@"name"];
}

#pragma mark - Button actions

- (IBAction)onPlayButtonClicked:(id)sender
{
    if (self.audioPlayer.isPlaying) {
        [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
        [self.audioPlayer pause];
    } else {
        [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
        [self.audioPlayer play];
    }
}

- (IBAction)onNextButtonClicked:(id)sender
{
    [self playNextMusic];
}

- (IBAction)onPreButtonClicked:(id)sender
{
    [self playPreMusic];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self playNextMusic];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    // 解码失败，自动播放下一首
    [self playNextMusic];
}

//  音乐播放器被打断 (如开始 打、接电话)
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    // 会自动暂停  do nothing ...
    NSLog(@"audioPlayerBeginInterruption---被打断");
}

//  音乐播放器打断终止 (如结束 打、接电话)
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    // 手动恢复播放
    [player play];
    NSLog(@"audioPlayerEndInterruption---打断终止");
}


#pragma mark - Timer

- (void)startTimer
{
    if (!self.progressTimer) {
        self.progressTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer
{
    if (self.progressTimer) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
}

- (void)updateProgress
{
    self.playedTotalSeconds++;
    self.progressView.progress = self.playedTotalSeconds / self.audioPlayer.duration;
}

#pragma mark - RemoteControlEvent

- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPause:
                [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
                [self.audioPlayer pause];
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
                [self.audioPlayer pause];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"上一首");
                [self playPreMusic];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"下一首");
                [self playNextMusic];
                break;
                
            default:
                break;  
        }  
    }  
}


@end
