#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIGraphics.h>

//#import <objc/runtime.h>
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <notify.h>
#import <Foundation/NSTask.h>

%class SBAwayController
%class SBApplication
%class SBUIController
%class TPLCDTextView

#import <sys/types.h>
#import <sys/stat.h>
@interface SBAwayView : UIView
CGPoint startLocation;
float endLocation;
NSMutableArray *movableViews;

UIImageView *cameraImageView;
@end



static BOOL logStuff = FALSE;
static UIImageView *grabbyView;
static UIView *dateView;
static UIView *lockBar;
static UIView *chargingView;
static UIView *albumArtView;
static UIView *lsHolder;
#define prefsPlist @"/var/mobile/Library/Preferences/com.whited00r.wd7lockscreen.plist"
//static UILabel *slideTitle;
static BOOL wasGrabby = FALSE;
static BOOL isWhited00r = FALSE;
static BOOL isiPhone = FALSE;
static BOOL hasBruce = FALSE;
static BOOL bouncy = FALSE;
static BOOL shouldSlide = TRUE;
static BOOL fadeSlide = TRUE;
static BOOL isSlidingLockscreen = FALSE;
static BOOL dontSwipeThis;
static NSString *appID;
static void loadPrefs();

//Smart and clean.

static UIView *wdInitView;


	/*
__attribute__((constructor))
static void initialize() {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if([[NSFileManager defaultManager]fileExistsAtPath:prefsPlist]){
		NSDictionary *prefs=[[NSDictionary alloc]initWithContentsOfFile:prefsPlist];

		bouncy=[[prefs objectForKey:@"Bouncy"]boolValue];
		fadeSlide=[[prefs objectForKey:@"FadeSlide"]boolValue];
		appID = [[prefs objectForKey:@"appID"] copy];
		////if(logStuff) NSLog(@"AppID: %@", [prefs objectForKey:@"appID"]);
		[prefs release];



	}else{
		NSMutableDictionary *prefs=[[NSMutableDictionary alloc]init];
		[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"Bouncy"];
		[prefs setObject:[NSNumber numberWithBool:TRUE] forKey:@"FadeSlide"];
		[prefs setObject:@"com.apple.mobileslideshow" forKey:@"appID"];
		[prefs writeToFile:prefsPlist atomically:YES];
		[prefs release];
	}
	

	[pool drain];
	}

*/






static void loadPrefs(){

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if([[NSFileManager defaultManager]fileExistsAtPath:prefsPlist]){
		NSDictionary *prefs=[[NSDictionary alloc]initWithContentsOfFile:prefsPlist];

		bouncy=[[prefs objectForKey:@"Bouncy"]boolValue];
		fadeSlide=[[prefs objectForKey:@"FadeSlide"]boolValue];
		logStuff=[[prefs objectForKey:@"logStuff"]boolValue];
		appID = [[prefs objectForKey:@"appID"] copy];
		////if(logStuff) NSLog(@"AppID: %@", [prefs objectForKey:@"appID"]);
		[prefs release];



	}else{
		NSMutableDictionary *prefs=[[NSMutableDictionary alloc]init];
		[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"Bouncy"];
		[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"logStuff"];
		[prefs setObject:[NSNumber numberWithBool:TRUE] forKey:@"FadeSlide"];
		[prefs setObject:@"com.apple.mobileslideshow" forKey:@"appID"];
		[prefs writeToFile:prefsPlist atomically:YES];
		[prefs release];
	}
if(logStuff) NSLog(@"WD7Lockscreen: Loaded up preferences :)");
if(!isWhited00r){
if(logStuff) NSLog(@"WD7Lockscreen: checking license ;)");
NSFileManager *fMgr = [NSFileManager defaultManager]; 


NSString *firstLevel = [NSString stringWithFormat:@"%@-CantCrackDis",[[UIDevice currentDevice] uniqueIdentifier]];
NSString *arguments = [NSString stringWithFormat:@"echo %@ | openssl dgst -sha1 -hmac \"PlsNo\"", firstLevel];
NSPipe *resultPipe = [[NSPipe alloc] init];
NSTask *taskCrypt = [[NSTask alloc] init];
NSArray *argsCrypt = [NSArray arrayWithObjects:@"-c", arguments, nil];
[taskCrypt setStandardOutput:resultPipe];

[taskCrypt setLaunchPath:@"/bin/bash"];
[taskCrypt setArguments:argsCrypt];
[taskCrypt launch];    // Run
[taskCrypt waitUntilExit]; // Wait
NSData *result = [[resultPipe fileHandleForReading] readDataToEndOfFile];
NSString *licenseKey = [[NSString alloc] initWithData: result
                               encoding: NSUTF8StringEncoding];

licenseKey = [licenseKey substringToIndex:[licenseKey length] - 1];

NSString *magicFilePath = [NSString stringWithFormat:@"/var/mobile/Whited00r/%@", licenseKey];
////NSLog(magicFilePath);

if ([fMgr fileExistsAtPath:magicFilePath] && [fMgr fileExistsAtPath:@"/var/lib/dpkg/info/com.whited00r.whited00r.list"]) { 
////if(logStuff) NSLog(@"LicenceKey isWhited00r: /var/mobile/Whited00r/%@", licenseKey);
if(logStuff) NSLog(@"WD7Lockscreen: valid license found");
isWhited00r = TRUE;
}
[taskCrypt release];
//[result release];
//[licenseKey release];
[resultPipe release];
if(logStuff) NSLog(@"WD7Lockscreen: Completed license code... draining autorelease pool...");
}
	[pool drain];
	
}


