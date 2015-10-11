//
//  DocumentsContainerViewController.h
//  BSMultipleDocumentsWindowController
//
//  Created by Pierre Bernard on 10/10/15.
//  Copyright (c) 2015 Houdah Software s.à r.l. All rights reserved.
//

#import "MultipleDocumentsWindowController.h"


@interface DocumentsContainerViewController : NSViewController

- (instancetype)initWithDocumentsWindowController:(MultipleDocumentsWindowController *)documentsWindowController;

@property (nonatomic, strong, readonly) MultipleDocumentsWindowController *documentsWindowController;

@end
