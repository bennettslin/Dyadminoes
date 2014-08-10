//
//  SoundEngine.m
//  Dyadminoes
//
//  Created by Bennett Lin on 6/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SoundEngine.h"
#import "Dyadmino.h"

@interface SoundEngine ()

@end

@implementation SoundEngine {
  
  NSUInteger _noteCount;
  FaceVector _faceVector;
  int _xOrigin;
  int _yOrigin;
  int32_t _xBits;
  int32_t _yBits;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationOfSound:) name:@"playSound" object:nil];
  }
  return self;
}

#pragma mark - notification and sound methods

-(void)handleNotificationOfSound:(NSNotification *)notification {
  if (notification.userInfo) {
    NotificationName notificationName = (NotificationName)[notification.userInfo[@"sound"] unsignedIntegerValue];
    NSString *soundFile = [self fileNameForNotificationName:notificationName];
    [self playSoundFile:soundFile];
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
      return kSoundFilePop;
      break;
    case kNotificationTwoNotesStruck:
    case kNotificationOneNoteStruck:
    case kNotificationOneNoteResonated:
      return kSoundFileRing;
      break;
    case kNotificationToggleBarOrField:
      return kSoundFileSwoosh;
    default:
      return kSoundFileClick;
      break;
  }
}

#pragma mark - AVAudioPlayer methods (not used)
  
/*

-(void)soundTouchedDyadmino:(Dyadmino *)dyadmino plucked:(BOOL)plucked {
  
  NSString *noteActionKey1 = [self returnNoteActionKey];
//  NSLog(@"%@", noteActionKey1);
  [self removeActionForKey:noteActionKey1];
//  [self runAction:sound withKey:noteActionKey1];
  [self incrementNoteCount];
  
//  NSString *noteActionKey2 = [self returnNoteActionKey];
//  NSLog(@"%@", noteActionKey2);
//  [self removeActionForKey:noteActionKey2];
//  [self runAction:sound withKey:noteActionKey2];
  [self incrementNoteCount];
}

-(void)soundTouchedDyadminoFace:(SKSpriteNode *)dyadminoFace plucked:(BOOL)plucked {
  
  NSLog(@"face touched is %@", dyadminoFace.name);
  
    // find out hexcoord
  Dyadmino *dyadmino = (Dyadmino *)dyadminoFace.parent;
  HexCoord faceHexCoord = [dyadmino getHexCoordOfFace:dyadminoFace];
//  NSLog(@"sounding note %@ on hexcoord %i, %i", dyadminoFace.name, faceHexCoord.x, faceHexCoord.y);
  
  [self recordFaceHexCoord:faceHexCoord];
  
//  SKAction *sound = plucked ?
//    [SKAction playSoundFileNamed:kSoundRing waitForCompletion:NO] : // plucked
//    [SKAction playSoundFileNamed:kSoundRing waitForCompletion:NO]; // resonated
  
//  NSURL *soundURL = [[NSBundle mainBundle] URLForResource:kSoundRing withExtension:@"wav"];
//  AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
//  [player setVolume:self.musicVolume];
  
//  SKAction *sound = [SKAction runBlock:^{
//    [player play];
//  }];

  NSString *noteActionKey = [self returnNoteActionKey];
//  NSLog(@"%@", noteActionKey);
  [self removeActionForKey:noteActionKey];
//  [self runAction:sound withKey:noteActionKey];
  [self incrementNoteCount];
}

-(void)recordFaceHexCoord:(HexCoord)faceHexCoord {
  
    // nothing yet touched
  if (_faceVector == kFaceVectorNone && _xBits == 0 && _yBits == 0) {
    NSLog(@"first touched");
    [self establishFirstFaceBitsWithHexCoord:faceHexCoord];

  } else {
      // make sure it's not the exact same face
    if (_xOrigin == faceHexCoord.x && _yOrigin == faceHexCoord.y) {
      return;
    }
      // get distances between origin and new face
    int xDistance = faceHexCoord.x - _xOrigin;
    int yDistance = faceHexCoord.y - _yOrigin;
    
    if (abs(xDistance) <= 3 && abs(yDistance) <= 3) {
      if (xDistance == 0 &&
          (_faceVector == kFaceVectorNone || _faceVector == kFaceVectorVertical)) {
        _faceVector = kFaceVectorVertical;
        _yBits |= 1 << (3 + yDistance);
        [self checkTriadOrSeventh];
      } else if (yDistance == 0 &&
          (_faceVector == kFaceVectorNone || _faceVector == kFaceVectorUpRight)) {
        _faceVector = kFaceVectorUpRight;
        _xBits |= 1 << (3 + xDistance);
        [self checkTriadOrSeventh];
      } else if (xDistance == yDistance * -1 &&
          (_faceVector == kFaceVectorNone || _faceVector == kFaceVectorUpLeft)) {
        _faceVector = kFaceVectorUpLeft;
        _yBits |= 1 << (3 + yDistance);
        _xBits |= 1 << (3 + xDistance);
        [self checkTriadOrSeventh];
      } else { // not on same axis
        [self establishFirstFaceBitsWithHexCoord:faceHexCoord];
      }
    } else { // too far
      [self establishFirstFaceBitsWithHexCoord:faceHexCoord];
    }
  }
}

-(void)establishFirstFaceBitsWithHexCoord:(HexCoord)faceHexCoord {
    // first bits is 00001000
  _faceVector = kFaceVectorNone;
  _xOrigin = faceHexCoord.x;
  _yOrigin = faceHexCoord.y;
  _xBits = 1 << 3;
  _yBits = 1 << 3;
}

  // probably won't be this complicated
-(void)checkTriadOrSeventh {
  NSLog(@"checking that it's a triad or seventh");
  if (_faceVector == kFaceVectorVertical && _xBits == 1 << 3 &&
      (_yBits == 15 || _yBits == 30 || _yBits == 60 || _yBits == 120 || _yBits == 14 || _yBits == 28 || _yBits == 56)) {
    NSLog(@"vertical");
  } else if (_faceVector == kFaceVectorUpRight && _yBits == 1 << 3 &&
             (_xBits == 15 || _xBits == 30 || _xBits == 60 || _xBits == 120 || _xBits == 14 || _xBits == 28 || _xBits == 56)) {
    NSLog(@"upright");
  } else if (_faceVector == kFaceVectorUpLeft &&
             ((_xBits == 15 && _yBits == 120) || (_xBits == 30 && _yBits == 60) ||
             (_xBits == 60 && _yBits == 60) || (_xBits == 120 && _yBits == 15) ||
             (_xBits == 14 && _yBits == 56) || (_xBits == 28 && _yBits == 28) || (_xBits == 56 && _yBits == 14))) {
    NSLog(@"upleft");
  }
}

-(NSString *)returnNoteActionKey {
  NSString *noteActionKey = [NSString stringWithFormat:@"note %i", _noteCount];
  return noteActionKey;
}

-(void)incrementNoteCount {
  _noteCount++;
  if (_noteCount > 3) {
    _noteCount = 0;
  }
}
 */

@end