%hook SBAwayController

-(void)lock{
	%orig;
	if(logStuff) NSLog(@"WD7Lockscreen: settings isSlidingLockscreen to 'FALSE'");
	isSlidingLockscreen = FALSE;
}

-(void)undimScreen{
%orig;
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-undimScreen called");
if(dontSwipeThis){
if(logStuff) NSLog(@"WD7Lockscreen: dontSwipeThis was 'TRUE', so returning on SBAwayController-undimScreen");
	return;
}

//if(isSlidingLockscreen) return;
if(![[self valueForKey:@"awayView"] isShowingDeviceLock] && ![self isSyncing]){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-undimScreen is not syncing and is showing the device lock, so resetting views for undim");
if(isiPhone){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-undimScreen isiPhone is 'TRUE', so setting lockbar apropriately");
if(lockBar) lockBar.frame = CGRectMake(lockBar.frame.origin.x, 460 - lockBar.frame.size.height, 260, lockBar.frame.size.height);
}
else{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-undimScreen isiPhone is 'FALSE', so setting lockbar apropriately");
if(lockBar) lockBar.frame = CGRectMake(lockBar.frame.origin.x, 460 - lockBar.frame.size.height, 260, lockBar.frame.size.height); //if(lockBar) lockBar.frame = CGRectMake(lockBar.frame.origin.x, 460 - lockBar.frame.size.height, 320, lockBar.frame.size.height);
}
if([self isLocked]){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-undimScreen isLocked is 'TRUE', so changing movableViews alphas to 1.");
	if(movableViews){
		for(UIView *view in movableViews){
			if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-undimScreen movableView: %@ alpha being set to 1.0", view);
			view.alpha = 1.0;
			if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-undimScreen movableView: %@ alpha was set to 1.0", view);
		}
	}
}

if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-undimScreen starting animations for resettng the views frames");
[UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

   if(dateView) dateView.frame = CGRectMake(0, 0, 320, dateView.frame.size.width);
   if(lockBar) lockBar.frame = CGRectMake(0, lockBar.frame.origin.y, lockBar.frame.size.width, lockBar.frame.size.height);
   if(albumArtView) albumArtView.frame = CGRectMake(50, albumArtView.frame.origin.y, albumArtView.frame.size.width, albumArtView.frame.size.height);
    if(isiPhone){
   if(grabbyView) grabbyView.frame = CGRectMake(280, grabbyView.frame.origin.y, grabbyView.frame.size.width, grabbyView.frame.size.height);
    }
    if(hasBruce){
    if(lsHolder) lsHolder.frame = CGRectMake(0, lsHolder.frame.origin.y, lsHolder.frame.size.width, lsHolder.frame.size.height);
    }
   if(chargingView) chargingView.frame = CGRectMake(25, chargingView.frame.origin.y, 320, chargingView.frame.size.height);
    //dateView.alpha = 1.0;
    [UIView commitAnimations];

if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-undimScreen finished all the code for undimScreen :)");
}


}

-(void)_unlockWithSound:(BOOL)sound{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound called, injecting code");
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound removing all animations from awayView");
[[self valueForKey:@"awayView"] removeAllAnimationsFromSubviews];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound removed all animations from awayView");
if(movableViews){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound movableViews existed, running code for that");
[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];

    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
 for(UIView *subview in movableViews){
 if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound setting movableViews view: %@ alpha to 0.0", subview);
subview.alpha = 0.0;
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound set movableViews view: %@ alpha to 0.0", subview);
}
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound setting all views to offscreen");
    if(dateView) dateView.frame = CGRectMake(320, 0, 320, dateView.frame.size.height);
    if(lockBar) lockBar.frame = CGRectMake(320, lockBar.frame.origin.y, lockBar.frame.size.width, lockBar.frame.size.height);
    if(isiPhone){
    if(grabbyView) grabbyView.frame = CGRectMake(500, grabbyView.frame.origin.y, grabbyView.frame.size.width, grabbyView.frame.size.height);
    }
    if(hasBruce){
    if(lsHolder) lsHolder.frame = CGRectMake(320, lsHolder.frame.origin.y, lsHolder.frame.size.width, lsHolder.frame.size.height);
    }
    if(chargingView) chargingView.frame = CGRectMake(320, chargingView.frame.origin.y, 320, chargingView.frame.size.height);
    if(albumArtView) albumArtView.frame = CGRectMake(370, albumArtView.frame.origin.y, albumArtView.frame.size.width, albumArtView.frame.size.height);
   if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound done setting all views to offscreen");
    [UIView commitAnimations];
}
if(movableViews){
	if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound releasing movableViews");
[movableViews release];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound released movableViews");
}
//if(lockBar) lockBar.frame = CGRectMake(lockBar.frame.origin.x, lockBar.frame.origin.y, 320, lockBar.frame.size.height);
/*
if(wdKeypad){
	[wdKeypad removeFromSuperView];
}
*/
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound calling original code");
%orig;
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController_unlockWithSound setting shouldSlide to 'TRUE'");
shouldSlide = TRUE;


}


