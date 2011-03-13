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
#import "BetterDictionaryConstants.h"


@implementation WordHistoryViewController
@synthesize table;
@synthesize wordHistory, wordLookupCount;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self loadWordHistory];
}

- (void)loadWordHistory {
    BetterDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kEntityName inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kCountKey ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

	[request setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSArray *objects = [context executeFetchRequest:request error:&error];
	
	if (objects == nil) {
		NSLog(@"%@ %@, %@", kErrorUnableToLoadHistory, error, [error userInfo]);
        
		
	} else {	
        NSMutableArray *words = [[NSMutableArray alloc] init];
        NSMutableArray *counts = [[NSMutableArray alloc] init];
        
        for (NSManagedObject *oneObject in objects) {
            NSString *word = [oneObject valueForKey:kWordKey];
            NSNumber *lookupCount = [oneObject valueForKey:kCountKey];
		
            [words addObject:word];
            [counts addObject:[lookupCount stringValue]];
        }
	
        if (wordHistory != nil) [wordHistory release];
        wordHistory = [[NSMutableArray alloc] initWithArray:words];
	
        if (wordLookupCount != nil) [wordLookupCount release];
        wordLookupCount = [[NSMutableArray alloc] initWithArray:counts];
	
        [words release];
        [counts release];
    }
    
	[sortDescriptor release];
	[sortDescriptors release];
	[request release];
	
	[table reloadData];
}


- (void)removeWordFromHistory:(NSString *)word {
	BetterDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kEntityName inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
    // Using kWordKey instead of "word" causes errors here. Oddness.
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(word = %@)", word];
	[request setPredicate:pred];
	
	NSError *error;
	NSArray *objects = [context executeFetchRequest:request error:&error];
	
	if (objects == nil) {
		NSLog(@"%@ %@, %@", kErrorUnableToLoadHistory, error, [error userInfo]);
        
        NSString *message = [[NSString alloc] initWithString:@"Unable to delete word from history"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        [message release];
	} else {
	
        for (NSManagedObject *oneObject in objects) {
            [context deleteObject:oneObject];
        }
       	[context save:&error];
    }
    
	[request release];

}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [wordHistory count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WordHistoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSUInteger row = [indexPath row]; 
    cell.textLabel.text = [wordHistory objectAtIndex:row];
	cell.detailTextLabel.text = [wordLookupCount objectAtIndex:row];
	
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSUInteger row = [indexPath row];
		
		NSString *word = [wordHistory objectAtIndex:row];
		[self removeWordFromHistory:word];
		
        [wordHistory removeObjectAtIndex:row];
		[wordLookupCount removeObjectAtIndex:row];
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }  
}


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
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
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

