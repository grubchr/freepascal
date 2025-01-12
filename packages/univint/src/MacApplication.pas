{
     File:       HIToolbox/MacApplication.h
 
     Contains:   Application-level APIs
 
     Version:    HIToolbox-219.4.81~2
 
     Copyright:  � 2000-2005 by Apple Computer, Inc., all rights reserved.
 
     Bugs?:      For bug reports, consult the following page on
                 the World Wide Web:
 
                     http://www.freepascal.org/bugs.html
 
}
{       Pascal Translation Updated:  Peter N Lewis, <peter@stairways.com.au>, August 2005 }
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

unit MacApplication;
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
uses MacTypes,CGImage,Menus,CGContext,Quickdraw,HIObjectCore,TextCommon,CFBase,CFDictionary;
{$ALIGN POWER}


{
 *  kHIToolboxVersionNumber
 *  
 *  Discussion:
 *    The current build number of HIToolbox.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available
 *    Non-Carbon CFM:   not available
 }
var kHIToolboxVersionNumber: Float32; external name '_kHIToolboxVersionNumber'; (* attribute const *)
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)

// the HIToolbox version number for various Mac OS X releases
const
	kHIToolboxVersionNumber10_3 = 145.0;
const
	kHIToolboxVersionNumber10_3_2 = 145.35;
const
	kHIToolboxVersionNumber10_3_3 = 145.38;
const
	kHIToolboxVersionNumber10_3_4 = 145.41;
const
	kHIToolboxVersionNumber10_3_5 = 145.43;


{
 *  Summary:
 *    Controls the presentation of system-provided user interface
 *    elements.
 *  
 *  Discussion:
 *    Note that the system UI mode is a per-process state. Switching
 *    from a process that is suppressing system UI to another process
 *    that is not will cause system UI elements to become visible
 *    automatically. Switching back to the first process will suppress
 *    system UI elements again.
 }
const
{
   * In this mode, all standard system UI elements are visible.
   }
	kUIModeNormal = 0;

  {
   * In this mode, system UI elements which cover the "content area" of
   * the screen (the area other than the menubar) are hidden. However,
   * these elements may automatically show themselves in response to
   * mouse movements or other user activity; specifically, the Dock
   * will still show itself automatically when the mouse moves into the
   * Dock's auto-show region.
   }
	kUIModeContentSuppressed = 1;

  {
   * In this mode, system UI elements which cover the "content area" of
   * the screen (the area other than the menubar) are hidden. Unlike
   * kUIModeContentSuppressed, most UI elements will not automatically
   * show themselves in this mode.
   }
	kUIModeContentHidden = 2;

  {
   * In this mode, all system UI elements, including the menubar, are
   * hidden. However, these elements may automatically show themselves
   * in response to mouse movements or other user activity;
   * specifically, the Dock and menubar will still show themselves
   * automatically when the mouse moves into the Dock's auto-show
   * region. Available in Mac OS X 10.3 and later.
   }
	kUIModeAllSuppressed = 4;

  {
   * In this mode, all system UI elements, including the menubar, are
   * hidden. Most system UI elements will not automatically show
   * themselves in this mode. The application may request that the
   * menubar automatically show itself while in this mode by passing
   * the kUIOptionAutoShowMenuBar flag to SetSystemUIMode.
   }
	kUIModeAllHidden = 3;

type
	SystemUIMode = UInt32;
	SystemUIModePtr = ^SystemUIMode;

{
 *  Summary:
 *    Controls optional behavior of system-provided user interface
 *    elements.
 }
const
{
   * Requests that the menubar automatically show itself when the user
   * moves the mouse into the screen area that would ordinarily be
   * occupied by the menubar. Only valid with kUIModeAllHidden.
   }
	kUIOptionAutoShowMenuBar = 1 shl 0;

  {
   * Disables all items in the Apple menu. Valid for all modes.
   }
	kUIOptionDisableAppleMenu = 1 shl 2;

  {
   * The active application may not be changed while this process is
   * active. Currently disables the Command-Tab and Command-Shift-Tab
   * key sequences to switch the active process, and the global window
   * rotation key sequence selected by the user in the Keyboard
   * preference pane. SetFrontProcess may still be used to explicitly
   * switch the active process. Only valid with modes other than
   * kUIModeNormal.
   }
	kUIOptionDisableProcessSwitch = 1 shl 3;

  {
   * The Force Quit window may not be displayed while this process is
   * active. Currently disables the Command-Option-Escape key sequence
   * to open the Force Quit window and the Force Quit menu item in the
   * Apple menu. Only valid with modes other than kUIModeNormal.
   }
	kUIOptionDisableForceQuit = 1 shl 4;

  {
   * The current login session may not be terminated while this process
   * is active. Currently disables the Power key and the Restart, Shut
   * Down, and Log Out menu items in the Apple menu. Only valid with
   * modes other than kUIModeNormal.
   }
	kUIOptionDisableSessionTerminate = 1 shl 5;

  {
   * The Hide menu item in the Application menu is disabled. Note that
   * this option does not prevent this application from being hidden if
   * Hide Others is selected in some other application. Available in
   * Mac OS X 10.3 and later.
   }
	kUIOptionDisableHide = 1 shl 6;

