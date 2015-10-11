//
//  BSPersistentDocument.m
//  HoudahSpot
//
//  Created by Pierre Bernard on 26/06/15.
//  Copyright (c) 2012 Sasmito Adibowo. Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  Copyright (c) 2014-2015 Houdah Software s.à r.l. Creative Commons Attribution-ShareAlike 3.0 Unported License.
//
//  Based upon http://cutecoder.org/programming/window-multiple-documents/
//

#import "BSPersistentDocument.h"

#import "BSMultipleDocumentsWindowController.h"


@interface BSPersistentDocument ()

@end


@implementation BSPersistentDocument

// Handle closeAll: windows (cmd-opt-w)
- (void)shouldCloseWindowController:(BSMultipleDocumentsWindowController *)windowController
						   delegate:(id)delegate
				shouldCloseSelector:(SEL)shouldCloseSelector
						contextInfo:(void *)contextInfo
{
	[windowController closeAllDocumentsWithDelegate:delegate
								didCloseAllSelector:shouldCloseSelector
										contextInfo:contextInfo];
}

@end
