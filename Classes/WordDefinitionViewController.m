//
//  WordDefinitionViewController.m
//  BetterDictionary
//
//  Created by James Weinert on 2/21/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//


#import <Wordnik/WNClient.h>

#import "WordDefinitionViewController.h"
#import "BetterDictionaryAppDelegate.h"
#import "SVProgressHUD.h"


@implementation WordDefinitionViewController
@synthesize wordDefinitionView, wordToLookup;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = wordToLookup;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self updateDefinition];
}

- (void)updateDefinition {
	NSArray *elements = [NSArray arrayWithObjects:
                         [WNWordDefinitionRequest requestWithDictionary:[WNDictionary wordnetDictionary]],
                         [WNWordExampleRequest request],
                         nil];
    WNWordRequest *req = [WNWordRequest requestWithWord: wordToLookup
                                   requestCanonicalForm: YES
                             requestSpellingSuggestions: YES
                                        elementRequests: elements];
    
    BetterDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    WNClient *client = [appDelegate wordnikClient];

    [SVProgressHUD showInView:self.view];
    [client wordWithRequest:req completionBlock:^(WNWordResponse *response, NSError *error) {      
        if (error != nil) {
            [SVProgressHUD dismissWithError:[error localizedFailureReason]];
        }
        else {
            NSMutableString *wordText = [NSMutableString string];
            WNWordObject *word = response.wordObject;
            
            /* Definitions */
            if (word.definitions != nil && word.definitions.count > 0) {
                
                for (WNDefinitionList *list in word.definitions) {
                    if (list.definitions.count == 0)
                        continue;
                    NSUInteger count = 1;
                    for (WNDefinition *def in list.definitions) {
                        [wordText appendString:[NSString stringWithFormat:@"%d. ", count]];
                        count++;
                        
                        if (def.extendedText != nil) {
                            [wordText appendString: def.extendedText];
                        } else {
                            [wordText appendString: def.text];
                        }
                        
                        [wordText appendString: @"\n\n"];
                    }
                }
            }
            
            /* Example sentences. */
            if (word.examples != nil && word.examples.count > 0) {
                NSArray *strings = [word.examples wn_map: ^(id obj) {
                    WNExample *sentence = obj;
                    return [NSString stringWithFormat: @"“%@”\n%@ (%d)", 
                            sentence.text, sentence.title, [sentence.publicationDateComponents year]];
                }];
                
                [wordText appendFormat: @"Examples:\n%@", [strings componentsJoinedByString: @"\n\n"]];
            }
            
            wordDefinitionView.text = wordText;
            [SVProgressHUD dismiss];
        }
    }];
}


#pragma mark -
#pragma mark Memory management


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.wordDefinitionView = nil;
	self.wordToLookup = nil;
}


- (void)dealloc {
    [super dealloc];
	[wordDefinitionView release];
	[wordToLookup release];
}


@end
