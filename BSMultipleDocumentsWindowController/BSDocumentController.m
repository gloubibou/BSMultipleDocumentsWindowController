//
//  BSDocumentController.m
//  HoudahSpot
//
//  Created by Pierre Bernard on 12/05/14.
//  Copyright (c) 2012 Sasmito Adibowo. Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  Copyright (c) 2014-2015 Houdah Software s.à r.l. Creative Commons Attribution-ShareAlike 3.0 Unported License.
//
//  Based upon http://cutecoder.org/programming/window-multiple-documents/
//

#import "BSDocumentController.h"

#import "BSMultipleDocumentsWindowController.h"


@interface BSDocumentController ()

@end


@implementation BSDocumentController

#pragma mark -
#pragma mark Action methods

- (IBAction)newDocumentTab:(id)sender
{
	BSMultipleDocumentsWindowController *multipleDocumentsWindowController	= nil;;
	NSWindowController					*windowController					= [[NSApp mainWindow] windowController];

	if ([windowController isKindOfClass:[BSMultipleDocumentsWindowController class]]) {
		multipleDocumentsWindowController = (id)windowController;
	}

	BOOL								makeWindow							= (multipleDocumentsWindowController == nil);

	NSError								*error								= nil;
	NSDocument							*document							= [self openUntitledDocumentAndDisplay:makeWindow error:&error];

	if (document == nil) {
		if (error != nil) {
			[self presentError:error];
		}

		return;
	}

	if ((! makeWindow) && ([document conformsToProtocol:@protocol(BSMultipleDocumentsDocument)])) {
		[multipleDocumentsWindowController addDocument:(NSDocument < BSMultipleDocumentsDocument > *)document];
	}
}

#pragma mark -
#pragma mark Instance methods

- (void)closeAllDocumentsWithDelegate:(id)delegate
				  didCloseAllSelector:(SEL)didCloseAllSelector
						  contextInfo:(void *)contextInfo
{
	NSArray *documents = [self documents];

	if ([documents count] > 0) {
		NSDocument	*lastDocument = [documents lastObject];

		void		(^didCloseCallback)(BOOL) = ^void (BOOL didClose) {
			if (didClose) {
				[self closeAllDocumentsWithDelegate:delegate didCloseAllSelector:didCloseAllSelector contextInfo:contextInfo];
			}
			else {
				[BSDocumentController documentController:self
											 didCloseAll:NO
												delegate:delegate
									 didCloseAllSelector:didCloseAllSelector
											 contextInfo:contextInfo];
			}
		};

		[lastDocument canCloseDocumentWithDelegate:self
							   shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
									   contextInfo:(void *)CFBridgingRetain([didCloseCallback copy])];
	}
	else {
		[BSDocumentController documentController:self
									 didCloseAll:YES
										delegate:delegate
							 didCloseAllSelector:didCloseAllSelector
									 contextInfo:contextInfo];
	}
}

- (void)document:(NSDocument<BSMultipleDocumentsDocument> *)document
	 shouldClose:(BOOL)shouldClose
	 contextInfo:(void *)contextInfo
{
	if (shouldClose) {
		// work on a copy of the window controllers array so that the doc can mutate its own array.
		NSArray *windowControllers = [document.windowControllers copy];

		for (BSMultipleDocumentsWindowController *windowController in windowControllers) {
			if ([windowController isKindOfClass:[BSMultipleDocumentsWindowController class]]) {
				[windowController removeDocument : document];
			}
		}

		[document close];
	}

	void (^didClose)(BOOL) = CFBridgingRelease(contextInfo);

	didClose(shouldClose);
}

#pragma mark -
#pragma mark Class methods

+ (void)documentController:(BSDocumentController *)documentController
			   didCloseAll:(BOOL)didCloseAll
				  delegate:(id)delegate
	   didCloseAllSelector:(SEL)didCloseAllSelector
			   contextInfo:(void *)contextInfo
{
	if ((delegate != nil) && (didCloseAllSelector != NULL)) {
		typedef void (*MethodType)(id, SEL, BSDocumentController *, BOOL, void *);

		MethodType methodToCall = (MethodType)[delegate methodForSelector : didCloseAllSelector];

		methodToCall(delegate, didCloseAllSelector, documentController, didCloseAll, contextInfo);
	}
}

@end
