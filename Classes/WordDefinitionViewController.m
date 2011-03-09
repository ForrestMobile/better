//
//  WordDefinitionViewController.m
//  BetterDictionary
//
//  Created by James Weinert on 2/21/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "WordDefinitionViewController.h"
#import "WordService.h"


@implementation WordDefinitionViewController
@synthesize wordDefinitionView, wordToLookup;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = wordToLookup;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([wordDefinitionView.text length] == 0) {
		loadingStatus = [[MBProgressHUD alloc] initWithView:self.view.window];
		[self.view.window addSubview:loadingStatus];
	
		loadingStatus.delegate = self;
	
		[loadingStatus showWhileExecuting:@selector(updateDefinition) onTarget:self withObject:nil animated:YES];
	}
}

- (void)updateDefinition {
	WordService *ws = [[WordService alloc] init];
	
	NSArray *definitions;
	NSMutableString *mergeDefinitions = [[NSMutableString alloc] init];
	
	definitions = [ws fetchDefinitions:wordToLookup useCanonical:YES];
	
	NSUInteger count = 1;
	for (Definition *def in definitions) {
		if([def text] != nil) {
			[mergeDefinitions appendString:[NSString stringWithFormat:@"%d. %@: %@\n\r", count, 
																						[[def partOfSpeech] name], 
																						[def text]]];
			count++;
		}
	}
	
	if ([mergeDefinitions length] == 0) 
	{
		[mergeDefinitions appendString:[NSString stringWithFormat:@"No definitions are available for %@.", wordToLookup]];
	}
	
	[self performSelectorOnMainThread:@selector(updateDefinitionText:) withObject:mergeDefinitions waitUntilDone:YES];
	
	[mergeDefinitions release];
	[ws release];	
}

- (void)updateDefinitionText:(NSString *)definition {
	wordDefinitionView.text = definition;
}


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [loadingStatus removeFromSuperview];
    [loadingStatus release];
}


#pragma mark -
#pragma mark Memory management


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    wordDefinitionView = nil;
	wordToLookup = nil;
}


- (void)dealloc {
    [super dealloc];
	[wordDefinitionView release];
	[wordToLookup release];
}


@end
