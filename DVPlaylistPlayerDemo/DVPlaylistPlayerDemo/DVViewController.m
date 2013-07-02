//
//  DVViewController.m
//  DVPlaylistPlayerDemo
//
//  Created by Mikhail Grushin on 07.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVViewController.h"
#import "DVPlayerUIView.h"
#import <AVFoundation/AVFoundation.h>
#import <DVPlaylistPlayer/DVPlaylistPlayer.h>

NSString *const urlString1 = @"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8";
NSString *const urlString2 = @"http://tv.i-ghost.net/stream/TEST/116.m3u8";
NSString *const urlString3 = @"http://tv.i-ghost.net/stream/TEST/139.m3u8";
NSString *const urlString4 = @"http://iphone-streaming.ustream.tv/ustreamVideo/1524/streams/live/playlist.m3u8";
NSString *const urlString5 = @"http://esioslive4-i.akamaihd.net/hls/live/200736/AL_ESP2_UK_ENG/playlist_400.m3u8";

@interface DVViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, DVPlaylistPlayerDataSource, DVPlaylistPlayerDelegate>
@property (nonatomic, strong) DVPlaylistPlayer *playlistPlayer;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) NSArray *arrayOfNames;
@property (nonatomic, strong) DVPlayerUIView *playerInterface;

@property (nonatomic, strong) UITableView *playlistTableView;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation DVViewController

-(NSArray *)arrayOfNames {
    if (!_arrayOfNames) {
        _arrayOfNames = [NSArray arrayWithObjects:@"BipBop", @"National Geographic", @"Russia 24", @"TWiT", @"EuroSport", nil];
    }
    
    return _arrayOfNames;
}

-(NSArray *)urlArray {
    if (!_urlArray) {
        NSURL *url1 = [NSURL URLWithString:urlString1];
        NSURL *url2 = [NSURL URLWithString:urlString2];
        NSURL *url3 = [NSURL URLWithString:urlString3];
        NSURL *url4 = [NSURL URLWithString:urlString4];
        NSURL *url5 = [NSURL URLWithString:urlString5];
        _urlArray = [NSArray arrayWithObjects:url1, url2, url3, url4, url5, nil];
    }
    
    return _urlArray;
}

-(DVPlaylistPlayer *)playlistPlayer {
    if (!_playlistPlayer) {
        _playlistPlayer = [[DVPlaylistPlayer alloc] init];
        _playlistPlayer.dataSource = self;
        _playlistPlayer.delegate = self;
        __weak DVViewController *weakSelf = self;
        [_playlistPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:NULL usingBlock:^(CMTime time) {
            CMTimeRange seekableRange = kCMTimeRangeInvalid;
            NSArray *seekableRanges = weakSelf.playlistPlayer.currentItem.seekableTimeRanges;
            if ([seekableRanges count] > 0) {
                seekableRange = [[seekableRanges objectAtIndex:0] CMTimeRangeValue];
            }
         
            weakSelf.playerInterface.seekBar.progress = CMTimeGetSeconds(time)/CMTimeGetSeconds(seekableRange.duration);
        }];
    }
    
    return _playlistPlayer;
}

