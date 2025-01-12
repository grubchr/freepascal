{
     File:       CarbonCore/DriverServices.h
 
     Contains:   Driver Services Interfaces.
 
     Version:    CarbonCore-783~2
 
     Copyright:  � 1985-2006 by Apple Computer, Inc., all rights reserved
 
}

{	 Pascal Translation:  Gale R Paeper, <gpaeper@empirenet.com>, 2008 }

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

unit DriverServices;
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
uses MacTypes;
{$ALIGN POWER}


const
	durationMicrosecond = -1;  { Microseconds are negative}
	durationMillisecond = 1;   { Milliseconds are positive}
	durationSecond = 1000; { 1000 * durationMillisecond}
	durationMinute = 60000; { 60 * durationSecond,}
	durationHour = 3600000; { 60 * durationMinute,}
	durationDay = 86400000; { 24 * durationHour,}
	durationNoWait = 0;   { don't block}
	durationForever = $7FFFFFFF; { no time limit}


type
	Nanoseconds = UnsignedWide;
{
 *  UpTime()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function UpTime: AbsoluteTime; external name '_UpTime';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetTimeBaseInfo()
 *  
 *  Availability:
 *    Mac OS X:         not available
 *    CarbonLib:        not available
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }


{
 *  AbsoluteToNanoseconds()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function AbsoluteToNanoseconds( absoluteTime_: AbsoluteTime ): Nanoseconds; external name '_AbsoluteToNanoseconds';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  AbsoluteToDuration()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function AbsoluteToDuration( absoluteTime_: AbsoluteTime ): Duration; external name '_AbsoluteToDuration';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  NanosecondsToAbsolute()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function NanosecondsToAbsolute( nanoseconds_: Nanoseconds ): AbsoluteTime; external name '_NanosecondsToAbsolute';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  DurationToAbsolute()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function DurationToAbsolute( duration_: Duration ): AbsoluteTime; external name '_DurationToAbsolute';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  AddAbsoluteToAbsolute()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function AddAbsoluteToAbsolute( absoluteTime1: AbsoluteTime; absoluteTime2: AbsoluteTime ): AbsoluteTime; external name '_AddAbsoluteToAbsolute';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SubAbsoluteFromAbsolute()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function SubAbsoluteFromAbsolute( leftAbsoluteTime: AbsoluteTime; rightAbsoluteTime: AbsoluteTime ): AbsoluteTime; external name '_SubAbsoluteFromAbsolute';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  AddNanosecondsToAbsolute()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function AddNanosecondsToAbsolute( nanoseconds_: Nanoseconds; absoluteTime_: AbsoluteTime ): AbsoluteTime; external name '_AddNanosecondsToAbsolute';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  AddDurationToAbsolute()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function AddDurationToAbsolute( duration_: Duration; absoluteTime_: AbsoluteTime ): AbsoluteTime; external name '_AddDurationToAbsolute';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SubNanosecondsFromAbsolute()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function SubNanosecondsFromAbsolute( nanoseconds_: Nanoseconds; absoluteTime_: AbsoluteTime ): AbsoluteTime; external name '_SubNanosecondsFromAbsolute';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SubDurationFromAbsolute()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function SubDurationFromAbsolute( duration_: Duration; absoluteTime_: AbsoluteTime ): AbsoluteTime; external name '_SubDurationFromAbsolute';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  AbsoluteDeltaToNanoseconds()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function AbsoluteDeltaToNanoseconds( leftAbsoluteTime: AbsoluteTime; rightAbsoluteTime: AbsoluteTime ): Nanoseconds; external name '_AbsoluteDeltaToNanoseconds';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  AbsoluteDeltaToDuration()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function AbsoluteDeltaToDuration( leftAbsoluteTime: AbsoluteTime; rightAbsoluteTime: AbsoluteTime ): Duration; external name '_AbsoluteDeltaToDuration';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  DurationToNanoseconds()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function DurationToNanoseconds( theDuration: Duration ): Nanoseconds; external name '_DurationToNanoseconds';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  NanosecondsToDuration()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0.2 and later
 *    Non-Carbon CFM:   in InterfaceLib 8.6 and later
 }
function NanosecondsToDuration( theNanoseconds: Nanoseconds ): Duration; external name '_NanosecondsToDuration';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

end.
