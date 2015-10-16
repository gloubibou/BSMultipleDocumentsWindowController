//
//  BSMultipleDocumentsWindowController.m
//  HoudahSpot
//
//  Created by Pierre Bernard on 12/05/14.
//  Copyright (c) 2012 Sasmito Adibowo. Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  Copyright (c) 2014-2015 Houdah Software s.à r.l. Creative Commons Attribution-ShareAlike 3.0 Unported License.
//
//  Based upon http://cutecoder.org/programming/window-multiple-documents/
//

#import "BSMultipleDocumentsWindowController.h"


@interface BSMultipleDocumentsWindowController ()

@property (nonatomic, strong, readonly) NSMutableSet *documents;

@property (nonatomic, copy) NSArray *documentViewControllers;
@property (nonatomic, strong) NSViewController<BSDocumentViewController> *selectedDocumentViewController;

@end


NSString *const BSDocumentNeedsWindowNotificationName = @"BSDocumentNeedsWindowNotification";

NSString *const BSMultipleDocumentsSelectedDocumentChangedNotificationName = @"BSMultipleDocumentsSelectedDocumentChangedNotification";
NSString *const BSMultipleDocumentsWindowControllerWillCloseNotificationName = @"BSMultipleDocumentsWindowControllerWillCloseNotification";


const struct BSMultipleDocumentsWindowControllerAttributes BSMultipleDocumentsWindowControllerAttributes = {
    .documentViewControllers = @"documentViewControllers", .selectedDocumentViewController = @"selectedDocumentViewController",
};


@implementation BSMultipleDocumentsWindowController

#pragma mark -
#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];

    if (self) {
        _documents = [NSMutableSet set];
        _documentViewControllers = [NSArray array];
        _selectedDocumentViewController = nil;
    }

    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];

    if (self) {
        _documents = [NSMutableSet set];
        _documentViewControllers = [NSArray array];
        _selectedDocumentViewController = nil;
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSWindow *window = [self window];
    NSButton *closeButton = [window standardWindowButton:NSWindowCloseButton];

    [closeButton setTarget:self];
    [closeButton setAction:@selector(closeAllTabs:)];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self
                           selector:@selector(multipleDocumentsWindowWillCloseNotification:)
                               name:NSWindowWillCloseNotification
                             object:window];
}

#pragma mark -
#pragma mark Finalization

- (void)dealloc
{
    NSWindow *window = [self window];
    NSButton *closeButton = [window standardWindowButton:NSWindowCloseButton];

    [closeButton setTarget:nil];
}

#pragma mark -
#pragma mark Accessors

- (void)setSelectedDocumentViewController:(NSViewController<BSDocumentViewController> *)selectedDocumentViewController
{
	[_selectedDocumentViewController.document removeWindowController:self];

	_selectedDocumentViewController = selectedDocumentViewController;

	[selectedDocumentViewController.document addWindowController:self];

    [self synchronizeTitleWithDocumentViewController:selectedDocumentViewController];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter postNotificationName:BSMultipleDocumentsSelectedDocumentChangedNotificationName object:self];
}

#pragma mark -
#pragma mark Instance methods

- (void)addDocument:(NSDocument<BSMultipleDocumentsDocument> *)document
{
	[self insertDocument:document viewController:nil atIndex:[self.documentViewControllers count]];
}

- (void)removeDocument:(NSDocument<BSMultipleDocumentsDocument> *)document
{
	NSArray *documentViewControllers = self.documentViewControllers;
	NSUInteger count = [documentViewControllers count];

	for (NSUInteger index = 0; index < count; index++) {
		NSViewController<BSDocumentViewController> *documentViewController = [documentViewControllers objectAtIndex:index];

		if (documentViewController.document == document) {
			[self removeDocumentAtIndex:index];

			documentViewController.document = nil;
		}
	}
}

- (void)insertDocument:(NSDocument<BSMultipleDocumentsDocument> *)document
		viewController:(NSViewController<BSDocumentViewController> *)documentViewController
			   atIndex:(NSUInteger)index;
{
    NSMutableSet *documents = self.documents;

    if ([documents containsObject:document]) {
        return;
    }

    if (documentViewController == nil) {
        documentViewController = [document makeViewController];

        NSAssert(documentViewController != nil, @"Must return a fresh view controller from -[NSDocument makeViewController]");
    }

    documentViewController.document = document;
    documentViewController.multipleDocumentsWindowController = self;

    NSWindow *window = [self window];

    [document setWindow:window];

    [documents addObject:document];

    NSMutableArray *documentViewControllers = [self.documentViewControllers mutableCopy];

    [documentViewControllers insertObject:documentViewController atIndex:index];

    self.documentViewControllers = documentViewControllers;
    self.selectedDocumentViewController = documentViewController;
}

