//
//  BAudioController.m
//  CoreAudio Starter Kit
//
//  Created by Ben Smiley-Andrews on 28/01/2013.
//  Copyright (c) 2013 Ben Smiley-Andrews. All rights reserved.
//

#import "BAudioController.h"

@implementation BAudioController

#define bSampleRate 44100.0
#define kSoundFontPiano @"AJH_Piano"

@synthesize samplerUnit = _samplerUnit;

-(id) init {
    if((self = [super init])) {
        
        [self setupAudioSession];
        
        // Set up variables for the audio graph
        OSStatus result = noErr;
        AUNode ioNode, mixerNode, samplerNode;
        
        // Specify the common portion of an audio unit's identify, used for all audio units
        // in the graph.
        AudioComponentDescription cd = {};
        cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
        
        // Instantiate an audio processing graph
        result = NewAUGraph (&_processingGraph);
        NSCAssert (result == noErr, @"Unable to create an AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
        // SAMPLER UNIT
        //Specify the Sampler unit, to be used as the first node of the graph
        cd.componentType = kAudioUnitType_MusicDevice;
        cd.componentSubType = kAudioUnitSubType_Sampler;
        
        // Create a new sampler note
        result = AUGraphAddNode (_processingGraph, &cd, &samplerNode);
        
        // Check for any errors
        NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // IO UNIT
        // Specify the Output unit, to be used as the second and final node of the graph
        cd.componentType = kAudioUnitType_Output;
        cd.componentSubType = kAudioUnitSubType_RemoteIO;
        
        // Add the Output unit node to the graph
        result = AUGraphAddNode (_processingGraph, &cd, &ioNode);
        NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // MIXER UNIT
        // Add the mixer unit to the graph
        cd.componentType = kAudioUnitType_Mixer;
        cd.componentSubType = kAudioUnitSubType_MultiChannelMixer;
        
        result = AUGraphAddNode (_processingGraph, &cd, &mixerNode);
        NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        
        // Open the graph
        result = AUGraphOpen (_processingGraph);
        NSCAssert (result == noErr, @"Unable to open the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Now that the graph is open get references to all the nodes and store
        // them as audio units
        
        // Get a reference to the sampler node and store it in the samplerUnit variable
        result = AUGraphNodeInfo (_processingGraph, samplerNode, 0, &_samplerUnit);
        NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Load a soundfont into the mixer unit
        [self loadSoundFont:kSoundFontPiano withPatch:0 withBank:kAUSampler_DefaultMelodicBankMSB withSampler:_samplerUnit];
        
        // Obtain a reference to the I/O unit from its node
        result = AUGraphNodeInfo (_processingGraph, ioNode, 0, &_ioUnit);
        NSCAssert (result == noErr, @"Unable to obtain a reference to the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        result = AUGraphNodeInfo (_processingGraph, mixerNode, 0, &_mixerUnit);
        NSCAssert (result == noErr, @"Unable to obtain a reference to the Mixer unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Set number of busses on mixer
        UInt32 busses = 1;
        result = AudioUnitSetProperty (_mixerUnit,
                              kAudioUnitProperty_ElementCount,
                              kAudioUnitScope_Input,
                              0,
                              &busses,sizeof (busses));
        NSCAssert (result == noErr, @"Unable to set input busses on mixer. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Connect the output of the mixer node to the input of he io node
        result = AUGraphConnectNodeInput (_processingGraph, samplerNode, 0, mixerNode, 0);
        NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);

        result = AUGraphConnectNodeInput (_processingGraph, mixerNode, 0, ioNode, 0);
        NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Print a graphic version of the graph
        CAShow(_processingGraph);
        
        // Start the graph
        result = AUGraphInitialize (_processingGraph);
        
        NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Start the graph
        result = AUGraphStart (_processingGraph);
        NSAssert (result == noErr, @"Unable to start audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
    }
    return self;
}

-(void) setInputVolume: (Float32) volume withBus: (AudioUnitElement) bus {
    OSStatus result = AudioUnitSetParameter(_mixerUnit,
                                     kMultiChannelMixerParam_Volume,
                                     kAudioUnitScope_Input,
                                     bus,
                                     volume, 0);
    NSAssert (result == noErr, @"Unable to set mixer input volume. Error code: %d '%.4s'", (int) result, (const char *)&result);
}

-(void) loadSoundFont: (NSString*) path withPatch: (int) patch withBank: (UInt8) bank withSampler: (AudioUnit) sampler {
        
    NSLog(@"Sound font: %@", path);
    
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:path ofType:@"sf2"]];
    [self loadFromDLSOrSoundFont: (NSURL *)presetURL withBank: bank withPatch: patch  withSampler:sampler];
    [presetURL relativePath];
}
        
// Load a SoundFont into a sampler
-(OSStatus) loadFromDLSOrSoundFont: (NSURL *)bankURL withBank: (UInt8) bank withPatch: (int)presetNumber withSampler: (AudioUnit) sampler {
    OSStatus result = noErr;
    
    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef)(bankURL);
    bpdata.bankMSB  = bank;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) presetNumber;
    
    // set the kAUSamplerProperty_LoadPresetFromBank property
    result = AudioUnitSetProperty(sampler,
                                  kAUSamplerProperty_LoadPresetFromBank,
                                  kAudioUnitScope_Global,
                                  0,
                                  &bpdata,
                                  sizeof(bpdata));
    
    // check for errors
    NSCAssert (result == noErr,
               @"Unable to set the preset property on the Sampler. Error code:%d '%.4s'",
               (int) result,
               (const char *)&result);
    
    return result;
}

//  AVAudioSession setup
//  This is all the external housekeeping needed in any ios coreaudio app
- (void) setupAudioSession {
    
    // setup the session
    _audioSession = [AVAudioSession sharedInstance];
    
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.0)) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleInterruption:)
                                                     name: AVAudioSessionInterruptionNotification
                                                   object: [AVAudioSession sharedInstance]];
    }
    else {
        [_audioSession setDelegate:self];
    }
    
    
    // tz change to play and record
	// Assign the Playback category to the audio session.
    NSError *audioSessionError = nil;
    
    
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.0)) {
        [_audioSession setCategory:AVAudioSessionCategoryPlayback
                       withOptions:AVAudioSessionCategoryOptionMixWithOthers
                             error:&audioSessionError];
        
        if (audioSessionError != nil) {
            NSLog (@"Error setting audio session category.");
        }

        [_audioSession setPreferredSampleRate:bSampleRate
                                        error:&audioSessionError];
        
        [self setBufferSize:1024.0];

    }
    else {
        [_audioSession setCategory:AVAudioSessionCategoryPlayback
                             error:&audioSessionError];
        
        if (audioSessionError != nil) {
            NSLog (@"Error setting audio session category.");
        }
        
        OSStatus propertySetError = 0;
        UInt32 allowMixing = true;
        propertySetError = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers,
                                                    sizeof (allowMixing),                               
                                                    &allowMixing);
        NSLog (@"Error enabling mixing.");
        
    }
    
    [self setAudioSessionActive:YES];
    
    if (audioSessionError != nil) {
        NSLog (@"Error activating audio session during initial setup.");
    }
    
    
    return ;   // everything ok
    
}

