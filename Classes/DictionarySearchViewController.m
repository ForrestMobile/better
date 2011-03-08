//
//  DictionarySearchViewController.m
//  BetterDictionary
//
//  Created by James Weinert on 2/23/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "DictionarySearchViewController.h"
#import "BetterDictionaryAppDelegate.h"
#import "WordDefinitionViewController.h"


@implementation DictionarySearchViewController
@synthesize searchBar, wordService, searchResults, workQueue;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	wordService = [[WordService alloc] init];
	workQueue = [[NSOperationQueue alloc] init];
	[workQueue setMaxConcurrentOperationCount:1];
}


#pragma mark -
#pragma mark UITableView data source and delegate methods

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
	static NSString *SearchCellIdentifier = @"DictionarySearchCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	if([searchResults objectAtIndex:indexPath.row] != nil)
	cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSString *word = [searchResults objectAtIndex:row];
	
	[self updateWordHistory:word];
	
	WordDefinitionViewController *wordDefViewController = [[WordDefinitionViewController alloc] 
														   initWithNibName:@"WordDefinitionViewController" 
														   bundle:nil];
	
	wordDefViewController.wordToLookup = word;
    [self.navigationController pushViewController:wordDefViewController animated:YES];
    [wordDefViewController release];
}


#pragma mark -
#pragma mark Search bar delegate methods

- (void)updateSearch:(NSString *)searchText {
//	NSLog([NSString stringWithFormat:@"updateSearch:%@ start", searchText]);
	if(searchResults != nil) [searchResults release];
	searchResults = [wordService suggestWord:searchText];
	
	[self.searchDisplayController.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) 
																		  withObject:nil 
																	   waitUntilDone:YES];
//	NSLog(@"updateSearch finished");
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([searchText length] > 0) {
		NSInvocationOperation *operation = [[[NSInvocationOperation alloc] initWithTarget:self
																				 selector:@selector(updateSearch:)
																				   object:searchText] autorelease];
		[workQueue cancelAllOperations];
		[workQueue addOperation:operation];
	} else {
		//searchResults = nil;
		[self.searchDisplayController.searchResultsTableView reloadData];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	searchBar = nil;
    wordService = nil;
	searchResults = nil;
	workQueue = nil;

}


- (void)dealloc {
	[searchBar release];
	[wordService release];
	[searchResults release];
	[workQueue release];
    [super dealloc];
}


@end
