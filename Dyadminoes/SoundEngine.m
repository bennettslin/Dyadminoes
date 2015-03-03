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

#define kNoteDelay 0.05f

#define kSoundFilePop @"hitCatLady"
#define kSoundFileClick @"Click2-Sebastian-759472264"
#define kSoundFileRing @"Electronic_Chime-KevanGC-495939803"
#define kSoundFileSwoosh @"Slide_Closed_SoundBible_com_1521580537"

typedef enum systemSound {
  kSoundPop,
  kSoundClick,
  kSoundRing,
  kSoundSwoosh
} SystemSound;

@interface SoundEngine () <BPianoDelegate>

@property (assign, nonatomic) SystemSoundID kSoundPop;
@property (assign, nonatomic) SystemSoundID kSoundClick;
@property (assign, nonatomic) SystemSoundID kSoundRing;
@property (assign, nonatomic) SystemSoundID kSoundSwoosh;

@end

@implementation SoundEngine {
  
  NSUInteger _noteCount;
  FaceVector _faceVector;
  int _xOrigin;
  int _yOrigin;
  int32_t _xBits;
  int32_t _yBits;
  BAudioController *_audioController;
  
  SystemSoundID _systemSoundIDs[4]; // same number as systemSound enum
}

-(void)initialiseSystemSounds {
    // make sure this is consistent with systemSound enum
  NSArray *systemSoundFileNames = @[kSoundFilePop, kSoundFileClick, kSoundFileRing, kSoundFileSwoosh];
  
  for (int i = 0; i < systemSoundFileNames.count; i++) {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:systemSoundFileNames[i] ofType:@"wav"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    SystemSoundID mySound;
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(soundURL), &mySound);
    _systemSoundIDs[i] = mySound;
  }
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
    
    [self initialiseSystemSounds];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationOfSound:) name:@"playSound" object:nil];
    
    
  }
  return self;
}

#pragma mark - music note methods

-(NSUInteger)lowestNote {
  return 36 + [[NSUserDefaults standardUserDefaults] integerForKey:@"register"] * 12;
}

-(void) noteOn:(Byte)note {
  CGFloat volume = [[NSUserDefaults standardUserDefaults] floatForKey:@"music"] * 127;
  MusicDeviceMIDIEvent(_audioController.samplerUnit, 0x90, note, volume, 0);
}

-(void) noteOff:(Byte)note {
  CGFloat volume = [[NSUserDefaults standardUserDefaults] floatForKey:@"music"] * 127;
  MusicDeviceMIDIEvent(_audioController.samplerUnit, 0x80, note, volume, 0);
}

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

#pragma mark - sound methods

//-(void)handleNotificationOfSound:(NSNotification *)notification {
//  if (notification.userInfo) {
//    NotificationName notificationName = (NotificationName)[notification.userInfo[@"sound"] unsignedIntegerValue];
//    
//      // called from options page
//    if (notificationName == kNotificationOptionsMusic || notificationName == kNotificationOptionsRegister) {
//      [self handleMusicNote:0];
//      
//    } else {
//      SystemSoundID soundID = [self systemSoundIDForNotificationName:notificationName];
//      [self playSoundForSystemSoundID:soundID];
//    }
//  }
//}

-(void)playSoundNotificationName:(NotificationName)notificationName {
    // called from options page
  if (notificationName == kNotificationOptionsMusic || notificationName == kNotificationOptionsRegister) {
    [self handleMusicNote:0];
    
  } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
    SystemSoundID soundID = [self systemSoundIDForNotificationName:notificationName];
    [self playSoundForSystemSoundID:soundID];
  }
}

-(void)playSoundForSystemSoundID:(SystemSoundID)mySound {
  AudioServicesPlaySystemSound(mySound);
}

-(SystemSoundID)systemSoundIDForNotificationName:(NotificationName)notificationName {
  
    // obviously, change this with better sound files
  switch (notificationName) {
      
    case kNotificationRackExchangeClick:
      return 1104; // Apple button pressed
      break;
    case kNotificationPivotClick:
    case kNotificationEaseIntoNode:
    case kNotificationButtonSunkIn:
    case kNotificationButtonLifted:
      return _systemSoundIDs[kSoundClick];
      break;
    case kNotificationDeviceOrientation:
    case kNotificationPopIntoNode:
    case kNotificationTogglePCs:
    case kNotificationBoardZoom:
    case kNotificationOptionsSoundEffects:
      return _systemSoundIDs[kSoundPop];
      break;
    case kNotificationToggleBarOrField:
      return _systemSoundIDs[kSoundSwoosh];
      break;
      
        // this should never get called
    case kNotificationOptionsMusic:
    case kNotificationOptionsRegister:
      return UINT32_MAX;
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