-(void) setAudioSessionActive: (BOOL) active {
    NSError *audioSessionError = nil;
    BOOL success = [_audioSession setActive:active error:&audioSessionError];
    if (!success) {
        NSLog (@"Error activating audio session!");
    }
}

// If the system interrupts the audio session - kill the volume
-(void) handleInterruption: (NSNotification *) notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
    
    if (interuptionType == AVAudioSessionInterruptionTypeBegan) {
        [self interrupt];
    }
    else if (interuptionType == AVAudioSessionInterruptionTypeEnded) {
        [self resumeFromInterruption];
    }
}

#pragma Interruption methods for iOS 5.1

-(void) beginInterruption {
    [self interrupt];
}

- (void)endInterruption {
    [self resumeFromInterruption];
}

-(void) interrupt {
    // Make sure we stop accepting MIDI messages
    _acceptMidiMessages = NO;
    
    // Stop the graph
    [self stopAUGraph];
    
    // Give up our audio session
    [self setAudioSessionActive:NO];
    NSLog(@"Audio Session Interrupted...");
    
    _suspended = YES;
}

-(BOOL) isGraphRunning {
    Boolean isRunning = false;
    OSStatus result = AUGraphIsRunning (_processingGraph, &isRunning);
    NSAssert (result == noErr, @"Error trying querying whether graph is running: %d '%.4s'", (int) result, (const char *)&result);

    // If the graph is running, stop it.
    if (isRunning) {
        NSLog(@"Audio Graph is running");
    }
    return isRunning;
}

-(void) resumeFromInterruption {
    
    if (!_suspended) {
        NSLog(@"App not suspended");
        return;
    }
    
    NSLog(@"Audio Session Re-starting.");
    
    // Test to see if the graph is running
    [self isGraphRunning];
    
    // Re-activate our audio session
    [self setAudioSessionActive:YES];
    
    // Start the graph
    [self startAUGraph];
    
    // Test again to see if the graph is running
    [self isGraphRunning];
    
    // We want to give the app a second to start up the graph again
    // to avoid errors
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(impl_resume) userInfo:Nil repeats:NO];
}

-(void) impl_resume {
    _acceptMidiMessages = YES;
}

-(void) startAUGraph {
    OSStatus result = AUGraphStart(_processingGraph);
    NSAssert (result == noErr, @"Failed to start Audio Graph: %d '%.4s'", (int) result, (const char *)&result);
}

-(void) stopAUGraph {
    // If the graph is running, stop it.
    if ([self isGraphRunning]) {
        OSStatus result = AUGraphStop(_processingGraph);
        NSAssert (result == noErr, @"Failed to stop Audio Graph: %d '%.4s'", (int) result, (const char *)&result);
    }
}

-(void) setBufferSize: (NSInteger) size {
	Float32 currentBufferDuration =  (Float32) (size / bSampleRate);
	
	NSLog(@"setting buffer duration to: %f", currentBufferDuration);
    
  NSError *audioSessionError = nil;
  [_audioSession setPreferredIOBufferDuration:currentBufferDuration error:&audioSessionError];
  if (audioSessionError != nil) {
      NSLog (@"Error setting audio session category.");
  }
  
  NSTimeInterval duration = [_audioSession preferredIOBufferDuration];
  NSLog(@"Current Buffer duration: %f", duration);
}

        
        



@end
