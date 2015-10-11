//
//  AppDelegate.m
//  BSMultipleDocumentsWindowController
//
//  Created by Pierre Bernard on 10/10/15.
//  Copyright (c) 2015 Houdah Software s.à r.l. All rights reserved.
//

#import "AppDelegate.h"

#import "BSDocumentController.h"
#import "BSMultipleDocumentsWindowController.h"
#import "MultipleDocumentsWindowController.h"


@interface AppDelegate ()

@property (nonatomic, strong, readonly) NSMutableArray *documentsWindowControllers;

@end


@implementation AppDelegate

- (instancetype)init
{
	self = [super init];

	if (self != nil) {
		_documentsWindowControllers = [NSMutableArray arrayWithCapacity:3];
	}

	return self;
}

- (void)dealloc
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter removeObserver:self];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter addObserver:self
						   selector:@selector(documentNeedsWindowNotification:)
							   name:BSDocumentNeedsWindowNotificationName
							 object:nil];

	[notificationCenter addObserver:self
						   selector:@selector(documentsWindowControllerWillClose:)
							   name:BSMultipleDocumentsWindowControllerWillCloseNotificationName
							 object:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[self openUntitledDocumentIfNeeded];
}

- (MultipleDocumentsWindowController *)newDocumentsWindowController
{
	MultipleDocumentsWindowController	*documentsWindowController	= [[MultipleDocumentsWindowController alloc] init];
	NSMutableArray						*documentsWindowControllers = self.documentsWindowControllers;

	[documentsWindowControllers addObject:documentsWindowController];

	return documentsWindowController;
}

- (void)documentNeedsWindowNotification:(NSNotification *)notification
{
	NSDocument <BSMultipleDocumentsDocument>	*document					= notification.object;
	MultipleDocumentsWindowController			*documentsWindowController	= [self newDocumentsWindowController];
	NSWindow									*documentsWindow			= documentsWindowController.window;

	[documentsWindowController addDocument:document];
	[documentsWindow makeKeyAndOrderFront:self];
}

- (void)openUntitledDocumentIfNeeded
{
	BSDocumentController *documentController = [BSDocumentController sharedDocumentController];

	if ([[documentController documents] count] == 0) {
		NSError		*error		= nil;
		NSDocument	*document	= (id)[documentController openUntitledDocumentAndDisplay:YES error:&error];

		if ((document == nil) && (error != nil)) {
			[NSApp presentError:error];
		}
	}
}

- (void)documentsWindowControllerWillClose:(NSNotification *)notification
{
	MultipleDocumentsWindowController	*documentsWindowController	= notification.object;

	if (documentsWindowController == nil) {
		return;
	}

	NSMutableArray						*documentsWindowControllers = self.documentsWindowControllers;

	[documentsWindowControllers removeObject:documentsWindowController];
}

@end
