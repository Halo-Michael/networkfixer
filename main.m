#include <objc/message.h>

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
    printf("\t-h\t\t\tPrint this help.\n");
}

int main(int argc, const char **argv, const char **envp) {
    if (argc == 1) {
        usage();
        return 1;
    }
    
    NSMutableArray *args = [[[NSProcessInfo processInfo] arguments] mutableCopy];
    [args removeObjectAtIndex:0];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF beginswith '-'"];
    NSArray *dashedArgs = [args filteredArrayUsingPredicate:pred];
    for (NSString *argument in dashedArgs) {
        if ( ![argument caseInsensitiveCompare:@"-h"] ) {
            usage();
            return 1;
        }
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

    for (NSString *exampleBundleid in args) {
        printf("Enable network for %s ...\n", [exampleBundleid UTF8String]);
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_12_0) {
            Class PSAppDataUsagePolicyCacheClass = NSClassFromString(@"PSAppDataUsagePolicyCache");
            id cacheInstance = [PSAppDataUsagePolicyCacheClass valueForKey:@"sharedInstance"];

            BOOL result = ((BOOL (*)(id, SEL, NSString *, BOOL, BOOL))objc_msgSend)(cacheInstance, NSSelectorFromString(@"setUsagePoliciesForBundle:cellular:wifi:"), exampleBundleid, true, true);
            if (!result) {
                printf("Fail to enable network for %s.\n", [exampleBundleid UTF8String]);
            } else {
                printf("Enable network for %s successfully.\n", [exampleBundleid UTF8String]);
            }
        } else {
            Class AppWirelessDataUsageManager = NSClassFromString(@"AppWirelessDataUsageManager");
            BOOL result = ((BOOL (*)(Class, SEL, NSNumber *, NSString *, id))objc_msgSend)(AppWirelessDataUsageManager, NSSelectorFromString(@"setAppWirelessDataOption:forBundleIdentifier:completionHandler:"), [NSNumber numberWithInt:3], exampleBundleid, nil);
            if (!result) {
                printf("Fail to enable network for %s.\n", [exampleBundleid UTF8String]);
                continue;
            }
            result = ((BOOL (*)(Class, SEL, NSNumber *, NSString *, id))objc_msgSend)(AppWirelessDataUsageManager, NSSelectorFromString(@"setAppCellularDataEnabled:forBundleIdentifier:completionHandler:"), [NSNumber numberWithInt:1], exampleBundleid, nil);
            if (!result) {
                printf("Fail to enable network for %s.\n", [exampleBundleid UTF8String]);
            } else {
                printf("Enable network for %s successfully.\n", [exampleBundleid UTF8String]);
            }
        }
    }
	return 0;
}
