{	CFUserNotification.h
	Copyright (c) 2000-2005, Apple, Inc. All rights reserved.
}
{	  Pascal Translation:  Peter N Lewis, <peter@stairways.com.au>, 2004 }
{	  Pascal Translation Updated:  Peter N Lewis, <peter@stairways.com.au>, November 2005 }
{
    Modified for use with Free Pascal
    Version 210
    Please report any bugs to <gpc@microbizz.nl>
}

{$mode macpas}
{$packenum 1}
{$macro on}
{$inline on}
{$calling mwpascal}

unit CFUserNotification;
interface
{$setc UNIVERSAL_INTERFACES_VERSION := $0342}
{$setc GAP_INTERFACES_VERSION := $0210}

{$ifc not defined USE_CFSTR_CONSTANT_MACROS}
    {$setc USE_CFSTR_CONSTANT_MACROS := TRUE}
{$endc}

{$ifc defined CPUPOWERPC and defined CPUI386}
	{$error Conflicting initial definitions for CPUPOWERPC and CPUI386}
{$endc}
{$ifc defined FPC_BIG_ENDIAN and defined FPC_LITTLE_ENDIAN}
	{$error Conflicting initial definitions for FPC_BIG_ENDIAN and FPC_LITTLE_ENDIAN}
{$endc}

{$ifc not defined __ppc__ and defined CPUPOWERPC}
	{$setc __ppc__ := 1}
{$elsec}
	{$setc __ppc__ := 0}
{$endc}
{$ifc not defined __i386__ and defined CPUI386}
	{$setc __i386__ := 1}
{$elsec}
	{$setc __i386__ := 0}
{$endc}

{$ifc defined __ppc__ and __ppc__ and defined __i386__ and __i386__}
	{$error Conflicting definitions for __ppc__ and __i386__}
{$endc}

{$ifc defined __ppc__ and __ppc__}
	{$setc TARGET_CPU_PPC := TRUE}
	{$setc TARGET_CPU_X86 := FALSE}
{$elifc defined __i386__ and __i386__}
	{$setc TARGET_CPU_PPC := FALSE}
	{$setc TARGET_CPU_X86 := TRUE}
{$elsec}
	{$error Neither __ppc__ nor __i386__ is defined.}
{$endc}
{$setc TARGET_CPU_PPC_64 := FALSE}

{$ifc defined FPC_BIG_ENDIAN}
	{$setc TARGET_RT_BIG_ENDIAN := TRUE}
	{$setc TARGET_RT_LITTLE_ENDIAN := FALSE}
{$elifc defined FPC_LITTLE_ENDIAN}
	{$setc TARGET_RT_BIG_ENDIAN := FALSE}
	{$setc TARGET_RT_LITTLE_ENDIAN := TRUE}
{$elsec}
	{$error Neither FPC_BIG_ENDIAN nor FPC_LITTLE_ENDIAN are defined.}
{$endc}
{$setc ACCESSOR_CALLS_ARE_FUNCTIONS := TRUE}
{$setc CALL_NOT_IN_CARBON := FALSE}
{$setc OLDROUTINENAMES := FALSE}
{$setc OPAQUE_TOOLBOX_STRUCTS := TRUE}
{$setc OPAQUE_UPP_TYPES := TRUE}
{$setc OTCARBONAPPLICATION := TRUE}
{$setc OTKERNEL := FALSE}
{$setc PM_USE_SESSION_APIS := TRUE}
{$setc TARGET_API_MAC_CARBON := TRUE}
{$setc TARGET_API_MAC_OS8 := FALSE}
{$setc TARGET_API_MAC_OSX := TRUE}
{$setc TARGET_CARBON := TRUE}
{$setc TARGET_CPU_68K := FALSE}
{$setc TARGET_CPU_MIPS := FALSE}
{$setc TARGET_CPU_SPARC := FALSE}
{$setc TARGET_OS_MAC := TRUE}
{$setc TARGET_OS_UNIX := FALSE}
{$setc TARGET_OS_WIN32 := FALSE}
{$setc TARGET_RT_MAC_68881 := FALSE}
{$setc TARGET_RT_MAC_CFM := FALSE}
{$setc TARGET_RT_MAC_MACHO := TRUE}
{$setc TYPED_FUNCTION_POINTERS := TRUE}
{$setc TYPE_BOOL := FALSE}
{$setc TYPE_EXTENDED := FALSE}
{$setc TYPE_LONGLONG := TRUE}
uses MacTypes,CFBase,CFDate,CFDictionary,CFString,CFURL,CFRunLoop;
{$ALIGN POWER}


