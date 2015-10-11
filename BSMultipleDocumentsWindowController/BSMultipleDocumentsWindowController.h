//
//  BSMultipleDocumentsWindowController.h
//  HoudahSpot
//
//  Created by Pierre Bernard on 12/05/14.
//  Copyright (c) 2012 Sasmito Adibowo. Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  Copyright (c) 2014-2015 Houdah Software s.à r.l. Creative Commons Attribution-ShareAlike 3.0 Unported License.
//
//  Based upon http://cutecoder.org/programming/window-multiple-documents/
//

@import Cocoa;


extern NSString *const BSDocumentNeedsWindowNotificationName;

extern NSString *const BSMultipleDocumentsSelectedDocumentChangedNotificationName;
extern NSString *const BSMultipleDocumentsWindowControllerWillCloseNotificationName;


extern const struct BSMultipleDocumentsWindowControllerAttributes {
    __unsafe_unretained NSString *documentViewControllers;
    __unsafe_unretained NSString *selectedDocumentViewController;
} BSMultipleDocumentsWindowControllerAttributes;


@protocol BSMultipleDocumentsDocument;
@protocol BSDocumentViewController;


@interface BSMultipleDocumentsWindowController : NSWindowController

@property (nonatomic, copy, readonly) NSArray *documentViewControllers;
@property (nonatomic, strong, readonly) NSViewController<BSDocumentViewController> *selectedDocumentViewController;

- (void)addDocument:(NSDocument<BSMultipleDocumentsDocument> *)document;
- (void)removeDocument:(NSDocument<BSMultipleDocumentsDocument> *)document;

- (void)selectDocumentAtIndex:(NSInteger)index;
- (void)closeDocumentAtIndex:(NSUInteger)index;

- (void)synchronizeTitleWithDocumentViewController:(NSViewController<BSDocumentViewController> *)documentViewController;

- (IBAction)closeTab:(id)sender;
- (IBAction)closeAllTabs:(id)sender;

- (IBAction)selectNextTab:(id)sender;
- (IBAction)selectPreviousTab:(id)sender;

- (void)moveDocumentAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeDocumentAtIndex:(NSUInteger)index;

- (void)insertDocument:(NSDocument<BSMultipleDocumentsDocument> *)document
		viewController:(NSViewController<BSDocumentViewController> *)documentViewController
			   atIndex:(NSUInteger)index;

- (void)closeAllDocumentsWithDelegate:(id)delegate
				  didCloseAllSelector:(SEL)didCloseAllSelector
						  contextInfo:(void *)contextInfo;

@end


@protocol BSDocumentViewController <NSObject>

@property (nonatomic, weak) NSDocument<BSMultipleDocumentsDocument> *document;
@property (nonatomic, weak) BSMultipleDocumentsWindowController *multipleDocumentsWindowController;

- (NSString *)titleForDocumentDisplayName:(NSString *)displayName;

@end


@protocol BSMultipleDocumentsDocument <NSObject>

- (NSViewController<BSDocumentViewController> *)makeViewController;

@end
