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

	NSMutableArray *wordHistory;
	NSMutableArray *wordLookupCount;
}
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSMutableArray *wordHistory;
@property (nonatomic, retain) NSMutableArray *wordLookupCount;

- (void)loadWordHistory;
- (void)removeWordFromHistory:(NSString *)word;

@end
