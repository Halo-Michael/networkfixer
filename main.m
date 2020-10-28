#import <Foundation/Foundation.h>

#ifndef kCFCoreFoundationVersionNumber_iOS_11_0
#   define kCFCoreFoundationVersionNumber_iOS_11_0 1443.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_12_0
#   define kCFCoreFoundationVersionNumber_iOS_12_0 1535.12
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_13_0
#   define kCFCoreFoundationVersionNumber_iOS_13_0 1665.15
#endif

@interface AppWirelessDataUsageManager : NSObject

+ (void)setAppCellularDataEnabled:(id)arg1 forBundleIdentifier:(id)arg2 completionHandler:(id /* block */)arg3;
+ (void)setAppWirelessDataOption:(id)arg1 forBundleIdentifier:(id)arg2 completionHandler:(id /* block */)arg3;

@end

@interface PSAppDataUsagePolicyCache : NSObject

+ (id)sharedInstance;
- (bool)setUsagePoliciesForBundle:(id)arg1 cellular:(bool)arg2 wifi:(bool)arg3;

@end

void usage() {
    printf("Usage:\tnetworkfixer [com.example.bundleid]\n");
    printf("\t-h\tPrint this help.\n");
}

int main(int argc, const char **argv, const char **envp) {
    if (argc == 1) {
        usage();
        return 1;
    }

    NSMutableArray *args = [NSMutableArray array];
    for (int i = 1; i < argc; i++) {
        [args addObject:[[NSString alloc] initWithUTF8String:argv[i]]];
    }
    if ([args containsObject:@"-h"]) {
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

    for (NSString *bundleID in args) {
        printf("Enable network for %s ...\n", [bundleID UTF8String]);
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_12_0) {
            if ([[NSClassFromString(@"PSAppDataUsagePolicyCache") sharedInstance] setUsagePoliciesForBundle:bundleID cellular:true wifi:true]) {
                printf("Enable network for %s successfully.\n", [bundleID UTF8String]);
            } else {
                printf("Fail to enable network for %s.\n", [bundleID UTF8String]);
            }
        } else {
            [NSClassFromString(@"AppWirelessDataUsageManager") setAppWirelessDataOption:[NSNumber numberWithInt:3] forBundleIdentifier:bundleID completionHandler:nil];
            [NSClassFromString(@"AppWirelessDataUsageManager") setAppCellularDataEnabled:[NSNumber numberWithInt:1] forBundleIdentifier:bundleID completionHandler:nil];
            printf("Enable network for %s successfully.\n", [bundleID UTF8String]);
        }
    }
	return 0;
}
