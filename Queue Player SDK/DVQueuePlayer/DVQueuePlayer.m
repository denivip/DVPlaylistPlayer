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

typedef void(^timeObserverBlock)(CMTime time);

NSString *const DVQueuePlayerStartPlayingEvent = @"DVQueuePlayerStartPlayingEvent";
NSString *const DVQueuePlayerResumePlayingEvent = @"DVQueuePlayerResumePlayingEvent";
NSString *const DVQueuePlayerPausePlayingEvent = @"DVQueuePlayerPausePlayingEvent";
NSString *const DVQueuePlayerStopPlayingEvent = @"DVQueuePlayerStopPlayingEvent";
NSString *const DVQueuePlayerCompletePlayingEvent = @"DVQueuePlayerCompletePlayingEvent";
NSString *const DVQueuePlayerMovedToNextTrackEvent = @"DVQueuePlayerMovedToNextTrackEvent";
NSString *const DVQueuePlayerMovedToPreviousTrackEvent = @"DVQueuePlayerMovedToPreviousTrackEvent";
NSString *const DVQueuePlayerBufferingEvent = @"DVQueuePlayerBufferingEvent";
NSString *const DVQueuePlayerMuteEvent = @"DVQueuePlayerMuteEvent";
NSString *const DVQueuePlayerUnmuteEvent = @"DVQueuePlayerUnmuteEvent";
NSString *const DVQueuePlayerVolumeChangedEvent = @"DVQueuePlayerVolumeChangedEvent";
NSString *const DVQueuePlayerErrorEvent = @"DVQueuePlayerErrorEvent";

@interface DVQueuePlayer()

@property (nonatomic, strong) NSInvocation *invocationOnError;
@property (nonatomic) float unmuteVolume;
@property (nonatomic) BOOL forcedStop;

@property (nonatomic, strong) THObserver *playerItemStatusObserver;
@property (nonatomic, strong) THObserver *playerRateObserver;
@property (nonatomic, strong) THObserver *playerItemPlaybackLikelyToKeepUpObserver;
@property (nonatomic, strong) id playerPeriodicTimeObserver;

@property (nonatomic) CMTime periodicTimeObserverTime;
@property (nonatomic) dispatch_queue_t periodicTimeObserverQueue;
@property (nonatomic, strong) timeObserverBlock periodicTimeObserverBlock;

@property (nonatomic, strong) NSError *error;

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

- (void)playMediaWithIndex:(NSInteger)index {
    
    if (!self.dataSource ||
        [self.dataSource numberOfPlayerItems] < 1) {
        [self fireEvent:DVQueuePlayerErrorEvent];
        return;
    }
    
    _currentItemIndex = index;
    
    [self playCurrentMedia];
}

- (void)playCurrentMedia {
    if (_currentItemIndex < 0) {
        _currentItemIndex = 0;
    } else if (_currentItemIndex > [self.dataSource numberOfPlayerItems] - 1) {
        _currentItemIndex = [self.dataSource numberOfPlayerItems] - 1;
        [self stop];
        return;
    }
    
    if (self.currentItem.status == AVPlayerItemStatusReadyToPlay &&
        self.forcedStop) {
        [self fireEvent:DVQueuePlayerStopPlayingEvent];
    }
    
    self.forcedStop = YES;
    
    AVPlayerItem *playerItem = [self.dataSource queuePlayer:self playerItemForIndex:_currentItemIndex];
    
    self.playerItemStatusObserver = [THObserver observerForObject:playerItem keyPath:@"status" block:^{
        switch (self.currentItem.status) {
            case AVPlayerItemStatusReadyToPlay: {
                [self.player play];
                _state = DVQueuePlayerStatePlaying;
            }
                break;
             
            case AVPlayerItemStatusFailed: {
                self.error = self.currentItem.error;
                [self fireEvent:DVQueuePlayerErrorEvent];
                [self.invocationOnError invoke];
            }
                break;
                
            case AVPlayerItemStatusUnknown:
            default:
                break;
        }
    }];
    
    self.playerItemPlaybackLikelyToKeepUpObserver = [THObserver observerForObject:playerItem keyPath:@"playbackLikelyToKeepUp" block:^{
            if (!self.currentItem.playbackLikelyToKeepUp) {
                [self fireEvent:DVQueuePlayerBufferingEvent];
                _state = DVQueuePlayerStateBuffering;
            }
    }];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    __block BOOL currentlyStartingToPlay = YES;
    self.playerRateObserver = [THObserver observerForObject:player keyPath:@"rate" block:^{
        if (self.player.rate > 0 && currentlyStartingToPlay) {
            currentlyStartingToPlay = NO;
            [self fireEvent:DVQueuePlayerStartPlayingEvent];
            _state = DVQueuePlayerStatePlaying;
        }
        else if (self.player.rate > 0) {
            [self fireEvent:DVQueuePlayerResumePlayingEvent];
            _state = DVQueuePlayerStatePlaying;
        }
        else if (self.player.rate == 0 && !currentlyStartingToPlay &&
                 self.currentItem.playbackLikelyToKeepUp) {
            [self fireEvent:DVQueuePlayerPausePlayingEvent];
            _state = DVQueuePlayerStatePause;
        }
    }];
    
    if (self.player && self.playerPeriodicTimeObserver) {
        [self.player removeTimeObserver:self.playerPeriodicTimeObserver];
        self.playerPeriodicTimeObserver = nil;
    }
    
    if (CMTIME_IS_VALID(self.periodicTimeObserverTime)) {
        self.playerPeriodicTimeObserver = [player addPeriodicTimeObserverForInterval:self.periodicTimeObserverTime
                                                                               queue:self.periodicTimeObserverQueue
                                                                          usingBlock:self.periodicTimeObserverBlock];
    }

    ((DVQueuePlayerView *)self.playerView).playerLayer.player = player;
    self.currentItem = playerItem;
    self.player = player;
}

