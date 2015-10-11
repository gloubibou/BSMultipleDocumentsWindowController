//
//  Document.h
//  BSMultipleDocumentsWindowController
//
//  Created by Pierre Bernard on 10/10/15.
//  Copyright (c) 2015 Houdah Software s.à r.l. All rights reserved.
//

#import "BSDocument.h"
#import "BSMultipleDocumentsWindowController.h"


@interface Document : BSDocument <BSMultipleDocumentsDocument>

@property (nonatomic, copy) NSString *documentBody;

- (NSViewController<BSDocumentViewController> *)makeViewController;

@end

