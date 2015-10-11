//
//  BSMultipleDocumentsWindow.m
//  HoudahSpot
//
//  Created by Pierre Bernard on 04/08/14.
//  Copyright (c) 2012 Sasmito Adibowo. Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  Copyright (c) 2014-2015 Houdah Software s.à r.l. Creative Commons Attribution-ShareAlike 3.0 Unported License.
//
//  Based upon http://cutecoder.org/programming/window-multiple-documents/
//

#import "BSMultipleDocumentsWindow.h"

#import "BSMultipleDocumentsWindowController.h"


@implementation BSMultipleDocumentsWindow

- (IBAction)performClose:(id)sender
{
    [NSApp sendAction:@selector(closeTab:) to:[self windowController] from:self];
}

- (IBAction)performCloseWindow:(id)sender
{
    [NSApp sendAction:@selector(closeAllTabs:) to:[self windowController] from:self];
}

@end
