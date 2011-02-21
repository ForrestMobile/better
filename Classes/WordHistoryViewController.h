//
//  WordHistoryViewController.h
//  BetterDictionary
//
//  Created by James Weinert on 2/17/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WordHistoryViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView *table;

	NSArray *wordHistory;
	NSArray *wordLookupCount;
}
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSArray *wordHistory;
@property (nonatomic, retain) NSArray *wordLookupCount;

@end