-(void)didAnimateLockKeypadIn{
//if(lockBar) lockBar.frame = CGRectMake(lockBar.frame.origin.x, lockBar.frame.origin.y, 260, lockBar.frame.size.height);
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-didAnimateLockKeypadIn setting shouldSlide to 'TRUE'");
shouldSlide = FALSE;
%orig;
}

-(void)didAnimateLockKeypadOut{
//if(lockBar) lockBar.frame = CGRectMake(lockBar.frame.origin.x, lockBar.frame.origin.y, 260, lockBar.frame.size.height);
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayController-didAnimateLockKeypadOut setting shouldSlide to 'TRUE'");
shouldSlide = TRUE;
%orig;
}
%end

//Gotta change that font size eh?
/*
%hook SBAwayDateView

-(id)initWithFrame:(CGRect)frame{
self = %orig;
if(self){
//[MSHookIvar<TPLCDTextView *>(self,"_titleLabel") setMinimumFontSize:50];
//[MSHookIvar<TPLCDTextView *>(self,"_timeLabel") setMinimumFontSize:50];
}

return self;


}

%end

*/

//Sliiiiideeeee :D
%hook SBAwayView
-(id)initWithFrame:(CGRect)frame{
self = %orig;
if(self){
//Setup screen handling...
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame called, executing code for this");
if([self respondsToSelector:@selector(dontSwipeThis)]){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame dontSwipeThis detected, returning original code and setting don't dontSwipeThis to 'TRUE'");
	dontSwipeThis = TRUE;
	return self;
}
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame setting up autorelease pool");
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; //Damn "memory management"
/*
wdInitView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
wdInitView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];

UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(100,40,120,130)];
logoView.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/WDLogo.png"];
[wdInitView addSubview:logoView];
[logoView release];
[self addSubview:wdInitView];
[wdInitView release];
*/
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame loading preferences");
loadPrefs();
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame loaded preferences");


if([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]){
isiPhone = TRUE; //FIXME
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame wasiPhone is 'TRUE'");
}

if ([self respondsToSelector:@selector(bruceEnabled)]) {
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame bruceEnabled was detected, setting hasBruce to 'TRUE'");
  hasBruce = TRUE;

}

if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame assigning all the movableViews and static references");
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame assigning dateView");
dateView = [self dateView];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame assinging lockBar");
lockBar = [self lockBar];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame assinging chargingView");
chargingView = [self chargingView];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame assinging albumArtView");
albumArtView = [self nowPlayingArtView];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame creating movableViews with the static views");
movableViews = [[NSMutableArray alloc] initWithObjects:dateView, chargingView, lockBar, albumArtView, nil];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame creating grabbyView");
if(isiPhone){
grabbyView = [[UIImageView alloc] initWithFrame:CGRectMake(280, lockBar.frame.origin.y, 40, lockBar.frame.size.height)];
grabbyView.userInteractionEnabled = TRUE;
}
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame creating lockBarCover");
UIView *lockBarCover = [[UIView alloc] initWithFrame:CGRectMake(0,0, lockBar.frame.size.width, lockBar.frame.size.height)];
lockBarCover.backgroundColor = [UIColor clearColor];
[lockBar addSubview:lockBarCover];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame releasing lockBarCover");
[lockBarCover release];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame getting textLabel from lockBar");
UIView * textLabel = [lockBar valueForKey:@"labelView"];

if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame creating chevron");
UIImageView *chevron = [[UIImageView alloc] initWithFrame:CGRectMake(textLabel.frame.origin.x - 50, (lockBar.frame.size.height / 5) * 2, 10, lockBar.frame.size.height / 5)];
chevron.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/RightChevron.png"];
[lockBar addSubview:chevron];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame added chevron to lockBar, releasing.");
[chevron release];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame released chevron");

//lockBar.hidden = TRUE;
lockBar.userInteractionEnabled = FALSE;
if(isiPhone){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame isiPhone is true :P changing lockBar frame slightly to accomidate for the grabber");
if(lockBar) lockBar.frame = CGRectMake(lockBar.frame.origin.x, 460 - lockBar.frame.size.height, 260, lockBar.frame.size.height);
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame adding grabbyView to movableViews");
grabbyView.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Grab.png"];
[self addSubview:grabbyView];
[movableViews addObject:grabbyView];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame added grabbyView to self as a view and to the movableViews array");

}
else{
	if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame was not an iPhone! Setting lockbar frame to apropriate sizes");
if(lockBar) lockBar.frame = CGRectMake(lockBar.frame.origin.x, 460 - lockBar.frame.size.height, 260, lockBar.frame.size.height); //if(lockBar) lockBar.frame = CGRectMake(lockBar.frame.origin.x, 460 - lockBar.frame.size.height, 320, lockBar.frame.size.height);
}
if(grabbyView) grabbyView.frame = CGRectMake(280, lockBar.frame.origin.y + 20, 40, lockBar.frame.size.height);
if(hasBruce){
	if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame grabbing lsHolder view for bruce and assigning to a static variable for it");
lsHolder = [self lsHolder];
[movableViews addObject:lsHolder];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame assinged lsHolder to static variable as well as added to movableViews");
}

if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame releasing grabbyView");
[grabbyView release];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame released grabbyView");
if(!isWhited00r){

if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame awwww shiiiiiit it wasn't whited00r ye dirty bastard.");
UILabel *pirateTitle = [[UILabel alloc] init];
pirateTitle.textAlignment = UITextAlignmentCenter;
pirateTitle.font = [UIFont boldSystemFontOfSize:24];
pirateTitle.frame=CGRectMake(0, 120, 320, 40);
pirateTitle.backgroundColor = [UIColor clearColor];
pirateTitle.text = @"Whited00r was here <3";
pirateTitle.textColor = [UIColor greenColor];

[self addSubview:pirateTitle];
[pirateTitle release];


}
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame draining autorelease pool");
[pool drain];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-initWithFrame drained autorelease pool");
}
return self;

}


