#import <dlfcn.h>
#import <Cephei/HBPreferences.h>

#define IS_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface NSExtension : NSObject
@property (nonatomic,copy) NSString * identifier;
@end

@interface UIApplicationExtensionActivity : UIActivity
@property (nonatomic,retain) NSExtension* applicationExtension;
+ (id)_applicationExtensionActivitiesForItems:(id)arg1;
@end

@interface UIActivityGroupViewController : UICollectionViewController
@property (nonatomic,copy) NSArray* activities;
@end

@interface _UIActivityGroupListViewController : UICollectionViewController
@property (nonatomic,copy) NSArray<UIActivityGroupViewController*>* activityGroupViewControllers;
@end

@interface _UIActivityViewControllerContentController : UIViewController
@property (nonatomic,retain) _UIActivityGroupListViewController* activityGroupListViewController;
@end

@interface UIActivityViewController ()
@property (nonatomic,copy) NSArray* activityItems;
@property (nonatomic,copy) NSArray* applicationActivities;
@property (nonatomic,readonly) NSArray* resolvedActivityItemsForCurrentActivity;
@property (nonatomic,retain) _UIActivityViewControllerContentController* contentController;
- (void)shareExtensionServiceRequestPerformActivityInHostForExtensionActivityWithBundleIdentifier:(NSString*)arg1;
- (void)_performActivity:(id)arg1;
@end

@interface TabDocument : NSObject
@property (nonatomic, getter=isBlankDocument) BOOL blankDocument;
- (id)URLForSharing;
@end

@interface _UIShareExtensionRemoteViewController : UIViewController
- (void)shareExtensionServiceRequestPerformActivityInHostForExtensionActivityWithBundleIdentifier:(NSString*)arg1;
@end

@interface ActionPanel : UIActivityViewController
@property (nonatomic,retain) _UIShareExtensionRemoteViewController * remoteContentViewController;
- (id)initWithTabDocument:(TabDocument*)arg1 activityDelegate:(id)arg2;	//iOS 10
- (id)initWithTabDocument:(id)arg1 sharingURL:(id)arg2 activityDelegate:(id)arg3;	//iOS 11
@end

@interface TabController : NSObject
@property (retain, nonatomic) TabDocument* activeTabDocument;
@end

@interface BrowserController : NSObject
@property (nonatomic, retain) ActionPanel *fastActionPanel;
@property (readonly, nonatomic) TabController* tabController;
- (void)_presentModalViewController:(id)arg1 fromButtonIdentifier:(long long)arg2 completion:(void (^)(void))arg3;
@end

@interface BrowserToolbar : UIToolbar
@property (nonatomic,retain) BrowserController* browserDelegate;
@property (nonatomic,retain) UIBarButtonItem* _lastPassButton;
@property (nonatomic,retain) UIBarButtonItem* _1PasswordButton;
@property (nonatomic,retain) UIBarButtonItem* _downloadsItem;
@end

HBPreferences* preferences;
BOOL lastPassButtonEnabled;
BOOL onePasswordButtonEnabled;

NSBundle* resourceBundle;

UIApplicationExtensionActivity* getExtensionActivityForBundleIdentifier(ActionPanel* actionPanel, NSString* identifier)
{
	for(UIActivityGroupViewController* activityGroupViewController in actionPanel.contentController.activityGroupListViewController.activityGroupViewControllers)
	{
		if([activityGroupViewController respondsToSelector:@selector(activities)])
		{
			for(id activity in activityGroupViewController.activities)
			{
				if([activity isKindOfClass:[%c(UIApplicationExtensionActivity) class]])
				{
					if([((UIApplicationExtensionActivity*)activity).applicationExtension.identifier isEqualToString:identifier])
					{
						return activity;
					}
				}
			}
		}
	}

	return nil;
}

%hook BrowserToolbar

//Property for new buttons
%property (nonatomic,retain) UIBarButtonItem *_lastPassButton;
%property (nonatomic,retain) UIBarButtonItem *_1PasswordButton;

