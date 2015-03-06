////
////  BPianoKey.m
////  CoreAudio Starter Kit
////
////  Created by Ben Smiley-Andrews on 24/01/2013.
////  Copyright (c) 2013 Ben Smiley-Andrews. All rights reserved.
////
//
//#import "BPianoKey.h"
//
//// Distance from left side of keyboard to left edge
//// of the first black key
//#define d1 68
//
//// The distance from the left side of the second black
//// key to the left side of the third black key minus
//// d1 * 2
//#define d2 62
//
//// The distance between the right side of the third black key
//// and the right side of the fourth white key
//#define d3 10
//
//// White key width and height in pixels
//#define white_key_width 112
//#define white_key_height 715
//
//@implementation BPianoKey
//
//@synthesize midiNote = _midiNote;
//@synthesize delegate;
//
//// This method sets up the key. It defines the key type and the two
//// images used - key pressed and key not pressed
//-(id) initWithKeyType: (bKeyType) keyType withMidiNote: (Byte) note {
//    
//    _type = keyType;
//    _midiNote = note;
//    
//    // If you want to use custom images you need to modify this section
//    // including the names of the relevant custom images. It's also necessary
//    // to modify the defines at the top with the relevant dimensions
//    [self setImageForType:keyType];
//    
//    // Set the UIImageView frame to the correct size
//    self.frame = CGRectMake(0, 0, _upImage.size.width, _upImage.size.height);
//    
//    return [self initWithImage:_upImage];
//}
//
//-(void) setImageForType: (bKeyType) keyType {
//    
//    // Check to see if our class has been initialized
//    BOOL initialized = _upImage != Nil;
//    
//    switch (keyType) {
//        case bBlackKey:
//            _upImage = [UIImage imageNamed:@"black_up"];
//            _downImage = [UIImage imageNamed:@"black_down"];
//            break;
//        case bLeftKey:
//            _upImage = [UIImage imageNamed:@"left_up"];
//            _downImage = [UIImage imageNamed:@"left_down"];
//            break;
//        case bCentreKey:
//            _upImage = [UIImage imageNamed:@"centre_up"];
//            _downImage = [UIImage imageNamed:@"centre_down"];
//            break;
//        case bRightKey:
//            _upImage = [UIImage imageNamed:@"right_up"];
//            _downImage = [UIImage imageNamed:@"right_down"];
//            break;
//        case bLeftCentreKey:
//            _upImage = [UIImage imageNamed:@"left_centre_up"];
//            _downImage = [UIImage imageNamed:@"left_centre_down"];
//            break;
//        case bRightCentreKey:
//            _upImage = [UIImage imageNamed:@"right_centre_up"];
//            _downImage = [UIImage imageNamed:@"right_centre_down"];
//            break;
//        case bTopKey:
//            _upImage = [UIImage imageNamed:@"top_key_up"];
//            _downImage = [UIImage imageNamed:@"top_key_down"];
//            break;
//        case bBottomKey:
//            _upImage = [UIImage imageNamed:@"bottom_key_up"];
//            _downImage = [UIImage imageNamed:@"bottom_key_down"];
//            break;
//    }
//    
//    if (initialized) {
//        [self setImage:_upImage];
//    }
//}
//
//-(void) setX: (float) x {
//    CGRect rect = self.frame;
//    rect.origin.x = x;
//    [self setFrame:rect];
//}
//
//-(void) setY: (float) y {
//    CGRect rect = self.frame;
//    rect.origin.y = y;
//    [self setFrame:rect];
//}
//
//-(void) isPressed: (BOOL) pressed {
//    // Check the note state has changed to avoid
//    // unnecessary work
//    if (pressed != self.isPressed) {
//        // Update the pressed status
//        self.isPressed = pressed;
//
//        // Inform the delegate
//        if (pressed)
//            [delegate noteOn:_midiNote];
//        else
//            [delegate noteOff:_midiNote];
//        
//        // Change the image to reflect the status
//        if (pressed) {
//            [self setImage:_downImage];
//        }
//        else {
//            [self setImage:_upImage];
//        }
//    }
//}
//
//+(float) getD1 {
//    return d1;
//}
//
//+(float) getD2 {
//    return d2;
//}
//
//+(float) getD3 {
//    return d3;
//}
//
//+(float) whiteKeyWidth {
//    return white_key_width;
//}
//
//+(float) whiteKeyHeight {
//    return white_key_height;
//}
//
//@end
