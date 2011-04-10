//
//  DictionarySearchViewController.h
//  BetterDictionary
//
//  Created by James Weinert on 2/23/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Wordnik/Wordnik.h>


@interface DictionarySearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, WNClientObserver> {
	UISearchBar *searchBar;
	WNClient *client;
    WNRequestTicket *requestTicket_;
	
	NSArray *searchResults;
}
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSArray *searchResults;

@end
