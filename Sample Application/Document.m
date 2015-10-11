//
//  Document.m
//  BSMultipleDocumentsWindowController
//
//  Created by Pierre Bernard on 10/10/15.
//  Copyright (c) 2015 Houdah Software s.à r.l. All rights reserved.
//

#import "Document.h"
#import "DocumentViewController.h"


@interface Document ()

@property (nonatomic, strong)       DocumentViewController *documentViewController;

@end


@implementation Document

- (instancetype)init
{
	self = [super init];

	if (self) {
		self.documentBody	= [NSString stringWithFormat:@"Created at %@", [NSDate date]];
	}

	return self;
}

- (void)setDisplayName:(NSString *)displayNameOrNil
{
	[super setDisplayName:displayNameOrNil];

	DocumentViewController *documentViewController = self.documentViewController;

	[documentViewController.multipleDocumentsWindowController synchronizeTitleWithDocumentViewController:documentViewController];
}

- (void)makeWindowControllers
{
	[[NSNotificationCenter defaultCenter] postNotificationName:BSDocumentNeedsWindowNotificationName object:self];
}

- (NSViewController <BSDocumentViewController> *)makeViewController
{
	DocumentViewController *documentViewController = [[DocumentViewController alloc] init];

	documentViewController.document = self;

	self.documentViewController		= documentViewController;

	return documentViewController;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	return [[NSData alloc] init];
}

@end
