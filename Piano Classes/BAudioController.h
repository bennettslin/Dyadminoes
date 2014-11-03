//
//  BAudioController.h
//  CoreAudio Starter Kit
//
//  Created by Ben Smiley-Andrews on 28/01/2013.
//  Copyright (c) 2013 Ben Smiley-Andrews. All rights reserved.
//

#import <AudioToolbox/MusicPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface BAudioController : NSObject<AVAudioSessionDelegate> {
    AUGraph _processingGraph;
    AudioUnit _samplerUnit;
    AudioUnit _ioUnit;
    AudioUnit _mixerUnit;

    AVAudioSession * _audioSession;
    BOOL _suspended;
    BOOL _acceptMidiMessages;
    
}

@property (nonatomic, readwrite) AudioUnit samplerUnit;

-(void) resumeFromInterruption;
-(void) interrupt;
-(void) setInputVolume: (Float32) volume withBus: (AudioUnitElement) bus;

@end
