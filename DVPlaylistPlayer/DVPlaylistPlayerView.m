//
//  DVPlaylistPlayerView.m
//  Playlist Player SDK
//
//  Created by Mikhail Grushin on 07.06.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVPlaylistPlayerView.h"

@implementation DVPlaylistPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end
