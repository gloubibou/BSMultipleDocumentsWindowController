//
//  DocumentViewController.h
//  BSMultipleDocumentsWindowController
//
//  Created by Pierre Bernard on 10/10/15.
//  Copyright (c) 2015 Houdah Software s.à r.l. All rights reserved.
//

#import "BSMultipleDocumentsWindowController.h"


@interface DocumentViewController : NSViewController<BSDocumentViewController>

@property (nonatomic, weak) NSDocument<BSMultipleDocumentsDocument> *document;
@property (nonatomic, weak) BSMultipleDocumentsWindowController *multipleDocumentsWindowController;

- (NSString *)titleForDocumentDisplayName:(NSString *)displayName;

@end
