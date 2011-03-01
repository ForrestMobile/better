//
//  WordDefinitionViewController.h
//  BetterDictionary
//
//  Created by James Weinert on 2/21/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface WordDefinitionViewController : UIViewController <MBProgressHUDDelegate> {
	MBProgressHUD *loadingStatus;
	UITextView *wordDefinitionView;
	NSString *wordToLookup;
}
@property (nonatomic, retain) IBOutlet UITextView *wordDefinitionView;
@property (nonatomic, retain) NSString *wordToLookup;

- (void)updateDefinition;
- (void)updateDefinitionText:(NSString *)definition;

@end