%new(v@:)
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan called, executing code");
if(dontSwipeThis){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan dontSwipeThis is 'TRUE'! Returning original code.");
	return;
}

//[[%c(SBAwayController) sharedAwayController] undimScreen];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan creating autorelease pool");
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan preventingIdleSleep... if that only worked -___-");
[[%c(SBAwayController) sharedAwayController] preventIdleSleepForNumberOfSeconds:3.0];
CGPoint pt = [[touches anyObject] locationInView:self];
UIView *touchedView = [self hitTest:pt withEvent:event];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan bringing self to front of superview... may not be needed");
	[[self superview] bringSubviewToFront:self];

if(touchedView == grabbyView){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan touchedView was grabbyView! Running apropriate code");
wasGrabby = TRUE;
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan creating cameraImageView");
cameraImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,480)];
cameraImageView.image = [UIImage imageWithContentsOfFile:@"/Applications/MobileSlideShow.app/Default-Camera.png"];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan getting cameraImageView subview index");
//int indexy = [[[self superview] subviews] indexOfObject:self] - 1;
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan inserting cameraImageView into superview at the apropriate index");
[[self superview] insertSubview:cameraImageView atIndex:0];
[cameraImageView release];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan released and inserted cameraImageView");
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan assigning startLocation");
startLocation = [[touches anyObject] locationInView:self];
}
else{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan was not grabby!");
wasGrabby = FALSE;
startLocation = [[touches anyObject] locationInView:dateView];
}

if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan draining autorelease pool");
[pool drain];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesBegan drained autorelease pool");
}


%new(v@:)
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved called, running code");
if(dontSwipeThis){
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved dontSwipeThis was 'TRUE', returning");
	return;
}
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved setting isSlidingLockscreen to 'TRUE'");
isSlidingLockscreen = TRUE;
//[[%c(SBAwayController) sharedAwayController] undimScreen];
//[[%c(SBAwayController) sharedAwayController] restartDimTimer:5.0];
//[[%c(SBAwayController) sharedAwayController] cancelDimTimer];
//if(![[%c(SBAwayController) sharedAwayController] isShowingMediaControls]){
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved creating autorelease pool");
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

if(shouldSlide){
	//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved shouldSlide was 'TRUE'");
CGPoint pt;
	// Calculate offset
	if(!wasGrabby){
	pt = [[touches anyObject] locationInView:dateView];
	}
	else{
	pt = [[touches anyObject] locationInView:self];
	}
	float dx = pt.x - startLocation.x;
	float dy = pt.y - startLocation.y;
	float newCenterX;
	float newCenterY;
	CGPoint dateCenter;
	CGPoint lockCenter;
	CGPoint chargingCenter;
	CGPoint grabbyCenter;
	CGPoint artCenter;
	CGPoint lsHolderCenter;
	if(dateView.center.x + dx <= 50){
	newCenterX = 50;
	}
	else{
	newCenterX = dateView.center.x + dx;
	}
	if(self.center.y + dy  >= 240){
	newCenterY = 240;
	}
	else{
	newCenterY = self.center.y + dy;
	}
	//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved setting new centers for views in notGrabby :P");
	if(!wasGrabby){
	dateCenter = CGPointMake(newCenterX, dateView.center.y);
	lockCenter = CGPointMake(newCenterX - 25, lockBar.center.y);
	artCenter = CGPointMake(newCenterX, albumArtView.center.y);
	chargingCenter = CGPointMake(newCenterX + 25, chargingView.center.y);
	//If it isn't an iPhone, it won't have this...
	if(isiPhone){
	grabbyCenter = CGPointMake(lockBar.frame.origin.x + 280, grabbyView.center.y);
	if(grabbyView) grabbyView.center = grabbyCenter;
	}

	if(hasBruce){
	lsHolderCenter = CGPointMake(newCenterX, lsHolder.center.y);
	if(lsHolder) lsHolder.center = lsHolderCenter;
	}
	// Set new location

	dateView.center = dateCenter;
	lockBar.center = lockCenter;
	chargingView.center = chargingCenter;
	
	albumArtView.center = artCenter;
	//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved set centers for subviews in notGrabby");
	}
	else{
	//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved was grabby, setting selfs center to something new :P");
	self.center = CGPointMake(self.center.x, newCenterY);
	//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved set selfs new center for grabby.");
	}


if(!wasGrabby){
if(dateView.center.x + dx <= 50){
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved resetting views to normal for notGrabby (ready to unlock position)");
for(UIView *subview in movableViews){
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved changing movableViews views: %@ alpha to 1.0", subview);
subview.alpha = 1.0;
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved set movableViews views: %@ alpha to 1.0", subview);
}//End subview looping...
}//End if for dateview under or equal to 50
else{
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved was grabby! Yayyyyy camera sliding.");
	if(fadeSlide){
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved oh my. Fade slide...");
for(UIView *subview in movableViews){
	float alphaIs = ((340 - dateView.center.x) / 32) / 10;
if([[%c(SBAwayController) sharedAwayController] isSyncing]){
	if(subview == dateView){
			subview.alpha = 0.0;
		}
		else{
			subview.alpha = alphaIs;
		}
	}
	else{
	//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved setting movableViews view: %@ alpha in fadeSlide", subview);
		subview.alpha = alphaIs;
	//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved set movableViews view: %@ alpha in fadeSlide", subview);
	}
}//End subview alpha set loop
}//End fadeSlide check
}//End else
}//End wasGrabby
}//End showing media controls check
else{
//[self bringSubviewToFront:dateView];

}
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved draining autorelease pool");
[pool drain];
//if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesMoved drained autorelease pool");
}



