@interface SBIcon : NSObject

typedef NS_ENUM(NSInteger, SBIconLocation) {
    SBIconLocationHomeScreen = 0,
    SBIconLocationDock       = 1,
    SBIconLocationSwitcher   = 2
};

- (NSString *)leafIdentifier;
- (void)launchFromLocation:(SBIconLocation)location;

@end

@interface SBIconView : UIView

- (SBIcon *)icon; //Is actually a property, but that's not relevant.

@end

@interface SBIconModel : NSObject

- (SBIcon *)expectedIconForDisplayIdentifier:(NSString *)displayID;

@end

@interface SBIconController : NSObject

+ (instancetype)sharedInstance;
- (SBIconModel *)model;

@end

%hook SBIconView

- (void)longPressTimerFired{
	@autoreleasepool{
		if([[[self icon] leafIdentifier] isEqualToString:@"com.apple.MobileSMS"]){
			[[(SBIconModel *)[[%c(SBIconController) sharedInstance] model] expectedIconForDisplayIdentifier:@"ph.telegra.Telegraph"] launchFromLocation:SBIconLocationHomeScreen];
		}else %orig();
	}
}

%end

//The following code adds support for Badger on iOS 7 showing notifications for Telegram wherever Messages is included.
%hook BFBadgerRootViewController

- (id)initWithIconViewFrame:(CGRect)arg1 badgeFrame:(CGRect)arg2 sections:(NSArray *)arg3 inverted:(BOOL)arg4{
     if([arg3 containsObject:@"com.apple.MobileSMS"]){
          NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:arg3];
          [newArray insertObject:@"ph.telegra.Telegraph" atIndex:[newArray indexOfObject:@"com.apple.MobileSMS"]];
          id ret = %orig(arg1, arg2, newArray, arg4);
          [newArray release];
          return ret;
     }
     else return %orig(arg1, arg2, arg3, arg4);
}
%end

//No need to show both icons; this code will hide the Telegram icon.
//Also good documentation for libhide (and one of the main reasons I'm open-sourcing this.)

%ctor{
	@autoreleasepool{
		void *libhide = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
		if(libhide!=NULL){
			BOOL (*hideIcon)(NSString *) = reinterpret_cast<BOOL (*)(NSString *)>(dlsym(libhide, "HideIconViaDisplayId"));
			if(hideIcon!=NULL){
				hideIcon(@"ph.telegra.Telegraph");
			}
		}
	}
}
