//
//  BPianoDelegate.h
//  CoreAudio Starter Kit
//
//  Created by Ben Smiley-Andrews on 28/01/2013.
//  Copyright (c) 2013 Ben Smiley-Andrews. All rights reserved.
//

@protocol BPianoDelegate <NSObject>

-(void) noteOn: (Byte) note;
-(void) noteOff: (Byte) note;

@end
