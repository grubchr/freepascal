{
     File:       HIServices/Processes.h
 
     Contains:   Process Manager Interfaces.
 
     Version:    HIServices-162.0.81~21
 
     Copyright:  � 1989-2005 by Apple Computer, Inc., all rights reserved
 
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

unit Processes;
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
uses MacTypes,CFBase,CFDictionary,Quickdraw,AEDataModel,Events,Files,TextCommon,CFString,MacOSXPosix;


{$ALIGN MAC68K}

const
{ Process identifier - Various reserved process serial numbers }
	kNoProcess = 0;
	kSystemProcess = 1;
	kCurrentProcess = 2;

{ Definition of the parameter block passed to _Launch }
{ Typedef and flags for launchControlFlags field}
type
	LaunchFlags = UInt16;
const
	launchContinue = $4000;
	launchNoFileFlags = $0800;
	launchUseMinimum = $0400;
	launchDontSwitch = $0200;
	launchAllow24Bit = $0100;
	launchInhibitDaemon = $0080;

{ Format for first AppleEvent to pass to new process. The size of the overall
  buffer variable: the message body immediately follows the messageLength }
type
	AppParameters = record
		theMsgEvent: EventRecord;
		eventRefCon: UInt32;
		messageLength: UInt32;
	end;
	AppParametersPtr = ^AppParameters;
{ Parameter block to _Launch }
type
	LaunchParamBlockRecPtr = ^LaunchParamBlockRec;
	LaunchParamBlockRec = record
		reserved1: UInt32;
		reserved2: UInt16;
		launchBlockID: UInt16;
		launchEPBLength: UInt32;
		launchFileFlags: UInt16;
		launchControlFlags: LaunchFlags;
		launchAppSpec: FSSpecPtr;
		launchProcessSN: ProcessSerialNumber;
		launchPreferredSize: UInt32;
		launchMinimumSize: UInt32;
		launchAvailableSize: UInt32;
		launchAppParameters: AppParametersPtr;
	end;
type
	LaunchPBPtr = LaunchParamBlockRecPtr;
{ Set launchBlockID to extendedBlock to specify that extensions exist.
 Set launchEPBLength to extendedBlockLen for compatibility.}
const
	extendedBlock = $4C43; { 'LC' }
	extendedBlockLen = SizeOf(LaunchParamBlockRec) - 12;

const
{ Definition of the information block returned by GetProcessInformation }
	modeReserved = $01000000;
	modeControlPanel = $00080000;
	modeLaunchDontSwitch = $00040000;
	modeDeskAccessory = $00020000;
	modeMultiLaunch = $00010000;
	modeNeedSuspendResume = $00004000;
	modeCanBackground = $00001000;
	modeDoesActivateOnFGSwitch = $00000800;
	modeOnlyBackground = $00000400;
	modeGetFrontClicks = $00000200;
	modeGetAppDiedMsg = $00000100;
	mode32BitCompatible = $00000080;
	modeHighLevelEventAware = $00000040;
	modeLocalAndRemoteHLEvents = $00000020;
	modeStationeryAware = $00000010;
	modeUseTextEditServices = $00000008;
	modeDisplayManagerAware = $00000004;

type
	ProcessApplicationTransformState = UInt32;
const
	kProcessTransformToForegroundApplication = 1;

{
   Record returned by GetProcessInformation
    When calling GetProcessInformation(), the input ProcessInfoRec
    should have the processInfoLength set to sizeof(ProcessInfoRec),
    the processName field set to nil or a pointer to a Str255, and
    processAppSpec set to nil or a pointer to an FSSpec. If
    processName or processAppSpec are not specified, this routine
    will very likely write data to whatever random location in memory
    these happen to point to, which is not a good thing.
    Note:  The processName field may not be what you expect, especially if
    an application has a localized name. The .processName field, if not NULL,
    on return will contain the filename part of the executable file of the
    application. If you want the localized, user-displayable name for an 
    application, call CopyProcessName().
    On Mac OS X, some flags in processMode will not be set as they were on
    Mac OS 9, even for Classic applications.  Mac OS X doesn't support
    applications which can't be sent into the background, so 
    modeCanBackground will always be set.  Similarly, Mac OS X applications
    will always have mode32BitCompatible and modeHighLevelEventAware
    set.
    
}
type
	ProcessInfoRec = record
		processInfoLength: UInt32;
		processName: StringPtr;
		processNumber: ProcessSerialNumber;
		processType: UInt32;
		processSignature: OSType;
		processMode: UInt32;
		processLocation: Ptr;
		processSize: UInt32;
		processFreeMem: UInt32;
		processLauncher: ProcessSerialNumber;
		processLaunchDate: UInt32;
		processActiveTime: UInt32;
		processAppSpec: FSSpecPtr;
	end;
	ProcessInfoRecPtr = ^ProcessInfoRec;
{
    Some applications assumed the size of a ProcessInfoRec would never change,
    which has caused problems trying to return additional information. In
    the future, we will add fields to ProcessInfoExtendedRec when necessary,
    and callers which wish to access 'more' data than originally was present
    in ProcessInfoRec should allocate space for a ProcessInfoExtendedRec,
    fill in the processInfoLength ( and processName and processAppSpec ptrs ),
    then coerce this to a ProcessInfoRecPtr in the call to
    GetProcessInformation().
    Note:  The processName field may not be what you expect, especially if
    an application has a localized name. The .processName field, if not NULL,
    on return will contain the filename part of the executable file of the
    application. If you want the localized, user-displayable name for an 
    application, call CopyProcessName().
    On Mac OS X, some flags in processMode will not be set as they were on
    Mac OS 9, even for Classic applications.  Mac OS X doesn't support
    applications which can't be sent into the background, so 
    modeCanBackground will always be set.  Similarly, Mac OS X applications
    will always have mode32BitCompatible and modeHighLevelEventAware
    set.
    
}
type
	ProcessInfoExtendedRec = record
		processInfoLength: UInt32;
		processName: StringPtr;
		processNumber: ProcessSerialNumber;
		processType: UInt32;
		processSignature: OSType;
		processMode: UInt32;
		processLocation: Ptr;
		processSize: UInt32;
		processFreeMem: UInt32;
		processLauncher: ProcessSerialNumber;
		processLaunchDate: UInt32;
		processActiveTime: UInt32;
		processAppSpec: FSSpecPtr;
		processTempMemTotal: UInt32;
		processPurgeableTempMemTotal: UInt32;
	end;
	ProcessInfoExtendedRecPtr = ^ProcessInfoExtendedRec;
{ Record corresponding to the SIZE resource definition }
type
	SizeResourceRec = record
		flags: UInt16;
		preferredHeapSize: UInt32;
		minimumHeapSize: UInt32;
	end;
	SizeResourceRecPtr = ^SizeResourceRec;
type
	SizeResourceRecHandle = ^SizeResourceRecPtr;

{
 *  Summary:
 *    Options for ProcessInformationCopyDictionary
 }
const
{
   * Return all information known about the application in the
   * dictionary.
   }
	kProcessDictionaryIncludeAllInformationMask = $FFFFFFFF;

{
    Applications and background applications can control when they are asked to quit
    by the system at restart/shutdown by setting these bits in a 'quit' ( 0 ) resource
    in their application's resource fork. Applications without a 'quit' ( 0 ) will
    be quit at kQuitAtNormalTime mask.
    These options only function on Mac OS 9.x at this time.
}
const
	kQuitBeforeNormalTimeMask = 1;
	kQuitAtNormalTimeMask = 2;
	kQuitBeforeFBAsQuitMask = 4;
	kQuitBeforeShellQuitsMask = 8;
	kQuitBeforeTerminatorAppQuitsMask = 16;
	kQuitNeverMask = 32;
	kQuitOptionsMask = $7F;
	kQuitNotQuitDuringInstallMask = $0100;
	kQuitNotQuitDuringLogoutMask = $0200;


{
 *  LaunchApplication()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function LaunchApplication( LaunchParams: LaunchPBPtr ): OSErr; external name '_LaunchApplication';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  LaunchDeskAccessory()
 *  
 *  Availability:
 *    Mac OS X:         not available
 *    CarbonLib:        not available
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }


{
 *  [Mac]GetCurrentProcess()
 *  
 *  Discussion:
 *    Return the canonical process serial number to the caller.
 *    
 *    All applications ( things which can appear in the Dock or which
 *    are not documents and are launched by the Finder or Dock ) on Mac
 *    OS 10 have a unique process serial number. This number is created
 *    when the application launches, and remains until the application
 *    quits. Other system services, like AppleEvents, use the
 *    ProcessSerialNumber to specify an application.
 *    
 *    During launch, every application 'checks in' with the Process
 *    Manager. Before this checkin, the application can not receive
 *    events or draw to the screen. Prior to Mac OS 10.2, this 'check
 *    in' happened before the applications's main() function was
 *    entered. In Mac OS 10.2 and later, this 'check in' does not
 *    happen until the first time the application calls a Process
 *    Manager function, or until it enters CFRunLoopRun() for the main
 *    runloop. This allows tools and other executables which do not
 *    need to receive events to link against more of the higher level
 *    toolbox frameworks, but may cause a problem if the application
 *    expects to be able to retrieve events or use CoreGraphics
 *    services before this checkin has occurred.
 *    
 *    An application can force the connection to the Process Manager to
 *    be set up by calling any Process Manager routine, but the
 *    recommended way to do this is to call GetCurrentProcess() to ask
 *    for the current application's PSN. This will initialize the
 *    connection to the Process Manager if it has not already been set
 *    up and 'check in' the application with the system.
 *    
 *    This function is named MacGetCurrentProcess() on non Macintosh
 *    platforms and GetCurrentProcess on the Macintosh. However, even
 *    Macintosh code can use the MacGetCurrentProcess() name since
 *    there is a macro which maps back to GetCurrentProcess().
 *    
 *    Lastly, it is usually not necessary to call GetCurrentProcess()
 *    to get the 'current' process psn merely to pass it to another
 *    Process Manager routine. Instead, just construct a
 *    ProcessSerialNumber with 0 in highLongOfPSN and kCurrentProcess
 *    in lowLongOfPSN and pass that. For example, to make the current
 *    process the frontmost process, use ( C code follows )
 *    
 *    ProcessSerialNumber psn = ( 0, kCurrentProcess ); 
 *    
 *    OSErr err = SetFrontProcess( & psn );
 *    
 *    If you need to pass a ProcessSerialNumber to another application
 *    or use it in an AppleEvent, you do need to get the canonical PSN
 *    with this routine.
 *  
 *  Parameters:
 *    
 *    PSN:
 *      Pass in where the current application process serial number
 *      should be returned.
 *  
 *  Result:
 *    An operating system status code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function GetCurrentProcess( var PSN: ProcessSerialNumber ): OSErr; external name '_GetCurrentProcess';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)
function MacGetCurrentProcess( var PSN: ProcessSerialNumber ): OSErr; external name '_GetCurrentProcess';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetFrontProcess()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function GetFrontProcess( var PSN: ProcessSerialNumber ): OSErr; external name '_GetFrontProcess';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetNextProcess()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function GetNextProcess( var PSN: ProcessSerialNumber ): OSErr; external name '_GetNextProcess';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetProcessInformation()
 *  
 *  Discussion:
 *    Fill in the provided record with information about the process
 *    with the provided process serial number.
 *    
 *    The caller must fill in the .processInfoLength field with the
 *    value sizeof ( ProcessInformationRecord ) before making this
 *    call. Also, the .processName field must point to either NULL or
 *    to a Str31 structure in the caller's memory space, and the
 *    .processAppSpec field must point to a FSSpec in the caller's
 *    memory space.
 *    
 *    If the caller does not care about the process name or the process
 *    application spec values, then setting those fields in the
 *    structure to NULL before this call means less work must be done
 *    to construct these values and so the call is more
 *    efficient.
 *    
 *    The processName field may not be what you expect, especially if
 *    an application has a localized name. The .processName field, if
 *    not NULL, on return will contain the filename part of the
 *    executable file of the application. If you want the localized,
 *    user-displayable name for an application, call
 *    CopyProcessName().
 *    
 *    On Mac OS X, the processSize and processFreeMem fields are
 *    returned with the value 0.
 *  
 *  Parameters:
 *    
 *    PSN:
 *      Pass in the process serial number of the process to return
 *      information for.
 *    
 *    info:
 *      Pass in a structure where the information will be returned.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function GetProcessInformation( const (*var*) PSN: ProcessSerialNumber; var info: ProcessInfoRec ): OSErr; external name '_GetProcessInformation';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  ProcessInformationCopyDictionary()
 *  
 *  Discussion:
 *    Return a CFDictionary containing information about the given
 *    process. This is intended to return a superset of the information
 *    returned by GetProcessInformation(), in more modern datatypes.
 *  
 *  Parameters:
 *    
 *    PSN:
 *      Pass in the process serial number of the process to return
 *      information for.
 *    
 *    infoToReturn:
 *      Pass in the value kProcessDictionaryIncludeAllInformationMask.
 *  
 *  Result:
 *    An immutable CFDictionaryRef containing these keys and their
 *    values. Keys marked with a '*' are optional. Over time more keys
 *    may be added.
 *    
 *    Key Name                    Type 
 *    --------                    ---- 
 *    "PSN"                       CFNumber, kCFNumberLongLongType 
 *     "Flavor"                    CFNumber, kCFNumberSInt32.  A hint
 *    as to the flavor of the application. Note that this should only
 *    be used as a hint, since a bundle of a different flavor might be
 *    loaded into an application's address space.  The assigned values
 *    at present are:  Mac OS Classic aplications have the value 0,
 *    Carbon applications have the value 2, Cocoa applications have the
 *    value 4. Other undocumented values may also be returned.
 *     "Attributes"                CFNumber, kCFNumberSInt32 
 *     "ParentPSN" *               CFNumber, kCFNumberLongLong 
 *     "FileType" *                CFString, file type 
 *     "FileCreator" *             CFString, file creator 
 *    "pid" *                     CFNumber, kCFNumberLongType 
 *     "LSBackgroundOnly"          CFBoolean 
 *    "LSUIElement"               CFBoolean 
 *    "IsHiddenAttr"              CFBoolean 
 *    "IsCheckedInAttr"           CFBoolean 
 *    "RequiresClassic"           CFBoolean 
 *    "RequiresCarbon"            CFBoolean 
 *    "LSUserQuitOnly"            CFBoolean 
 *    "LSUIPresentationMode"      CFNumber, kCFNumberShortType 
 *     "BundlePath" *              CFString 
 *    kIOBundleExecutableKey *    CFString 
 *    kIOBundleNameKey *          CFString 
 *    kIOBundleIdentifierKey *    CFString
 *  
 *  Availability:
 *    Mac OS X:         in version 10.2 and later in ApplicationServices.framework
 *    CarbonLib:        not available in CarbonLib 1.x
 *    Non-Carbon CFM:   not available
 }