type
	SystemUIOptions = OptionBits;
	SystemUIOptionsPtr = ^SystemUIOptions;
{
 *  SetSystemUIMode()
 *  
 *  Summary:
 *    Sets the presentation mode for system-provided user interface
 *    elements.
 *  
 *  Discussion:
 *    The presentation mode of an application determines which
 *    system-provided user interface elements are visible on thes
 *    screen. When the frontmost application changes its presentation
 *    mode, a kEventAppSystemUIModeChanged Carbon event is sent to all
 *    applications that have registered for the event. This event is
 *    also sent when an application is activated; it contains the newly
 *    active application's presentation mode.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inMode:
 *      The new mode.
 *    
 *    inOptions:
 *      Options controlling how the new mode behaves.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.2 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.2 and later
 *    Non-Carbon CFM:   not available
 }
function SetSystemUIMode( inMode: SystemUIMode; inOptions: SystemUIOptions ): OSStatus; external name '_SetSystemUIMode';
(* AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER *)


{
 *  GetSystemUIMode()
 *  
 *  Summary:
 *    Returns the current presentation mode of the application.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    outMode:
 *      On exit, contains the current mode. You may pass NULL if you
 *      don't need this information.
 *    
 *    outOptions:
 *      On exit, contains the current options for the mode. You may
 *      pass NULL if you don't need this information.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.2 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.2 and later
 *    Non-Carbon CFM:   not available
 }
procedure GetSystemUIMode( outMode: SystemUIModePtr { can be NULL }; outOptions: SystemUIOptionsPtr { can be NULL } ); external name '_GetSystemUIMode';
(* AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER *)


{
 *  HIApplicationGetCurrent()
 *  
 *  Discussion:
 *    Returns the HIObjectRef of the currently running application
 *    object. This HIObject's EventTargetRef is what will be returned
 *    from GetApplicationEventTarget.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Result:
 *    The HIObjectRef of the currently running application object.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.2 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.2 and later
 *    Non-Carbon CFM:   not available
 }
function HIApplicationGetCurrent: HIObjectRef; external name '_HIApplicationGetCurrent';
(* AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER *)