type
	CFUserNotificationRef = ^SInt32; { an opaque 32-bit type }

{ A CFUserNotification is a notification intended to be presented to a 
user at the console (if one is present).  This is for the use of processes
that do not otherwise have user interfaces, but may need occasional
interaction with a user.  There is a parallel API for this functionality
at the System framework level, described in UNCUserNotification.h.

The contents of the notification can include a header, a message, textfields,
a popup button, radio buttons or checkboxes, a progress indicator, and up to
three ordinary buttons.  All of these items are optional, but a default
button will be supplied even if not specified unless the
kCFUserNotificationNoDefaultButtonFlag is set.

The contents of the notification are specified in the dictionary used to
create the notification, whose keys should be taken from the list of constants
below, and whose values should be either strings or arrays of strings
(except for kCFUserNotificationProgressIndicatorValueKey, in which case the
value should be a number between 0 and 1, for a "definite" progress indicator,
or a boolean, for an "indefinite" progress indicator).  Additionally, URLs can
optionally be supplied for an icon, a sound, and a bundle whose Localizable.strings
files will be used to localize strings.
    
Certain request flags are specified when a notification is created.
These specify an alert level for the notification, determine whether
radio buttons or check boxes are to be used, specify which if any of these
are checked by default, specify whether any of the textfields are to
be secure textfields, and determine which popup item should be selected
by default.  A timeout is also specified, which determines how long the
notification should be supplied to the user (if zero, it will not timeout).
    
A CFUserNotification is dispatched for presentation when it is created.
If any reply is required, it may be awaited in one of two ways:  either
synchronously, using CFUserNotificationReceiveResponse, or asynchronously,
using a run loop source.  CFUserNotificationReceiveResponse has a timeout
parameter that determines how long it will block (zero meaning indefinitely)
and it may be called as many times as necessary until a response arrives.
If a notification has not yet received a response, it may be updated with
new information, or it may be cancelled.  Notifications may not be reused.
    
When a response arrives, it carries with it response flags that describe
which button was used to dismiss the notification, which checkboxes or
radio buttons were checked, and what the selection of the popup was.
It also carries a response dictionary, which describes the contents
of the textfields.  }
    
type
	CFUserNotificationCallBack = procedure( userNotification: CFUserNotificationRef; responseFlags: CFOptionFlags );

function CFUserNotificationGetTypeID: CFTypeID; external name '_CFUserNotificationGetTypeID';

function CFUserNotificationCreate( allocator: CFAllocatorRef; timeout: CFTimeInterval; flags: CFOptionFlags; var error: SInt32; dictionary: CFDictionaryRef ): CFUserNotificationRef; external name '_CFUserNotificationCreate';

function CFUserNotificationReceiveResponse( userNotification: CFUserNotificationRef; timeout: CFTimeInterval; var responseFlags: CFOptionFlags ): SInt32; external name '_CFUserNotificationReceiveResponse';

function CFUserNotificationGetResponseValue( userNotification: CFUserNotificationRef; key: CFStringRef; idx: CFIndex ): CFStringRef; external name '_CFUserNotificationGetResponseValue';

function CFUserNotificationGetResponseDictionary( userNotification: CFUserNotificationRef ): CFDictionaryRef; external name '_CFUserNotificationGetResponseDictionary';

function CFUserNotificationUpdate( userNotification: CFUserNotificationRef; timeout: CFTimeInterval; flags: CFOptionFlags; dictionary: CFDictionaryRef ): SInt32; external name '_CFUserNotificationUpdate';

function CFUserNotificationCancel( userNotification: CFUserNotificationRef ): SInt32; external name '_CFUserNotificationCancel';

function CFUserNotificationCreateRunLoopSource( allocator: CFAllocatorRef; userNotification: CFUserNotificationRef; callout: CFUserNotificationCallBack; order: CFIndex ): CFRunLoopSourceRef; external name '_CFUserNotificationCreateRunLoopSource';

{ Convenience functions for handling the simplest and most common cases:  
a one-way notification, and a notification with up to three buttons. }
    
function CFUserNotificationDisplayNotice( timeout: CFTimeInterval; flags: CFOptionFlags; iconURL: CFURLRef; soundURL: CFURLRef; localizationURL: CFURLRef; alertHeader: CFStringRef; alertMessage: CFStringRef; defaultButtonTitle: CFStringRef ): SInt32; external name '_CFUserNotificationDisplayNotice';

