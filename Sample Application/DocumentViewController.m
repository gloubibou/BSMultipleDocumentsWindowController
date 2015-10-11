//
//  DocumentViewController.m
//  BSMultipleDocumentsWindowController
//
//  Created by Pierre Bernard on 10/10/15.
//  Copyright (c) 2015 Houdah Software s.à r.l. All rights reserved.
//

#import "DocumentViewController.h"


@interface DocumentViewController ()


@end


@implementation DocumentViewController

- (instancetype)init
{
	self = [super initWithNibName:[[self class] nibName] bundle:nil];

	if (self != nil) {}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (NSString *)titleForDocumentDisplayName:(NSString *)displayName
{
	return displayName;
}

+ (NSString *)nibName
{
	return NSStringFromClass([self class]);
}

- (IBAction)markDirty:(id)sender
{
	[self.document updateChangeCount:NSChangeDone];
}

- (IBAction)markClean:(id)sender
{
	[self.document updateChangeCount:NSChangeCleared];
}

@end