{
 *  SetApplicationDockTileImage()
 *  
 *  Discussion:
 *    Sets the image for the tile in the dock that represents your
 *    application while it is running. If you set the image, it will
 *    NOT revert back to its original image when your application
 *    terminates. You need to manually restore it before quitting.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inImage:
 *      The image you wish to have as your tile image.
 *  
 *  Result:
 *    An operating system status code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
function SetApplicationDockTileImage( inImage: CGImageRef ): OSStatus; external name '_SetApplicationDockTileImage';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  OverlayApplicationDockTileImage()
 *  
 *  Discussion:
 *    Takes the image passed in and composites it on top of the current
 *    image of your application's dock tile. You might do this to put a
 *    standard badge over your application's icon to indicate something
 *    to the user.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inImage:
 *      The image you wish to overlay onto your tile image.
 *  
 *  Result:
 *    An operating system status code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
function OverlayApplicationDockTileImage( inImage: CGImageRef ): OSStatus; external name '_OverlayApplicationDockTileImage';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  RestoreApplicationDockTileImage()
 *  
 *  Discussion:
 *    Restores the tile for your appliation in the dock to its normal
 *    image (your application icon). You would use this if some overlay
 *    or change of the application icon needed to be removed.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Result:
 *    An operating system status code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
function RestoreApplicationDockTileImage: OSStatus; external name '_RestoreApplicationDockTileImage';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  BeginCGContextForApplicationDockTile()
 *  
 *  Discussion:
 *    Creates and returns a CGContextRef. You can use this context to
 *    draw into your application's dock tile with Quartz. You **MUST**
 *    call EndCGContextForApplicationDockTile and NOT CGEndContext when
 *    using this API, as it locks your application's tile in the dock.
 *    If you call CGEndContext, the dock will never know you are done
 *    with the tile.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Result:
 *    An Quartz (Core Graphics) context reference.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
function BeginCGContextForApplicationDockTile: CGContextRef; external name '_BeginCGContextForApplicationDockTile';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  EndCGContextForApplicationDockTile()
 *  
 *  Discussion:
 *    Ends the CG context for your application tile and frees the lock
 *    on the application dock tile. You **MUST** call this routine and
 *    NOT CGEndContext when using BeginCGContextForApplicationDockTile,
 *    as it locks your application's tile in the dock. If you call
 *    CGEndContext, the dock will never know you are done with the tile.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inContext:
 *      The context to end. The context is invalid after this call and
 *      should no longer be used.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
procedure EndCGContextForApplicationDockTile( inContext: CGContextRef ); external name '_EndCGContextForApplicationDockTile';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  BeginQDContextForApplicationDockTile()
 *  
 *  Discussion:
 *    Creates and returns a CGrafPtr for your application's tile in the
 *    dock. You can use this port to draw into your application's dock
 *    tile with Quickdraw. You **MUST** call
 *    EndQDContextForApplicationDockTile and NOT DisposePort when using
 *    this API, as it locks your application's tile in the dock. If you
 *    call DisposePort, the dock will never know you are done with the
 *    tile.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Result:
 *    A Quickdraw port reference.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
function BeginQDContextForApplicationDockTile: CGrafPtr; external name '_BeginQDContextForApplicationDockTile';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  EndQDContextForApplicationDockTile()
 *  
 *  Discussion:
 *    Disposes the Quickdraw port for your application tile and frees
 *    the lock on the application dock tile. You **MUST** call this
 *    routine and NOT DisposePort when using
 *    BeginQDContextForApplicationDockTile, else the dock will never
 *    know you are done with the tile.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inContext:
 *      The context to end. The context is invalid after this call and
 *      should no longer be used.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
procedure EndQDContextForApplicationDockTile( inContext: CGrafPtr ); external name '_EndQDContextForApplicationDockTile';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SetApplicationDockTileMenu()
 *  
 *  Summary:
 *    Sets the menu that is displayed by the application's dock tile.
 *  
 *  Discussion:
 *    The Carbon Window Manager and the Dock will always automatically
 *    display a menu containing a list of the application's document
 *    windows. If the application wants to add other additional menu
 *    items, it can use the SetApplicationDockTileMenu API to provide
 *    those items. The items in the specified menu will be combined
 *    with the window title items. This API increments the refcount of
 *    the specified menu. Before the menu is actually displayed, it
 *    will receive kEventMenuPopulate, kEventMenuOpening, and
 *    kEventMenuEnableItems Carbon events, so any event handlers for
 *    these events may update the menu appropriately for the current
 *    state of the application. The application should set a command ID
 *    for each menu item in the dock tile menu, and when that item is
 *    chosen, a kEventCommandProcess Carbon event containing the item's
 *    command ID will be sent to the user focus target.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inMenu:
 *      The menu to display, or NULL to remove the current dock tile
 *      menu.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.1 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.1 and later
 *    Non-Carbon CFM:   not available
 }
function SetApplicationDockTileMenu( inMenu: MenuRef ): OSStatus; external name '_SetApplicationDockTileMenu';
(* AVAILABLE_MAC_OS_X_VERSION_10_1_AND_LATER *)


{
 *  GetApplicationDockTileMenu()
 *  
 *  Summary:
 *    Returns the menu that is displayed by the application's dock tile.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Result:
 *    The application's dock tile menu, or NULL if none.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.1 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.1 and later
 *    Non-Carbon CFM:   not available
 }
function GetApplicationDockTileMenu: MenuRef; external name '_GetApplicationDockTileMenu';
(* AVAILABLE_MAC_OS_X_VERSION_10_1_AND_LATER *)


{
 *  CreateCGImageFromPixMaps()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
function CreateCGImageFromPixMaps( inImage: PixMapHandle; inMask: PixMapHandle; var outImage: CGImageRef ): OSStatus; external name '_CreateCGImageFromPixMaps';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetApplicationTextEncoding()
 *  
 *  Summary:
 *    Returns the application's primary text encoding.
 *  
 *  Discussion:
 *    The application text encoding is used when you create a
 *    CFStringRef from text stored in Resource Manager resources, which
 *    typically uses one of the Mac encodings such as MacRoman or
 *    MacJapanese. The encoding is determined by: (a) if your app is
 *    bundled, the encoding of the .lproj directory chosen by CFBundle,
 *    (b) else if your plist has a CFBundleDevelopmentRegionKey, the
 *    encoding specified by that key, (c) else if your app has a 'vers'
 *    resource, the encoding for the region field in the 'vers', (d)
 *    else the current localization of the operating system.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.2 and later
 *    Non-Carbon CFM:   not available
 }
