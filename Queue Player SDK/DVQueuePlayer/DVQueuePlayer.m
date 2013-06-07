//
//  DVQueuePlayer.m
//  Queue Player SDK
//
//  Created by Mikhail Grushin on 07.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVQueuePlayer.h"
#import "DVAudioSession.h"
#import "DVQueuePlayerView.h"
#import "THObserver.h"

@interface DVQueuePlayer()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic) NSUInteger currentItemIndex;
@property (nonatomic, strong) NSInvocation *invocationOnError;
@property (nonatomic) float unmuteVolume;
@property (nonatomic, strong) THObserver *playerItemStatusObserver;
@property (nonatomic, strong) THObserver *playerRateObserver;
@property (nonatomic, strong) THObserver *playerPeriodicTimeObserver;

@end

@implementation DVQueuePlayer

@synthesize playerView = _playerView;

-(UIView *)playerView {
    if (!_playerView) {
        _playerView = [[DVQueuePlayerView alloc] initWithFrame:CGRectZero];
    }
    
    return _playerView;
}

#pragma mark - Player control methods

-(void)playMediaWithIndex:(NSUInteger)index {
    NSLog(@"Play index %d", index);
    
    if (!self.dataSource ||
        [self.dataSource numberOfPlayerItems] < 1 ||
        index > [self.dataSource numberOfPlayerItems]) {
        #warning TODO Fire error event
        return;
    }
    
    AVPlayerItem *playerItem = [self.dataSource queuePlayer:self playerItemForIndex:index];
    
    self.playerItemStatusObserver = [THObserver observerForObject:playerItem keyPath:@"status" block:^{
        switch (self.currentItem.status) {
            case AVPlayerItemStatusReadyToPlay: {
                [self.player play];
            }
                break;
             
            case AVPlayerItemStatusFailed: {
            #warning TODO Fire error event
            }
                break;
                
            case AVPlayerItemStatusUnknown:
            default:
                break;
        }
    }];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    __block BOOL shouldPlay = YES;
    self.playerRateObserver = [THObserver observerForObject:player keyPath:@"player.rate" block:^{
        if (self.player.rate > 0 && shouldPlay) {
            shouldPlay = NO;
            self.state = DVQueuePlayerStatePlaying;
#warning TODO Fire play event
        }
        else if (self.player.rate > 0) {
#warning TODO Fire resume event
        }
        else if (self.player.rate == 0 && !shouldPlay) {
#warning TODO Fire pause event
        }
    }];
    
    if (self.player && self.playerPeriodicTimeObserver) {
        [self.player removeTimeObserver:self.playerPeriodicTimeObserver];
        self.playerPeriodicTimeObserver = nil;
    }
    
    self.playerPeriodicTimeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:NULL usingBlock:^(CMTime time) {
//        [self updateProgress];
    }];

    ((DVQueuePlayerView *)self.playerView).playerLayer.player = player;
    self.currentItem = playerItem;
    self.player = player;
}

-(void)resume {
    NSLog(@"Resume");
    [self.player play];
    self.invocationOnError = nil;
}

-(void)pause {
    NSLog(@"Pause");
    [self.player pause];
}

-(void)stop {
    NSLog(@"Stop");
    self.invocationOnError = nil;
}

-(void)next {
    NSLog(@"Next");
    
    self.invocationOnError = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(next)]];
    self.invocationOnError.target = self;
    self.invocationOnError.selector = @selector(next);
}

-(void)previous {
    NSLog(@"Previous");
    
    self.invocationOnError = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(previous)]];
    self.invocationOnError.target = self;
    self.invocationOnError.selector = @selector(previous);
}

#pragma mark - Volume Control

- (void)configureVolume
{
    float volume = (self.isMuted ? 0.f : self.volume);
    [DVAudioSession defaultSession].volume = volume;
}

- (void)mute
{
    if (self.isMuted) {
        return;
    }
    
    _muted = YES;
    self.unmuteVolume = self.volume;
    [self configureVolume];
}

- (void)unmute
{
    if (! self.isMuted) {
        return;
    }
    
    _muted = NO;
    _volume = self.unmuteVolume;
    [self configureVolume];
}

- (void)setVolume:(float)volume
{
    _volume = volume;
    
    if (_volume > 0.f) {
        _muted = NO;
    }
}

@end