function ProcessInformationCopyDictionary( const (*var*) PSN: ProcessSerialNumber; infoToReturn: UInt32 ): CFDictionaryRef; external name '_ProcessInformationCopyDictionary';
(* AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER *)


{
 *  SetFrontProcess()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function SetFrontProcess( const (*var*) PSN: ProcessSerialNumber ): OSErr; external name '_SetFrontProcess';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  Summary:
 *    Options for SetFrontProcessWithOptions
 }
const
{
   * Activate the process, but bring only the frontmost non-floating
   * window forward. If this option is not set, all process windows are
   * brought forward.
   }
	kSetFrontProcessFrontWindowOnly = 1 shl 0;


{
 *  SetFrontProcessWithOptions()
 *  
 *  Discussion:
 *    Brings a process to the front of the process list and activates
 *    it. This is much like the SetFrontProcess API, though we allow
 *    more control here. Passing 0 for the options is equivalent to
 *    calling SetFrontProcess. Alternatively, you can pass
 *    kSetFrontProcessFrontWindowOnly, which will activate a process
 *    without bringing all of the process's windows forward (just the
 *    front window of the process will come forward).
 *  
 *  Parameters:
 *    
 *    inProcess:
 *      The process to make frontmost.
 *    
 *    inOptions:
 *      Any options you wish to specify.
 *  
 *  Result:
 *    An operating system status code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.2 and later in ApplicationServices.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.2 and later
 *    Non-Carbon CFM:   not available
 }
