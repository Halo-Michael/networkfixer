#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <objc/message.h>

@interface AppWirelessDataUsageManager
+ (void)setAppCellularDataEnabled:(id)arg1 forBundleIdentifier:(id)arg2 completionHandler:(id)arg3;
+ (void)setAppWirelessDataOption:(id)arg1 forBundleIdentifier:(id)arg2 completionHandler:(id)arg3;
@end

@interface PSAppDataUsagePolicyCache
+ (id)sharedInstance;
- (bool)setUsagePoliciesForBundle:(id)arg1 cellular:(bool)arg2 wifi:(bool)arg3;
@end

#ifndef kCFCoreFoundationVersionNumber_iOS_11_0
#   define kCFCoreFoundationVersionNumber_iOS_11_0 1443.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_12_0
#   define kCFCoreFoundationVersionNumber_iOS_12_0 1535.12
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_13_0
#   define kCFCoreFoundationVersionNumber_iOS_13_0 1665.15
#endif

void usage() {
    printf("Usage:\tnetworkfixer [com.example.bundleid]\n");
}

int main(int argc, const char **argv, const char **envp) {
    if (argc == 1) {
        usage();
        return 1;
    }

    NSBundle *bundle;
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_13_0) {
        bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SettingsCellular.framework"];
    } else if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_11_0) {
        bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Preferences.framework"];
    }

    if (![bundle load]) {
        printf("iOS version too low, 11.0 or higher required\n");
        return 1;
    }

    NSString *exampleBundleid;
    for (int i=1; i<argc; i++) {
        exampleBundleid = [NSString stringWithUTF8String:argv[i]];
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_12_0) {
            [[NSClassFromString(@"PSAppDataUsagePolicyCache") sharedInstance] setUsagePoliciesForBundle:exampleBundleid cellular:true wifi:true];
        } else {
            [NSClassFromString(@"AppWirelessDataUsageManager") setAppWirelessDataOption:[NSNumber numberWithInt:3] forBundleIdentifier:exampleBundleid completionHandler:nil];
            [NSClassFromString(@"AppWirelessDataUsageManager") setAppCellularDataEnabled:[NSNumber numberWithInt:1] forBundleIdentifier:exampleBundleid completionHandler:nil];
        }
        printf("Enable network for %s ...\n", argv[i]);
    }
	return 0;
}

