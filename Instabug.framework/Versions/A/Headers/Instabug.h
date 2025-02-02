/*
 File:       Instabug/Instabug.h
 
 Contains:   API for using Instabug's SDK.
 
 Copyright:  (c) 2013 by Instabug, Inc., all rights reserved.
 
 Version:    1.1.2
 */

//=============================================================================================
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//=============================================================================================

//=============================================================================================
//  Enums
//=============================================================================================
/*!
 @enum       InstabugFeedbackEvent
 
 @abstract   The event used to fire up (show) the feedback form
 
 @constant   InstabugFeedbackEventShake
                Shaking the device while in any screen to show the feedback form
 
 @constant   InstabugFeedbackEventScreenshot
                Taking a screenshot using the Home+Lock buttons while in any screen to show the feedback form, substituted with InstabugFeedbackEventShake on iOS 6.1.3 and earlier
 
 @constant   InstabugFeedbackEventThreeFingersSwipe
                Swiping three fingers up while in any screen to show the feedback form
 
 @constant   InstabugFeedbackEventNone
                No event will be registered to show the feedback form, you'll need to code your own and call the function ShowFeedbackForm
 */
typedef enum{
    InstabugFeedbackEventShake,
    InstabugFeedbackEventScreenshot,
    InstabugFeedbackEventThreeFingersSwipe,
    InstabugFeedbackEventNone
} InstabugFeedbackEvent;

/*!
 @enum       InstabugCaptureSource
 
 @abstract   The capture source for capturing the screenshot
 
 @constant   InstabugCaptureSourceUIKit
                Captures elements from the UIKit framework
 
 @constant   InstabugCaptureSourceOpenGL
                Captures OpenGL elements rendered
 */
typedef enum{
    InstabugCaptureSourceUIKit,
    InstabugCaptureSourceOpenGL
} InstabugCaptureSource;

/*!
 @enum       InstabugColorTheme
 
 @abstract   The color theme of the different UI elements
 
 @constant   InstabugColorThemeBlack
                The black theme
 
 @constant   InstabugColorThemeGrey
                The grey theme
 
 @constant   InstabugColorThemeOrange
                The orange theme
 
 @constant   InstabugColorThemeRed
                The red theme
 
 @constant   InstabugColorThemeNavy
                The navy theme
 
 @constant   InstabugColorThemeGreen
                The green theme
 
 @constant   InstabugColorThemeCyan
                The cyan theme
 
 @constant   InstabugColorThemeBlue
                The blue theme
 
 @constant   InstabugColorThemeFlatWhite
                The flat white theme
 
 @constant   InstabugColorThemeFlatGrey
                The flat grey theme
 
 @constant   InstabugColorThemeFlatBlack
                The flat black theme
 
 @constant   InstabugColorThemeFlatBlue
                The flat blue theme
 
 @constant   InstabugColorThemeFlatRed
                The flat red theme
 
 @constant   InstabugColorThemeFlatGreen
                The flat green theme
 */
typedef enum{
    InstabugColorThemeBlack,
    InstabugColorThemeGrey,
    InstabugColorThemeOrange,
    InstabugColorThemeRed,
    InstabugColorThemeNavy,
    InstabugColorThemeGreen,
    InstabugColorThemeCyan,
    InstabugColorThemeBlue,
    InstabugColorThemeFlatWhite,
    InstabugColorThemeFlatGrey,
    InstabugColorThemeFlatBlack,
    InstabugColorThemeFlatBlue,
    InstabugColorThemeFlatRed,
    InstabugColorThemeFlatGreen
} InstabugColorTheme;
//=============================================================================================





@interface Instabug : NSObject

//=============================================================================================
//  The main SDK function that does all the magic.
//  Should be called at the end of the function application:didFinishLaunchingWithOptions:
//  This is the only function that SHOULD be called.
//  This function should be called before all other functions
//=============================================================================================
/*!
 @method		KickOffWithToken:CaptureSource:FeedbackEvent:IsTrackingLocation:
 @discussion	Starts the SDK
 
 */
