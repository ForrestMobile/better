//
//  WordDefinitionViewController.m
//  BetterDictionary
//
//  Created by James Weinert on 2/21/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//
#import <Wordnik/Wordnik.h>
#import <WordnikUI/WordnikUI.h>

#import "WordDefinitionViewController.h"
#import "BetterDictionaryAppDelegate.h"


@implementation WordDefinitionViewController
@synthesize adViewController, wordDefinitionView, wordToLookup;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = wordToLookup;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self didPressLookupButton];
/**	if ([wordDefinitionView.text length] == 0) {
		loadingStatus = [[MBProgressHUD alloc] initWithView:self.view.window];
		[self.view.window addSubview:loadingStatus];
	
		loadingStatus.delegate = self;
	
		[loadingStatus showWhileExecuting:@selector(updateDefinition) onTarget:self withObject:nil animated:YES];
	}**/
}

- (void)updateDefinition {
    BetterDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	WNClient *client = [appDelegate wordnikClient];

    NSMutableString *mergeDefinitions = [NSMutableString string];
    
    NSArray *elements = [NSArray arrayWithObjects:
                         [WNWordDefinitionRequest requestWithDictionary:[WNDictionary wordnetDictionary]],
                         [WNWordExampleRequest request],
                         nil];
    WNWordRequest *req = [WNWordRequest requestWithWord:wordToLookup
                                   requestCanonicalForm:YES
                             requestSpellingSuggestions:NO
                                        elementRequests:elements];
    
    /* Submit */
    [client wordWithRequest:req completionBlock:^(WNWordResponse *response, NSError *error) {
        
        /* Report error */
        if (error != nil) {
            [self reportError: error];
        }
        
        WNWordObject *word = response.wordObject;
              
        /* Definitions */
        if (word.definitions != nil && word.definitions.count > 0) {
            [mergeDefinitions appendString: @"Definitions:\n"];
            for (WNDefinitionList *list in word.definitions) {
                if (list.definitions.count == 0)
                    continue;
                
                [mergeDefinitions appendFormat: @" - %@ - \n", list.sourceDictionary.localizedName];
                for (WNDefinition *def in list.definitions) {
                    [mergeDefinitions appendString: @"• "];
                    
                    if (def.extendedText != nil) {
                        [mergeDefinitions appendString: def.extendedText];
                    } else {
                        [mergeDefinitions appendString: def.text];
                    }
                    
                    [mergeDefinitions appendString: @"\n\n"];
                }
            }
        }
        
        /* Example sentences. */
        if (word.examples != nil && word.examples.count > 0) {
            /* Create a sentence list */
            NSArray *strings = [word.examples wn_map: ^(id obj) {
                WNExample *sentence = obj;
                return [NSString stringWithFormat: @"“%@”\n%@ (%d)", 
                        sentence.text, sentence.title, [sentence.publicationDateComponents year]];
            }];
            
            [mergeDefinitions appendFormat: @"Examples:\n%@", [strings componentsJoinedByString: @"\n\n"]];
        }
    }];

    
    
	[self performSelectorOnMainThread:@selector(updateDefinitionText:) withObject:mergeDefinitions waitUntilDone:YES];
	
	[mergeDefinitions release];
}

- (void) reportError: (NSError *) error {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle: @"Lookup Failure" 
                                                     message: [error localizedFailureReason]
                                                    delegate: nil 
                                           cancelButtonTitle: @"OK" 
                                           otherButtonTitles: nil] autorelease];
    [alert show];
    return;
}

