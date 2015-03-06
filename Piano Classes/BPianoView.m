////
////  BPianoView.m
////  CoreAudio Starter Kit
////
////  Created by Ben Smiley-Andrews on 24/01/2013.
////  Copyright (c) 2013 Ben Smiley-Andrews. All rights reserved.
////
//
//#import "BPianoView.h"
//
//@implementation BPianoView
//
//static bKeyType keyOrder [7] = {bLeftKey, bCentreKey, bRightKey, bLeftKey, bLeftCentreKey, bRightCentreKey, bRightKey};
//
//@synthesize delegate;
//
//-(id) initWithNumberOfNotes: (NSInteger) numberOfWhiteNotes withScale: (float) scale withStartingNote: (Byte) startingNote {
//    if ((self = [super init])) {
//        
//        // Make sure that user interaction is enabled for the view
//        self.userInteractionEnabled = YES;
//        self.multipleTouchEnabled = YES;
//
//        _whiteKeys = [NSMutableArray new];
//        _blackKeys = [NSMutableArray new];
//
//        // Setup some variables
//        bKeyType keyType;
//        BPianoKey * key;
//        float x;
//        
//        // Set the frame size for the view
//        self.frame = CGRectMake(0, 0, [BPianoKey whiteKeyWidth] * numberOfWhiteNotes * scale, [BPianoKey whiteKeyHeight] * scale);
//        
//        // Three distances which allow us to position the black keys
//        // more details available in the BPianoKey source file
//        float d1 = [BPianoKey getD1] * scale;
//        float d2 = [BPianoKey getD2] * scale;
//        float d3 = [BPianoKey getD3] * scale;
//        
//        // Get the extra notes which aren't part of a full octave
//        NSInteger remainingNotes = numberOfWhiteNotes - floor(numberOfWhiteNotes / OCTAVE) * OCTAVE;
//        NSInteger octaveSize;
//        NSInteger numberOfCompleteOctaves = floor(numberOfWhiteNotes / OCTAVE);
//        
//        // Loop over the number of octaves
//        for (NSInteger octave = 0; octave <= numberOfCompleteOctaves; octave++) {
//            
//            if (octave == numberOfCompleteOctaves) {
//                octaveSize = remainingNotes;
//            }
//            else {
//                octaveSize = OCTAVE;
//            }
//            
//            // For each octave loop over the white keys
//            for (NSInteger keyNum = 0; keyNum < octaveSize; keyNum++) {
//                                
//                // Get the white key type
//                keyType = [self getNoteTypeForNoteNumber:keyNum];
//                
//                // Create a new white key
//                key = [[BPianoKey alloc] initWithKeyType:keyType withMidiNote:[self getWhiteNoteMidiNumber:keyNum withOctave:octave withStartingNote:startingNote]];
//                key.delegate = self;
//                
//                // Set the key scale
//                [key setTransform:CGAffineTransformMakeScale(scale, scale)];
//                
//                // Set the white key position based on the octave and key number and scale
//                [key setX:key.frame.size.width * keyNum + octave * [BPianoKey whiteKeyWidth] * OCTAVE * scale];
//                [key setY:0];
//                
//                // Add the key to the view
//                [_whiteKeys addObject:key];
//                [self addSubview:key];
//            }
//
//            // Print the correct number of black notes
//            if (octaveSize <= 3) {
//                octaveSize = octaveSize + 1;
//            }
//            
//            // Add the black keys on top
//            for (NSInteger keyNum = 0; keyNum < octaveSize - 2; keyNum++) {
//                
//                // Create a new black key
//                key = [[BPianoKey alloc] initWithKeyType:bBlackKey withMidiNote:[self getBlackNoteMidiNumber:keyNum withOctave:octave withStartingNote:startingNote]];
//                key.delegate = self;
//                
//                // Apply the scale to the key's image
//                [key setTransform:CGAffineTransformMakeScale(scale, scale)];
//
//                // The x position depends on whether the key is in a
//                // pair or a triplet of black keys
//                
//                // The pair is calculated as follows:
//                // i.e. the second black note's co-ordinate is 3 * d1
//                x = d1 * (1 + 2*keyNum);
//                
//                // The triplet are then calculated as:
//                // d2 takes into account the big gap between the second
//                // and third black key
//                // d3 is a nudging factor because the three keys are slightly
//                // closer together
//                if (keyNum >= 2) {
//                    x += d2 - ((keyNum - 2) * d3);
//                }
//                
//                // Take into account x position for higher octaves
//                x += octave * [BPianoKey whiteKeyWidth] * OCTAVE * scale;
//                
//                [key setY:0];
//                [key setX:x];
//                
//                // Add the key to the view
//                [_blackKeys addObject:key];
//                [self addSubview:key];
//            }
//            
//        }
//    }
//    return self;
//}
//
//-(id) initAsStandard88NoteKeyboardWithScale: (float) scale withStartingNote: (Byte) startingNote {
//    BPianoView * pianoView = [self initWithNumberOfNotes:57 withScale:scale withStartingNote:(startingNote - 9)];
//    
//    // Remove the bottom 5 white notes
//    for (NSInteger i=0; i<5; i++) {
//        [self removeWhiteKey:[pianoView->_whiteKeys objectAtIndex:0]];
//    }
//    // Remove the bottom 4 black notes
//    for (NSInteger i=0; i<4; i++) {
//        [self removeBlackKey:[pianoView->_blackKeys objectAtIndex:0]];
//    }
//
//    // now replace the images for the top and bottom keys
//    [[pianoView->_whiteKeys objectAtIndex:0] setImageForType:bBottomKey];
//    [[pianoView->_whiteKeys lastObject] setImageForType:bTopKey];
//    
//    // Move all the keys down
//    [self translateKeyboardInXDirectionBy:-([BPianoKey whiteKeyWidth] * scale * 5)];
//
//    return pianoView;
//}
//
//-(void) removeWhiteKey: (BPianoKey *) key {
//    if([_whiteKeys containsObject:key]) {
//        [_whiteKeys removeObject:key];
//        [key removeFromSuperview];
//    }
//}
//
//-(void) removeBlackKey: (BPianoKey *) key {
//    if([_blackKeys containsObject:key]) {
//        [_blackKeys removeObject:key];
//        [key removeFromSuperview];
//    }
//}
//
//-(void) translateKeyboardInXDirectionBy: (float) distance {
//    for (BPianoKey * key in self->_whiteKeys) {
//        [key setX:(key.frame.origin.x + distance)];
//    }
//    
//    for (BPianoKey * key in self->_blackKeys) {
//        [key setX:(key.frame.origin.x + distance)];
//    }
//}
//
//// Working out midi numbers is a bit tricky - you really need to draw it out
//// with some paper
//-(Byte) getWhiteNoteMidiNumber: (NSInteger) whiteNoteNumber withOctave: (NSInteger) octave withStartingNote: (Byte) startingNote {
//    if (whiteNoteNumber <= 2) {
//        return startingNote + octave * NOTES_IN_OCTAVE + 2 * whiteNoteNumber;
//    }
//    else {
//        return startingNote + octave * NOTES_IN_OCTAVE + 2 * whiteNoteNumber - 1;
//    }
//}
//
//-(Byte) getBlackNoteMidiNumber: (NSInteger) whiteNoteNumber withOctave: (NSInteger) octave withStartingNote: (Byte) startingNote {
//    if (whiteNoteNumber <= 1) {
//        return startingNote + octave * NOTES_IN_OCTAVE + 2 * whiteNoteNumber + 1;
//    }
//    else {
//        return startingNote + octave * NOTES_IN_OCTAVE + 2 * whiteNoteNumber + 2;
//    }
//}
//
//// Delegate methods - pass the midi commands to the delegate
//-(void) noteOn:(Byte)note {
//    [delegate noteOn:note];
//}
//
//-(void) noteOff:(Byte)note {
//    [delegate noteOff:note];
//}
//
//// Get the white note type for it's position in the octave
//-(bKeyType) getNoteTypeForNoteNumber: (NSInteger) noteNumber {
//    return keyOrder[noteNumber % OCTAVE];
//}
//
////
//-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self updateTouches:touches withEvent:event];
//}
// 
//-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self updateTouches:touches withEvent:event];
//}
//
//-(void) updateTouches: (NSSet *)touches withEvent:(UIEvent *)event {
//    
//    NSMutableArray * whiteKeyTouches = [NSMutableArray arrayWithArray:[[event allTouches] allObjects]];
//    CGPoint point;
//    BOOL inside, tempIsPressed;
//    
//    // Loop over all the black keys
//    for (BPianoKey * key in _blackKeys) {
//        
//        tempIsPressed = NO;
//        
//        for (UITouch * touch in [event allTouches]) {
//
//            point = [touch locationInView:key];
//            inside = [key pointInside:point withEvent:event];
//            
//            if (inside) {
//                tempIsPressed = YES;
//                [whiteKeyTouches removeObject:touch];
//            }
//        }
//        
//        [key isPressed:tempIsPressed];
//        
//    }
//    for (BPianoKey * key in _whiteKeys) {
//
//        tempIsPressed = NO;
//
//        for (UITouch * touch in whiteKeyTouches) {
//        
//            point = [touch locationInView:key];
//            inside = [key pointInside:point withEvent:event];
//            
//            if (inside) {
//                tempIsPressed = YES;
//            }
//        }
//        [key isPressed:tempIsPressed];
//    }
//    
//
//
//}
//
//-(void) endKeyTouches: (NSMutableArray *) keys withTouches: (NSSet *) touches withEvent: (UIEvent *) event {
//    BOOL inside, lastInside;
//    NSInteger count, countLast;
//    
//    for (BPianoKey * key in keys) {
//        for (UITouch * touch in [touches allObjects]) {
//            
//            inside = [self touchInside:touch withEvent:event withView:key];
//            lastInside = [self lastTouchInside:touch withEvent:event withView:key];
//            
//            if (inside || lastInside) {
//                
//                count = 0;
//                countLast = 0;
//                // Check that another touch isn't holding this key down
//                for (UITouch * otherTouch in [event allTouches]) {
//                    if ([self touchInside:otherTouch withEvent:event withView:key])
//                        count ++;
//                    if ([self lastTouchInside:otherTouch withEvent:event withView:key])
//                        countLast ++;
//                }
//                
//                if (count == 1 || countLast == 1) {
//                    [key isPressed:NO];
//                }
//            }
//        }
//    }
//}
//
//
//-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//     
//     [self endKeyTouches:_blackKeys withTouches:touches withEvent:event];
//     [self endKeyTouches:_whiteKeys withTouches:touches withEvent:event];
//  }
//
//-(BOOL) touchInside: (UITouch *) touch withEvent: (UIEvent *) event withView: (UIView *) view {
//    return [view pointInside:[touch locationInView:view] withEvent:event];
//}
//
//-(BOOL) lastTouchInside: (UITouch *) touch withEvent: (UIEvent *) event withView: (UIView *) view {
//    return [view pointInside:[touch previousLocationInView:view] withEvent:event];
//}
//
//
//@end
