#import <Preferences/Preferences.h>

@interface MultipleReturnToSenderPrefsListController: PSListController {
}
@end

@implementation MultipleReturnToSenderPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"MultipleReturnToSenderPrefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
