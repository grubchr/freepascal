{
 *  CGWindowLevel.h
 *  CoreGraphics
 *
 *  Copyright (c) 2000 Apple Computer, Inc. All rights reserved.
 *
 }
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

unit CGWindowLevels;
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
uses MacTypes,CGBase;
{$ALIGN POWER}


{
 * Windows may be assigned to a particular level. When assigned to a level,
 * the window is ordered relative to all other windows in that level.
 * Windows with a higher level are sorted in front of windows with a lower
 * level.
 *
 * A common set of window levels is defined here for use within higher
 * level frameworks.  The levels are accessed via a key and function,
 * so that levels may be changed or adjusted in future releases without
 * breaking binary compatability.
 }

type
	CGWindowLevel = SInt32;
type
	CGWindowLevelKey = SInt32;

type
	_CGCommonWindowLevelKey = SInt32;
const
	kCGBaseWindowLevelKey = 0;
	kCGMinimumWindowLevelKey = 1;
	kCGDesktopWindowLevelKey = 2;
	kCGBackstopMenuLevelKey = 3;
	kCGNormalWindowLevelKey = 4;
	kCGFloatingWindowLevelKey = 5;
	kCGTornOffMenuWindowLevelKey = 6;
	kCGDockWindowLevelKey = 7;
	kCGMainMenuWindowLevelKey = 8;
	kCGStatusWindowLevelKey = 9;
	kCGModalPanelWindowLevelKey = 10;
	kCGPopUpMenuWindowLevelKey = 11;
	kCGDraggingWindowLevelKey = 12;
	kCGScreenSaverWindowLevelKey = 13;
	kCGMaximumWindowLevelKey = 14;
	kCGOverlayWindowLevelKey = 15;
	kCGHelpWindowLevelKey = 16;
	kCGUtilityWindowLevelKey = 17;
	kCGDesktopIconWindowLevelKey = 18;
	kCGCursorWindowLevelKey = 19;
	kCGAssistiveTechHighWindowLevelKey = 20;
	kCGNumberOfWindowLevelKeys = 21;	{ Internal bookkeeping; must be last }

function CGWindowLevelForKey( key: CGWindowLevelKey ): CGWindowLevel; external name '_CGWindowLevelForKey';

{ number of levels above kCGMaximumWindowLevel reserved for internal use }
const
	kCGNumReservedWindowLevels = 16;

(*
{ Definitions of older constant values as calls }
#define kCGBaseWindowLevel		CGWindowLevelForKey(kCGBaseWindowLevelKey)	{ LONG_MIN }
#define kCGMinimumWindowLevel 		CGWindowLevelForKey(kCGMinimumWindowLevelKey)	{ (kCGBaseWindowLevel + 1) }
#define kCGDesktopWindowLevel		CGWindowLevelForKey(kCGDesktopWindowLevelKey)	{ kCGMinimumWindowLevel }
#define kCGDesktopIconWindowLevel		CGWindowLevelForKey(kCGDesktopIconWindowLevelKey)	{ kCGMinimumWindowLevel + 20 }
#define kCGBackstopMenuLevel		CGWindowLevelForKey(kCGBackstopMenuLevelKey)	{ -20 }
#define kCGNormalWindowLevel		CGWindowLevelForKey(kCGNormalWindowLevelKey)	{ 0 }
#define kCGFloatingWindowLevel		CGWindowLevelForKey(kCGFloatingWindowLevelKey)	{ 3 }
#define kCGTornOffMenuWindowLevel	CGWindowLevelForKey(kCGTornOffMenuWindowLevelKey)	{ 3 }
#define kCGDockWindowLevel		CGWindowLevelForKey(kCGDockWindowLevelKey)	{ 20 }
#define kCGMainMenuWindowLevel		CGWindowLevelForKey(kCGMainMenuWindowLevelKey)	{ 24 }
#define kCGStatusWindowLevel		CGWindowLevelForKey(kCGStatusWindowLevelKey)	{ 25 }
#define kCGModalPanelWindowLevel	CGWindowLevelForKey(kCGModalPanelWindowLevelKey)	{ 8 }
#define kCGPopUpMenuWindowLevel		CGWindowLevelForKey(kCGPopUpMenuWindowLevelKey)	{ 101 }
#define kCGDraggingWindowLevel		CGWindowLevelForKey(kCGDraggingWindowLevelKey)	{ 500 }
#define kCGScreenSaverWindowLevel	CGWindowLevelForKey(kCGScreenSaverWindowLevelKey)	{ 1000 }
#define kCGCursorWindowLevel		CGWindowLevelForKey(kCGCursorWindowLevelKey)	{ 2000 }
#define kCGOverlayWindowLevel		CGWindowLevelForKey(kCGOverlayWindowLevelKey)	{ 102 }
#define kCGHelpWindowLevel		CGWindowLevelForKey(kCGHelpWindowLevelKey)	{ 102 }
#define kCGUtilityWindowLevel		CGWindowLevelForKey(kCGUtilityWindowLevelKey)	{ 19 }

#define kCGAssistiveTechHighWindowLevel		CGWindowLevelForKey(kCGAssistiveTechHighWindowLevelKey)	{ 1500 }

#define kCGMaximumWindowLevel 		CGWindowLevelForKey(kCGMaximumWindowLevelKey)	{ LONG_MAX - kCGNumReservedWindowLevels }
*)

end.