-(DVPlayerUIView *)playerInterface {
    if (!_playerInterface) {
        CGSize size = CGSizeMake(self.view.bounds.size.width, 80.f);
        _playerInterface = [[DVPlayerUIView alloc] initWithFrame:CGRectMake(0.f,
                                                                                CGRectGetMaxY(self.view.bounds) - size.height,
                                                                                size.width,
                                                                                size.height)];
        _playerInterface.volumeBar.volume = self.playlistPlayer.volume;
        _playerInterface.volume = self.playerInterface.volumeBar.volume;
        _playerInterface.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        [_playerInterface.playButton addTarget:self action:@selector(playButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [_playerInterface.stopButton addTarget:self action:@selector(stopButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [_playerInterface.prevButton addTarget:self action:@selector(prevButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [_playerInterface.nextButton addTarget:self action:@selector(nextButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [_playerInterface.muteButton addTarget:self action:@selector(muteButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [_playerInterface.volumeBar addTarget:self action:@selector(volumeChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    return _playerInterface;
}

-(UITableView *)playlistTableView
{
    if (!_playlistTableView) {
        _playlistTableView = [[UITableView alloc] init];
        _playlistTableView.delegate = self;
        _playlistTableView.dataSource = self;
        
        [_playlistTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        _playlistTableView.layer.borderWidth = 1.f;
    }
    
    return _playlistTableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIView *playerView = self.playlistPlayer.playerView;
    playerView.frame = self.view.bounds;
    playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:playerView atIndex:0];
    
    [self.view addSubview:self.playerInterface];
    [self.view addSubview:self.playlistTableView];
}

- (void)viewDidLayoutSubviews
{
    CGFloat interfaceHeight = 100.f;
    CGSize halfSize = CGSizeMake(self.view.bounds.size.width/2.f,
                                 self.view.bounds.size.height/2.f);

    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.playlistPlayer.playerView.frame = CGRectMake(0,
                                                       0,
                                                       self.view.bounds.size.width*2/3,
                                                       self.view.bounds.size.height - interfaceHeight);
        self.playerInterface.frame = CGRectMake(0.f,
                                                self.view.bounds.size.height - interfaceHeight,
                                                self.view.bounds.size.width*2/3,
                                                interfaceHeight);
        self.playlistTableView.frame = CGRectMake(CGRectGetMaxX(self.playerInterface.frame),
                                               0.f,
                                               self.view.bounds.size.width - self.playerInterface.frame.size.width,
                                               self.view.bounds.size.height);
    } else {
        self.playlistTableView.frame = CGRectMake(0.f,
                                               0.f,
                                               self.view.bounds.size.width,
                                               halfSize.height - interfaceHeight/2.f);
        
        self.playlistPlayer.playerView.frame = CGRectMake(0.f,
                                                       CGRectGetMaxY(self.playlistTableView.frame),
                                                       self.view.bounds.size.width,
                                                       halfSize.height - interfaceHeight/2.f);
        
        self.playerInterface.frame = CGRectMake(0.f,
                                                CGRectGetMaxY(self.playlistPlayer.playerView.frame),
                                                self.view.bounds.size.width,
                                                interfaceHeight);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Interface Button Actions

- (void)playButtonTap
{
    if (self.playlistPlayer.state == DVQueuePlayerStatePlaying) {
        NSLog(@"Play -> Pause");
        [self.playlistPlayer pause];
    } else if (self.playlistPlayer.state == DVQueuePlayerStatePause) {
        NSLog(@"Pause -> Resume");
        [self.playlistPlayer resume];
    } else {
        NSLog(@"Stop -> Play");
        [self.playlistPlayer playMediaAtIndex:0];
    }
}

- (void)stopButtonTap
{
    [self.playlistPlayer stop];
}

- (void)prevButtonTap
{
    [self.playlistPlayer previous];
}

- (void)nextButtonTap
{
    [self.playlistPlayer next];
}

- (void)volumeChanged
{
    self.playlistPlayer.volume = self.playerInterface.volumeBar.volume;
    self.playerInterface.volume = self.playerInterface.volumeBar.volume;
    
    if (self.playerInterface.volumeBar.volume &&
        self.playlistPlayer.isMuted) {
        [self.playlistPlayer unmute];
    }
}

- (void)muteButtonTap
{
    if (!self.playlistPlayer.isMuted) {
        [self.playlistPlayer mute];
    } else {
        [self.playlistPlayer unmute];
    }
}

#pragma mark - Queue player data source

-(NSUInteger)numberOfPlayerItems {
    return self.urlArray.count;
}

-(AVPlayerItem *)queuePlayer:(DVPlaylistPlayer *)queuePlayer playerItemAtIndex:(NSInteger)index {
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[self.urlArray objectAtIndex:index]];
    return item;
}

#pragma mark - Queue player delegate

- (void)queuePlayerDidStartPlaying:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Started playing");
    NSInteger index = queuePlayer.currentItemIndex;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.playlistTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)queuePlayerDidResumePlaying:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Resume playing");
}

- (void)queuePlayerDidPausePlaying:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Paused");
}

- (void)queuePlayerDidStopPlaying:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Stopped playing");
    
    [self.playlistTableView deselectRowAtIndexPath:self.playlistTableView.indexPathForSelectedRow animated:YES];
}

-(void)queuePlayerDidCompletePlaying:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Complete playing");
    
    [self.playlistTableView deselectRowAtIndexPath:self.playlistTableView.indexPathForSelectedRow animated:YES];
}

- (void)queuePlayerDidMoveToNext:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Playing next");
}

- (void)queuePlayerDidMoveToPrevious:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Playing previous");
}

-(void)queuePlayerBuffering:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Buffering");
}

- (void)queuePlayerDidMute:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Muted");
    self.playerInterface.muteButton.selected = YES;
    [self.playerInterface.volumeBar mute];
}

- (void)queuePlayerDidUnmute:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Back to sound");
    self.playerInterface.muteButton.selected = NO;
    [self.playerInterface.volumeBar unmute];
}

- (void)queuePlayerDidChangeVolume:(DVPlaylistPlayer *)queuePlayer {
    NSLog(@"Changed volume to %f", queuePlayer.volume);
    if (!self.playerInterface.volumeBar.isMuted) {
        self.playerInterface.muteButton.selected = NO;
    }
}

- (void)queuePlayerFailedToPlay:(DVPlaylistPlayer *)queuePlayer withError:(NSError *)error {
    NSLog(@"Failed to play with error : %@", error.localizedDescription);
}

#pragma mark - UITableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.urlArray.count)
        [self.playlistPlayer playMediaAtIndex:indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.urlArray.count < 6)?self.playlistTableView.bounds.size.height/self.urlArray.count:40.f;
}

#pragma mark - UITableView data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.urlArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Condensed" size:10.f];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [self.arrayOfNames objectAtIndex:indexPath.row];
    cell.clipsToBounds = YES;
    
    return cell;
}

@end
