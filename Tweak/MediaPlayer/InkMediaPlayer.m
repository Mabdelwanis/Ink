#import "InkMediaPlayer.h"

CSCoverSheetView* coverSheetView;

// TODO: drop shadow
// TODO: different blur?
// TODO: floating player
// TODO: animate the background artwork
// TODO: animate player appearance and disappearance

#pragma mark - CSCoverSheetView class properties

static UIImageView* inkArtworkBackgroundImageView(CSCoverSheetView* self, SEL _cmd) {
    return (UIImageView *)objc_getAssociatedObject(self, (void *)inkArtworkBackgroundImageView);
};
static void setInkArtworkBackgroundImageView(CSCoverSheetView* self, SEL _cmd, UIImageView* rawValue) {
    objc_setAssociatedObject(self, (void *)inkArtworkBackgroundImageView, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static UIView* inkArtworkContainerView(CSCoverSheetView* self, SEL _cmd) {
    return (UIView *)objc_getAssociatedObject(self, (void *)inkArtworkContainerView);
};
static void setInkArtworkContainerView(CSCoverSheetView* self, SEL _cmd, UIView* rawValue) {
    objc_setAssociatedObject(self, (void *)inkArtworkContainerView, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static UIImageView* inkArtworkImageView(CSCoverSheetView* self, SEL _cmd) {
    return (UIImageView *)objc_getAssociatedObject(self, (void *)inkArtworkImageView);
};
static void setInkArtworkImageView(CSCoverSheetView* self, SEL _cmd, UIImageView* rawValue) {
    objc_setAssociatedObject(self, (void *)inkArtworkImageView, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - CSCoverSheetView class hooks

static void (* orig_CSCoverSheetView_initWithFrame)(CSCoverSheetView* self, SEL _cmd, CGRect frame);
static void override_CSCoverSheetView_initWithFrame(CSCoverSheetView* self, SEL _cmd, CGRect frame) {
    orig_CSCoverSheetView_initWithFrame(self, _cmd, frame);

    coverSheetView = self;


    [self setInkArtworkBackgroundImageView:[[UIImageView alloc] initWithFrame:[self bounds]]];
	[[self inkArtworkBackgroundImageView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[[self inkArtworkBackgroundImageView] setContentMode:UIViewContentModeScaleAspectFill];
    [[self inkArtworkBackgroundImageView] setHidden:YES];
	[self insertSubview:[self inkArtworkBackgroundImageView] atIndex:0];


    _UIBackdropViewSettings* settings = (_UIBackdropViewSettings *)[[objc_getClass("_UIBackdropViewSettingsATVMediumDark") alloc] init];
    _UIBackdropView* backdropView = [[objc_getClass("_UIBackdropView") alloc] initWithFrame:[[self inkArtworkBackgroundImageView] bounds] autosizesToFitSuperview:YES settings:settings];
    [[self inkArtworkBackgroundImageView] addSubview:backdropView];


    [self setInkArtworkContainerView:[[UIView alloc] init]];
    [[self inkArtworkBackgroundImageView] addSubview:[self inkArtworkContainerView]];

    [[self inkArtworkContainerView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [[[self inkArtworkContainerView] centerXAnchor] constraintEqualToAnchor:[[self inkArtworkBackgroundImageView] centerXAnchor]],
        [[[self inkArtworkContainerView] centerYAnchor] constraintEqualToAnchor:[[self inkArtworkBackgroundImageView] centerYAnchor] constant:-16],
        [[[self inkArtworkContainerView] widthAnchor] constraintEqualToConstant:310],
        [[[self inkArtworkContainerView] heightAnchor] constraintEqualToConstant:310]
    ]];


    [self setInkArtworkImageView:[[UIImageView alloc] init]];
    [[self inkArtworkImageView] setClipsToBounds:YES];
    [[[self inkArtworkImageView] layer] setCornerRadius:8];
    [[self inkArtworkContainerView] addSubview:[self inkArtworkImageView]];

    [[self inkArtworkImageView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [[[self inkArtworkImageView] topAnchor] constraintEqualToAnchor:[[self inkArtworkContainerView] topAnchor]],
        [[[self inkArtworkImageView] trailingAnchor] constraintEqualToAnchor:[[self inkArtworkContainerView] trailingAnchor]],
        [[[self inkArtworkImageView] bottomAnchor] constraintEqualToAnchor:[[self inkArtworkContainerView] bottomAnchor]],
        [[[self inkArtworkImageView] leadingAnchor] constraintEqualToAnchor:[[self inkArtworkContainerView] leadingAnchor]]
    ]];
}

#pragma mark - CSAdjunctItemView class hooks

static void (* orig_CSAdjunctItemView_removeFromSuperview)(CSAdjunctItemView* self, SEL _cmd);
static void override_CSAdjunctItemView_removeFromSuperview(CSAdjunctItemView* self, SEL _cmd) {
    orig_CSAdjunctItemView_removeFromSuperview(self, _cmd);
    // hide the artwork when the player is dismissed by inactivity
    [[coverSheetView inkArtworkBackgroundImageView] setHidden:YES];
}

#pragma mark - SBMediaController class hooks

static void (* orig_SBMediaController_setNowPlayingInfo)(SBMediaController* self, SEL _cmd, NSDictionary* info);
static void override_SBMediaController_setNowPlayingInfo(SBMediaController* self, SEL _cmd, NSDictionary* info) {
    orig_SBMediaController_setNowPlayingInfo(self, _cmd, info);

    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        if (information) {
            NSDictionary* dict = (__bridge NSDictionary *)information;
            if (dict) {
                UIImage* artwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
                [[coverSheetView inkArtworkBackgroundImageView] setImage:artwork];
                [[coverSheetView inkArtworkImageView] setImage:artwork];
                [[coverSheetView inkArtworkBackgroundImageView] setHidden:NO];
            }
        } else {
            [[coverSheetView inkArtworkBackgroundImageView] setHidden:YES];
        }
  	});
}

#pragma mark - SpringBoard class hooks

static void (* orig_SpringBoard_applicationDidFinishLaunching)(SpringBoard* self, SEL _cmd, BOOL didFinishLaunching);
static void override_SpringBoard_applicationDidFinishLaunching(SpringBoard* self, SEL _cmd, BOOL didFinishLaunching) {
    orig_SpringBoard_applicationDidFinishLaunching(self, _cmd, didFinishLaunching);
    // fix the artwork not showing after a respring
    [[objc_getClass("SBMediaController") sharedInstance] setNowPlayingInfo:nil];
}

#pragma mark - Constructor

__attribute((constructor)) static void initialize() {
    // properties
    class_addProperty(objc_getClass("CSCoverSheetView"), "inkArtworkBackgroundImageView", (objc_property_attribute_t[]){{"T", "@\"UIImageView\""}, {"N", ""}, {"V", "_inkArtworkBackgroundImageView"}}, 3);
    class_addMethod(objc_getClass("CSCoverSheetView"), @selector(inkArtworkBackgroundImageView), (IMP)&inkArtworkBackgroundImageView, "@@:");
    class_addMethod(objc_getClass("CSCoverSheetView"), @selector(setInkArtworkBackgroundImageView:), (IMP)&setInkArtworkBackgroundImageView, "v@:@");

    class_addProperty(objc_getClass("CSCoverSheetView"), "inkArtworkContainerView", (objc_property_attribute_t[]){{"T", "@\"UIView\""}, {"N", ""}, {"V", "_inkArtworkContainerView"}}, 3);
    class_addMethod(objc_getClass("CSCoverSheetView"), @selector(inkArtworkContainerView), (IMP)&inkArtworkContainerView, "@@:");
    class_addMethod(objc_getClass("CSCoverSheetView"), @selector(setInkArtworkContainerView:), (IMP)&setInkArtworkContainerView, "v@:@");

    class_addProperty(objc_getClass("CSCoverSheetView"), "inkArtworkImageView", (objc_property_attribute_t[]){{"T", "@\"UIImageView\""}, {"N", ""}, {"V", "_inkArtworkImageView"}}, 3);
    class_addMethod(objc_getClass("CSCoverSheetView"), @selector(inkArtworkImageView), (IMP)&inkArtworkImageView, "@@:");
    class_addMethod(objc_getClass("CSCoverSheetView"), @selector(setInkArtworkImageView:), (IMP)&setInkArtworkImageView, "v@:@");

    // hooks
    MSHookMessageEx(objc_getClass("CSCoverSheetView"), @selector(initWithFrame:), (IMP)&override_CSCoverSheetView_initWithFrame, (IMP *)&orig_CSCoverSheetView_initWithFrame);
    MSHookMessageEx(objc_getClass("CSAdjunctItemView"), @selector(removeFromSuperview), (IMP)&override_CSAdjunctItemView_removeFromSuperview, (IMP *)&orig_CSAdjunctItemView_removeFromSuperview);
    MSHookMessageEx(objc_getClass("SBMediaController"), @selector(setNowPlayingInfo:), (IMP)&override_SBMediaController_setNowPlayingInfo, (IMP *)&orig_SBMediaController_setNowPlayingInfo);
    MSHookMessageEx(objc_getClass("SpringBoard"), @selector(applicationDidFinishLaunching:), (IMP)&override_SpringBoard_applicationDidFinishLaunching, (IMP *)&orig_SpringBoard_applicationDidFinishLaunching);
}
