//
//  WordHistoryViewController.m
//  BetterDictionary
//
//  Created by James Weinert on 2/17/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "WordHistoryViewController.h"
#import "BetterDictionaryAppDelegate.h"
#import "WordDefinitionViewController.h"


@implementation WordHistoryViewController
@synthesize table;
@synthesize wordHistory, wordLookupCount;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
    BetterDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lookupCount" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSArray *objects = [context executeFetchRequest:request error:&error];
	
	if (objects == nil) {
		NSLog(@"There was an error!");
		// Error Handling
	}
	
	NSMutableArray *words = [[NSMutableArray alloc] init];
	NSMutableArray *counts = [[NSMutableArray alloc] init];
	
	for (NSManagedObject *oneObject in objects) {
		NSString *word = [oneObject valueForKey:@"word"];
		NSNumber *lookupCount = [oneObject valueForKey:@"lookupCount"];
		
		[words addObject:word];
		[counts addObject:[lookupCount stringValue]];
	}
	
	if (wordHistory != nil) [wordHistory release];
	wordHistory = [[NSArray alloc] initWithArray:words];
	if (wordLookupCount != nil) [wordLookupCount release];
	wordLookupCount = [[NSArray alloc] initWithArray:counts];
	
	[words release];
	[counts release];
	[request release];
	
	[table reloadData];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [wordHistory count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSUInteger row = [indexPath row]; 
    cell.textLabel.text = [wordHistory objectAtIndex:row];
	cell.detailTextLabel.text = [wordLookupCount objectAtIndex:row];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WordDefinitionViewController *wordDefViewController = [[WordDefinitionViewController alloc] 
														   initWithNibName:@"WordDefinitionViewController" 
														   bundle:nil];
	
	NSUInteger row = [indexPath row];
	wordDefViewController.wordToLookup = [wordHistory objectAtIndex:row];
    [self.navigationController pushViewController:wordDefViewController animated:YES];
    [wordDefViewController release];

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	table = nil;
	wordHistory = nil;
	wordLookupCount = nil;
}


- (void)dealloc {
	[table release];
	[wordHistory release];
	[wordLookupCount release];
    [super dealloc];
}


@end

