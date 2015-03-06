////
////  BPianoKey.h
////  CoreAudio Starter Kit
////
////  Created by Ben Smiley-Andrews on 24/01/2013.
////  Copyright (c) 2013 Ben Smiley-Andrews. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//#import "bKeyType.h"
//#import "BPianoDelegate.h"
//
//@interface BPianoKey : UIImageView {
//    
//    // Image used when key is pressed
//    UIImage * _upImage;
//    
//    // Image used when key is not pressed
//    UIImage * _downImage;
//    
//    // The key type - i.e. black/white also which white key
//    bKeyType _type;
//    
//    // The midi note which will be played by the key
//    Byte _midiNote;
//    
//}
//
//// A delegate which will recieve note-on and note-off commands
//@property (nonatomic, readwrite, weak) id<BPianoDelegate> delegate;
//
//// The midi note
//@property (nonatomic, readwrite) Byte midiNote;
//
//// Whether the key is currently pressed or not
//@property (nonatomic, readwrite) BOOL isPressed;
//
//
//-(id) initWithKeyType: (bKeyType) keyType withMidiNote: (Byte) note;
//
//// Set the keys x position
//-(void) setX: (float) x;
//
//// Set the keys y position
//-(void) setY: (float) y;
//
//// Defines distances for positioning the black keys
//// more details are included in the .m file
//+(float) getD1;
//+(float) getD2;
//+(float) getD3;
//
//// White key width and height used for alignment
//+(float) whiteKeyWidth;
//+(float) whiteKeyHeight;
//
//// Set the up and down images for the key
//-(void) setImageForType: (bKeyType) keyType;
//
//// A function which presses/unpresses the key
//-(void) isPressed: (BOOL) pressed;
//
//@end
