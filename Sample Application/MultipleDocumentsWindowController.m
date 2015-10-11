//
//  MultipleDocumentsWindowController.m
//  BSMultipleDocumentsWindowController
//
//  Created by Pierre Bernard on 10/10/15.
//  Copyright (c) 2015 Houdah Software s.à r.l. All rights reserved.
//

#import "MultipleDocumentsWindowController.h"

#import "DocumentsContainerViewController.h"


@interface MultipleDocumentsWindowController ()

@property (nonatomic, weak) IBOutlet NSView						*containerView;

@property (nonatomic, strong) DocumentsContainerViewController	*documentsContainerViewController;


@end


@implementation MultipleDocumentsWindowController

- (instancetype)init
{
	self = [super initWithWindowNibName:[[self class] nibName]];

	if (self != nil) {}

	return self;
}

- (void)windowDidLoad
{
	[super windowDidLoad];

	DocumentsContainerViewController	*documentsContainerViewController	=
	[[DocumentsContainerViewController alloc] initWithDocumentsWindowController:self];

	self.documentsContainerViewController = documentsContainerViewController;

	NSView								*containerView						= self.containerView;

	[documentsContainerViewController.view setFrame:[containerView bounds]];
	[documentsContainerViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

	[containerView addSubview:documentsContainerViewController.view];

}

+ (NSString *)nibName
{
	return NSStringFromClass([self class]);
}

@end