function SetFrontProcessWithOptions( const (*var*) inProcess: ProcessSerialNumber; inOptions: OptionBits ): OSStatus; external name '_SetFrontProcessWithOptions';
(* AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER *)


{
 *  WakeUpProcess()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function WakeUpProcess( const (*var*) PSN: ProcessSerialNumber ): OSErr; external name '_WakeUpProcess';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SameProcess()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function SameProcess( const (*var*) PSN1: ProcessSerialNumber; const (*var*) PSN2: ProcessSerialNumber; var result: Boolean ): OSErr; external name '_SameProcess';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{  ExitToShell was previously in SegLoad.h}
{
 *  ExitToShell()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
procedure ExitToShell; external name '_ExitToShell';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  KillProcess()
 *  
 *  Discussion:
 *    Kills the process with the given process serial number, without
 *    sending it a 'quit' AppleEvent or otherwise allowing it to save
 *    user data or clean up. This should be a last resort way to 'kill'
 *    an application, after all other attempts to make it stop have
 *    failed. It is not guaranteed that this will succeed and that the
 *    target application will be killed, even if this function returns
 *    noErr and seems to work.
 *  
 *  Parameters:
 *    
 *    inProcess:
 *      The process to kill.
 *  
 *  Result:
 *    An operating system status code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.2 and later in ApplicationServices.framework
 *    CarbonLib:        not available in CarbonLib 1.x
 *    Non-Carbon CFM:   not available
 }
function KillProcess( const (*var*) inProcess: ProcessSerialNumber ): OSErr; external name '_KillProcess';
(* AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER *)


{
   LaunchControlPanel is similar to LaunchDeskAccessory, but for Control Panel files instead.
   It launches a control panel in an application shell maintained by the Process Manager.
}
{
 *  LaunchControlPanel()
 *  
 *  Availability:
 *    Mac OS X:         not available
 *    CarbonLib:        not available
 *    Non-Carbon CFM:   in InterfaceLib 9.0 and later
 }


{
 *  GetProcessBundleLocation()
 *  
 *  Summary:
 *    Retrieve the filesystem location of the process bundle, or
 *    executable if unbundled.
 *  
 *  Discussion:
 *    Retrieves a reference to the filesystem location of the specified
 *    application. For an application that is packaged as an app
 *    bundle, this will be the app bundle directory; otherwise it will
 *    be the location of the executable itself.
 *  
 *  Parameters:
 *    
 *    psn:
 *      Serial number of the target process
 *    
 *    location:
 *      Location of the bundle or executable, as an FSRef
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.5 and later
 *    Non-Carbon CFM:   not available
 }
function GetProcessBundleLocation( const (*var*) psn: ProcessSerialNumber; var location: FSRef ): OSStatus; external name '_GetProcessBundleLocation';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  CopyProcessName()
 *  
 *  Summary:
 *    Get a copy of the name of a process.
 *  
 *  Discussion:
 *    Use this call to get the name of a process as a CFString. The
 *    name returned is a copy, so the caller must CFRelease the name
 *    when finished with it. The difference between this call and the
 *    processName field filled in by GetProcessInformation is that the
 *    name here is a CFString, and thus is capable of representing a
 *    multi-lingual name, whereas previously only a mac-encoded string
 *    was possible.
 *  
 *  Parameters:
 *    
 *    psn:
 *      Serial number of the target process
 *    
 *    name:
 *      CFString representing the name of the process (must be released
 *      by caller with CFRelease)
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.5 and later
 *    Non-Carbon CFM:   not available
 }
