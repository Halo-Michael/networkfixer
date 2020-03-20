#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <objc/message.h>

#ifndef kCFCoreFoundationVersionNumber_iOS_12_0
#   define kCFCoreFoundationVersionNumber_iOS_12_0 1535.12
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_13_0
#   define kCFCoreFoundationVersionNumber_iOS_13_0 1665.15
#endif

void usage() {
    puts("usage: networkfixer com.example.bundleid");
}


int main(int argc, const char **argv, const char **envp) {
    if (argc == 1) {
        usage();
        return 1;
    }

    NSBundle *bundle;
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_13_0) {
        bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SettingsCellular.framework"];
    } else if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_12_0) {
        bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Preferences.framework"];
    } else {
        printf("iOS version too low, 12.0 or higher required\n");
        return 1;
    }
    
    if (![bundle load]) {
        printf("Load framework failed.\n");
        return -1;
    }

    Class PSAppDataUsagePolicyCacheClass = NSClassFromString(@"PSAppDataUsagePolicyCache");
    id cacheInstance = [PSAppDataUsagePolicyCacheClass valueForKey:@"sharedInstance"];
    if (!cacheInstance) {
        printf("Instance not found.\n");
        return -1;
    }

    NSString *exampleBundleid;
    for (int i=1; i<argc; i++) {
        exampleBundleid = [NSString stringWithUTF8String:argv[i]];
        if (((BOOL (*)(id, SEL, NSString *, BOOL, BOOL))objc_msgSend)(cacheInstance, NSSelectorFromString(@"setUsagePoliciesForBundle:cellular:wifi:"), exampleBundleid, true, true)) {
            printf("Enable network for %s successfully.\n", argv[i]);
        } else {
            printf("Fail to enable network for %s.\n", argv[i]);
        }
    }
	return 0;
}

