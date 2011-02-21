//
//  DefineViewController.m
//  BetterDictionary
//
//  Created by James Weinert on 2/12/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "DefineViewController.h"
#import "BetterDictionaryAppDelegate.h"


@implementation DefineViewController
@synthesize text;
@synthesize searchResults, wordService;
@synthesize savedSearchTerm, savedScopeButtonIndex, searchWasActive;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	searchWasActive = NO;
	wordService = [[WordService alloc] init];
	workQueue = [[NSOperationQueue alloc] init];
	[workQueue setMaxConcurrentOperationCount:1];
}


#pragma mark -
#pragma mark UITableView data source and delegate methods

- (void)updateDefinition:(NSString *)wordToLookup {
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
	
	text.text = mergeDefinitions;
	
	[ws release];	
}


- (void)updateWordHistory:(NSString *)wordLookedUp {
	BetterDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSError *error;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:context];
	[request setEntity:entityDescription];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(word = %@)", wordLookedUp];
	[request setPredicate:pred];
	
	NSManagedObject *word = nil;
	
	NSArray *objects = [context executeFetchRequest:request error:&error];
	
	if(objects == nil) {
		NSLog(@"There was an error");
		// Handle the error
	}
	if ([objects count] > 0)
		word = [objects objectAtIndex:0];
	else 
		word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:context];
	
	int count = [[word valueForKey:@"lookupCount"] intValue];
	count++;
	
	[word setValue:wordLookedUp forKey:@"word"];
	[word setValue:[NSNumber numberWithInt:count] forKey:@"lookupCount"];
	
	[request release];
	[context save:&error];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [searchResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SearchCellIdentifier = @"SearchCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSString *word = [searchResults objectAtIndex:row];
	
	[self saveSearch];
	[self.searchDisplayController setActive:NO animated:YES];
	self.searchDisplayController.searchBar.text = word;
	[self updateDefinition:word];
	[self updateWordHistory:word];
}


#pragma mark -
#pragma mark Content Filtering

- (void)saveSearch {
	self.searchWasActive = YES;
	self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}


- (void)updateSearch:(NSString*)searchText {
	NSLog([NSString stringWithFormat:@"updateSearch:%@ start", searchText]);
	searchResults = [wordService suggestWord:searchText];

	[self.searchDisplayController.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) 
																		  withObject:nil 
																	   waitUntilDone:YES];
	NSLog(@"updateSearch finished");
}


#pragma mark -
#pragma mark Search Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	NSInvocationOperation *operation = [[[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(updateSearch:)
																			   object:searchText] autorelease];
	[workQueue cancelAllOperations];
	[workQueue addOperation:operation];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    if(searchWasActive) {
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
    }
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	searchResults = nil;
	wordService = nil;
	workQueue = nil;
}


- (void)dealloc {
	[searchResults release];
	[wordService release];
	[workQueue release]; 
    [super dealloc];
}


@end