- (void)selectDocumentAtIndex:(NSInteger)index
{
    NSArray *documentViewControllers = self.documentViewControllers;

	if ((index > -1) && (index < [documentViewControllers count])) {
        NSViewController<BSDocumentViewController> *documentViewController = [documentViewControllers objectAtIndex:index];

        self.selectedDocumentViewController = documentViewController;
    }
    else {
        self.selectedDocumentViewController = nil;
    }
}

- (void)closeDocumentAtIndex:(NSUInteger)index
{
	NSArray *documentViewControllers = self.documentViewControllers;
	NSViewController<BSDocumentViewController> *documentViewController = [documentViewControllers objectAtIndex:index];
	NSDocument *document = documentViewController.document;

	[document canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(document:shouldClose:contextInfo:) contextInfo:NULL];
}

- (void)removeDocumentAtIndex:(NSUInteger)index
{
    NSMutableArray *documentViewControllers = [self.documentViewControllers mutableCopy];
    NSViewController<BSDocumentViewController> *documentViewController = [documentViewControllers objectAtIndex:index];
    NSDocument<BSMultipleDocumentsDocument> *document = documentViewController.document;

    [document removeWindowController:self];

    NSMutableSet *documents = self.documents;

    [documents removeObject:document];

    [documentViewControllers removeObjectAtIndex:index];

    self.documentViewControllers = documentViewControllers;

	documentViewController.multipleDocumentsWindowController = nil;

    if ([documentViewControllers count] == 0) {
        [super close];
    }
	else {
		NSInteger previousIndex = MAX(0, (NSInteger)index - 1);
		NSViewController<BSDocumentViewController> *previousDocumentViewController = [documentViewControllers objectAtIndex:previousIndex];

		[self setSelectedDocumentViewController:previousDocumentViewController];
	}
}

- (void)moveDocumentAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    NSMutableArray *documentViewControllers = [self.documentViewControllers mutableCopy];
    NSViewController<BSDocumentViewController> *documentViewController = [documentViewControllers objectAtIndex:fromIndex];

    [documentViewControllers removeObjectAtIndex:fromIndex];
    [documentViewControllers insertObject:documentViewController atIndex:toIndex];

    self.documentViewControllers = documentViewControllers;
}

- (void)synchronizeTitleWithDocumentViewController:(NSViewController<BSDocumentViewController> *)documentViewController
{
    NSDocument *document = documentViewController.document;

    if (document == nil) {
        return;
    }

    NSString *displayName = [document displayName];
    NSString *title = [documentViewController titleForDocumentDisplayName:displayName];

    documentViewController.title = title;

	if (documentViewController == self.selectedDocumentViewController) {
        [self synchronizeWindowTitleWithDocumentName];
    }
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
    NSViewController<BSDocumentViewController> *selectedDocumentViewController = self.selectedDocumentViewController;
    NSString *title = [selectedDocumentViewController titleForDocumentDisplayName:displayName];

    return title;
}

- (void)close
{
	// Called by -[NSDocument close]
	NSDocument<BSMultipleDocumentsDocument> *document = self.selectedDocumentViewController.document;

	[self removeDocument:document];
}

- (void)multipleDocumentsWindowWillCloseNotification:(NSNotification *)notification
{
    NSWindow *window = self.window;

    if (notification.object != window) {
        return;
    }

	[window endEditingFor:nil];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter removeObserver:self name:NSWindowWillCloseNotification object:window];

    for (NSViewController<BSDocumentViewController> *documentViewController in self.documentViewControllers) {
        NSDocument *document = documentViewController.document;

		documentViewController.document = nil;
		documentViewController.multipleDocumentsWindowController = nil;

        [document removeWindowController:self];
        [document close];
    }

    self.documentViewControllers = [NSArray array];

    [self.documents removeAllObjects];

    [notificationCenter postNotificationName:BSMultipleDocumentsWindowControllerWillCloseNotificationName object:self];
}

- (id)supplementalTargetForAction:(SEL)action sender:(id)sender
{
    id target = [super supplementalTargetForAction:action sender:sender];

    if (target != nil) {
        return target;
    }

    NSViewController<BSDocumentViewController> *selectedDocumentViewController = self.selectedDocumentViewController;

    if (selectedDocumentViewController != nil) {
        target = [NSApp targetForAction:action to:selectedDocumentViewController from:sender];

        if (![target respondsToSelector:action]) {
            target = [target supplementalTargetForAction:action sender:sender];
        }

        if ([target respondsToSelector:action]) {
            return target;
        }
    }

    return nil;
}

#pragma mark -
#pragma mark Action methods