+(void)KickOffWithToken:(NSString*)token
          CaptureSource:(InstabugCaptureSource)captureSource
          FeedbackEvent:(InstabugFeedbackEvent)feedbackEvent
     IsTrackingLocation:(BOOL)isTrackingLocation;
//=============================================================================================





//=============================================================================================
//  Other options to show the feedback form
//=============================================================================================
/*!
 @method		ShowFeedbackForm
 @discussion	Instantly shows the feedback form
 */
+(void)ShowFeedbackForm;
 
/*!
 @method		ShowFeedbackFormWithScreenshot
 @discussion	Instantly shows the feedback form either with or without a screenshot
 */
+(void)ShowFeedbackFormWithScreenshot:(BOOL)withScreenshot;

/*!
 @method		disableSDK
 @discussion	Disables the SDK, this will disable all the SDK functions
 */
+(void)disableSDK;

/*!
 @method		enableSDK
 @discussion	Enables the SDK, this will enable all the SDK functions. The SDK is enabled by default
 */
+(void)enableSDK;
//=============================================================================================





//=============================================================================================
//  Sets the SDK parameters
//=============================================================================================
/*!
 @method		setUserDataString
 @discussion	Sets optional user data in a string. Maximum size of the string is 1000 characters
 */
+(void)setUserDataString:(NSString*) userDataString;

/*!
 @method		setShowScreenshot
 @discussion	Sets the default value of the screenshot, whether to show it or not
 */
+(void)setShowScreenshot:(BOOL) showScreenshot;

/*!
 @method		setShowEmail
 @discussion	Sets the default value of the email field, whether to ask the user for it or not
 */
+(void)setShowEmail:(BOOL) showEmail;

/*!
 @method		setEmail
 @discussion	Sets the default value of the email field
 */
+(void)setEmail:(NSString*) email;

/*!
 @method		setEmailIsRequired
 @discussion	Sets the value of whether the email field is required or not
 */
+(void)setEmailIsRequired:(BOOL) emailIsRequired;

/*!
 @method		setEmailInvalidText
 @discussion	Sets the email invalid alert text, shown if an invalid email is entered
 */
+(void)setEmailInvalidText:(NSString*) emailInvalidText;

/*!
 @method		setShowStartAlert
 @discussion	Sets the default value of the start alert, whether to show it or not
 */
+(void)setShowStartAlert:(BOOL) showStartAlert;

/*!
 @method		setStartAlertText
 @discussion	Sets the start alert text
 */
+(void)setStartAlertText:(NSString*) startAlertText;

/*!
 @method		setShowThankYouAlert
 @discussion	Sets the default value of the thank you alert, that gets shown after sending a feedback
 */
+(void)setShowThankYouAlert:(BOOL) showThankYouAlert;

/*!
 @method		setThankYouAlertText
 @discussion	Sets the thank you alert text, that gets shown after sending a feedback
 */
+(void)setThankYouAlertText:(NSString*) thankYouAlertText;
//=============================================================================================





//=============================================================================================
//  Sets the design customizations
//=============================================================================================
/*!
 @method		setColorTheme
 @discussion	Sets the color theme of the whole SDK UI, you can use is instead of the other design customization functions
 */
+(void)setColorTheme:(InstabugColorTheme) colorTheme;

/*!
 @method		setHeaderColor
 @discussion	Sets the header background color
 */
+(void)setHeaderColor:(UIColor*) color;

/*!
 @method		setHeaderFontColor
 @discussion	Sets the header font color
 */
+(void)setHeaderFontColor:(UIColor*) color;

/*!
 @method		setButtonsColor
 @discussion	Sets the buttons background color
 */
+(void)setButtonsColor:(UIColor*) color;

/*!
 @method		setButtonsFontColor
 @discussion	Sets the buttons font color
 */
+(void)setButtonsFontColor:(UIColor*) color;

/*!
 @method		setTextBackgroundColor
 @discussion	Sets the background color of the text area
 */
+(void)setTextBackgroundColor:(UIColor*) color;

/*!
 @method		setTextColor
 @discussion	Sets the email, comment and footer font color
 */
+(void)setTextFontColor:(UIColor*) color;
//=============================================================================================
@end