- (void) didPressLookupButton {
    
    WNClientConfig *config = [WNClientConfig configWithAPIKey:@"bd96bdcc1a0e2abe410050b634807facc67143ae8e00d7267"];
    WNClient *client = [[[WNClient alloc] initWithClientConfig: config] autorelease];
    
    /* Fetch API usage information (for testing purposes). */
    [client requestAPIUsageStatusWithCompletionBlock: ^(WNClientAPIUsageStatus *status, NSError *error) {
        if (error != nil) {
            NSLog(@"Usage request failed: %@", error);
            return;
        }
        
        NSMutableString *output = [NSMutableString string];
        [output appendFormat: @"Expires at: %@\n", status.expirationDate];
        [output appendFormat: @"Reset at: %@\n", status.resetDate];
        [output appendFormat: @"Total calls permitted: %ld\n", (long) status.totalPermittedRequestCount];
        [output appendFormat: @"Total calls remaining: %ld\n", (long) status.remainingPermittedRequestCount];
        
        NSLog(@"API Usage:\n%@", output);
    }];
    
    /* Create our request */
    NSArray *elements = [NSArray arrayWithObjects:
                         [WNWordDefinitionRequest requestWithDictionary: [WNDictionary wordnetDictionary]],
                         [WNWordBigramRequest request],
                         [WNWordExampleRequest request],
                         [WNWordRelatedWordsRequest request],
                         [WNWordUsageFrequencyRequest request],
                         [WNWordTextPronunciationRequest request],
						 [WNAudioFileMetadataRequest request],
                         nil];
    WNWordRequest *req = [WNWordRequest requestWithWord: wordToLookup
                                   requestCanonicalForm: YES
                             requestSpellingSuggestions: YES
                                        elementRequests: elements];
    
    /* Submit */
    [client wordWithRequest: req completionBlock: ^(WNWordResponse *response, NSError *error) {
        /* Fix up the UI */
     //   _wordField.enabled = YES;
     //   _lookupButton.enabled = YES;
    //    [_runningIndicator stopAnimating];
        
        /* Report error */
        if (error != nil) {
            [self reportError: error];
        }
        
        /* Populate the word info text field */
        NSMutableString *infoText = [NSMutableString string];
        WNWordObject *word = response.wordObject;
        
        /* Spelling suggestions */
        if ([response.spellingSuggestions count] > 0) {
            [infoText appendString: @"Did you mean: "];
            NSArray *wordStrings = [response.spellingSuggestions wn_map: ^id (id obj) {
                return [obj word];
            }];
            
            [infoText appendFormat: @"%@\n\n", [wordStrings componentsJoinedByString: @", "]];
        }
		
		/* Audio */
		if(word.audioFileMetadata != nil){
			[infoText appendFormat: @"Found %d audio files:\n", [word.audioFileMetadata count]];
			for(WNAudioFileMetadata * meta in word.audioFileMetadata){
				[infoText appendFormat: @"%@\n", meta.createdBy];
			}
		}
        
        /* Definitions */
        if (word.definitions != nil && word.definitions.count > 0) {
            [infoText appendString: @"Definitions:\n"];
            for (WNDefinitionList *list in word.definitions) {
                if (list.definitions.count == 0)
                    continue;
                
                [infoText appendFormat: @" - %@ - \n", list.sourceDictionary.localizedName];
                for (WNDefinition *def in list.definitions) {
                    [infoText appendString: @"• "];
                    
                    if (def.extendedText != nil) {
                        [infoText appendString: def.extendedText];
                    } else {
                        [infoText appendString: def.text];
                    }
                    
                    [infoText appendString: @"\n\n"];
                }
            }
        }
        
        /* Example sentences. */
        if (word.examples != nil && word.examples.count > 0) {
            /* Create a sentence list */
            NSArray *strings = [word.examples wn_map: ^(id obj) {
                WNExample *sentence = obj;
                return [NSString stringWithFormat: @"“%@”\n%@ (%d)", 
                        sentence.text, sentence.title, [sentence.publicationDateComponents year]];
            }];
            
            [infoText appendFormat: @"Examples:\n%@", [strings componentsJoinedByString: @"\n\n"]];
        }
        
        /* Pronunciation */
        if (word.textPronunciations != nil && word.textPronunciations.count > 0) {
            NSArray *strings = [word.textPronunciations wn_map: ^(id obj) {
                WNTextPronunciation *pr = obj;
                return [NSString stringWithFormat: @"• %@: %@", pr.pronunciationType.name, pr.pronunciationString];
            }];
            
            [infoText appendFormat: @"\n\nPronunciation:\n%@", [strings componentsJoinedByString: @"\n"]];
        }
        
        /* Related words */
        if (word.relatedWords != nil && word.relatedWords.relatedWords.count > 0) {
            for (WNRelatedWordType *type in word.relatedWords.relationTypes) {
                /* Create a word list */
                NSArray *strings = [[word.relatedWords wordsForRelationType: type] wn_map: ^id (id obj) {
                    WNRelatedWordObject *relWord = obj;
                    return relWord.word;
                }];
                
                /* Append list */
                [infoText appendFormat: @"\n\n%@: %@", type.name, [strings componentsJoinedByString: @", "]];
            }
        };
        
        /* Bigrams */
        if (word.bigrams != nil && word.bigrams.count > 0) {
            NSArray *bigramStrings = [word.bigrams wn_map: ^(id obj) {
                WNBigram *bigram = obj;
                return [NSString stringWithFormat: @"• %@ %@", bigram.firstWordString, bigram.secondWordString];
            }];
            
            [infoText appendFormat: @"\n\nBigram Phrases:\n%@", [bigramStrings componentsJoinedByString: @"\n"]];
        }
        
        /* Usage frequency. */
        if (word.usageFrequencyTimeline != nil && word.usageFrequencyTimeline.wordFrequencies.count > 0) {
            NSArray *strings = [word.usageFrequencyTimeline.wordFrequencies wn_map: ^(id obj) {
                WNUsageFrequency *freq = obj;
                return [NSString stringWithFormat: @"• %d - %d", freq.year, freq.usageCount];
            }];
            
            [infoText appendFormat: @"\n\nUsage Frequency:\n%@", [strings componentsJoinedByString: @"\n"]];
        }
        
   //     _resultTextView.text = infoText;
    }];
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
    self.adViewController = nil;
    self.wordDefinitionView = nil;
	self.wordToLookup = nil;
}


- (void)dealloc {
    [super dealloc];
    [adViewController release];
	[wordDefinitionView release];
	[wordToLookup release];
}


@end
