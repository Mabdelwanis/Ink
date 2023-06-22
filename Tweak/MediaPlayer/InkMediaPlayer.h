#import <substrate.h>
#import <UIKit/UIKit.h>
#import <MediaRemote/MediaRemote.h>

@interface _UIBackdropViewSettingsATVMediumDark : NSObject
@end

@interface _UIBackdropViewSettings : NSObject
@end

@interface _UIBackdropView : UIView
- (instancetype)initWithFrame:(CGRect)frame autosizesToFitSuperview:(BOOL)autosizes settings:(_UIBackdropViewSettings *)settings;
@end

@interface CSCoverSheetView : UIView
@property(nonatomic, retain)UIImageView* inkArtworkBackgroundImageView;
@property(nonatomic, retain)UIView* inkArtworkContainerView;
@property(nonatomic, retain)UIImageView* inkArtworkImageView;
@end

@interface CSAdjunctItemView : UIView
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (void)setNowPlayingInfo:(NSDictionary *)arg1;
@end

@interface SpringBoard : UIApplication
@end
