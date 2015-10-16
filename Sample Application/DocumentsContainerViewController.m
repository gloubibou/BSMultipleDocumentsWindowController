//
//  DocumentsContainerViewController.m
//  BSMultipleDocumentsWindowController
//
//  Created by Pierre Bernard on 10/10/15.
//  Copyright (c) 2015 Houdah Software s.à r.l. All rights reserved.
//

#import "DocumentsContainerViewController.h"


@interface DocumentsContainerViewController ()

@property (nonatomic, weak) IBOutlet NSTabView					*tabView;

@property (nonatomic, assign) BOOL								observingDocumentsWindowController;
@property (nonatomic, strong) MultipleDocumentsWindowController *documentsWindowController;

@end


static void														*kDocumentViewControllersContext		= &kDocumentViewControllersContext;
static void														*kSelectedDocumentViewControllerContext = &kSelectedDocumentViewControllerContext;


@implementation DocumentsContainerViewController

- (instancetype)initWithDocumentsWindowController:(MultipleDocumentsWindowController *)documentsWindowController;
{
	self = [super initWithNibName:[[self class] nibName] bundle:nil];

	if (self != nil) {
		_documentsWindowController = documentsWindowController;

		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

		[notificationCenter addObserver:self
							   selector:@selector(documentsWindowWillClose:)
								   name:NSWindowWillCloseNotification
								 object:documentsWindowController.window];
	}

	return self;
}

+ (NSString *)nibName
{
	return NSStringFromClass([self class]);
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self startObservingDocumentsWindowController];
}

#pragma mark -
#pragma mark Finalization

- (void)documentsWindowWillClose:(NSNotification *)notification
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter removeObserver:self name:NSWindowWillCloseNotification object:notification.object];

	[self stopObservingDocumentsWindowController];

	self.documentsWindowController	= nil;
	self.tabView.delegate			= nil;
}

- (void)dealloc
{
	[self stopObservingDocumentsWindowController];

	self.tabView.delegate = nil;
}

#pragma mark -
#pragma mark Instance methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == kDocumentViewControllersContext) {
		[self updateTabView];
	}
	else if (context == kSelectedDocumentViewControllerContext) {
		[self updateSelectedTabIndex];
	}
}

- (void)startObservingDocumentsWindowController
{
	if (self.observingDocumentsWindowController) {
		return;
	}

	self.observingDocumentsWindowController = YES;

	MultipleDocumentsWindowController *documentsWindowController = self.documentsWindowController;

	[documentsWindowController addObserver:self
								forKeyPath:BSMultipleDocumentsWindowControllerAttributes.documentViewControllers
								   options:NSKeyValueObservingOptionInitial
								   context:kDocumentViewControllersContext];
	[documentsWindowController addObserver:self
								forKeyPath:BSMultipleDocumentsWindowControllerAttributes.selectedDocumentViewController
								   options:NSKeyValueObservingOptionInitial
								   context:kSelectedDocumentViewControllerContext];
}

- (void)stopObservingDocumentsWindowController
{
	if (!self.observingDocumentsWindowController) {
		return;
	}

	self.observingDocumentsWindowController = NO;

	MultipleDocumentsWindowController *documentsWindowController = self.documentsWindowController;

	[documentsWindowController removeObserver:self
								   forKeyPath:BSMultipleDocumentsWindowControllerAttributes.documentViewControllers
									  context:kDocumentViewControllersContext];
	[documentsWindowController removeObserver:self
								   forKeyPath:BSMultipleDocumentsWindowControllerAttributes.selectedDocumentViewController
									  context:kSelectedDocumentViewControllerContext];
}

- (void)updateTabView
{
	NSTabView							*tabView					= self.tabView;

	MultipleDocumentsWindowController	*documentsWindowController	= self.documentsWindowController;
	NSArray								*documentViewControllers	= documentsWindowController.documentViewControllers;
	NSInteger							vCount						= [documentViewControllers count];

	NSInteger							index						= 0;

	for (NSInteger v = 0; v < vCount; v++) {
		NSViewController <BSDocumentViewController> *documentViewController = [documentViewControllers objectAtIndex:v];
		NSInteger									tabViewItemIndex		= NSNotFound;

		if (v < [tabView.tabViewItems count]) {
			NSTabViewItem *tentativeTabViewItem = [tabView tabViewItemAtIndex:v];

			if (tentativeTabViewItem.viewController == documentViewController) {
				tabViewItemIndex = v;
			}
		}

		if (tabViewItemIndex == NSNotFound) {
			tabViewItemIndex = [tabView indexOfTabViewItemWithIdentifier:documentViewController];
		}

		NSTabViewItem								*tabViewItem			= nil;

		if (tabViewItemIndex != NSNotFound) {
			tabViewItem = [tabView tabViewItemAtIndex:tabViewItemIndex];
		}
		else {
			tabViewItem				= [NSTabViewItem tabViewItemWithViewController:documentViewController];
			tabViewItem.identifier	= documentViewController;

			//            [tabViewItem bind:@"label" toObject:documentViewController withKeyPath:@"title" options:nil];

			[self addChildViewController:documentViewController];
		}

		if (tabViewItemIndex != index) {
			if ((tabViewItemIndex != NSNotFound) && (tabViewItemIndex > index)) {
				[tabView removeTabViewItem:tabViewItem];
			}

			[tabView insertTabViewItem:tabViewItem atIndex:index];
		}

		NSString *title = documentViewController.title;

		if (title == nil) {
			title = documentViewController.document.displayName;
		}

		if (title != nil) {
			tabViewItem.label = title;
		}

		index++;
	}

	while ([tabView.tabViewItems count] > vCount) {
		NSTabViewItem		*tabViewItem			= [tabView tabViewItemAtIndex:vCount];
		NSViewController	*documentViewController = tabViewItem.viewController;

		[documentViewController removeFromParentViewController];

		//        [tabViewItem unbind:@"label"];
		[tabView removeTabViewItem:tabViewItem];
	}
}