-(void)setCurrentItem:(AVPlayerItem *)currentItem {
    if (!currentItem && _currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_currentItem];
    }
    
    _currentItem = currentItem;
    
    if (_currentItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemReachedEnd)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_currentItem];
    }
}

- (void)playerItemReachedEnd {
    self.forcedStop = NO;
    [self fireEvent:DVQueuePlayerCompletePlayingEvent];
    
    [self next];
}

-(void)resume {
    [self.player play];
    self.invocationOnError = nil;
}

-(void)pause {
    [self.player pause];
}

-(void)stop {
    self.invocationOnError = nil;
    
    if (!self.player)
        return;
    
    [self.player removeTimeObserver:self.playerPeriodicTimeObserver];
    
    self.playerItemStatusObserver = nil;
    self.playerPeriodicTimeObserver = nil;
    self.playerRateObserver = nil;
    self.playerItemPlaybackLikelyToKeepUpObserver = nil;
    
    ((DVQueuePlayerView *)self.playerView).playerLayer.player = nil;
    self.player = nil;
    self.currentItem = nil;
    
    _state = DVQueuePlayerStateStop;
    
    if (self.forcedStop)
        [self fireEvent:DVQueuePlayerStopPlayingEvent];
    self.forcedStop = NO;
}

-(void)next {    
    ++_currentItemIndex;
    
    self.invocationOnError = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(next)]];
    self.invocationOnError.target = self;
    self.invocationOnError.selector = @selector(next);
    [self fireEvent:DVQueuePlayerMovedToNextTrackEvent];
    
    [self playCurrentMedia];
    
}

-(void)previous {
    --_currentItemIndex;
    
    self.invocationOnError = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(previous)]];
    self.invocationOnError.target = self;
    self.invocationOnError.selector = @selector(previous);
    
    [self playCurrentMedia];
}

-(void)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime))block {
    self.periodicTimeObserverTime = interval;
    self.periodicTimeObserverQueue = queue;
    self.periodicTimeObserverBlock = block;
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
    
    [self fireEvent:DVQueuePlayerMuteEvent];
}

- (void)unmute
{
    if (! self.isMuted) {
        return;
    }
    
    _muted = NO;
    _volume = self.unmuteVolume;
    [self configureVolume];
    
    [self fireEvent:DVQueuePlayerUnmuteEvent];
}

- (void)setVolume:(float)volume
{
    _volume = volume;
    
    if (_volume > 0.f) {
        _muted = NO;
    }
    
    [self configureVolume];
    [self fireEvent:DVQueuePlayerVolumeChangedEvent];
}

#pragma mark - Firing events

- (void)fireEvent:(NSString *)eventType {
    if ([eventType isEqualToString:DVQueuePlayerStartPlayingEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerDidStartPlaying:)]) {
            [self.delegate queuePlayerDidStartPlaying:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerPausePlayingEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerDidPausePlaying:)]) {
            [self.delegate queuePlayerDidPausePlaying:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerResumePlayingEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerDidResumePlaying:)]) {
            [self.delegate queuePlayerDidResumePlaying:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerStopPlayingEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerDidStopPlaying:)]) {
            [self.delegate queuePlayerDidStopPlaying:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerCompletePlayingEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerDidCompletePlaying:)]) {
            [self.delegate queuePlayerDidCompletePlaying:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerMovedToNextTrackEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerDidMovedToNext:)]) {
            [self.delegate queuePlayerDidMovedToNext:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerMovedToPreviousTrackEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerDidMovedToPrevious:)]) {
            [self.delegate queuePlayerDidMovedToPrevious:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerBufferingEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerBuffering:)]) {
            [self.delegate queuePlayerBuffering:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerMuteEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerDidMute:)]) {
            [self.delegate queuePlayerDidMute:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerUnmuteEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerDidUnmute:)]) {
            [self.delegate queuePlayerDidUnmute:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerVolumeChangedEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerDidChangeVolume:)]) {
            [self.delegate queuePlayerDidChangeVolume:self];
        }
    } else if ([eventType isEqualToString:DVQueuePlayerErrorEvent]) {
        if ([self.delegate respondsToSelector:@selector(queuePlayerFailedToPlay: withError:)]) {
            [self.delegate queuePlayerFailedToPlay:self withError:self.error];
            self.error = nil;
        }
        _state = DVQueuePlayerStateStop;
    }
}

@end