function CopyProcessName( const (*var*) psn: ProcessSerialNumber; var name: CFStringRef ): OSStatus; external name '_CopyProcessName';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetProcessPID()
 *  
 *  Summary:
 *    Get the UNIX process ID corresponding to a process.
 *  
 *  Discussion:
 *    Given a Process serial number, this call will get the UNIX
 *    process ID for that process. Note that this call does not make
 *    sense for Classic apps, since they all share a single UNIX
 *    process ID.
 *  
 *  Parameters:
 *    
 *    psn:
 *      Serial number of the target process
 *    
 *    pid:
 *      UNIX process ID of the process
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
function GetProcessPID( const (*var*) psn: ProcessSerialNumber; var pid: pid_t ): OSStatus; external name '_GetProcessPID';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetProcessForPID()
 *  
 *  Summary:
 *    Get the process serial number corresponding to a UNIX process ID.
 *  
 *  Discussion:
 *    Given a UNIX process ID, this call will get the process serial
 *    number for that process, if appropriate. Note that this call does
 *    not make sense for Classic apps, since they all share a single
 *    UNIX process ID.
 *  
 *  Parameters:
 *    
 *    psn:
 *      Serial number of the process
 *    
 *    pid:
 *      UNIX process ID of the target process
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
function GetProcessForPID( pid: pid_t; var psn: ProcessSerialNumber ): OSStatus; external name '_GetProcessForPID';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{************************************************************************
 *  Process Visibility.
 ************************************************************************}
{
 *  IsProcessVisible()
 *  
 *  Summary:
 *    Determines whether a particular process is visible or not.
 *  
 *  Discussion:
 *    Given a psn, this call will return true or false depending on
 *    whether or not the process is currently visible.
 *  
 *  Parameters:
 *    
 *    psn:
 *      Serial number of the process
 *  
 *  Availability:
 *    Mac OS X:         in version 10.1 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.5 and later
 *    Non-Carbon CFM:   not available
 }
