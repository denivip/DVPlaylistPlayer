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

NSString *const DVQueuePlayerStartPlayingEvent = @"DVQueuePlayerStartPlayingEvent";
NSString *const DVQueuePlayerResumePlayingEvent = @"DVQueuePlayerResumePlayingEvent";
NSString *const DVQueuePlayerPausePlayingEvent = @"DVQueuePlayerPausePlayingEvent";
NSString *const DVQueuePlayerStopPlayingEvent = @"DVQueuePlayerStopPlayingEvent";
NSString *const DVQueuePlayerMovedToNextTrackEvent = @"DVQueuePlayerMovedToNextTrackEvent";
NSString *const DVQueuePlayerMovedToPreviousTrackEvent = @"DVQueuePlayerMovedToPreviousTrackEvent";
NSString *const DVQueuePlayerMuteEvent = @"DVQueuePlayerMuteEvent";
NSString *const DVQueuePlayerUnmuteEvent = @"DVQueuePlayerUnmuteEvent";
NSString *const DVQueuePlayerVolumeChangedEvent = @"DVQueuePlayerVolumeChangedEvent";
NSString *const DVQueuePlayerErrorEvent = @"DVQueuePlayerErrorEvent";

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
        [self fireEvent:DVQueuePlayerErrorEvent];
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
                [self.invocationOnError invoke];
                [self fireEvent:DVQueuePlayerErrorEvent];
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
            [self fireEvent:DVQueuePlayerStartPlayingEvent];
        }
        else if (self.player.rate > 0) {
            [self fireEvent:DVQueuePlayerResumePlayingEvent];
        }
        else if (self.player.rate == 0 && !shouldPlay) {
            [self fireEvent:DVQueuePlayerPausePlayingEvent];
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
    [self fireEvent:DVQueuePlayerStopPlayingEvent];
}

-(void)next {
    NSLog(@"Next");
    
    self.invocationOnError = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(next)]];
    self.invocationOnError.target = self;
    self.invocationOnError.selector = @selector(next);
    
    [self playMediaWithIndex:_currentItemIndex];
}

-(void)previous {
    NSLog(@"Previous");
    
    self.invocationOnError = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(previous)]];
    self.invocationOnError.target = self;
    self.invocationOnError.selector = @selector(previous);
    
    [self playMediaWithIndex:_currentItemIndex];
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

#pragma mark - Firing events

- (void)fireEvent:(NSString *)eventType {
    if ([eventType isEqualToString:DVQueuePlayerUpdateProgressEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayer:didUpdateProgress:)]) {
            [self.delegate queuePlayer:self didUpdateProgress:self.progress];
        }
    }
}

@end
