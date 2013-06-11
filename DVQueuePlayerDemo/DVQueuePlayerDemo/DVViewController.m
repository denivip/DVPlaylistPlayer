//
//  DVViewController.m
//  DVQueuePlayerDemo
//
//  Created by Mikhail Grushin on 07.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVViewController.h"
#import "DVPlayerUIView.h"
#import <AVFoundation/AVFoundation.h>

NSString *const urlString1 = @"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8";
NSString *const urlString2 = @"http://stream.alayam.com/alayam/alayam/playlist.m3u8";
NSString *const urlString3 = @"http://www.nasa.gov/multimedia/nasatv/NTV-Public-IPS.m3u8";
NSString *const urlString4 = @"http://iphone-streaming.ustream.tv/ustreamVideo/1524/streams/live/playlist.m3u8";
NSString *const urlString5 = @"http://esioslive4-i.akamaihd.net/hls/live/200736/AL_ESP2_UK_ENG/playlist_400.m3u8";

@interface DVViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) DVQueuePlayer *queuePlayer;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) NSArray *arrayOfNames;
@property (nonatomic, strong) DVPlayerUIView *playerInterface;

@property (nonatomic, strong) UITableView *queueTableView;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation DVViewController

-(NSArray *)arrayOfNames {
    if (!_arrayOfNames) {
        _arrayOfNames = [NSArray arrayWithObjects:@"BipBop", @"Alayam", @"NASA", @"UStream", @"EuroSport", nil];
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

-(DVQueuePlayer *)queuePlayer {
    if (!_queuePlayer) {
        _queuePlayer = [[DVQueuePlayer alloc] init];
        _queuePlayer.dataSource = self;
        _queuePlayer.delegate = self;
    }
    
    return _queuePlayer;
}

-(DVPlayerUIView *)playerInterface {
    if (!_playerInterface) {
        CGSize size = CGSizeMake(self.view.bounds.size.width, 80.f);
        _playerInterface = [[DVPlayerUIView alloc] initWithFrame:CGRectMake(0.f,
                                                                                CGRectGetMaxY(self.view.bounds) - size.height,
                                                                                size.width,
                                                                                size.height)];
        _playerInterface.volumeBar.volume = self.queuePlayer.volume;
        _playerInterface.volume = self.playerInterface.volumeBar.volume;
        _playerInterface.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        [_playerInterface.playButton addTarget:self action:@selector(playButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [_playerInterface.stopButton addTarget:self action:@selector(stopButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [_playerInterface.prevButton addTarget:self action:@selector(prevButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [_playerInterface.nextButton addTarget:self action:@selector(nextButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [_playerInterface.muteButton addTarget:self action:@selector(muteButtonTap) forControlEvents:UIControlEventTouchUpInside];
        
        [_playerInterface.seekBar addTarget:self action:@selector(seekBarProgressChanged) forControlEvents:UIControlEventValueChanged];
        [_playerInterface.volumeBar addTarget:self action:@selector(volumeChanged) forControlEvents:UIControlEventValueChanged];
        
        [_playerInterface.elapsedButton addTarget:self action:@selector(timeButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [_playerInterface.durationButton addTarget:self action:@selector(timeButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playerInterface;
}

-(UITableView *)queueTableView
{
    if (!_queueTableView) {
        _queueTableView = [[UITableView alloc] init];
        _queueTableView.delegate = self;
        _queueTableView.dataSource = self;
        
        [_queueTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        _queueTableView.layer.borderWidth = 1.f;
    }
    
    return _queueTableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIView *playerView = self.queuePlayer.playerView;
    playerView.frame = self.view.bounds;
    playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:playerView atIndex:0];
    
    [self.view addSubview:self.playerInterface];
    [self.view addSubview:self.queueTableView];
}

- (void)viewDidLayoutSubviews
{
    CGFloat interfaceHeight = 100.f;
    CGSize halfSize = CGSizeMake(self.view.bounds.size.width/2.f,
                                 self.view.bounds.size.height/2.f);
    self.playerInterface.interfaceOrientation = self.interfaceOrientation;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.queuePlayer.playerView.frame = CGRectMake(0,
                                                       0,
                                                       self.view.bounds.size.width*2/3,
                                                       self.view.bounds.size.height - interfaceHeight);
        self.playerInterface.frame = CGRectMake(0.f,
                                                self.view.bounds.size.height - interfaceHeight,
                                                self.view.bounds.size.width*2/3,
                                                interfaceHeight);
        self.queueTableView.frame = CGRectMake(CGRectGetMaxX(self.playerInterface.frame),
                                               0.f,
                                               self.view.bounds.size.width - self.playerInterface.frame.size.width,
                                               self.view.bounds.size.height);
    } else {
        self.queueTableView.frame = CGRectMake(0.f,
                                               0.f,
                                               self.view.bounds.size.width,
                                               halfSize.height - interfaceHeight/2.f);
        
        self.queuePlayer.playerView.frame = CGRectMake(0.f,
                                                       CGRectGetMaxY(self.queueTableView.frame),
                                                       self.view.bounds.size.width,
                                                       halfSize.height - interfaceHeight/2.f);
        
        self.playerInterface.frame = CGRectMake(0.f,
                                                CGRectGetMaxY(self.queuePlayer.playerView.frame),
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
    if (self.queuePlayer.state == DVQueuePlayerStatePlaying) {
        NSLog(@"Pause");
        [self.queuePlayer pause];
    } else if (self.queuePlayer.state == DVQueuePlayerStatePause) {
        NSLog(@"Pause -> Resume");
        [self.queuePlayer resume];
    } else {
        NSLog(@"Stop -> Play");
        [self.queuePlayer playMediaWithIndex:0];
    }
}

- (void)stopButtonTap
{
    [self.queuePlayer stop];
}

- (void)prevButtonTap
{
    [self.queuePlayer previous];
}

- (void)nextButtonTap
{
    [self.queuePlayer next];
}

- (void)seekBarProgressChanged
{
//    [self.queuePlayer seekToPercent:[NSString stringWithFormat:@"%f%%", self.playerInterface.seekBar.progress*100.f]];
}

- (void)volumeChanged
{
    self.queuePlayer.volume = self.playerInterface.volumeBar.volume;
    self.playerInterface.volume = self.playerInterface.volumeBar.volume;
    
    if (self.playerInterface.volumeBar.volume &&
        self.queuePlayer.isMuted) {
        [self.queuePlayer unmute];
    }
}

- (void)muteButtonTap
{
    if (!self.queuePlayer.isMuted) {
        [self.queuePlayer mute];
    } else {
        [self.queuePlayer unmute];
    }
}

- (void)timeButtonTap:(UIButton *)button
{
//    if (self.playerInterface.elapsedButton == button)
//        [self.queuePlayer seekToPosition:self.playerInterface.elapsed-5.f];
//    else if (self.playerInterface.durationButton == button)
//        [self.queuePlayer seekToPosition:self.playerInterface.elapsed+5.f];
}

#pragma mark - Queue player data source

-(NSUInteger)numberOfPlayerItems {
    return self.urlArray.count;
}

-(AVPlayerItem *)queuePlayer:(DVQueuePlayer *)queuePlayer playerItemForIndex:(NSInteger)index {
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[self.urlArray objectAtIndex:index]];
    return item;
}

#pragma mark - Queue player delegate


#pragma mark - UITableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.urlArray.count)
        [self.queuePlayer playMediaWithIndex:indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.urlArray.count < 6)?self.queueTableView.bounds.size.height/self.urlArray.count:40.f;
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