- (void)updateSelectedTabIndex
{
	MultipleDocumentsWindowController			*documentsWindowController		= self.documentsWindowController;
	NSArray										*documentViewControllers		= documentsWindowController.documentViewControllers;

	NSViewController <BSDocumentViewController> *selectedDocumentViewController = documentsWindowController.selectedDocumentViewController;

	NSInteger									index							= [documentViewControllers indexOfObject:selectedDocumentViewController];
	NSTabView									*tabView						= self.tabView;

	if (index != NSNotFound) {
		if (index < [tabView numberOfTabViewItems]) {
			[tabView selectTabViewItemAtIndex:index];
		}
		else {
			NSLog(@"Error %@", tabView);
		}
	}
}

- (id)supplementalTargetForAction:(SEL)action sender:(id)sender
{
	id					target					= [super supplementalTargetForAction:action sender:sender];

	if (target != nil) {
		return target;
	}

	NSTabViewItem		*selectedTabViewItem	= self.tabView.selectedTabViewItem;
	NSViewController	*childViewController	= selectedTabViewItem.viewController;

	if (childViewController != nil) {
		target = [NSApp targetForAction:action to:childViewController from:sender];

		if (![target respondsToSelector:action]) {
			target = [target supplementalTargetForAction:action sender:sender];
		}

		if ([target respondsToSelector:action]) {
			return target;
		}
	}

	return nil;
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSInteger index = [tabView indexOfTabViewItem:tabViewItem];

	[self.documentsWindowController selectDocumentAtIndex:index];
}

- (void)tabView:(NSTabView *)tabView didMoveTabViewItem:(NSTabViewItem *)tabViewItem toIndex:(NSUInteger)toIndex
{
	MultipleDocumentsWindowController			*documentsWindowController	= self.documentsWindowController;
	NSArray										*documentViewControllers	= documentsWindowController.documentViewControllers;

	NSViewController <BSDocumentViewController> *documentViewController		= (id)tabViewItem.viewController;
	NSUInteger									fromIndex					= [documentViewControllers indexOfObject:documentViewController];

	if (fromIndex != NSNotFound) {
		[documentsWindowController moveDocumentAtIndex:fromIndex toIndex:toIndex];
	}

	NSInteger									index						= [tabView indexOfTabViewItem:tabViewItem];

	[self.documentsWindowController selectDocumentAtIndex:index];
}

- (BOOL)tabView:(NSTabView *)tabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSInteger index = [tabView indexOfTabViewItem:tabViewItem];

	if (index == NSNotFound) {
		NSLog(@"Cannot close document tab: %@", tabViewItem);

		return YES;
	}

	[self.documentsWindowController closeDocumentAtIndex:index];

	return NO;
}

- (NSImage *)tabView:(NSTabView *)tabView imageForTabViewItem:(NSTabViewItem *)tabViewItem offset:(NSSize *)offset styleMask:(NSUInteger *)styleMask
{
	NSWindow			*window					= tabView.window;
	CGWindowID			windowID				= (CGWindowID)[window windowNumber];
	CGWindowImageOption imageOptions			= kCGWindowImageDefault;
	CGWindowListOption	singleWindowListOptions = kCGWindowListOptionIncludingWindow;
	CGRect				imageBounds				= CGRectNull;

	CGImageRef			windowImage				= CGWindowListCreateImage(imageBounds, singleWindowListOptions, windowID, imageOptions);

	if (windowImage != NULL) {
		NSImage *image = [[NSImage alloc] initWithCGImage:windowImage size:[window frame].size];

		[image setCacheMode:NSImageCacheNever];

		CFRelease(windowImage);

		return image;
	}

	return nil;
}

@end