%new(v@:)
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded code called, executing code");
if(dontSwipeThis){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded dontSwipeThis was 'TRUE', returning");
	return;
}
isSlidingLockscreen = FALSE;
//[[%c(SBAwayController) sharedAwayController] undimScreen];
//[[%c(SBAwayController) sharedAwayController] restartDimTimer:5.0];
//if(![[%c(SBAwayController) sharedAwayController] isShowingMediaControls]){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded creating autorelease pool");
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
if(shouldSlide){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded shouldSlide was true :O");
if(!wasGrabby){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasn't grabby");
endLocation = dateView.center.x;

if(dateView.center.x < 320){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded starting reset to normal positions animations");
[UIView beginAnimations:nil context:nil];
[UIView setAnimationDuration:0.3];
//[UIView setAnimationBeginsFromCurrentState:YES]; //Crash fix? Cancel old animations.
if(bouncy){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded it was bouncy :(");
[UIView setAnimationDidStopSelector:@selector(bounceBackStepOne:finished:context:)];
}


[UIView setAnimationDelegate:self];
[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
for(UIView *subview in movableViews){
if([[%c(SBAwayController) sharedAwayController] isSyncing]){
	if(subview == dateView){
			subview.alpha = 0.0;
		}
		else{
			subview.alpha = 1.0;
		}
	}
	else{
	if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded setting movableViews view: %@ alpha to 1.0", subview);
		subview.alpha = 1.0;
	if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded set movableViews view: %@ alpha to 1.0", subview);
	}
}
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded moving normal views frames around. These should all work well...");
    if(dateView) dateView.frame = CGRectMake(0, 0, 320, dateView.frame.size.width);
    if(lockBar) lockBar.frame = CGRectMake(0, lockBar.frame.origin.y, lockBar.frame.size.width, lockBar.frame.size.height);
    if(albumArtView) albumArtView.frame = CGRectMake(50, albumArtView.frame.origin.y, albumArtView.frame.size.width, albumArtView.frame.size.height);
    if(isiPhone){
    if(grabbyView) grabbyView.frame = CGRectMake(280, grabbyView.frame.origin.y, grabbyView.frame.size.width, grabbyView.frame.size.height);
    }
    if(hasBruce){
    if(lsHolder) lsHolder.frame = CGRectMake(0, lsHolder.frame.origin.y, lsHolder.frame.size.width, lsHolder.frame.size.height);
    }
    if(chargingView) chargingView.frame = CGRectMake(25, chargingView.frame.origin.y, 320, chargingView.frame.size.height);
    //dateView.alpha = 1.0;
   if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded set all frames postions, animating changes.");
    [UIView commitAnimations];
}
else{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded unlocking. Magic, yes?");
if(![[%c(SBAwayController) sharedAwayController] isPasswordProtected]){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded no passcode, just straight up unlocking.");

	[[%c(SBAwayController) sharedAwayController] unlockWithSound:TRUE];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded unlocked!");
}
else{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded unlock code was passcode protected.");
for(UIView *subview in movableViews){
if([[%c(SBAwayController) sharedAwayController] isSyncing]){
	if(subview == dateView){
			subview.alpha = 0.0;
		}
		else{
			subview.alpha = 1.0;
		}
	}
	else{
	if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded changing movableViews view: %@ alpha to 1.0", subview);
		subview.alpha = 1.0;
	if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded set movableViews view: %@ alpha to 1.0", subview);
	}
}

if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded begining passcode animation stuff to get the view back to normal for opening the passcode to stop bugging out stuff");
[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
[UIView setAnimationDidStopSelector:@selector(passcodeAnimationDidStop:finished:context:)];
[UIView setAnimationDelegate:self];
//[UIView setAnimationBeginsFromCurrentState:YES]; //Crash fix? Cancel old animations.
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded setting frames for passcode animation :P");
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    if(albumArtView) albumArtView.frame = CGRectMake(50, albumArtView.frame.origin.y, albumArtView.frame.size.width, albumArtView.frame.size.height);
    if(lockBar) lockBar.frame = CGRectMake(0, lockBar.frame.origin.y, lockBar.frame.size.width, lockBar.frame.size.height);
    if(isiPhone){
    if(grabbyView) grabbyView.frame = CGRectMake(280, grabbyView.frame.origin.y, grabbyView.frame.size.width, grabbyView.frame.size.height);
    }
        if(hasBruce){
    if(lsHolder) lsHolder.frame = CGRectMake(320, lsHolder.frame.origin.y, lsHolder.frame.size.width, lsHolder.frame.size.height);
    }
    if(dateView) dateView.frame = CGRectMake(0, 0, 320, dateView.frame.size.height);
    if(chargingView) chargingView.frame = CGRectMake(25, chargingView.frame.origin.y, 320, chargingView.frame.size.height);
   if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded set frames for passcode animation, animating changes.");
    [UIView commitAnimations];



}

}
}//end was grabby?
else{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasGrabby:'TRUE' running code for it.");
endLocation = self.center.y;
if(self.center.y >= 20){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasGrabby:'TRUE' starting animation for resetting the view to normal");
[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
if(bouncy){
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasGrabby:'TRUE' wasBouncy:'TRUE' :(");
[UIView setAnimationDidStopSelector:@selector(bounceBackStepOne:finished:context:)];
}
[UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//[UIView setAnimationBeginsFromCurrentState:YES]; //Crash fix? Cancel old animations.
  if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasGrabby:'TRUE' resetting self frame to normal");
self.frame = CGRectMake(0,0,320, 480);
    //dateView.alpha = 1.0;

    [UIView commitAnimations];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasGrabby:'TRUE' set self frame to normal");
}
else{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasGrabby:'TRUE' opening camera app :)");
[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
//[UIView setAnimationBeginsFromCurrentState:YES]; //Crash fix? Cancel old animations.

    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    if(![[%c(SBAwayController) sharedAwayController] isPasswordProtected]){
    if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasGrabby:'TRUE' no passcode... good news.");
	 self.frame = CGRectMake(0,-560,320, 480);
    }
    else{
    if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasGrabby:'TRUE'. Had a passcode. Resetting frame and showing passcode screen");
    	self.frame = CGRectMake(0,0,320, 480);
    	[[%c(SBAwayController) sharedAwayController] unlockWithSound:TRUE];
    }
    [UIView commitAnimations];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasGrabby:'TRUE'. Launching camera app now using special well handled WD7UI method.");
//Launching le app
[[%c(SBUIController) sharedInstance] openAppWithBundleID:[NSString stringWithFormat:@"com.apple.mobileslideshow"]];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded wasGrabby:'TRUE'. Launched camera app using special well handled WD7UI method.");


}



}
}
else{
//[self bringSubviewToFront:dateView];

}
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded drainging autorelease pool");
[pool drain];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-touchesEnded drained autorelease pool");
}






%new(v@:)
- (void)bounceBackStepOne:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-bounceBackStepOne - running code for bounce back... Oh gosh. Shouldn't be debugging this.");
[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
[UIView setAnimationDidStopSelector:@selector(bounceBackStepTwo:finished:context:)];
[UIView setAnimationDelegate:self];
//[UIView setAnimationBeginsFromCurrentState:YES]; //Crash fix? Cancel old animations.
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
if(!wasGrabby){
 for(UIView *subview in movableViews){
if([[%c(SBAwayController) sharedAwayController] isSyncing]){
	if(subview == dateView){
			subview.alpha = 0.0;
		}
		else{
			subview.alpha = 0.8;
		}
	}
	else{
		subview.alpha = 0.8;
	}
}
     if(albumArtView) albumArtView.frame = CGRectMake(70, albumArtView.frame.origin.y, albumArtView.frame.size.width, albumArtView.frame.size.height);
    if(dateView) dateView.frame = CGRectMake(20, 0, 320, dateView.frame.size.height);
    if(lockBar) lockBar.frame = CGRectMake(20, lockBar.frame.origin.y, lockBar.frame.size.width, lockBar.frame.size.height);
if(isiPhone){
if(grabbyView) grabbyView.frame = CGRectMake(300, grabbyView.frame.origin.y, grabbyView.frame.size.width, grabbyView.frame.size.height);
}
    if(hasBruce){
    if(lsHolder) lsHolder.frame = CGRectMake(20, lsHolder.frame.origin.y, lsHolder.frame.size.width, lsHolder.frame.size.height);
    }
    if(chargingView) chargingView.frame = CGRectMake(45, chargingView.frame.origin.y, 320, chargingView.frame.size.height);
}
else{
self.frame = CGRectMake(0,-40,320, 480);
}
    [UIView commitAnimations];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-bounceBackStepOne code ran well?");
}

%new(v@:)
- (void)bounceBackStepTwo:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-bounceBackStepTwo running code");
[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
[UIView setAnimationDidStopSelector:@selector(bounceBackStepThree:finished:context:)];
[UIView setAnimationDelegate:self];
//[UIView setAnimationBeginsFromCurrentState:YES]; //Crash fix? Cancel old animations.
  [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
if(!wasGrabby){
 for(UIView *subview in movableViews){
if([[%c(SBAwayController) sharedAwayController] isSyncing]){
	if(subview == dateView){
			subview.alpha = 0.0;
		}
		else{
			subview.alpha = 1.0;
		}
	}
	else{
		subview.alpha = 1.0;
	}
}
    if(albumArtView) albumArtView.frame = CGRectMake(50, albumArtView.frame.origin.y, albumArtView.frame.size.width, albumArtView.frame.size.height);
    if(dateView) dateView.frame = CGRectMake(0, 0, 320, dateView.frame.size.height);
    if(lockBar) lockBar.frame = CGRectMake(0, lockBar.frame.origin.y, lockBar.frame.size.width, lockBar.frame.size.height);
if(isiPhone){
if(grabbyView) grabbyView.frame = CGRectMake(280, grabbyView.frame.origin.y, grabbyView.frame.size.width, grabbyView.frame.size.height);
}
    if(hasBruce){
    if(lsHolder) lsHolder.frame = CGRectMake(0, lsHolder.frame.origin.y, lsHolder.frame.size.width, lsHolder.frame.size.height);
    }
    if(chargingView) chargingView.frame = CGRectMake(25, chargingView.frame.origin.y, 320, chargingView.frame.size.height);
}
else{
self.frame = CGRectMake(0,0,320, 480);
}
    [UIView commitAnimations];
//[self bringSubviewToFront:dateView];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-bounceBackStepTwo ran code well");
}


%new(v@:)
- (void)bounceBackStepThree:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-bounceBackStepThree running code");
[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
[UIView setAnimationDidStopSelector:@selector(bounceBackStepFour:finished:context:)];
[UIView setAnimationDelegate:self];
//[UIView setAnimationBeginsFromCurrentState:YES]; //Crash fix? Cancel old animations.
   // [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
if(!wasGrabby){
 for(UIView *subview in movableViews){
if([[%c(SBAwayController) sharedAwayController] isSyncing]){
	if(subview == dateView){
			subview.alpha = 0.0;
		}
		else{
			subview.alpha = 0.8;
		}
	}
	else{
		subview.alpha = 0.8;
	}
}
    if(albumArtView) albumArtView.frame = CGRectMake(60, albumArtView.frame.origin.y, albumArtView.frame.size.width, albumArtView.frame.size.height);
    if(dateView) dateView.frame = CGRectMake(10, 0, 320, dateView.frame.size.height);
    if(lockBar) lockBar.frame = CGRectMake(20, lockBar.frame.origin.y, lockBar.frame.size.width, lockBar.frame.size.height);
if(isiPhone){
if(grabbyView) grabbyView.frame = CGRectMake(290, grabbyView.frame.origin.y, grabbyView.frame.size.width, grabbyView.frame.size.height);
}
    if(hasBruce){
    if(lsHolder) lsHolder.frame = CGRectMake(10, lsHolder.frame.origin.y, lsHolder.frame.size.width, lsHolder.frame.size.height);
    }
    if(chargingView) chargingView.frame = CGRectMake(35, chargingView.frame.origin.y, 320, chargingView.frame.size.height);
}
else{
self.frame = CGRectMake(0,-10,320, 480);
}
    [UIView commitAnimations];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-bounceBackStepThree ran code well");
}




%new(v@:)
- (void)bounceBackStepFour:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-bounceBackStepFour running code");
[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
//[UIView setAnimationBeginsFromCurrentState:YES]; //Crash fix? Cancel old animations.
   // [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
if(!wasGrabby){
 for(UIView *subview in movableViews){

if([[%c(SBAwayController) sharedAwayController] isSyncing]){
	if(subview == dateView){
			subview.alpha = 0.0;
		}
		else{
			subview.alpha = 1.0;
		}
	}
	else{
		subview.alpha = 1.0;
	}
}
    if(albumArtView) albumArtView.frame = CGRectMake(50, albumArtView.frame.origin.y, albumArtView.frame.size.width, albumArtView.frame.size.height);
    if(dateView) dateView.frame = CGRectMake(0, 0, 320, dateView.frame.size.height);
    if(lockBar) lockBar.frame = CGRectMake(0, lockBar.frame.origin.y, lockBar.frame.size.width, lockBar.frame.size.height);
if(isiPhone){
    if(grabbyView) grabbyView.frame = CGRectMake(280, grabbyView.frame.origin.y, grabbyView.frame.size.width, grabbyView.frame.size.height);
}
    if(hasBruce){
    if(lsHolder) lsHolder.frame = CGRectMake(0, lsHolder.frame.origin.y, lsHolder.frame.size.width, lsHolder.frame.size.height);
    }
    if(chargingView) chargingView.frame = CGRectMake(25, chargingView.frame.origin.y, 320, chargingView.frame.size.height);
}
else{
self.frame = CGRectMake(0,0,320, 480);
}
    [UIView commitAnimations];
//[cameraImageView removeFromSuperView];
//[self bringSubviewToFront:dateView];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-bounceBackStepFour ran code well");
}



%new(v@:)
- (void)passcodeAnimationDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-passCodeAnimationDidStop finished. Unlocking device code running now");
[[%c(SBAwayController) sharedAwayController] unlockWithSound:TRUE];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-passCodeAnimationDidStop code ran, and unlock code ran");
}

-(void)addChargingView{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-addChargingView called, running original code");
	%orig;
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-addChargingView original code ran, injecting own code");
	if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-addChargingView grabbing batteryChargingView");
	id batteryChargingView = [chargingView valueForKey:@"chargingView"];
	[batteryChargingView setShowsReflection:FALSE];
	if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-addChargingView grabbed batteryChargingView and set ShowsReflection to 'FALSE'");



}


%new(v@:)
-(void)removeAllAnimationsFromSubviews{
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-removeAllAnimationsFromSubviews code called. This should be self sufficient anyway...");
	if(hasBruce){
		if(lsHolder) [lsHolder.layer removeAllAnimations];
	}
	if(chargingView) [chargingView.layer removeAllAnimations];
	if(isiPhone){
		if(grabbyView) [grabbyView.layer removeAllAnimations];
	}
	if(lockBar) [lockBar.layer removeAllAnimations];
	if(dateView) [dateView.layer removeAllAnimations];
	if(albumArtView) [albumArtView.layer removeAllAnimations];
if(logStuff) NSLog(@"WD7Lockscreen: SBAwayView-removeAllAnimationsFromSubviews code ran");
}



%end


%hook SBSlidingAlertDisplay

-(void)animateToShowingDeviceLock:(BOOL)showingDeviceLock{
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-animateToShowingDeviceLock called");
//UIView *keypad = [self valueForKey:@"deviceLockKeypad"];
//if(logStuff) NSLog(@"WD7Lockscreen: animate to showing device lock called");
//[[self valueForKey:@"deviceLockEntryField"] setButtonWidth:320];
//keypad.hidden = TRUE;
if(showingDeviceLock){
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-animateToShowingDeviceLock showingDeviceLock:'TRUE' so setting grabbyView to hidden");
//if(logStuff) NSLog(@"WD7Lockscreen: animated to showing device lock was true");
/*
if(!wdKeypad){
	wdKeypad = [[WDKeypad alloc] initWithFrame:CGRectMake(-320, 100, 320, 360)];
	[self addSubview:wdKeypad];
}

[UIView beginAnimations:nil context:nil];
[UIView setAnimationDuration:0.3];
wdKeypad.frame = CGRectMake(0, 100, 320, 360);
[UIView commitAnimations];
*/
if(isiPhone){
if(grabbyView) grabbyView.hidden = TRUE;
}
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-animateToShowingDeviceLock showingDeviceLock:'TRUE' set grabbyView to hidden");
}
/*
else{
	if(!wdKeypad){
	wdKeypad = [[WDKeypad alloc] initWithFrame:CGRectMake(-320, 100, 320, 360)];
	[self addSubview:wdKeypad];
}
[UIView beginAnimations:nil context:nil];
[UIView setAnimationDuration:0.3];
wdKeypad.frame = CGRectMake(-320, 100, 320, 360);
[UIView commitAnimations];

}
*/
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-animateToShowingDeviceLock running original code");
%orig;
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-animateToShowingDeviceLock ran original code");
//keypad.hidden = TRUE;
//wdKeypad.backgroundColor = [UIColor clearColor];
//wdKeypad.delegate = self;
//[wdKeypad release];

}


-(void)_animateToHidingDeviceLockFinished{
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_animateToHidingDeviceLockFinished code called");
//if(logStuff) NSLog(@"WD7Lockscreen: Animate to hiding device lock finished");
//UIView *keypad = MSHookIvar<id>(self, "_deviceLockKeypad");
//[[self valueForKey:@"deviceLockEntryField"] setButtonWidth:320];
//UIView *keypadEntry = [self valueForKey:@"deviceLockEntryField"];
//keypadEntry.frame = CGRectMake(0, -60, 320, 40);

//keypad.hidden = TRUE;
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_animateToHidingDeviceLockFinished hiding grabbyView");
if(isiPhone){
if(grabbyView) grabbyView.hidden = FALSE;
}
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_animateToHidingDeviceLockFinished hid grabbyView and now running original code");
%orig;
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_animateToHidingDeviceLockFinished ran original code");
}

-(void)_animateToShowingDeviceLockFinished{
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_animateToShowingDeviceLockFinished code called, running original code");
	%orig;
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_animateToShowingDeviceLockFinished original code ran, injecting own code");
	//if(logStuff) NSLog(@"WD7Lockscreen: Animate to showing device lock finished");
//UIView *keypad = [self valueForKey:@"deviceLockKeypad"];
//UIView *keypadEntry = [self valueForKey:@"deviceLockEntryField"];
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_animateToShowingDeviceLockFinished getting statusView");
UIView *statusView = [self valueForKey:@"deviceLockStatusView"];
if(statusView){
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_animateToShowingDeviceLockFinished got statusView, getting textView");
TPLCDTextView *textView = [statusView valueForKey:@"textView"];

if(textView){
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_animateToShowingDeviceLockFinished got statusView, got textView, setting fonts sizes and frames");
[textView setFont:[UIFont systemFontOfSize:18]];
[textView setFrame:CGRectMake(0, 20, 320, 20)];
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_animateToShowingDeviceLockFinished got statusView, got textView, set font sizes and frames.");
}
}
//keypadEntry.frame = CGRectMake(keypadEntry.frame.origin.x, keypadEntry.frame.origin.y, 320, keypadEntry.frame.size.height);
//[[self valueForKey:@"deviceLockEntryField"] setButtonWidth:320];
//[keypadEntry setButtonWidth:100];
//keypad.frame = CGRectMake(0,150,320, 360);
//keypad.hidden = TRUE;
//wdKeypad.hidden = FALSE;

}



-(void)_setTopBarImage:(id)image shadowColor:(id)color{
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_setTopBarImage called. changing color");
	color = [UIColor clearColor];
	%orig;
if(logStuff) NSLog(@"WD7Lockscreen: SBSlidingAlertDisplay-_setTopBarImage called, changed color and also ran original code");
}
%end
