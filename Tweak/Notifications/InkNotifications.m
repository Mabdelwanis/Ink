#import "InkNotifications.h"

#pragma mark - CSCombinedListViewController class hooks

static UIEdgeInsets (* orig_CSCombinedListViewController__listViewDefaultContentInsets)(CSCombinedListViewController* self, SEL _cmd);
static UIEdgeInsets override_CSCombinedListViewController__listViewDefaultContentInsets(CSCombinedListViewController* self, SEL _cmd) {
    UIEdgeInsets originalInsets = orig_CSCombinedListViewController__listViewDefaultContentInsets(self, _cmd);
    originalInsets.top += 315;
    return originalInsets;
}

#pragma mark

static CSFocusActivityView* (* orig_CSFocusActivityView_initWithFrame)(CSFocusActivityView* self, SEL _cmd, CGRect frame);
static CSFocusActivityView* override_CSFocusActivityView_initWithFrame(CSFocusActivityView* self, SEL _cmd, CGRect frame) {
    return nil;
}

#pragma mark - Constructor

__attribute((constructor)) static void initialize() {
    MSHookMessageEx(objc_getClass("CSCombinedListViewController"), @selector(_listViewDefaultContentInsets), (IMP)&override_CSCombinedListViewController__listViewDefaultContentInsets, (IMP *)&orig_CSCombinedListViewController__listViewDefaultContentInsets);
    MSHookMessageEx(objc_getClass("CSFocusActivityView"), @selector(initWithFrame:), (IMP)&override_CSFocusActivityView_initWithFrame, (IMP *)&orig_CSFocusActivityView_initWithFrame);
}
