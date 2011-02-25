//
//  DictionarySearchViewController.h
//  BetterDictionary
//
//  Created by James Weinert on 2/23/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordService.h"


@interface DictionarySearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
	UISearchBar *searchBar;
	WordService *wordService;
	
	NSArray *searchResults;
	NSOperationQueue *workQueue;
}
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) WordService *wordService;
@property (nonatomic, retain) NSArray *searchResults;
@property (nonatomic, retain) NSOperationQueue *workQueue;

@end
