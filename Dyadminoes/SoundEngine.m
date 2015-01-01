//
//  SoundEngine.m
//  Dyadminoes
//
//  Created by Bennett Lin on 6/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SoundEngine.h"
#import "Dyadmino.h"
#import "BPianoDelegate.h"
#import "BAudioController.h"

#define kOptionsNote 0
#define kNoteDelay 0.05f

@interface SoundEngine () <BPianoDelegate>

@end

@implementation SoundEngine {
  
  NSUInteger _noteCount;
  FaceVector _faceVector;
  int _xOrigin;
  int _yOrigin;
  int32_t _xBits;
  int32_t _yBits;
  BAudioController *_audioController;
}

-(id)init {
  self = [super init];
  if (self) {
    _noteCount = 0;
    _faceVector = kFaceVectorNone;
    _xOrigin = 0;
    _yOrigin = 0;
    _xBits = 0;
    _yBits = 0;
    
    _audioController = [[BAudioController alloc] init];
    [_audioController setInputVolume:1 withBus:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationOfSound:) name:@"playSound" object:nil];
  }
  return self;
}

-(NSUInteger)lowestNote {
  return 36 + [[NSUserDefaults standardUserDefaults] integerForKey:@"register"] * 12;
}

#pragma mark - piano delegate methods

-(void) noteOn:(Byte)note {
  CGFloat volume = [[NSUserDefaults standardUserDefaults] floatForKey:@"music"] * 127;
  MusicDeviceMIDIEvent(_audioController.samplerUnit, 0x90, note, volume, 0);
}

-(void) noteOff:(Byte)note {
  CGFloat volume = [[NSUserDefaults standardUserDefaults] floatForKey:@"music"] * 127;
  MusicDeviceMIDIEvent(_audioController.samplerUnit, 0x80, note, volume, 0);
}

#pragma mark - notification and sound methods

-(void)handleMusicNote:(NSUInteger)note withHexCoord:(HexCoord)hexCoord {
    
    // FIXME: for now, just log hexCoord
  
  [self handleMusicNote:note];
//  NSLog(@"hexCoord is %i, %i", hexCoord.x, hexCoord.y);
}

-(void)handleMusicNote:(NSUInteger)note {
  if (note != -1) {

      // values will range from 36 to 84
    [self noteOn:note + [self lowestNote]];
  }
}

-(void)handleMusicNote1:(NSUInteger)note1 andNote2:(NSUInteger)note2 withOrientation:(DyadminoOrientation)dyadminoOrientation {
  
  NSUInteger lowestNote = [self lowestNote];
  note1 = note1 + lowestNote;
  
    // first determine pitches
  switch (dyadminoOrientation) {
        // note 1 is higher than note 2
    case kPC1atTenOClock:
    case kPC1atTwelveOClock:
    case kPC1atTwoOClock:
      note2 = note2 + lowestNote - 12;
      break;
      
        // note 2 is higher than note 1
    case kPC1atEightOClock:
    case kPC1atSixOClock:
    case kPC1atFourOClock:
      note2 = note2 + lowestNote;
      break;
  }
  
    // then determine delay
  NSUInteger noteSoundedFirst;
  NSUInteger noteSoundedSecond;
  
  switch (dyadminoOrientation) {
        // they're sounded simultaneously
    case kPC1atTwelveOClock:
    case kPC1atSixOClock:
      noteSoundedFirst = -1;
      break;
        // note 2 sounds first
    case kPC1atTwoOClock:
    case kPC1atFourOClock:
      noteSoundedFirst = note2;
      noteSoundedSecond = note1;
      break;
        // note 1 sounds first
    case kPC1atTenOClock:
    case kPC1atEightOClock:
      noteSoundedFirst = note1;
      noteSoundedSecond = note2;
      break;
  }
  
    // sound simultaneously
  if (noteSoundedFirst == -1) {
    [self noteOn:note1];
    [self noteOn:note2];
    
      // sound with delay
  } else {
    [self noteOn:noteSoundedFirst];
    double delayInSeconds = kNoteDelay;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^(void){
      [self noteOn:noteSoundedSecond];
    });
  }
}

-(void)handleNotificationOfSound:(NSNotification *)notification {
  if (notification.userInfo) {
    NotificationName notificationName = (NotificationName)[notification.userInfo[@"sound"] unsignedIntegerValue];
    NSString *soundFile = [self fileNameForNotificationName:notificationName];
    
      // called from options page
    if (notificationName == kNotificationOptionsMusic || notificationName == kNotificationOptionsRegister) {
      [self handleMusicNote:kOptionsNote];
    } else {
      [self playSoundFile:soundFile];
    }
  }
}

-(void)playSoundFile:(NSString *)soundFile {
  SKAction *playAction = [SKAction playSoundFileNamed:soundFile waitForCompletion:NO];
  [self removeActionForKey:soundFile];
  [self runAction:playAction withKey:soundFile];
}

-(NSString *)fileNameForNotificationName:(NotificationName)notificationName {
  
    // obviously, change this with better sound files
  switch (notificationName) {
    case kNotificationPivotClick:
    case kNotificationEaseIntoNode:
    case kNotificationRackExchangeClick:
    case kNotificationButtonSunkIn:
    case kNotificationButtonLifted:
      return kSoundFileClick;
      break;
    case kNotificationDeviceOrientation:
    case kNotificationPopIntoNode:
    case kNotificationTogglePCs:
    case kNotificationBoardZoom:
    case kNotificationOptionsSoundEffects:
      return kSoundFilePop;
      break;
    case kNotificationToggleBarOrField:
      return kSoundFileSwoosh;
      break;
    case kNotificationOptionsMusic:
    case kNotificationOptionsRegister:
      return nil;
      break;
  }
}

#pragma mark - singleton method

+(SoundEngine *)sharedSoundEngine {
  static dispatch_once_t pred;
  static SoundEngine *shared = nil;
  dispatch_once(&pred, ^{
    shared = [[SoundEngine alloc] init];
  });
  return shared;
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
