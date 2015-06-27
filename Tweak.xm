@interface CKComposition : NSObject

@property (nonatomic, copy) NSAttributedString *text;
@property (getter=isTextOnly, nonatomic, readonly) BOOL textOnly;

- (CKComposition*)compositionByAppendingText:(NSAttributedString*)text;

@end

@interface CKMessageEntryView : NSObject

@property (nonatomic, retain) CKComposition *composition;

- (void)updateEntryView;

@end

@interface CKInlineReplyViewController : NSObject

@property(retain, nonatomic) CKMessageEntryView *entryView;

- (void)sendMessage;
- (void)messageEntryViewDidChange:(CKMessageEntryView*)entryView;
- (void)messageEntryViewSendButtonHit:(CKMessageEntryView*)entryView;

@end

static const CFStringRef DOMAIN_NAME = CFSTR("com.mohammadag.multiplereturntosender");
static NSString * const KEY_RETURN_COUNT = @"return_count";

static int returnCount = 3;

static int getIntPreference(NSDictionary *dictionary, NSString *key, int defaultValue) {
    id value = [dictionary objectForKey:key];
    if (value)
        return [value intValue];
    
    return defaultValue;
}

static int getNewLineCharacterCount(NSString *string) {
    if (!string)
        return 0;
    
    int count = 0;
    for (int i = 0; i < string.length; i++) {
        unichar character = [string characterAtIndex:[string length]-(i+1)];
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:character]) {
            count++;
        } else {
            break;
        }
    }
    return count;
}


static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    CFPreferencesAppSynchronize(DOMAIN_NAME);
    
    CFArrayRef keyList = CFPreferencesCopyKeyList(DOMAIN_NAME, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (!keyList) {
        NSLog(@"There's been an error getting the key list!");
        return;
    }
    NSDictionary* preferences = (NSDictionary *) CFPreferencesCopyMultiple(keyList, DOMAIN_NAME, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (!preferences) {
        NSLog(@"There's been an error getting the preferences dictionary!");
    }
    
    returnCount = getIntPreference(preferences, KEY_RETURN_COUNT, 3);
    if (returnCount <= 0)
        returnCount = 1;
    
    CFRelease(keyList);
    
    [preferences release];
}

%group MessagesNotificationViewService

%hook CKInlineReplyViewController

- (void)messageEntryViewDidChange:(CKMessageEntryView*)entryView {
    %orig;
    if (entryView.composition.text) {
        NSString *message = entryView.composition.text.string;
        int count = getNewLineCharacterCount(message);
        if (count >= returnCount) {
            NSString *cutString = [message substringToIndex:message.length-count];
            CKComposition *composition = [[%c(CKComposition) alloc] compositionByAppendingText:[[NSAttributedString alloc] initWithString:cutString]];
            self.entryView.composition = composition;
            [self.entryView updateEntryView];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self messageEntryViewSendButtonHit:self.entryView];
            });
        }
    }
}

%end

%end

// Thanks to Replock (https://github.com/shinvou/Replock), couldn't figure
// out how to hook this without it.
%ctor {
    @autoreleasepool {
        if ([[[NSClassFromString(@"NSProcessInfo") processInfo] processName] isEqualToString:@"MessagesNotificationViewService"]) {
            notificationCallback(NULL, NULL, NULL, NULL, NULL);
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef) @"com.mohammadag.multiplereturntosender/preferences_changed", NULL, CFNotificationSuspensionBehaviorCoalesce);
            %init(MessagesNotificationViewService);
        }
    }
}