- (IBAction)closeTab:(id)sender
{
	NSDocument *document = self.selectedDocumentViewController.document;

	[document canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(document:shouldClose:contextInfo:) contextInfo:NULL];
}

- (IBAction)closeAllTabs:(id)sender
{
    SEL didCloseAllSelector = @selector(windowController:didCloseAll:contextInfo:);

    [self closeAllDocumentsWithDelegate:self didCloseAllSelector:didCloseAllSelector contextInfo:NULL];
}

- (void)closeAllDocumentsWithDelegate:(id)delegate didCloseAllSelector:(SEL)didCloseAllSelector contextInfo:(void *)contextInfo
{
    NSArray *documentViewControllers = self.documentViewControllers;

    if ([documentViewControllers count] > 0) {
        NSViewController<BSDocumentViewController> *documentViewController = [documentViewControllers lastObject];
        NSDocument *document = documentViewController.document;

        void (^didCloseCallback)(BOOL) = ^void(BOOL didClose) {
            if (didClose) {
                [self closeAllDocumentsWithDelegate:delegate didCloseAllSelector:didCloseAllSelector contextInfo:contextInfo];
            }
            else {
                [BSMultipleDocumentsWindowController windowController:self
                                                          didCloseAll:NO
                                                             delegate:delegate
                                                  didCloseAllSelector:didCloseAllSelector
                                                          contextInfo:contextInfo];
            }
        };

        [document canCloseDocumentWithDelegate:self
                           shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
                                   contextInfo:(void *)CFBridgingRetain([didCloseCallback copy])];
    }
    else {
        [BSMultipleDocumentsWindowController windowController:self
                                                  didCloseAll:YES
                                                     delegate:delegate
                                          didCloseAllSelector:didCloseAllSelector
                                                  contextInfo:contextInfo];
    }
}

- (void)document:(NSDocument<BSMultipleDocumentsDocument> *)document shouldClose:(BOOL)shouldClose contextInfo:(void *)contextInfo
{
    if (shouldClose) {
		[self removeDocument:document];

        [document close];
    }

    if (contextInfo != NULL) {
        void (^didClose)(BOOL) = CFBridgingRelease(contextInfo);

        didClose(shouldClose);
    }
}

- (void)windowController:(BSMultipleDocumentsWindowController *)windowController didCloseAll:(BOOL)didCloseAll contextInfo:(void *)contextInfo
{
    if (didCloseAll) {
        //	[self close];
    }
}

- (IBAction)selectNextTab:(id)sender
{
	NSArray *documentViewControllers = self.documentViewControllers;
	NSUInteger documentCount = [documentViewControllers count];
	NSViewController<BSDocumentViewController> *selectedDocumentViewController = self.selectedDocumentViewController;
	NSUInteger selectedDocumentIndex = [documentViewControllers indexOfObject:selectedDocumentViewController];

	if (selectedDocumentIndex == NSNotFound) {
		selectedDocumentIndex = 0;
	}

	selectedDocumentIndex = (selectedDocumentIndex + 1) % documentCount;

	[self selectDocumentAtIndex:selectedDocumentIndex];
}

- (IBAction)selectPreviousTab:(id)sender;
{
	NSArray *documentViewControllers = self.documentViewControllers;
	NSUInteger documentCount = [documentViewControllers count];
	NSViewController<BSDocumentViewController> *selectedDocumentViewController = self.selectedDocumentViewController;
	NSUInteger selectedDocumentIndex = [documentViewControllers indexOfObject:selectedDocumentViewController];

	if (selectedDocumentIndex == NSNotFound) {
		selectedDocumentIndex = 0;
	}

	selectedDocumentIndex = (selectedDocumentIndex + documentCount - 1) % documentCount;

	[self selectDocumentAtIndex:selectedDocumentIndex];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = menuItem.action;

	if (action == @selector(selectNextTab:) ||
		action == @selector(selectPreviousTab:)) {
		NSArray *documentViewControllers = self.documentViewControllers;
		NSUInteger documentCount = [documentViewControllers count];

		return (documentCount > 1);
	}

	return YES;
}

#pragma mark -
#pragma mark Class methods

+ (void)windowController:(BSMultipleDocumentsWindowController *)windowController
             didCloseAll:(BOOL)didCloseAll
                delegate:(id)delegate
     didCloseAllSelector:(SEL)didCloseAllSelector
             contextInfo:(void *)contextInfo
{
    if ((delegate != nil) && (didCloseAllSelector != NULL)) {
        typedef void (*MethodType)(id, SEL, BSMultipleDocumentsWindowController *, BOOL, void *);

        MethodType methodToCall = (MethodType)[delegate methodForSelector : didCloseAllSelector];

        methodToCall(delegate, didCloseAllSelector, windowController, didCloseAll, contextInfo);
    }
}

@end
