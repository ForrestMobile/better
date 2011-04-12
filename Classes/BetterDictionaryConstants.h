//
//  Constants.h
//  BetterDictionary
//
//  Created by James Weinert on 3/12/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

// Core Data Keys
#define kEntityName     @"Word"
#define kWordKey        @"word"
#define kCountKey       @"lookupCount"

// Error messgaes
#define kErrorUnableToSaveContext           @"Unable to save context"
#define kErrorUnableToUpdateWordHistory     @"Unable to update word history"
#define kErrorUnableToLoadHistory           @"Unable to load word history"
#define kErrorUnableToDeleteWord            @"Unable to delete word from history"
#define kErrorUnableToCreatePersistentStore @"Unable to create Persistent Store"

#define kErrorCoreDataMessageForUser        @"Unable to save word to history. Please restart the app using your Home button"