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
#import "BetterDictionaryAPIConstants.h"
#import "SVProgressHUD.h"


@implementation WordDefinitionViewController
@synthesize wordDefinitionView, wordToLookup;
@synthesize adBannerView;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = wordToLookup;
    
    adBannerView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    if ([wordDefinitionView.text length] == 0) {
        [self updateDefinition];
    }
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
                
                NSString *partOfSpeech = @"";
                for (WNDefinitionList *list in word.definitions) {
                    if (list.definitions.count == 0)
                        continue;
                    
                    NSUInteger count = 1;
                    for (WNDefinition *def in list.definitions) {
                        if (![partOfSpeech isEqualToString:def.partOfSpeech.name]) {
                            partOfSpeech = def.partOfSpeech.name;
                            [wordText appendString:[NSString stringWithFormat:@"-%@\n", partOfSpeech]];
                        }
                        
                        [wordText appendString:[NSString stringWithFormat:@"%d. ", count]];
                        count++;
                        
                        if (def.extendedText != nil) {
                            [wordText appendString:def.extendedText];
                        } else {
                            [wordText appendString:def.text];
                        }
                        
                        [wordText appendString: @"\n\n"];
                    }
                }
            }
            
            /* Example sentences. */
            if (word.examples != nil && word.examples.count > 0) {
                NSArray *strings = [word.examples wn_map:^(id obj) {
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
#pragma mark ADBannerViewDelegate methods

- (void)updateiADBannerViewPosition:(BOOL)animated {
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    CGFloat bannerHeight = self.adBannerView.bounds.size.height;
    
    CGRect newBannerFrame = self.adBannerView.frame;
    CGRect newWordDefFrame = self.view.frame;
    
    if(self.adBannerView.bannerLoaded) {
        newWordDefFrame.size.height -= bannerHeight;
        newWordDefFrame.origin.y += bannerHeight;
        newBannerFrame.origin.y = self.view.frame.origin.y;
    } else {
        newBannerFrame.origin.y = self.view.frame.origin.y - bannerHeight;
    }
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.wordDefinitionView.frame = newWordDefFrame;
                         self.adBannerView.frame = newBannerFrame;
                     }];
}


- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    NSLog(@"bannerViewDidLoadAd");
    [self updateiADBannerViewPosition:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"bannerView didFailToReceiveAd");
    [self updateiADBannerViewPosition:YES];
}


#pragma mark -
#pragma mark Memory management


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    adBannerView.delegate = nil;
    self.adBannerView = nil;
    self.wordDefinitionView = nil;
	self.wordToLookup = nil;
}


- (void)dealloc {
    [super dealloc];
    adBannerView.delegate = nil;
    [adBannerView release];
	[wordDefinitionView release];
	[wordToLookup release];
}


@end