function CFUserNotificationDisplayAlert( timeout: CFTimeInterval; flags: CFOptionFlags; iconURL: CFURLRef; soundURL: CFURLRef; localizationURL: CFURLRef; alertHeader: CFStringRef; alertMessage: CFStringRef; defaultButtonTitle: CFStringRef; alternateButtonTitle: CFStringRef; otherButtonTitle: CFStringRef; var responseFlags: CFOptionFlags ): SInt32; external name '_CFUserNotificationDisplayAlert';


{ Flags }

const
	kCFUserNotificationStopAlertLevel = 0;
	kCFUserNotificationNoteAlertLevel = 1;
	kCFUserNotificationCautionAlertLevel = 2;
	kCFUserNotificationPlainAlertLevel = 3;

const
	kCFUserNotificationDefaultResponse = 0;
	kCFUserNotificationAlternateResponse = 1;
	kCFUserNotificationOtherResponse = 2;
	kCFUserNotificationCancelResponse = 3;

const
	kCFUserNotificationNoDefaultButtonFlag = 1 shl 5;
	kCFUserNotificationUseRadioButtonsFlag = 1 shl 6;

function CFUserNotificationCheckBoxChecked( i: CFIndex ): CFOptionFlags; inline;
function CFUserNotificationSecureTextField( i: CFIndex ): CFOptionFlags; inline;
function CFUserNotificationPopUpSelection( n: CFIndex ): CFOptionFlags; inline;


{ Keys }

var kCFUserNotificationIconURLKey: CFStringRef; external name '_kCFUserNotificationIconURLKey'; (* attribute const *)

var kCFUserNotificationSoundURLKey: CFStringRef; external name '_kCFUserNotificationSoundURLKey'; (* attribute const *)

var kCFUserNotificationLocalizationURLKey: CFStringRef; external name '_kCFUserNotificationLocalizationURLKey'; (* attribute const *)

var kCFUserNotificationAlertHeaderKey: CFStringRef; external name '_kCFUserNotificationAlertHeaderKey'; (* attribute const *)

var kCFUserNotificationAlertMessageKey: CFStringRef; external name '_kCFUserNotificationAlertMessageKey'; (* attribute const *)

var kCFUserNotificationDefaultButtonTitleKey: CFStringRef; external name '_kCFUserNotificationDefaultButtonTitleKey'; (* attribute const *)

var kCFUserNotificationAlternateButtonTitleKey: CFStringRef; external name '_kCFUserNotificationAlternateButtonTitleKey'; (* attribute const *)

var kCFUserNotificationOtherButtonTitleKey: CFStringRef; external name '_kCFUserNotificationOtherButtonTitleKey'; (* attribute const *)

var kCFUserNotificationProgressIndicatorValueKey: CFStringRef; external name '_kCFUserNotificationProgressIndicatorValueKey'; (* attribute const *)

var kCFUserNotificationPopUpTitlesKey: CFStringRef; external name '_kCFUserNotificationPopUpTitlesKey'; (* attribute const *)

var kCFUserNotificationTextFieldTitlesKey: CFStringRef; external name '_kCFUserNotificationTextFieldTitlesKey'; (* attribute const *)

var kCFUserNotificationCheckBoxTitlesKey: CFStringRef; external name '_kCFUserNotificationCheckBoxTitlesKey'; (* attribute const *)

var kCFUserNotificationTextFieldValuesKey: CFStringRef; external name '_kCFUserNotificationTextFieldValuesKey'; (* attribute const *)

{#if MAC_OS_X_VERSION_10_3 <= MAC_OS_X_VERSION_MAX_ALLOWED}
var kCFUserNotificationPopUpSelectionKey: CFStringRef; external name '_kCFUserNotificationPopUpSelectionKey'; (* attribute const *)
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)
{#endif}

implementation


{$R-}

function CFUserNotificationCheckBoxChecked( i: CFIndex ): CFOptionFlags; inline;
begin
	CFUserNotificationCheckBoxChecked := CFOptionFlags(1 shl (8+i));
end;

function CFUserNotificationSecureTextField( i: CFIndex ): CFOptionFlags; inline;
begin
	CFUserNotificationSecureTextField := CFOptionFlags(1 shl (16+i));
end;

function CFUserNotificationPopUpSelection( n: CFIndex ): CFOptionFlags; inline;
begin
	CFUserNotificationPopUpSelection := CFOptionFlags(n shl 24);
end;

end.
