//
//  RootViewController.m
//  WLCMusicPlayer
//
//  Created by wanglichun on 15/9/24.
//  Copyright © 2015年 thunder. All rights reserved.
//

#import "RootViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface RootViewController ()<AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSArray *musicFiles;
@property (assign, nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) NSTimer *progressTimer;
@property (assign, nonatomic) NSInteger playedTotalSeconds;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) NSString *lyricsText;
@property (strong, nonatomic) NSArray *lyricsArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *headButton;

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
    
    self.lyricsText =  @"还没好好的感受 雪花绽放的气候\r\n"
                                @"我们一起颤抖 会更明白\r\n"
                                @"什么是温柔\r\n"
                                @"还没跟你牵著手 走过荒芜的沙丘\r\n"
                                @"可能从此以后 学会珍惜\r\n"
                                @"天长和地久\r\n"
                                @"有时候 有时候\r\n"
                                @"我会相信一切有尽头\r\n"
                                @"相聚离开 都有时候\r\n"
                                @"没有什么会永垂不朽\r\n"
                                @"可是我 有时候\r\n"
                                @"宁愿选择留恋不放手\r\n"
                                @"等到风景都看透\r\n"
                                @"也许你会陪我 看细水长流\r\n"
                                @"还没为你把红豆 熬成缠绵的伤口\r\n"
                                @"然后一起分享 会更明白\r\n"
                                @"相思的哀愁\r\n"
                                @"还没好好的感受 醒著亲吻的温柔\r\n"
                                @"可能在我左右 你才追求\r\n"
                                @"孤独的自由\r\n"
                                @"有时候 有时候\r\n"
                                @"我会相信一切有尽头\r\n"
                                @"相聚离开 都有时候\r\n"
                                @"没有什么会永垂不朽\r\n"
                                @"可是我 有时候\r\n"
                                @"宁愿选择留恋不放手\r\n"
                                @"等到风景都看透\r\n"
                                @"也许你会陪我 看细水长流\r\n"
                                @"有时候 有时候\r\n"
                                @"我会相信一切有尽头\r\n"
                                @"相聚离开 都有时候\r\n"
                                @"没有什么会永垂不朽\r\n"
                                @"可是我 有时候\r\n"
                                @"宁愿选择留恋不放手\r\n"
                                @"等到风景都看透\r\n"
                                @"也许你会陪我 看细水长流";
    
    self.lyricsArr = [self.lyricsText componentsSeparatedByString:@"\r\n"];
    
    [self addHeadRotateAmination];
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

- (void)addHeadRotateAmination
{
    CALayer *layer = self.headButton.layer;
    layer.cornerRadius = self.headButton.frame.size.width / 2;
    // http://www.cnblogs.com/kenshincui/p/3972100.html原因就是当绘制一张图片到图层上的时候会重新创建一个图层添加到当前图层，这样一来如果设置了圆角之后虽然底图层有圆角效果，但是子图层还是矩形，只有设置了masksToBounds为YES让子图层按底图层剪切才能显示圆角效果。同样的，有些朋友经常在网上提问说为什么使用UIImageView的layer设置圆角后图片无法显示圆角，只有设置masksToBounds才能出现效果，也是类似的问题。
    layer.masksToBounds = YES;
    
    // 旋转动画
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI_2*4];
    rotateAnimation.duration = 10;
    rotateAnimation.repeatCount = HUGE_VALF;
    [layer addAnimation:rotateAnimation forKey:@"KCBasicAnimation_Rotation"];
}

- (void)pauseHeadRotateAmination
{
    CALayer *layer = self.headButton.layer;
    //[layer removeAnimationForKey:@"KCBasicAnimation_Rotation"];
    layer.speed = 0;
}

#pragma mark - Button actions

- (IBAction)onPlayButtonClicked:(id)sender
{
    if (self.audioPlayer.isPlaying) {
        [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
        [self.audioPlayer pause];
        [self pauseHeadRotateAmination];
    } else {
        [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
        [self.audioPlayer play];
        [self addHeadRotateAmination];
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
    NSLog(@"thread is = %@", [NSThread currentThread]);
    if (!self.progressTimer) {
        //self.progressTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        //[[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
        
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
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
    NSLog(@"current mode = %@", [NSRunLoop currentRunLoop].currentMode);
    self.playedTotalSeconds++;
    CGFloat rate = self.playedTotalSeconds / self.audioPlayer.duration;
    self.progressView.progress = rate;
    
    NSInteger currentRow = rate * self.lyricsArr.count;
    if (currentRow < self.lyricsArr.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lyricsArr.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 28;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"LyricsTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.textLabel.text = self.lyricsArr[indexPath.row];
    
    return cell;
}

@end