- (NSMutableArray *)defaultItems
{
	if(lastPassButtonEnabled || onePasswordButtonEnabled)
	{
		NSMutableArray* defaultItems = %orig;

		if((lastPassButtonEnabled && ![defaultItems containsObject:self._lastPassButton]) || (onePasswordButtonEnabled && ![defaultItems containsObject:self._1PasswordButton]))
		{
			if(onePasswordButtonEnabled && !self._1PasswordButton)
			{
				self._1PasswordButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"1PasswordButton.png" inBundle:resourceBundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain
							 target:self.browserDelegate action:@selector(onePasswordFromButtonBar)];
			}

			if(lastPassButtonEnabled && !self._lastPassButton)
			{
				self._lastPassButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LastPassButton.png" inBundle:resourceBundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain
							target:self.browserDelegate action:@selector(lastPassFromButtonBar)];
			}

			NSInteger placement = MSHookIvar<NSInteger>(self, "_placement");

			if(placement == 0)
			{
				[defaultItems removeObjectAtIndex:4];
				if(onePasswordButtonEnabled && lastPassButtonEnabled)
				{
					[defaultItems removeObjectAtIndex:2];
				}
				[defaultItems removeObjectAtIndex:0];

				if(onePasswordButtonEnabled)
				{
					[defaultItems insertObject:self._1PasswordButton atIndex:3];
				}

				if(lastPassButtonEnabled)
				{
					[defaultItems insertObject:self._lastPassButton atIndex:3];
				}
			}
			else
			{
				UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
								  target:nil action:nil];

				BOOL needsModify = YES;

				if([self respondsToSelector:@selector(_downloadsItem)])	//Safari Plus detection & compatibility
				{
					if([defaultItems containsObject:self._downloadsItem])
					{
						needsModify = NO;
					}
				}

				if(needsModify)
				{
					UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
								       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
								       target:nil action:nil];

					UIBarButtonItem *fixedSpaceHalf = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
									   target:nil action:nil];

					UIBarButtonItem *fixedSpaceTwo = [[UIBarButtonItem alloc]
									  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
									  target:nil action:nil];

					fixedSpace.width = 15;
					fixedSpaceHalf.width = 7.5f;
					fixedSpaceTwo.width = 6;

					defaultItems = [@[defaultItems[1], fixedSpace, flexibleSpace,
							  fixedSpaceHalf, defaultItems[4], fixedSpaceHalf, flexibleSpace, fixedSpaceTwo,
							  defaultItems[7], flexibleSpace, defaultItems[10], flexibleSpace, defaultItems[13]] mutableCopy];
				}

				if(onePasswordButtonEnabled)
				{
					[defaultItems insertObject:flexibleSpace atIndex:12];
					[defaultItems insertObject:self._1PasswordButton atIndex:12];
				}

				if(lastPassButtonEnabled)
				{
					[defaultItems insertObject:flexibleSpace atIndex:12];
					[defaultItems insertObject:self._lastPassButton atIndex:12];
				}

			}
		}

		return defaultItems;
	}

	return %orig;
}

%end

%hook BrowserController

%property (nonatomic, retain) ActionPanel *fastActionPanel;

%new
- (void)lastPassFromButtonBar
{
	if(self.tabController.activeTabDocument.blankDocument)
	{
		return;
	}

	if([[%c(ActionPanel) class] instancesRespondToSelector:@selector(initWithTabDocument:activityDelegate:)])
	{
		self.fastActionPanel = [[%c(ActionPanel) alloc] initWithTabDocument:self.tabController.activeTabDocument activityDelegate:self];
	}
	else
	{
		self.fastActionPanel = [[%c(ActionPanel) alloc] initWithTabDocument:self.tabController.activeTabDocument sharingURL:[self.tabController.activeTabDocument URLForSharing] activityDelegate:self];
	}

	[self _presentModalViewController:self.fastActionPanel fromButtonIdentifier:0 completion:nil];

	dispatch_async(dispatch_get_main_queue(), ^(void)
	{
		UIApplicationExtensionActivity* activity = getExtensionActivityForBundleIdentifier(self.fastActionPanel, @"com.lastpass.ilastpass.LastPassExt");
		if(activity)
		{
			[self.fastActionPanel _performActivity:activity];
		}
	});
}

%new
- (void)onePasswordFromButtonBar
{
	if(self.tabController.activeTabDocument.blankDocument)
	{
		return;
	}

	if([[%c(ActionPanel) class] instancesRespondToSelector:@selector(initWithTabDocument:activityDelegate:)])
	{
		self.fastActionPanel = [[%c(ActionPanel) alloc] initWithTabDocument:self.tabController.activeTabDocument activityDelegate:self];
	}
	else
	{
		self.fastActionPanel = [[%c(ActionPanel) alloc] initWithTabDocument:self.tabController.activeTabDocument sharingURL:[self.tabController.activeTabDocument URLForSharing] activityDelegate:self];
	}

	[self _presentModalViewController:self.fastActionPanel fromButtonIdentifier:0 completion:nil];

	dispatch_async(dispatch_get_main_queue(), ^(void)
	{
		UIApplicationExtensionActivity* activity = getExtensionActivityForBundleIdentifier(self.fastActionPanel, @"com.agilebits.onepassword-ios.extension");
		if(activity)
		{
			[self.fastActionPanel _performActivity:activity];
		}
	});
}

%end

%ctor
{
	resourceBundle = [NSBundle bundleWithPath:@"/Library/Application Support/FastSafariPW.bundle"];

	if(!resourceBundle)
	{
		resourceBundle = [NSBundle bundleWithPath:@"/Applications/MobileSafari.app/FastSafariPW.bundle"];	//Guy that offered the bounty had a sandbox issue with Substrate on Meridian, this is why this is needed
	}

	if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/SafariPlus.dylib"])
	{
		dlopen("/Library/MobileSubstrate/DynamicLibraries/SafariPlus.dylib", RTLD_NOW);
	}

	preferences = [[HBPreferences alloc] initWithIdentifier:@"com.opa334.fastsafaripwprefs"];

	[preferences registerBool:&onePasswordButtonEnabled default:YES forKey:@"onePasswordButtonEnabled"];
	[preferences registerBool:&lastPassButtonEnabled default:YES forKey:@"lastPassButtonEnabled"];

	%init();
}
