//
//  BPianoView.h
//  CoreAudio Starter Kit
//
//  Created by Ben Smiley-Andrews on 24/01/2013.
//  Copyright (c) 2013 Ben Smiley-Andrews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "bKeyType.h"
#import "BPianoKey.h"
#import "BPianoDelegate.h"

// The number of white notes in an octave
#define OCTAVE 7

// The number of notes in an octave
#define NOTES_IN_OCTAVE 12


@interface BPianoView : UIView<BPianoDelegate> {
    
    // Maintain lists of the black and white keys
    NSMutableArray * _whiteKeys;
    NSMutableArray * _blackKeys;
}

@property (nonatomic, readwrite, weak) id<BPianoDelegate> delegate;

// Create a new keyboard instance
// numberOfWhiteNotes - probably best to choose a whole number of octaves
// scale - The size of the keyboard
// startingNote - the MIDI note number for the bottom key of the keyboard
// the MIDI range goes from 0 - 127 where middle C is 60
-(id) initWithNumberOfNotes: (NSInteger) numberOfWhiteNotes withScale: (float) scale withStartingNote: (Byte) startingNote;

// Create a new keyboard as a standard 88 key keyboard
-(id) initAsStandard88NoteKeyboardWithScale: (float) scale withStartingNote: (Byte) startingNote;

// 
-(void) translateKeyboardInXDirectionBy: (float) distance;

@end