function GetApplicationTextEncoding: TextEncoding; external name '_GetApplicationTextEncoding';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetApplicationScript()
 *  
 *  Summary:
 *    Returns the application script.
 *  
 *  Discussion:
 *    The application script is used when you need a ScriptCode to pass
 *    to some other API, such as UseThemeFont.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.3 and later
 *    Non-Carbon CFM:   not available
 }
function GetApplicationScript: ScriptCode; external name '_GetApplicationScript';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{------------------------------------------------------------------------------}
{  HIAboutBox                                                                  }
{  The strings below are for use as keys in the inOptions parameter of the     }
{  HIAboutBox function, described below.                                       }
{------------------------------------------------------------------------------}

{$ifc USE_CFSTR_CONSTANT_MACROS}
{$definec kHIAboutBoxNameKey CFSTRP('HIAboutBoxName')}
{$endc}
{$ifc USE_CFSTR_CONSTANT_MACROS}
{$definec kHIAboutBoxVersionKey CFSTRP('HIAboutBoxVersion')}
{$endc}
{$ifc USE_CFSTR_CONSTANT_MACROS}
{$definec kHIAboutBoxCopyrightKey CFSTRP('HIAboutBoxCopyright')}
{$endc}
{$ifc USE_CFSTR_CONSTANT_MACROS}
{$definec kHIAboutBoxDescriptionKey CFSTRP('HIAboutBoxDescription')}
{$endc}
{$ifc USE_CFSTR_CONSTANT_MACROS}
{$definec kHIAboutBoxStringFileKey CFSTRP('HIAboutBoxStringFile')}
{$endc}

{
 *  HIAboutBox()
 *  
 *  Summary:
 *    Displays an HI-conformant about box.
 *  
 *  Discussion:
 *    This about box is a generic about box that automatically can
 *    display your application name, version string, and copyright
 *    string. It peeks into either the Info.plist (for the
 *    CFBundleName, CFBundleVersion, and CFBundleGetInfoString keys) or
 *    your bundle resource (not recommended) to get the information by
 *    default. You can customize what it displays by passing in various
 *    options in the input dictionary. Note that currently the
 *    description string can only be specified in the options
 *    dictionary; this function does not check your Info.plist for a
 *    descriptions string. <br>
 *    There are three basic ways to call this function. First, you can
 *    pass NULL for inOptions. As mentioned, default information will
 *    be displayed. Second, you can pass the actual values for the
 *    strings displayed by passing the strings in the inOptions
 *    dictionary using the keys provided, such as kHIAboutBoxNameKey.
 *    If a replacement string is not passed, the default behavior kicks
 *    in. For example, you could pass some variant of your application
 *    name in the dictionary, but not pass a replacement version or
 *    copyright strings. The Toolbox would display your replacement
 *    string, and fall back to looking in the Info.plist for the other
 *    strings. The third way to call this is to pass the name of a
 *    string file in the dictionary with the key
 *    kHIAboutBoxStringFileKey. We will automatically use that file to
 *    find the strings for the about box. The keys in the string file
 *    should be the same value as the keys you would use to pass into
 *    the inOptions dictionary. Again, if a string is not found in that
 *    file, we would fall back to looking for a string in the
 *    dictionary, and then finally the Info.plist. 
 *    
 *    Certainly this is not the be-all-end-all of about boxes, but it
 *    does provide a simple no-work about box for your application. The
 *    standard Toolbox application handler now responds to the
 *    kHICommandAbout command ID by calling HIAboutBox for you. This
 *    means that any Carbon Event-based application will get this
 *    behavior for free right out of the box. If you wish for the
 *    window to respond to cmd-W in the menu bar, you should make sure
 *    that menu item has the kHICommandClose commandID.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inOptions:
 *      A dictionary of replacement strings, or the name of a string
 *      file to retrieve the strings from, or NULL. See the discussion
 *      for how this is used.
 *  
 *  Result:
 *    An operating system status code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIAboutBox( inOptions: CFDictionaryRef ): OSStatus; external name '_HIAboutBox';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HISearchWindowShow()
 *  
 *  Summary:
 *    Sends a message to the System UI server to put up Spotlight UI.
 *  
 *  Discussion:
 *    Brings up "search for string" Spotlight UI. The window is shown
 *    in the default configuration (Search scope and grouping rules)
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inSearchString:
 *      A CFString to search for. You may pass NULL to open the search
 *      window with no initial query string.
 *    
 *    inFlags:
 *      Optional flags. Use kNilOptions for now.
 *  
 *  Result:
 *    An operating system status code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.4 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.4 and later
 *    Non-Carbon CFM:   not available
 }
function HISearchWindowShow( inSearchString: CFStringRef { can be NULL }; inFlags: OptionBits ): OSStatus; external name '_HISearchWindowShow';
(* AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER *)


end.
