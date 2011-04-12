//
//  WordDefinitionViewController.h
//  BetterDictionary
//
//  Created by James Weinert on 2/21/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface WordDefinitionViewController : UIViewController <ADBannerViewDelegate> {
	UITextView *wordDefinitionView;
	NSString *wordToLookup;
    
    ADBannerView *adBannerView;
}
@property (nonatomic, retain) IBOutlet UITextView *wordDefinitionView;
@property (nonatomic, retain) NSString *wordToLookup;

@property (nonatomic, retain) IBOutlet ADBannerView *adBannerView;

- (void)updateDefinition;

@end