function IsProcessVisible( const (*var*) psn: ProcessSerialNumber ): Boolean; external name '_IsProcessVisible';
(* AVAILABLE_MAC_OS_X_VERSION_10_1_AND_LATER *)


{
 *  ShowHideProcess()
 *  
 *  Summary:
 *    Hides or shows a given process.
 *  
 *  Discussion:
 *    Given a psn, this call will hide or show the process specified in
 *    the psn parameter. You determine whether you would like to show
 *    or hide the process with the visible parameter. True passed into
 *    visible indicates you wish for the process to become visible.
 *  
 *  Parameters:
 *    
 *    psn:
 *      Serial number of the process
 *    
 *    visible:
 *      true = show process; false = hide process
 *  
 *  Availability:
 *    Mac OS X:         in version 10.1 and later in ApplicationServices.framework
 *    CarbonLib:        in CarbonLib 1.5 and later
 *    Non-Carbon CFM:   not available
 }
function ShowHideProcess( const (*var*) psn: ProcessSerialNumber; visible: Boolean ): OSErr; external name '_ShowHideProcess';
(* AVAILABLE_MAC_OS_X_VERSION_10_1_AND_LATER *)


{
 *  TransformProcessType()
 *  
 *  Summary:
 *    Changes the 'type' of the process specified in the psn parameter.
 *     The type is specified in the transformState parameter.
 *  
 *  Discussion:
 *    Given a psn which is a background-only application, this call can
 *    cause that application to be transformed into a foreground
 *    application.  A background only application does not appear in
 *    the Dock or in the Force Quit dialog, and never has a menu bar or
 *    is frontmost, while a foreground application does appear in the
 *    Dock and Force Quit dialog and does have a menu bar.  This call
 *    does not cause the application to be brought to the front ( use
 *    SetFrontProcess for that ).
 *  
 *  Parameters:
 *    
 *    psn:
 *      Serial number of the process
 *    
 *    transformState:
 *      state to tranform the application to.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in ApplicationServices.framework
 *    CarbonLib:        not available in CarbonLib 1.x
 *    Non-Carbon CFM:   not available
 }
function TransformProcessType( const (*var*) psn: ProcessSerialNumber; transformState: ProcessApplicationTransformState ): OSStatus; external name '_TransformProcessType';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{ Values of the 'message' parameter to a Control Panel 'cdev' }
const
	initDev = 0;    {Time for cdev to initialize itself}
	hitDev = 1;    {Hit on one of my items}
	closeDev = 2;    {Close yourself}
	nulDev = 3;    {Null event}
	updateDev = 4;    {Update event}
	activDev = 5;    {Activate event}
	deactivDev = 6;    {Deactivate event}
	keyEvtDev = 7;    {Key down/auto key}
	macDev = 8;    {Decide whether or not to show up}
	undoDev = 9;
	cutDev = 10;
	copyDev = 11;
	pasteDev = 12;
	clearDev = 13;
	cursorDev = 14;

{ Special values a Control Panel 'cdev' can return }
const
	cdevGenErr = -1;   {General error; gray cdev w/o alert}
	cdevMemErr = 0;    {Memory shortfall; alert user please}
	cdevResErr = 1;    {Couldn't get a needed resource; alert}
	cdevUnset = 3;     { cdevValue is initialized to this}

{ Control Panel Default Proc }




end.
