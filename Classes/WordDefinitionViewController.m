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
	[self updateDefinition];
}

- (void)updateDefinition {
	WordService *ws = [[WordService alloc] init];
	
	NSArray *definitions;
	NSString *mergeDefinitions = @"";
	
	definitions = [ws fetchDefinitions:wordToLookup useCanonical:YES];
	
	NSUInteger count = 1;
	for (Definition *def in definitions) {
		if([def text] != nil) {
			mergeDefinitions = [mergeDefinitions stringByAppendingFormat:@"%d. %@: %@\n\r", count, [[def partOfSpeech] name], [def text]];
			count++;
		}
	}
	
	wordDefinitionView.text = mergeDefinitions;
	
	[ws release];	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
