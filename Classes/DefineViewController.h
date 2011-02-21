//
//  DefineViewController.h
//  BetterDictionary
//
//  Created by James Weinert on 2/12/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordService.h"

@interface DefineViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
	UITextView *text;
	
	WordService *wordService;
	
	NSArray *searchResults;
	
	NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
	
	NSOperationQueue *workQueue;
}
@property (nonatomic, retain) IBOutlet UITextView *text;

@property (nonatomic, retain) WordService *wordService;

@property (nonatomic, retain) NSArray *searchResults;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

- (void)saveSearch;
- (void)updateSearch:(NSString*)searchText;
- (void)updateDefinition:(NSString*)wordToLookup;
@end
