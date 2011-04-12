//
//  BetterDictionaryAppDelegate.h
//  BetterDictionary
//
//  Created by James Weinert on 2/12/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Wordnik/Wordnik.h>
#import <Wordnik/WNClient.h>

@interface BetterDictionaryAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
	UITabBarController *tabBarController;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
    
    WNClient *wordnikClient_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain, readonly) WNClient *wordnikClient_;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

@end

