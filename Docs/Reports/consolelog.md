默认	20:38:24.128639+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [osservice<com.apple.coreservices.launchservicesd>:368] with description <RBSAssertionDescriptor| "frontmost:60949" ID:402-368-17028 target:60949 attributes:[
	<RBSDomainAttribute| domain:"com.apple.launchservicesd" name:"RoleUserInteractiveFocal" sourceEnvironment:"(null)">
	]>
默认	20:38:24.129157+0800	WindowServer	c752b[SetFrontProcess]: [DeferringManager] Updating policy {
    advicePolicy: .frontmost;
    frontmostProcess: 0x0-0x254254 (Nota4) mainConnectionID: B79A3;
} for reason: updated frontmost process
默认	20:38:24.129318+0800	WindowServer	c752b[SetFrontProcess]: [DeferringManager] Deferring events from frontmost process PSN 0x0-0x254254 (Nota4) -> <pid: 60949>
默认	20:38:24.129654+0800	runningboardd	Assertion 402-368-17028 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:38:24.129508+0800	WindowServer	new deferring rules for pid:398: [
    [398-5C6]; <keyboardFocus; Nota4:0x0-0x254254>; () -> <pid: 60949>; reason: frontmost PSN --> outbound target,
    [398-5C5]; <keyboardFocus; <frontmost>>; () -> <token: Nota4:0x0-0x254254; pid: 398>; reason: frontmost PSN,
    [398-5C4]; <keyboardFocus>; () -> <token: <frontmost>; pid: 398>; reason: Deferring to <frontmost>
]
默认	20:38:24.129575+0800	WindowServer	[keyboardFocus 0x8b5f445f0] setRules:forPID(398): [
    [398-5C6]; <keyboardFocus; Nota4:0x0-0x254254>; () -> <pid: 60949>; reason: frontmost PSN --> outbound target,
    [398-5C5]; <keyboardFocus; <frontmost>>; () -> <token: Nota4:0x0-0x254254; pid: 398>; reason: frontmost PSN,
    [398-5C4]; <keyboardFocus>; () -> <token: <frontmost>; pid: 398>; reason: Deferring to <frontmost>
]
默认	20:38:24.130676+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:38:24.130698+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:38:24.130738+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Set darwin role to: UserInteractiveFocal
默认	20:38:24.130776+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:38:24.130754+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:38:24.130781+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:38:24.134022+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [osservice<com.apple.WindowServer(88)>:398] with description <RBSAssertionDescriptor| "FUSBFrontmostProcess" ID:402-398-17029 target:60949 attributes:[
	<RBSDomainAttribute| domain:"com.apple.fuseboard" name:"Frontmost" sourceEnvironment:"(null)">,
	<RBSAcquisitionCompletionAttribute| policy:AfterApplication>
	]>
默认	20:38:24.134186+0800	runningboardd	Assertion 402-398-17029 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:38:24.150561+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:38:24.151053+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:38:24.150988+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [osservice<com.apple.coreservices.launchservicesd>:368] with description <RBSAssertionDescriptor| "notification:60949" ID:402-368-17030 target:60949 attributes:[
	<RBSDomainAttribute| domain:"com.apple.launchservicesd" name:"LSNotification" sourceEnvironment:"(null)">
	]>
默认	20:38:24.151190+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:38:24.151304+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:38:24.151329+0800	runningboardd	Assertion 402-368-17030 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:38:24.151335+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:38:24.159965+0800	Nota4	0x14c06c0c0 - [PID=0] WebProcessCache::setApplicationIsActive: (isActive=1)
默认	20:38:24.161731+0800	Nota4	<<<< Alt >>>> fpSupport_GetVideoRangeForCoreDisplayWithPreference: displayID 1 reported potentialHeadRoom=16 wideColorSupported=YES marz=NO almd=NO deviceAllowsHDR=YES isBuiltinPanel=YES externalPanel=YES prefersHDR10=NO
默认	20:38:24.162189+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:38:24.164251+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:38:24.164612+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:38:24.164663+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:38:24.164696+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:38:24.164830+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:38:24.171947+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:38:24.172491+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:38:24.172293+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app
默认	20:38:24.173002+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents
默认	20:38:24.173077+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/Info.plist
默认	20:38:24.173352+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app
默认	20:38:24.173799+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/MacOS/Nota4
默认	20:38:24.174019+0800	kernel	1 duplicate report for Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/MacOS/Nota4
默认	20:38:24.174024+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-xattr /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/MacOS/Nota4
默认	20:38:24.174453+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/Info.plist
默认	20:38:24.197105+0800	Nota4	PageClientImpl 0x14c000200 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:38:24.197110+0800	Nota4	PageClientImpl 0x14c000200 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:38:24.197266+0800	Nota4	WebContent[61014]: PerformanceMonitor::measureCPUUsageInActivityState: Process is using 0.1% CPU in state: <private>
默认	20:38:25.060203+0800	Nota4	PageClientImpl 0x14c000200 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:38:25.060221+0800	Nota4	PageClientImpl 0x14c000200 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:38:26.100421+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:26.161355+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:26.169406+0800	Nota4	PageClientImpl 0x14c000200 isViewVisible(): viewWindow 0x0, window visible 0, view hidden 0, window occluded 1
默认	20:38:26.169418+0800	Nota4	0x84a4bea18 - [pageProxyID=26, webPageID=27, PID=61014] WebPageProxy::updateActivityState: view visibility state changed 1 -> 0
默认	20:38:26.169424+0800	Nota4	PageClientImpl 0x14c000200 isViewVisible(): viewWindow 0x0, window visible 0, view hidden 0, window occluded 1
默认	20:38:26.169430+0800	Nota4	PageClientImpl 0x14c000200 isViewVisible(): viewWindow 0x0, window visible 0, view hidden 0, window occluded 1
默认	20:38:26.169435+0800	Nota4	0x84a4bea18 - [pageProxyID=26, webPageID=27, PID=61014] WebPageProxy::viewIsBecomingInvisible:
默认	20:38:26.169445+0800	Nota4	Screen Time has updated to hide the system shield for all URLs.
默认	20:38:26.169480+0800	Nota4	0x84a4bea18 - [pageProxyID=26, webPageID=27, PID=61014] WebPageProxy::updateThrottleState: UIProcess is releasing a foreground assertion because the view is no longer visible
默认	20:38:26.169487+0800	Nota4	0x14c1180f0 - [PID=61014, throttler=0x14c0a06d0] ProcessThrottler::Activity::Activity: Starting background activity / 'View was recently visible'
默认	20:38:26.169497+0800	Nota4	0x14c1183f0 - [PID=61014, throttler=0x14c0a06d0] ProcessThrottler::Activity::invalidate: Ending foreground activity / 'View is visible'
默认	20:38:26.169502+0800	Nota4	0x14c0a06d0 - [PID=61014] ProcessThrottler::setThrottleState: Updating process assertion type to 1 (foregroundActivities=0, backgroundActivities=2)
默认	20:38:26.169529+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::didChangeThrottleState: type=1
默认	20:38:26.169534+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::didChangeThrottleState(Background) Taking background assertion for network process
默认	20:38:26.169542+0800	Nota4	0x14c118150 - [PID=61011, throttler=0x14c120220] ProcessThrottler::Activity::Activity: Starting background activity / 'Networking for background view(s)'
默认	20:38:26.169538+0800	Nota4	0x14c1e01e0 - ProcessAssertion::acquireSync Trying to take RBS assertion 'WebProcess Background Assertion' for process with PID=61014
默认	20:38:26.169545+0800	Nota4	0x14c1182a0 - [PID=61011, throttler=0x14c120220] ProcessThrottler::Activity::invalidate: Ending foreground activity / 'Networking for foreground view(s)'
默认	20:38:26.169549+0800	Nota4	0x14c118180 - [PID=61010, throttler=0x14c114280] ProcessThrottler::Activity::Activity: Starting background activity / 'GPU for background view(s)'
默认	20:38:26.169553+0800	Nota4	0x14c1182d0 - [PID=61010, throttler=0x14c114280] ProcessThrottler::Activity::invalidate: Ending foreground activity / 'GPU for foreground view(s)'
默认	20:38:26.169766+0800	Nota4	WebContent[61014]: PerformanceMonitor::measureCPUUsageInActivityState: Process is using 1.6% CPU in state: <private>
默认	20:38:26.169955+0800	runningboardd	Acquiring assertion targeting [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014](WebProcess61014) from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] with description <RBSAssertionDescriptor| "WebProcess Background Assertion" ID:402-60949-17031 target:61014<WebProcess61014> attributes:[
	<RBSDomainAttribute| domain:"com.apple.webkit" name:"IndefiniteBackground" sourceEnvironment:"(null)">
	]>
默认	20:38:26.170298+0800	runningboardd	Assertion 402-60949-17031 (target:[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014](WebProcess61014)) will be created as active
默认	20:38:26.170517+0800	Nota4	0x14c1e01e0 - ProcessAssertion::acquireSync Successfully took RBS assertion 'WebProcess Background Assertion' for process with PID=61014
默认	20:38:26.174407+0800	runningboardd	Calculated state for xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014: running-active (role: UserInteractiveFocal) (endowments: (null))
默认	20:38:26.174987+0800	WindowServer	Received state update for 61014 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014, running-active-NotVisible
默认	20:38:26.175081+0800	gamepolicyd	Received state update for 61014 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014, running-active-NotVisible
默认	20:38:26.175334+0800	UIKitSystem	Received state update for 61014 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014, running-active-NotVisible
默认	20:38:26.821290+0800	Nota4	[0x845925400] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:38:26.833117+0800	Nota4	[0x845926f80] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:38:26.834281+0800	Nota4	[0x845926bc0] activating connection: mach=false listener=false peer=false name=com.apple.TextInputUI.xpc.CursorUIViewService
默认	20:38:26.835273+0800	Nota4	[0x845926bc0] invalidated after the last release of the connection object
默认	20:38:26.835413+0800	Nota4	[0x845926580] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:38:26.835531+0800	Nota4	[0x845926bc0] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:38:26.843872+0800	Nota4	0x84a4bea18 - [pageProxyID=26, webPageID=27, PID=61014] WebPageProxy::close:
默认	20:38:26.844239+0800	Nota4	PlaybackSessionManagerProxy::invalidate(29B13DE5)
默认	20:38:26.844254+0800	Nota4	PlaybackSessionManagerProxy::invalidate(29B13DE5)
默认	20:38:26.844310+0800	Nota4	PlaybackSessionManagerProxy::~VideoPresentationManagerProxy(29B13DE5)
默认	20:38:26.845109+0800	runningboardd	PERF: Received lookupHandleForPredicate request from [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] (euid 501, auid 501) (persona (null))
默认	20:38:26.844415+0800	Nota4	PlaybackSessionManagerProxy::invalidate(29B13DE5)
错误	20:38:26.846185+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] client not entitled to get limitationsForInstance: <Error Domain=RBSServiceErrorDomain Code=1 "Client not entitled" UserInfo={RBSEntitlement=com.apple.runningboard.process-state, NSLocalizedFailureReason=Client not entitled, RBSPermanent=false}>
默认	20:38:26.844510+0800	Nota4	PlaybackSessionManagerProxy::~PlaybackSessionManagerProxy(29B13DE5)
默认	20:38:26.844626+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::removeWebPage: webPage=0x84a4bea18, pageProxyID=26, webPageID=27
默认	20:38:26.844695+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::canTerminateAuxiliaryProcess: returns false (pageCount=0, provisionalPageCount=0, suspendedPageCount=0, m_isInProcessCache=0, m_shutdownPreventingScopeCounter=1)
默认	20:38:26.844815+0800	Nota4	0x14c1180f0 - [PID=61014, throttler=0x14c0a06d0] ProcessThrottler::Activity::invalidate: Ending background activity / 'View was recently visible'
默认	20:38:26.846514+0800	Nota4	0x14c0a06d0 - [PID=61014] ProcessThrottler::sendPrepareToSuspendIPC: Sending PrepareToSuspend(2, isSuspensionImminent=0) IPC, remainingRunTime=0.000000s
默认	20:38:26.846525+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::sendPrepareToSuspend: isSuspensionImminent=0
默认	20:38:26.846719+0800	Nota4	WebContent[61014]: [sessionID=1] WebProcess::prepareToSuspend: isSuspensionImminent=0, remainingRunTime=0.000117s
默认	20:38:26.846853+0800	Nota4	WebContent[61014] 0x10d020000 - [sessionID=1] WebProcess::releaseMemory: BEGIN
默认	20:38:26.846923+0800	Nota4	0x84a4bea18 - [pageProxyID=26, webPageID=27, PID=61014] WebPageProxy::destructor:
默认	20:38:26.847729+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::canTerminateAuxiliaryProcess: returns false (pageCount=0, provisionalPageCount=0, suspendedPageCount=0, m_isInProcessCache=0, m_shutdownPreventingScopeCounter=1)
默认	20:38:26.847743+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::canTerminateAuxiliaryProcess: returns true
默认	20:38:26.847755+0800	Nota4	0x14c06c0c0 - [PID=61014] WebProcessCache::canCacheProcess: Not caching process because the cache has no capacity
默认	20:38:26.848020+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::shutDown:
默认	20:38:26.848145+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::processWillShutDown:
默认	20:38:26.848153+0800	Nota4	0x14c1e0240 - ProcessAssertion::acquireSync Trying to take RBS assertion 'XPCConnectionTerminationWatchdog' for process with PID=61014
默认	20:38:26.848166+0800	Nota4	0x14c0a06d0 - [PID=61014] ProcessThrottler::processReadyToSuspend: Updating process assertion to allow suspension
默认	20:38:26.848264+0800	Nota4	0x14c0a06d0 - [PID=61014] ProcessThrottler::setThrottleState: Updating process assertion type to 0 (foregroundActivities=0, backgroundActivities=0)
默认	20:38:26.848335+0800	Nota4	0x14c0a06d0 - [PID=61014] ProcessThrottler::clearAssertion:
默认	20:38:26.848386+0800	Nota4	0x14c0a06d0 - [PID=61014] ProcessThrottler::clearAssertion: Releasing near-suspended assertion
默认	20:38:26.848732+0800	runningboardd	Acquiring assertion targeting [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014](WebProcess61014) from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] with description <RBSAssertionDescriptor| "XPCConnectionTerminationWatchdog" ID:402-60949-17032 target:61014<WebProcess61014> attributes:[
	<RBSDomainAttribute| domain:"com.apple.webkit" name:"IndefiniteBackground" sourceEnvironment:"(null)">
	]>
默认	20:38:26.848445+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::didChangeThrottleState: type=0
默认	20:38:26.848500+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::didChangeThrottleState(Suspended) Release all assertions for network process
默认	20:38:26.848551+0800	Nota4	0x14c118150 - [PID=61011, throttler=0x14c120220] ProcessThrottler::Activity::invalidate: Ending background activity / 'Networking for background view(s)'
默认	20:38:26.848598+0800	Nota4	0x14c118180 - [PID=61010, throttler=0x14c114280] ProcessThrottler::Activity::invalidate: Ending background activity / 'GPU for background view(s)'
默认	20:38:26.848661+0800	Nota4	0x14c0a06d0 - [PID=61014] ProcessThrottler::didDisconnectFromProcess:
默认	20:38:26.848736+0800	Nota4	0x14c0a0640 - [PID=61014] WebProcessProxy::destructor:
默认	20:38:26.850743+0800	Nota4	WebBackForwardCache::clear
默认	20:38:26.850801+0800	Nota4	0x14c0a06d0 - [PID=61014] ProcessThrottler::didDisconnectFromProcess:
默认	20:38:26.850840+0800	Nota4	0x14c0c4220 - ~ProcessAssertion: Releasing process assertion 'Jetsam Boost' for process with PID=61014
默认	20:38:26.848977+0800	Nota4	[0x845926e40] Re-initialization successful; calling out to event handler with XPC_ERROR_CONNECTION_INTERRUPTED
默认	20:38:26.850908+0800	Nota4	0x14c0a06d0 - [PID=0] ProcessThrottler::invalidateAllActivities: BEGIN (foregroundActivityCount: 0, backgroundActivityCount: 0)
默认	20:38:26.850939+0800	Nota4	0x14c0a06d0 - [PID=0] ProcessThrottler::invalidateAllActivities: END
默认	20:38:26.850989+0800	Nota4	0x14c1e0180 - ~ProcessAssertion: Releasing process assertion 'WebProcess Foreground Assertion' for process with PID=61014
默认	20:38:26.857505+0800	runningboardd	Invalidating assertion 402-60949-17014 (target:[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014](WebProcess61014)) from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]
默认	20:38:26.857578+0800	runningboardd	Invalidating assertion 402-60949-17015 (target:[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014](WebProcess61014)) from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]
默认	20:38:26.857801+0800	runningboardd	Acquiring assertion targeting [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014](WebProcess61014) from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] with description <RBSAssertionDescriptor| "WebProcess NearSuspended Assertion" ID:402-60949-17033 target:61014<WebProcess61014> attributes:[
	<RBSDomainAttribute| domain:"com.apple.webkit" name:"Suspended" sourceEnvironment:"(null)">
	]>
错误	20:38:26.857490+0800	Nota4	Error acquiring assertion: <Error Domain=RBSServiceErrorDomain Code=1 "(target is not running or doesn't have entitlement com.apple.runningboard.assertions.webkit AND originator doesn't have entitlement com.apple.runningboard.assertions.webkit)" UserInfo={NSLocalizedFailureReason=(target is not running or doesn't have entitlement com.apple.runningboard.assertions.webkit AND originator doesn't have entitlement com.apple.runningboard.assertions.webkit)}>
错误	20:38:26.857508+0800	Nota4	0x14c1e0240 - ProcessAssertion::acquireSync Failed to acquire RBS assertion 'XPCConnectionTerminationWatchdog' for process with PID=61014, error: Error Domain=RBSServiceErrorDomain Code=1 "(target is not running or doesn't have entitlement com.apple.runningboard.assertions.webkit AND originator doesn't have entitlement com.apple.runningboard.assertions.webkit)" UserInfo={NSLocalizedFailureReason=(target is not running or doesn't have entitlement com.apple.runningboard.assertions.webkit AND originator doesn't have entitlement com.apple.runningboard.assertions.webkit)}
默认	20:38:26.857522+0800	Nota4	0x14c1e02a0 - ProcessAssertion::acquireSync Trying to take RBS assertion 'WebProcess NearSuspended Assertion' for process with PID=61014
默认	20:38:26.857534+0800	Nota4	0x14c1e0240 - ProcessAssertion::processAssertionWasInvalidated() PID=61014
默认	20:38:26.861735+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014] termination reported by launchd (0, 0, 0)
默认	20:38:26.861799+0800	runningboardd	Removing process: [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014]
默认	20:38:26.861927+0800	runningboardd	removeJobWithInstance called for identity without existing job [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014]
默认	20:38:26.862262+0800	runningboardd	Removing assertions for terminated process: [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014]
默认	20:38:26.862297+0800	runningboardd	Removed last relative-start-date-defining assertion for process xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014
错误	20:38:26.862432+0800	Nota4	Error acquiring assertion: <Error Domain=RBSServiceErrorDomain Code=1 "(target is not running or doesn't have entitlement com.apple.runningboard.assertions.webkit AND originator doesn't have entitlement com.apple.runningboard.assertions.webkit)" UserInfo={NSLocalizedFailureReason=(target is not running or doesn't have entitlement com.apple.runningboard.assertions.webkit AND originator doesn't have entitlement com.apple.runningboard.assertions.webkit)}>
错误	20:38:26.862452+0800	Nota4	0x14c1e02a0 - ProcessAssertion::acquireSync Failed to acquire RBS assertion 'WebProcess NearSuspended Assertion' for process with PID=61014, error: Error Domain=RBSServiceErrorDomain Code=1 "(target is not running or doesn't have entitlement com.apple.runningboard.assertions.webkit AND originator doesn't have entitlement com.apple.runningboard.assertions.webkit)" UserInfo={NSLocalizedFailureReason=(target is not running or doesn't have entitlement com.apple.runningboard.assertions.webkit AND originator doesn't have entitlement com.apple.runningboard.assertions.webkit)}
默认	20:38:26.862473+0800	Nota4	0x14c1e02a0 - ProcessAssertion::processAssertionWasInvalidated() PID=61014
默认	20:38:26.862484+0800	Nota4	0x14c1e01e0 - ~ProcessAssertion: Releasing process assertion 'WebProcess Background Assertion' for process with PID=61014
默认	20:38:26.862521+0800	Nota4	0x14c1e02a0 - ~ProcessAssertion: Releasing process assertion 'WebProcess NearSuspended Assertion' for process with PID=61014
默认	20:38:26.863300+0800	Nota4	-[TUINSCursorUIController activate:]_block_invoke: Create CursorUIViewService: TUINSRemoteViewController
默认	20:38:26.863630+0800	Nota4	[0x845927d40] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:38:26.863646+0800	Nota4	[0x845927c00] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:38:26.865531+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:38:26.866450+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:38:26.868912+0800	runningboardd	Calculated state for xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014: none (role: None) (endowments: (null))
默认	20:38:26.869285+0800	WindowServer	Received state update for 61014 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014, none-NotVisible
默认	20:38:26.869285+0800	UIKitSystem	Received state update for 61014 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014, none-NotVisible
默认	20:38:26.869107+0800	runningboardd	Calculated state for xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014: none (role: None) (endowments: (null))
默认	20:38:26.869484+0800	WindowServer	Received state update for 61014 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014, none-NotVisible
默认	20:38:26.869486+0800	UIKitSystem	Received state update for 61014 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014, none-NotVisible
默认	20:38:26.870172+0800	gamepolicyd	Received state update for 61014 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014, none-NotVisible
错误	20:38:26.960935+0800	runningboardd	RBSStateCapture remove item called for untracked item 402-60949-17014 (target:[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014](WebProcess61014))
错误	20:38:26.960957+0800	runningboardd	RBSStateCapture remove item called for untracked item 402-60949-17015 (target:[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:4F9C3621-B68E-422A-B1A0-6166E9BDBE4B]{definition:com.apple.WebKit.WebContent[standard][client]}:61014:61014](WebProcess61014))
默认	20:38:28.485156+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:28.486625+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:29.099531+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:38:29.099596+0800	Nota4	Requesting sharingServicesForItems:<private> mask:6
默认	20:38:29.099841+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:38:29.099903+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:29.100003+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:38:29.105140+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:38:29.105283+0800	Nota4	2 plugins found
默认	20:38:29.105523+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:38:29.105545+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:38:29.106373+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:38:29.107534+0800	Nota4	Service with identifier <private> passes activation rule: 0
默认	20:38:29.107598+0800	Nota4	Service dictionary for plugin <private> not available, skip it.
默认	20:38:29.107625+0800	Nota4	1 compatible services found for attributes <private>
默认	20:38:29.107640+0800	Nota4	Discovery done
默认	20:38:29.107671+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:29.107726+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:38:29.108836+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:38:29.108871+0800	Nota4	0 plugins found
默认	20:38:29.108892+0800	Nota4	0 compatible services found for attributes <private>
默认	20:38:29.108902+0800	Nota4	Discovery done
默认	20:38:29.108932+0800	Nota4	Completed querying extensions: <private>
默认	20:38:29.109251+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:38:29.109462+0800	Nota4	Sorted services: <private>
默认	20:38:29.109477+0800	Nota4	It took 9 ms to get sharing services sync for mask <private>
默认	20:38:29.110766+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:38:29.110796+0800	Nota4	Requesting sharingServicesForItems:<private> mask:6
默认	20:38:29.110902+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:38:29.110922+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:29.110951+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:38:29.113051+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:38:29.113127+0800	Nota4	2 plugins found
默认	20:38:29.113269+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:38:29.113281+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:38:29.113785+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:38:29.114447+0800	Nota4	Service with identifier <private> passes activation rule: 0
默认	20:38:29.114461+0800	Nota4	Service dictionary for plugin <private> not available, skip it.
默认	20:38:29.114474+0800	Nota4	1 compatible services found for attributes <private>
默认	20:38:29.114483+0800	Nota4	Discovery done
默认	20:38:29.114499+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:29.114521+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:38:29.115107+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:38:29.115123+0800	Nota4	0 plugins found
默认	20:38:29.115139+0800	Nota4	0 compatible services found for attributes <private>
默认	20:38:29.115147+0800	Nota4	Discovery done
默认	20:38:29.115159+0800	Nota4	Completed querying extensions: <private>
默认	20:38:29.115298+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:38:29.115432+0800	Nota4	Sorted services: <private>
默认	20:38:29.115443+0800	Nota4	It took 4 ms to get sharing services sync for mask <private>
默认	20:38:29.116185+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:38:29.116206+0800	Nota4	Requesting sharingServicesForItems:<private> mask:6
默认	20:38:29.116260+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:38:29.116271+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:29.116291+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:38:29.118393+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:38:29.118460+0800	Nota4	2 plugins found
默认	20:38:29.118552+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:38:29.118561+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:38:29.119638+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:38:29.120378+0800	Nota4	Service with identifier <private> passes activation rule: 0
默认	20:38:29.120392+0800	Nota4	Service dictionary for plugin <private> not available, skip it.
默认	20:38:29.120402+0800	Nota4	1 compatible services found for attributes <private>
默认	20:38:29.120408+0800	Nota4	Discovery done
默认	20:38:29.120418+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:29.120434+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:38:29.120918+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:38:29.120935+0800	Nota4	0 plugins found
默认	20:38:29.120946+0800	Nota4	0 compatible services found for attributes <private>
默认	20:38:29.120959+0800	Nota4	Discovery done
默认	20:38:29.120970+0800	Nota4	Completed querying extensions: <private>
默认	20:38:29.121084+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:38:29.121200+0800	Nota4	Sorted services: <private>
默认	20:38:29.121208+0800	Nota4	It took 5 ms to get sharing services sync for mask <private>
默认	20:38:30.145906+0800	runningboardd	Assertion did invalidate due to timeout: 402-368-17030 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])
默认	20:38:30.169919+0800	WindowServer	destinations for Keyboard event: (<keyboardFocus; Nota4.60949; token: viewbridge-key-window>)
默认	20:38:30.177879+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:30.178551+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:30.348241+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:38:30.348287+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:38:30.348303+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:38:30.348366+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:38:30.356237+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:38:30.357556+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:38:31.908474+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:31.910033+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:32.783185+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:38:32.783255+0800	Nota4	Requesting sharingServicesForItems:<private> mask:6
默认	20:38:32.783454+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:38:32.783499+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:32.783571+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:38:32.787801+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:38:32.787929+0800	Nota4	2 plugins found
默认	20:38:32.788173+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:38:32.788197+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:38:32.789099+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:38:32.790354+0800	Nota4	Service with identifier <private> passes activation rule: 0
默认	20:38:32.790374+0800	Nota4	Service dictionary for plugin <private> not available, skip it.
默认	20:38:32.790396+0800	Nota4	1 compatible services found for attributes <private>
默认	20:38:32.790405+0800	Nota4	Discovery done
默认	20:38:32.790431+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:32.790472+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:38:32.791563+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:38:32.791595+0800	Nota4	0 plugins found
默认	20:38:32.791616+0800	Nota4	0 compatible services found for attributes <private>
默认	20:38:32.791625+0800	Nota4	Discovery done
默认	20:38:32.791651+0800	Nota4	Completed querying extensions: <private>
默认	20:38:32.791979+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:38:32.792186+0800	Nota4	Sorted services: <private>
默认	20:38:32.792202+0800	Nota4	It took 8 ms to get sharing services sync for mask <private>
默认	20:38:32.793420+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:38:32.793443+0800	Nota4	Requesting sharingServicesForItems:<private> mask:6
默认	20:38:32.793512+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:38:32.793526+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:32.793551+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:38:32.795790+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:38:32.795866+0800	Nota4	2 plugins found
默认	20:38:32.795994+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:38:32.796005+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:38:32.796663+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:38:32.797468+0800	Nota4	Service with identifier <private> passes activation rule: 0
默认	20:38:32.797486+0800	Nota4	Service dictionary for plugin <private> not available, skip it.
默认	20:38:32.797499+0800	Nota4	1 compatible services found for attributes <private>
默认	20:38:32.797509+0800	Nota4	Discovery done
默认	20:38:32.797527+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:32.797554+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:38:32.798218+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:38:32.798244+0800	Nota4	0 plugins found
默认	20:38:32.798259+0800	Nota4	0 compatible services found for attributes <private>
默认	20:38:32.798269+0800	Nota4	Discovery done
默认	20:38:32.798286+0800	Nota4	Completed querying extensions: <private>
默认	20:38:32.798463+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:38:32.798614+0800	Nota4	Sorted services: <private>
默认	20:38:32.798625+0800	Nota4	It took 5 ms to get sharing services sync for mask <private>
默认	20:38:32.799386+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:38:32.799412+0800	Nota4	Requesting sharingServicesForItems:<private> mask:6
默认	20:38:32.799472+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:38:32.799484+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:32.799506+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:38:32.801218+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:38:32.801281+0800	Nota4	2 plugins found
默认	20:38:32.801394+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:38:32.801404+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:38:32.802237+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:38:32.802953+0800	Nota4	Service with identifier <private> passes activation rule: 0
默认	20:38:32.802968+0800	Nota4	Service dictionary for plugin <private> not available, skip it.
默认	20:38:32.802978+0800	Nota4	1 compatible services found for attributes <private>
默认	20:38:32.802983+0800	Nota4	Discovery done
默认	20:38:32.802995+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:32.803016+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:38:32.803539+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:38:32.803559+0800	Nota4	0 plugins found
默认	20:38:32.803572+0800	Nota4	0 compatible services found for attributes <private>
默认	20:38:32.803579+0800	Nota4	Discovery done
默认	20:38:32.803591+0800	Nota4	Completed querying extensions: <private>
默认	20:38:32.803714+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:38:32.803831+0800	Nota4	Sorted services: <private>
默认	20:38:32.803839+0800	Nota4	It took 4 ms to get sharing services sync for mask <private>
默认	20:38:32.807117+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:38:32.807137+0800	Nota4	Requesting sharingServicesForItems:<private> mask:6
默认	20:38:32.807190+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:38:32.807199+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:32.807218+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:38:32.808923+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:38:32.808981+0800	Nota4	2 plugins found
默认	20:38:32.809065+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:38:32.809073+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:38:32.809675+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:38:32.810535+0800	Nota4	Service with identifier <private> passes activation rule: 0
默认	20:38:32.810548+0800	Nota4	Service dictionary for plugin <private> not available, skip it.
默认	20:38:32.810558+0800	Nota4	1 compatible services found for attributes <private>
默认	20:38:32.810564+0800	Nota4	Discovery done
默认	20:38:32.810575+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:32.810595+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:38:32.811084+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:38:32.811098+0800	Nota4	0 plugins found
默认	20:38:32.811108+0800	Nota4	0 compatible services found for attributes <private>
默认	20:38:32.811113+0800	Nota4	Discovery done
默认	20:38:32.811124+0800	Nota4	Completed querying extensions: <private>
默认	20:38:32.811249+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:38:32.811367+0800	Nota4	Sorted services: <private>
默认	20:38:32.811376+0800	Nota4	It took 4 ms to get sharing services sync for mask <private>
默认	20:38:32.815433+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:38:32.815454+0800	Nota4	Requesting sharingServicesForItems:<private> mask:6
默认	20:38:32.815515+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:38:32.815526+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:32.815556+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:38:32.817290+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:38:32.817352+0800	Nota4	2 plugins found
默认	20:38:32.817452+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:38:32.817461+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:38:32.818110+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:38:32.818861+0800	Nota4	Service with identifier <private> passes activation rule: 0
默认	20:38:32.818870+0800	Nota4	Service dictionary for plugin <private> not available, skip it.
默认	20:38:32.818876+0800	Nota4	1 compatible services found for attributes <private>
默认	20:38:32.818881+0800	Nota4	Discovery done
默认	20:38:32.818892+0800	Nota4	Discover extensions with attributes <private>
默认	20:38:32.818909+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:38:32.819408+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:38:32.819425+0800	Nota4	0 plugins found
默认	20:38:32.819433+0800	Nota4	0 compatible services found for attributes <private>
默认	20:38:32.819441+0800	Nota4	Discovery done
默认	20:38:32.819452+0800	Nota4	Completed querying extensions: <private>
默认	20:38:32.819545+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:38:32.819648+0800	Nota4	Sorted services: <private>
默认	20:38:32.819659+0800	Nota4	It took 4 ms to get sharing services sync for mask <private>
默认	20:38:34.051706+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:34.053006+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:34.085452+0800	WindowServer	destinations for Keyboard event: (<keyboardFocus; Nota4.60949; token: viewbridge-key-window>)
默认	20:38:34.090739+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:34.091465+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:35.212796+0800	Nota4	[0x845924b40] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:38:35.214674+0800	Nota4	[0x845927980] activating connection: mach=false listener=false peer=false name=com.apple.appkit.xpc.openAndSavePanelService
默认	20:38:35.215087+0800	Nota4	[0x845927980] invalidated after the last release of the connection object
默认	20:38:35.215239+0800	Nota4	[0x8459266c0] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:38:35.262109+0800	com.apple.appkit.xpc.openAndSavePanelService	Client requested in-app message updates in bundle com.nota4.Nota4
默认	20:38:35.262135+0800	com.apple.appkit.xpc.openAndSavePanelService	Client requested in-app message updates in bundle com.nota4.Nota4 with placement InApp
默认	20:38:35.379669+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:35.379839+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:35.379956+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:35.427259+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:38:35.463530+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>,
    <token: 7597; pid: 60949>,
    <token: vbi_25057243447_52155_440410304562_106573_1374561000504260164056; pid: 60949>,
    <token: 7598; pid: 61005>
]
默认	20:38:37.492005+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:38:37.498167+0800	WindowServer	Hit test info for record 0x8b3dfbca0: {
    a = "0.96";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (1.00, 1.00) 0 (0.00) 0 (0.50, 0.00) 0";
}
默认	20:38:37.500525+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:37.515485+0800	WindowServer	Hit test info for record 0x8b3df9770: {
    a = "0.68";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.99, 0.99) 0 (0.00) 0 (3.00, 1.50) 0";
}
默认	20:38:37.515474+0800	runningboardd	Acquiring assertion targeting [xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] from originator [osservice<com.apple.WindowServer(88)>:398] with description <RBSAssertionDescriptor| "AppVisible" ID:402-398-17038 target:61005 attributes:[
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"AppVisible" sourceEnvironment:"(null)">,
	<RBSAcquisitionCompletionAttribute| policy:AfterApplication>
	]>
默认	20:38:37.515522+0800	runningboardd	Assertion 402-398-17038 (target:[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005]) will be created as active
默认	20:38:37.515716+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring jetsam update because this process is not memory-managed
默认	20:38:37.515748+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring suspend because this process is not lifecycle managed
默认	20:38:37.515794+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring GPU update because this process is not GPU managed
默认	20:38:37.515842+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring memory limit update because this process is not memory-managed
默认	20:38:37.530252+0800	WindowServer	Hit test info for record 0x8b3dfbca0: {
    a = "0.44";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.99, 0.99) 0 (0.00) 0 (5.00, 2.50) 0";
}
默认	20:38:37.526753+0800	Nota4	[0x8459275c0] activating connection: mach=false listener=false peer=false name=com.apple.TextInputUI.xpc.CursorUIViewService
默认	20:38:37.528394+0800	Nota4	[0x8459275c0] invalidated after the last release of the connection object
默认	20:38:37.528476+0800	Nota4	[0x845927e80] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:38:37.528537+0800	Nota4	[0x8459275c0] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:38:37.545250+0800	gamepolicyd	Received state update for 61005 (xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005, running-NotVisible
默认	20:38:37.546853+0800	WindowServer	Hit test info for record 0x8af1b0be0: {
    a = "0.27";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.99, 0.98) 0 (0.00) 0 (6.50, 3.50) 0";
}
默认	20:38:37.556118+0800	WindowServer	Hit test info for record 0x8b3dfbca0: {
    a = "0.21";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.98, 0.98) 0 (0.00) 0 (7.00, 3.50) 0";
}
默认	20:38:37.568195+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:37.568437+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:37.582741+0800	Nota4	-[TUINSCursorUIController activate:]_block_invoke: Create CursorUIViewService: TUINSRemoteViewController
默认	20:38:37.582935+0800	Nota4	[0x845926bc0] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:38:37.582946+0800	Nota4	[0x845926580] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:38:37.584058+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:38:37.584610+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:38:37.590481+0800	Nota4	ERROR: Negative values for <private> not allowed (0.000)
默认	20:38:37.908584+0800	Nota4	[0x845924b40] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:38:37.908603+0800	Nota4	[0x8459266c0] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:38:37.913852+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:38:38.006313+0800	suggestd	SGDSpotlightReceiver: deleting 1 unique identifiers (1 after de-duplication) for com.nota4.Nota4: <private>
默认	20:38:38.591888+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:38.593280+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:38.796875+0800	runningboardd	Invalidating assertion 402-398-17038 (target:[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005]) from originator [osservice<com.apple.WindowServer(88)>:398]
默认	20:38:38.900398+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring jetsam update because this process is not memory-managed
默认	20:38:38.900425+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring suspend because this process is not lifecycle managed
默认	20:38:38.900445+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring GPU update because this process is not GPU managed
默认	20:38:38.900501+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring memory limit update because this process is not memory-managed
默认	20:38:38.906029+0800	gamepolicyd	Received state update for 61005 (xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005, running-NotVisible
默认	20:38:39.392046+0800	WindowServer	destinations for Keyboard event: (<keyboardFocus; Nota4.60949; token: viewbridge-key-window>)
默认	20:38:39.398086+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:39.615227+0800	WindowServer	destinations for Keyboard event: (<keyboardFocus; Nota4.60949; token: viewbridge-key-window>)
默认	20:38:39.617690+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:39.621845+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:38:40.858330+0800	Nota4	[0x845925f40] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:38:40.860152+0800	Nota4	[0x845926580] activating connection: mach=false listener=false peer=false name=com.apple.appkit.xpc.openAndSavePanelService
默认	20:38:40.860518+0800	Nota4	[0x845926580] invalidated after the last release of the connection object
默认	20:38:40.860666+0800	Nota4	[0x845926bc0] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:38:40.908657+0800	com.apple.appkit.xpc.openAndSavePanelService	Client requested in-app message updates in bundle com.nota4.Nota4
默认	20:38:40.908693+0800	com.apple.appkit.xpc.openAndSavePanelService	Client requested in-app message updates in bundle com.nota4.Nota4 with placement InApp
默认	20:38:41.025407+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:41.025573+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:41.025688+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:38:41.072247+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:38:41.105740+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>,
    <token: 7602; pid: 60949>,
    <token: vbi_25572013066_152171_412135346463_171145_1250731000704260164216; pid: 60949>,
    <token: 7603; pid: 61005>
]
默认	20:38:42.787714+0800	WindowServer	0[outside of RPC]: [DeferringManager] Updating policy {
    advicePolicy: .frontmost;
    frontmostProcess: 0x0-0x254254 (Nota4) mainConnectionID: B79A3;
} for reason: deferringPolicyEvaluationSuppression
默认	20:38:42.787756+0800	WindowServer	0[outside of RPC]: [DeferringManager] Deferring events from frontmost process PSN 0x0-0x254254 (Nota4) -> <pid: 60949>
默认	20:38:42.787820+0800	WindowServer	new deferring rules for pid:398: [
    [398-5C9]; <keyboardFocus; Nota4:0x0-0x254254>; () -> <pid: 60949>; reason: frontmost PSN --> outbound target,
    [398-5C8]; <keyboardFocus; <frontmost>>; () -> <token: Nota4:0x0-0x254254; pid: 398>; reason: frontmost PSN,
    [398-5C7]; <keyboardFocus>; () -> <token: <frontmost>; pid: 398>; reason: Deferring to <frontmost>
]
默认	20:38:42.787843+0800	WindowServer	[keyboardFocus 0x8b5f445f0] setRules:forPID(398): [
    [398-5C9]; <keyboardFocus; Nota4:0x0-0x254254>; () -> <pid: 60949>; reason: frontmost PSN --> outbound target,
    [398-5C8]; <keyboardFocus; <frontmost>>; () -> <token: Nota4:0x0-0x254254; pid: 398>; reason: frontmost PSN,
    [398-5C7]; <keyboardFocus>; () -> <token: <frontmost>; pid: 398>; reason: Deferring to <frontmost>
]
默认	20:38:42.788553+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>,
    <token: 7602; pid: 60949>,
    <token: vbi_25572013066_152171_412135346463_171145_1250731000704260164216; pid: 60949>,
    <token: 7603; pid: 61005>
]
默认	20:38:55.054546+0800	Nota4	-[NSPersistentUIManager flushAllChanges]
默认	20:38:55.057939+0800	Nota4	-[NSPersistentUIManager flushAllChanges] finishing enqueued operations
默认	20:38:55.057956+0800	Nota4	-[NSPersistentUIManager flushAllChanges]_block_invoke asyncing to main queue
默认	20:38:55.057984+0800	Nota4	-[NSPersistentUIManager flushAllChanges]_block_invoke writing records
默认	20:38:56.849356+0800	Nota4	Could not signal service com.apple.WebKit.WebContent: 113: Could not find specified service
默认	20:38:56.849375+0800	Nota4	[0x845926e40] invalidated after the last release of the connection object
默认	20:38:56.849404+0800	Nota4	0x14c1e0240 - ~ProcessAssertion: Releasing process assertion 'XPCConnectionTerminationWatchdog' for process with PID=61014
默认	20:39:06.302921+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:39:06.309957+0800	Nota4	channel:<private> signal:<private> sessionID:<private> timestamp:<private> payload:<private>
默认	20:39:06.326139+0800	WindowServer	Hit test info for record 0x8afe37bb0: {
    a = "0.79";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (1.00, 1.00) 0 (0.00) 0 (2.00, 1.00) 0";
}
默认	20:39:06.330508+0800	WindowServer	Hit test info for record 0x8afe358b0: {
    a = "0.65";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.99, 0.99) 0 (0.00) 0 (3.00, 1.50) 0";
}
默认	20:39:06.335486+0800	Nota4	[0x845926580] activating connection: mach=false listener=false peer=false name=com.apple.TextInputUI.xpc.CursorUIViewService
默认	20:39:06.338766+0800	Nota4	[0x845926580] invalidated after the last release of the connection object
默认	20:39:06.338869+0800	Nota4	[0x845927d40] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:39:06.347759+0800	runningboardd	Acquiring assertion targeting [xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] from originator [osservice<com.apple.WindowServer(88)>:398] with description <RBSAssertionDescriptor| "AppVisible" ID:402-398-17047 target:61005 attributes:[
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"AppVisible" sourceEnvironment:"(null)">,
	<RBSAcquisitionCompletionAttribute| policy:AfterApplication>
	]>
默认	20:39:06.347806+0800	runningboardd	Assertion 402-398-17047 (target:[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005]) will be created as active
默认	20:39:06.338937+0800	Nota4	[0x845926580] activating connection: mach=false listener=false peer=false name=(anonymous)
默认	20:39:06.340368+0800	WindowServer	Hit test info for record 0x8afe37bb0: {
    a = "0.53";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.99, 0.99) 0 (0.00) 0 (4.00, 2.00) 0";
}
默认	20:39:06.347331+0800	WindowServer	Hit test info for record 0x8afe372a0: {
    a = "0.42";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.99, 0.99) 0 (0.00) 0 (5.00, 2.50) 0";
}
默认	20:39:06.352005+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring jetsam update because this process is not memory-managed
默认	20:39:06.352051+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring suspend because this process is not lifecycle managed
默认	20:39:06.352103+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring GPU update because this process is not GPU managed
默认	20:39:06.352186+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring memory limit update because this process is not memory-managed
默认	20:39:06.357240+0800	WindowServer	Hit test info for record 0x8b3df8370: {
    a = "0.33";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.99, 0.99) 0 (0.00) 0 (6.00, 3.00) 0";
}
默认	20:39:06.362914+0800	gamepolicyd	Received state update for 61005 (xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005, running-NotVisible
默认	20:39:06.364698+0800	WindowServer	Hit test info for record 0x8b3df8690: {
    a = "0.25";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.99, 0.98) 0 (0.00) 0 (6.50, 3.50) 0";
}
默认	20:39:06.374229+0800	WindowServer	Hit test info for record 0x8b3df9220: {
    a = "0.2";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.98, 0.98) 0 (0.00) 0 (7.00, 3.50) 0";
}
默认	20:39:06.380804+0800	WindowServer	Hit test info for record 0x8b3df8370: {
    a = "0.15";
    default = 0;
    host = "com.nota4.Nota4";
    hti = YES;
    inf = 1;
    "occ_components" = "1 0 0 0";
    ocp = 0;
    pip = 1;
    sdkVersion = "26.1";
    service = "com.apple.appkit.xpc.openAndSavePanelService";
    tf = YES;
    "tf_components" = "0 0 0 (0.00) 1 0 (0.98, 0.98) 0 (0.00) 0 (7.50, 4.00) 0";
}
默认	20:39:06.388448+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:39:06.388720+0800	Nota4	-[TUINSCursorUIController scheduleUpdateCursorLocation]
默认	20:39:06.390747+0800	Nota4	-[TUINSCursorUIController activate:]_block_invoke: Create CursorUIViewService: TUINSRemoteViewController
默认	20:39:06.391015+0800	Nota4	[0x8459275c0] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:39:06.391026+0800	Nota4	[0x845927e80] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:39:06.392010+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:39:06.392465+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:39:06.411948+0800	Nota4	ERROR: Negative values for <private> not allowed (0.000)
默认	20:39:06.798212+0800	Nota4	[0x845925f40] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:39:06.798230+0800	Nota4	[0x845926bc0] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:39:06.804017+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:39:06.805351+0800	suggestd	SGDSpotlightReceiver: deleting 1 unique identifiers (1 after de-duplication) for com.nota4.Nota4: <private>
默认	20:39:07.610414+0800	runningboardd	Invalidating assertion 402-398-17047 (target:[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005]) from originator [osservice<com.apple.WindowServer(88)>:398]
默认	20:39:07.715821+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring jetsam update because this process is not memory-managed
默认	20:39:07.715842+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring suspend because this process is not lifecycle managed
默认	20:39:07.715861+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring GPU update because this process is not GPU managed
默认	20:39:07.715902+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring memory limit update because this process is not memory-managed
默认	20:39:07.720501+0800	gamepolicyd	Received state update for 61005 (xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005, running-NotVisible
默认	20:39:11.606599+0800	WindowServer	0[outside of RPC]: [DeferringManager] Updating policy {
    advicePolicy: .frontmost;
    frontmostProcess: 0x0-0x254254 (Nota4) mainConnectionID: B79A3;
} for reason: deferringPolicyEvaluationSuppression
默认	20:39:11.606822+0800	WindowServer	0[outside of RPC]: [DeferringManager] Deferring events from frontmost process PSN 0x0-0x254254 (Nota4) -> <pid: 60949>
默认	20:39:11.607117+0800	WindowServer	new deferring rules for pid:398: [
    [398-5CC]; <keyboardFocus; Nota4:0x0-0x254254>; () -> <pid: 60949>; reason: frontmost PSN --> outbound target,
    [398-5CB]; <keyboardFocus; <frontmost>>; () -> <token: Nota4:0x0-0x254254; pid: 398>; reason: frontmost PSN,
    [398-5CA]; <keyboardFocus>; () -> <token: <frontmost>; pid: 398>; reason: Deferring to <frontmost>
]
默认	20:39:11.607219+0800	WindowServer	[keyboardFocus 0x8b5f445f0] setRules:forPID(398): [
    [398-5CC]; <keyboardFocus; Nota4:0x0-0x254254>; () -> <pid: 60949>; reason: frontmost PSN --> outbound target,
    [398-5CB]; <keyboardFocus; <frontmost>>; () -> <token: Nota4:0x0-0x254254; pid: 398>; reason: frontmost PSN,
    [398-5CA]; <keyboardFocus>; () -> <token: <frontmost>; pid: 398>; reason: Deferring to <frontmost>
]
默认	20:39:11.608875+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:39:11.884754+0800	suggestd	SGDSpotlightReceiver: deleting 1 unique identifiers (1 after de-duplication) for com.nota4.Nota4: <private>
默认	20:39:12.015130+0800	Nota4	0x14c06c0c0 - [PID=0] WebProcessCache::updateCapacity: Cache is disabled because process swap on navigation is disabled
默认	20:39:12.017493+0800	Nota4	0x84a74e088 - PageConfiguration::delaysWebProcessLaunchUntilFirstLoad() -> true because of associated processPool value
默认	20:39:12.017503+0800	Nota4	0x8494e0608 - WebProcessPool::createWebPage: delaying WebProcess launch until first load
默认	20:39:12.017509+0800	Nota4	0x14c0a0100 - [PID=0] WebProcessProxy::constructor:
默认	20:39:12.017529+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=0] WebPageProxy::constructor, site isolation enabled 0
默认	20:39:12.017534+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x0, window visible 0, view hidden 0, window occluded 0
默认	20:39:12.017540+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x0, window visible 0, view hidden 0, window occluded 0
默认	20:39:12.017544+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x0, window visible 0, view hidden 0, window occluded 0
默认	20:39:12.017563+0800	Nota4	0x14c0a0100 - [PID=0] WebProcessProxy::addExistingWebPage: webPage=0x84a4bea18, pageProxyID=47, webPageID=48
默认	20:39:12.017581+0800	Nota4	0x14c06c0c0 - [PID=0] WebProcessCache::updateCapacity: Cache is disabled by client
默认	20:39:12.017716+0800	Nota4	<<<< Alt >>>> fpSupport_GetVideoRangeForCoreDisplayWithPreference: displayID 1 reported potentialHeadRoom=16 wideColorSupported=YES marz=NO almd=NO deviceAllowsHDR=YES isBuiltinPanel=YES externalPanel=YES prefersHDR10=NO
默认	20:39:12.017935+0800	Nota4	<<<< Alt >>>> fpSupport_GetVideoRangeForCoreDisplayWithPreference: displayID 1 reported potentialHeadRoom=16 wideColorSupported=YES marz=NO almd=NO deviceAllowsHDR=YES isBuiltinPanel=YES externalPanel=YES prefersHDR10=NO
默认	20:39:12.018662+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=0] WebPageProxy::loadData:
默认	20:39:12.018673+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=0] WebPageProxy::launchProcess:
默认	20:39:12.018677+0800	Nota4	0x14c0a0100 - [PID=0] WebProcessProxy::removeWebPage: webPage=0x84a4bea18, pageProxyID=47, webPageID=48
默认	20:39:12.018690+0800	Nota4	0x14c0a0640 - [PID=0] WebProcessProxy::constructor:
默认	20:39:12.018868+0800	Nota4	[0x84658fd40] activating connection: mach=false listener=false peer=false name=com.apple.WebKit.WebContent
默认	20:39:12.019061+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.019160+0800	Nota4	<<<< Alt >>>> fpSupport_GetVideoRangeForCoreDisplayWithPreference: displayID 1 reported potentialHeadRoom=16 wideColorSupported=YES marz=NO almd=NO deviceAllowsHDR=YES isBuiltinPanel=YES externalPanel=YES prefersHDR10=NO
默认	20:39:12.019210+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.019253+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.019259+0800	Nota4	0x14c1180f0 - [PID=0, throttler=0x14c0a06d0] ProcessThrottler::Activity::Activity: Starting foreground activity / 'Process initialization'
默认	20:39:12.019304+0800	Nota4	0x14c0a0100 - [PID=0] WebProcessProxy::destructor:
默认	20:39:12.019314+0800	Nota4	0x14c0a0190 - [PID=0] ProcessThrottler::didDisconnectFromProcess:
默认	20:39:12.019318+0800	Nota4	0x14c0a0190 - [PID=0] ProcessThrottler::invalidateAllActivities: BEGIN (foregroundActivityCount: 0, backgroundActivityCount: 0)
默认	20:39:12.019320+0800	Nota4	0x14c0a0190 - [PID=0] ProcessThrottler::invalidateAllActivities: END
默认	20:39:12.019325+0800	Nota4	0x14c0a0640 - [PID=0] WebProcessProxy::addExistingWebPage: webPage=0x84a4bea18, pageProxyID=47, webPageID=48
默认	20:39:12.019341+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x0, window visible 0, view hidden 0, window occluded 1
默认	20:39:12.019345+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x0, window visible 0, view hidden 0, window occluded 1
默认	20:39:12.019349+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x0, window visible 0, view hidden 0, window occluded 1
默认	20:39:12.019392+0800	Nota4	PlaybackSessionManagerProxy::PlaybackSessionManagerProxy(7F2C51E0)
默认	20:39:12.019418+0800	Nota4	PlaybackSessionManagerProxy::VideoPresentationManagerProxy(7F2C51E0)
默认	20:39:12.019496+0800	Nota4	WebProcessPool::registerUserInstalledFonts: start registering fonts
默认	20:39:12.037180+0800	Nota4	WebProcessPool::registerUserInstalledFonts: done registering fonts
默认	20:39:12.037240+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037269+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037341+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037379+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037414+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037452+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037491+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037524+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037560+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037595+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037626+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037661+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037698+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037736+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037771+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037792+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037825+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037864+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037900+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037935+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.037987+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038028+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038070+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038104+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038141+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038166+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038201+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038235+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038259+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038285+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038321+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038355+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038388+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038410+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038438+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038460+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038481+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038501+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038535+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038572+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038609+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038640+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038665+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038686+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038710+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038733+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038765+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038789+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038810+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038842+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038876+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038908+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038930+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038953+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.038985+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039009+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039035+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039072+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039093+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039114+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039139+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039171+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039195+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039216+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039252+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039273+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039304+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039326+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039350+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039369+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039391+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039429+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039453+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039475+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039494+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039530+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039565+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039587+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039608+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039628+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039650+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039680+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039702+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039725+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039748+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039777+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039798+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039822+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039853+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039875+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039896+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039930+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039954+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.039985+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040007+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040030+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040049+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040071+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040092+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040124+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040158+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040180+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040204+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040226+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040247+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040270+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040292+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040326+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040361+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040396+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040419+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040441+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040461+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040493+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040513+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040545+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040579+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040611+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040633+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040654+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040673+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040695+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040729+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040751+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040775+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040797+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040828+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040852+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040883+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040904+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040925+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040956+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.040987+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041017+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041048+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041069+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041091+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041114+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041136+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041168+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041192+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041214+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041239+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041258+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041276+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041296+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041316+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041349+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041384+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041408+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041430+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041462+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041487+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041506+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041524+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041547+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041562+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.041579+0800	Nota4	Successfully created a sandbox extension for '<private>'
默认	20:39:12.042280+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=0] WebPageProxy::WebPageProxy::shouldForceForegroundPriorityForClientNavigation() returns 1 based on PageClient::canTakeForegroundAssertions()
默认	20:39:12.042289+0800	Nota4	0x14c118210 - [PID=0, throttler=0x14c0a06d0] ProcessThrottler::Activity::Activity: Starting foreground activity / 'Client navigation'
默认	20:39:12.042298+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=0] WebPageProxy::loadDataWithNavigation
默认	20:39:12.042310+0800	Nota4	0x14c0a0640 - [PID=0] WebProcessProxy::assumeReadAccessToBaseURL(11220479): path = <private>
默认	20:39:12.042339+0800	Nota4	0x14c1280e0 - NavigationState is taking a process network assertion because a page load started
默认	20:39:12.042342+0800	Nota4	0x14c118240 - [PID=0, throttler=0x14c0a06d0] ProcessThrottler::Activity::Activity: Starting background activity / 'Page Load'
默认	20:39:12.042922+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:39:12.042934+0800	Nota4	Requesting sharingServicesForFilteredItems:<private> mask:<private>
默认	20:39:12.042957+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:39:12.042964+0800	Nota4	Requesting sharingServicesForFilteredItems:<private> mask:<private>
默认	20:39:12.042994+0800	Nota4	filteredItemsFromItems:<private> [60949]--> <private>
默认	20:39:12.043001+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:39:12.043003+0800	Nota4	Requesting sharingServicesForFilteredItems:<private> mask:<private>
默认	20:39:12.043003+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:39:12.043011+0800	Nota4	0x14c0a0640 - [PID=61037] WebProcessProxy::didFinishLaunching:
默认	20:39:12.043016+0800	Nota4	0x14c118270 - [PID=61037, throttler=0x14c0a06d0] ProcessThrottler::Activity::Activity: Starting foreground activity / 'Lifetime Activity'
默认	20:39:12.043018+0800	Nota4	Discover extensions with attributes <private>
默认	20:39:12.043028+0800	Nota4	Discover extensions with attributes <private>
默认	20:39:12.043047+0800	Nota4	0x14c0a06d0 - [PID=61037] ProcessThrottler::didConnectToProcess
默认	20:39:12.043080+0800	Nota4	0x14c0a06d0 - [PID=61037] ProcessThrottler::setThrottleState: Updating process assertion type to 3 (foregroundActivities=3, backgroundActivities=2)
默认	20:39:12.043107+0800	Nota4	0x14c0a0640 - [PID=61037] WebProcessProxy::didChangeThrottleState: type=2
默认	20:39:12.043129+0800	Nota4	0x14c0a0640 - [PID=61037] WebProcessProxy::didChangeThrottleState(Foreground) Taking foreground assertion for network process
默认	20:39:12.043154+0800	Nota4	0x14c1182a0 - [PID=61011, throttler=0x14c120220] ProcessThrottler::Activity::Activity: Starting foreground activity / 'Networking for foreground view(s)'
默认	20:39:12.043184+0800	Nota4	0x14c1182d0 - [PID=61010, throttler=0x14c114280] ProcessThrottler::Activity::Activity: Starting foreground activity / 'GPU for foreground view(s)'
默认	20:39:12.043206+0800	Nota4	0x14c120190 - NetworkProcessProxy::sendXPCEndpointToProcess(0x14c0a0640) state = 1 has connection = 1 XPC endpoint message = 0x849717800
默认	20:39:12.043232+0800	Nota4	0x14c118270 - [PID=61037, throttler=0x14c0a06d0] ProcessThrottler::Activity::invalidate: Ending foreground activity / 'Lifetime Activity'
默认	20:39:12.043040+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:39:12.043044+0800	Nota4	0x14c0c4220 - ProcessAssertion::acquireSync Trying to take RBS assertion 'Jetsam Boost' for process with PID=61037
默认	20:39:12.043351+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:39:12.043392+0800	Nota4	0x14c1180f0 - [PID=61037, throttler=0x14c0a06d0] ProcessThrottler::Activity::invalidate: Ending foreground activity / 'Process initialization'
默认	20:39:12.043421+0800	Nota4	0x14c120190 - NetworkProcessProxy::getNetworkProcessConnection: Taking a background assertion because web process pid 61037 (core identifier 9) is requesting a connection
默认	20:39:12.043267+0800	Nota4	Matching dictionary: <private>, attributesArray: <private>
默认	20:39:12.043514+0800	Nota4	Discover extensions with attributes <private>
默认	20:39:12.043621+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.ui-services
默认	20:39:12.043895+0800	runningboardd	Resolved pid 61037 to [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037]
默认	20:39:12.044239+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] Memory Limits: active 2048 inactive 2048
 <private>
默认	20:39:12.044253+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] This process will be managed.
错误	20:39:12.044281+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] Memorystatus failed with unexpected error: Invalid argument (22)
默认	20:39:12.044289+0800	runningboardd	Now tracking process: [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037]
默认	20:39:12.044449+0800	runningboardd	Calculated state for xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037: running-suspended (role: None) (endowments: (null))
默认	20:39:12.044786+0800	runningboardd	Acquiring assertion targeting [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037](WebProcess61037) from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] with description <RBSAssertionDescriptor| "Jetsam Boost" ID:402-60949-17049 target:61037<WebProcess61037> attributes:[
	<RBSDomainAttribute| domain:"com.apple.webkit" name:"BoostedJetsam" sourceEnvironment:"(null)">
	]>
默认	20:39:12.045109+0800	Nota4	0x14c0c4220 - ProcessAssertion::acquireSync Successfully took RBS assertion 'Jetsam Boost' for process with PID=61037
默认	20:39:12.044886+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] reported to RB as running
默认	20:39:12.045007+0800	runningboardd	Assertion 402-60949-17049 (target:[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037](WebProcess61037)) will be created as active
默认	20:39:12.045120+0800	Nota4	0x14c1e0180 - ProcessAssertion::acquireSync Trying to take RBS assertion 'WebProcess Foreground Assertion' for process with PID=61037
默认	20:39:12.045376+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:39:12.045409+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.045414+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::updateActivityState: view visibility state changed 0 -> 1
默认	20:39:12.045439+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.045650+0800	WindowServer	Hit the server for a process handle 1c304fda0000ee6d that resolved to: [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037]
默认	20:39:12.045469+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.045494+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::viewIsBecomingVisible:
默认	20:39:12.045533+0800	Nota4	Screen Time has updated to use the system shield for any blocked URL.
默认	20:39:12.045696+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] Set jetsam priority to 40 [0] flag[1]
默认	20:39:12.045574+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::updateThrottleState: UIProcess is taking a foreground assertion because the view is visible
默认	20:39:12.045619+0800	Nota4	0x14c1183f0 - [PID=61037, throttler=0x14c0a06d0] ProcessThrottler::Activity::Activity: Starting foreground activity / 'View is visible'
默认	20:39:12.045890+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] Suspending task.
默认	20:39:12.045769+0800	Nota4	RemoteLayerTreeDrawingAreaProxy(50)::hideContentUntilAnyUpdate
默认	20:39:12.045981+0800	Nota4	2 plugins found
默认	20:39:12.046006+0800	UIKitSystem	Hit the server for a process handle 1c304fda0000ee6d that resolved to: [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037]
默认	20:39:12.046242+0800	runningboardd	Acquiring assertion targeting [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037](WebProcess61037) from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] with description <RBSAssertionDescriptor| "WebProcess Foreground Assertion" ID:402-60949-17050 target:61037<WebProcess61037> attributes:[
	<RBSDomainAttribute| domain:"com.apple.webkit" name:"Foreground" sourceEnvironment:"(null)">
	]>
默认	20:39:12.046334+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] Shutdown sockets (ALL)
默认	20:39:12.046355+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:39:12.046416+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] Set darwin role to: None
默认	20:39:12.046391+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:39:12.046475+0800	runningboardd	Assertion 402-60949-17050 (target:[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037](WebProcess61037)) will be created as active
默认	20:39:12.046998+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] set Memory Limits to Soft Inactive (2048)
默认	20:39:12.047286+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] check if suspended process is holding locks
默认	20:39:12.045700+0800	WindowServer	Received state update for 61037 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037, running-suspended-NotVisible
默认	20:39:12.048657+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:39:12.048882+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:39:12.049163+0800	Nota4	2 plugins found
默认	20:39:12.049401+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:39:12.049454+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:39:12.050012+0800	Nota4	Service with identifier <private> passes activation rule: 0
默认	20:39:12.050055+0800	Nota4	Service dictionary for plugin <private> not available, skip it.
默认	20:39:12.050138+0800	Nota4	1 compatible services found for attributes <private>
默认	20:39:12.050190+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.050232+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.050179+0800	Nota4	Discovery done
默认	20:39:12.050292+0800	Nota4	Discover extensions with attributes <private>
默认	20:39:12.050369+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:39:12.046062+0800	UIKitSystem	Received state update for 61037 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037, running-suspended-NotVisible
默认	20:39:12.051197+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:39:12.052195+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 2
默认	20:39:12.052347+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:39:12.052436+0800	Nota4	2 plugins found
默认	20:39:12.052772+0800	Nota4	Use of NSTruePredicate is forbidden: <private>
默认	20:39:12.052798+0800	Nota4	Service with identifier <private> passes activation rule: 1
默认	20:39:12.052855+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:39:12.052934+0800	Nota4	0 plugins found
默认	20:39:12.052995+0800	Nota4	0 compatible services found for attributes <private>
默认	20:39:12.053040+0800	Nota4	Discovery done
默认	20:39:12.053109+0800	Nota4	Completed querying extensions: <private>
默认	20:39:12.054078+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:39:12.054362+0800	Nota4	Sorted services: <private>
默认	20:39:12.054423+0800	Nota4	It took 11 ms to get sharing services async for mask <private>
默认	20:39:12.054946+0800	Nota4	Role type not provided, assuming Action for <private>
默认	20:39:12.055366+0800	Nota4	2 compatible services found for attributes <private>
默认	20:39:12.055419+0800	Nota4	Discovery done
默认	20:39:12.055473+0800	Nota4	Discover extensions with attributes <private>
默认	20:39:12.055535+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:39:12.055938+0800	Nota4	Service with identifier <private> passes activation rule: 0
默认	20:39:12.055946+0800	Nota4	Service dictionary for plugin <private> not available, skip it.
默认	20:39:12.055953+0800	Nota4	1 compatible services found for attributes <private>
默认	20:39:12.055958+0800	Nota4	Discovery done
默认	20:39:12.055965+0800	Nota4	Discover extensions with attributes <private>
默认	20:39:12.055998+0800	runningboardd	Calculated state for xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037: running-suspended (role: None) (endowments: (null))
默认	20:39:12.055978+0800	Nota4	[d <private>] <PKHost:0x846900840> Beginning discovery for flags: 1024, point: com.apple.services
默认	20:39:12.056044+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:39:12.056056+0800	Nota4	0x14c1e0180 - ProcessAssertion::acquireSync Successfully took RBS assertion 'WebProcess Foreground Assertion' for process with PID=61037
默认	20:39:12.056087+0800	Nota4	0 plugins found
默认	20:39:12.056137+0800	Nota4	0 compatible services found for attributes <private>
默认	20:39:12.056174+0800	Nota4	Discovery done
默认	20:39:12.056224+0800	Nota4	Completed querying extensions: <private>
默认	20:39:12.056406+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:39:12.056499+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] Set jetsam priority to 100 [0] flag[1]
默认	20:39:12.056541+0800	gamepolicyd	Hit the server for a process handle 1c304fda0000ee6d that resolved to: [xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037]
默认	20:39:12.056694+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] Resuming task.
默认	20:39:12.056649+0800	Nota4	[d <private>] <PKHost:0x846900840> Completed discovery. Final # of matches: 0
默认	20:39:12.056674+0800	Nota4	Sorted services: <private>
默认	20:39:12.056778+0800	runningboardd	[xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037:61037] Set darwin role to: UserInteractiveFocal
默认	20:39:12.056575+0800	gamepolicyd	Received state update for 61037 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037, running-suspended-NotVisible
默认	20:39:12.056687+0800	Nota4	0 plugins found
默认	20:39:12.056716+0800	Nota4	It took 13 ms to get sharing services async for mask <private>
默认	20:39:12.056747+0800	Nota4	0 compatible services found for attributes <private>
默认	20:39:12.056828+0800	Nota4	Discovery done
默认	20:39:12.056941+0800	Nota4	Completed querying extensions: <private>
默认	20:39:12.057128+0800	Nota4	Copy: canPerformWithItems returns YES
默认	20:39:12.057329+0800	Nota4	Sorted services: <private>
默认	20:39:12.057368+0800	Nota4	It took 14 ms to get sharing services async for mask <private>
默认	20:39:12.057476+0800	Nota4	0x14c148220 [pageProxyID=47, webPageID=48, PID=61037, DisplayID=1] RemoteLayerTreeDrawingAreaProxyMac::didRefreshDisplay
默认	20:39:12.065658+0800	WindowServer	Received state update for 61037 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037, running-active-NotVisible
默认	20:39:12.065305+0800	runningboardd	Calculated state for xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037: running-active (role: UserInteractiveFocal) (endowments: (null))
默认	20:39:12.065754+0800	UIKitSystem	Received state update for 61037 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037, running-active-NotVisible
默认	20:39:12.072578+0800	gamepolicyd	Received state update for 61037 (xpcservice<com.apple.WebKit.WebContent([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}[uuid:D8ACB7C1-B2B7-4D40-B661-2B29ACA236F7]{definition:com.apple.WebKit.WebContent[standard][client]}:61037, running-active-NotVisible
默认	20:39:12.076423+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::decidePolicyForNavigationAction: frameID=4294967299, isMainFrame=1, navigationID=53
默认	20:39:12.076489+0800	Nota4	0x14c0180f0 - SOAuthorizationCoordinator::tryAuthorize
默认	20:39:12.076508+0800	Nota4	Fetching native takeover URLs
默认	20:39:12.076724+0800	Nota4	URL shouldn't be processed
默认	20:39:12.076816+0800	Nota4	SOAuthorizationCoordinator::tryAuthorize: The requested URL is not registered for AppSSO handling. No further action needed.
默认	20:39:12.076821+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::decidePolicyForNavigationAction: listener called: frameID=4294967299, isMainFrame=1, navigationID=53, policyAction=Use, isAppBoundDomain=0, wasNavigationIntercepted=0
默认	20:39:12.076828+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::receivedNavigationActionPolicyDecision: frameID=4294967299, isMainFrame=1, navigationID=53, policyAction=Use
默认	20:39:12.076921+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::decidePolicyForNavigationAction: keep using process 61037 for navigation, reason=Process has not yet committed any provisional loads
默认	20:39:12.076944+0800	Nota4	0x14c0a0640 - [PID=61037] WebProcessProxy::canTerminateAuxiliaryProcess: returns false (pageCount=1, provisionalPageCount=0, suspendedPageCount=0, m_isInProcessCache=0, m_shutdownPreventingScopeCounter=0)
默认	20:39:12.078174+0800	Nota4	WebContent[61037]: [webFrameID=4294967299, webPageID=48] WebFrameLoaderClient::dispatchDecidePolicyForNavigationAction: Got policyAction Use from async IPC
默认	20:39:12.078186+0800	Nota4	WebContent[61037] 0x10a1d8180 - [pageID=48, frameID=4294967299] PolicyChecker::checkNavigationPolicy: continuing because this policyAction from dispatchDecidePolicyForNavigationAction is Use
默认	20:39:12.078192+0800	Nota4	WebContent[61037]: [pageID=48 frameID=4294967299 isMainFrame=1] FrameLoader::stopAllLoaders: m_provisionalDocumentLoader=0, m_documentLoader=4479877120
默认	20:39:12.078197+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, isMainFrame=1] DocumentLoader::stopLoading
默认	20:39:12.078201+0800	Nota4	WebContent[61037]: [pageID=48 frameID=4294967299 isMainFrame=1] FrameLoader::setProvisionalDocumentLoader: Setting provisional document loader to 4479893504 (was 0)
默认	20:39:12.078205+0800	Nota4	WebContent[61037]: [pageID=48 frameID=4294967299 isMainFrame=1] FrameLoader::continueLoadAfterNavigationPolicy: Setting provisional document loader (m_provisionalDocumentLoader=4479893504)
默认	20:39:12.078207+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::freezeLayerTree: Adding a reason to freeze layer tree (reason=1, new=1, old=0)
默认	20:39:12.078228+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.078234+0800	Nota4	WebContent[61037]: [pageID=48 frameID=4294967299 isMainFrame=1] FrameLoader::setPolicyDocumentLoader: Setting policy document loader to 0 (was 4479893504)
默认	20:39:12.078277+0800	Nota4	WebContent[61037]: [pageID=48 frameID=4294967299 isMainFrame=1] FrameLoader::prepareForLoadStart: Starting frame load
默认	20:39:12.078285+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.078313+0800	Nota4	WebContent[61037]: ProgressTracker::progressStarted: frameID 4294967299, value 0.100000, tracked frames 1, originating frameID 4294967299, isMainLoad 1
默认	20:39:12.078344+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, isMainFrame=1] DocumentLoader::startLoadingMainResource: Starting load
默认	20:39:12.078349+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::didStartProvisionalLoadForFrame: frameID=4294967299, isMainFrame=1
默认	20:39:12.078366+0800	Nota4	WebContent[61037] 0x10b05c000 - [pageID=48, frameID=4294967299, isMainFrame=1] DocumentLoader::startLoadingMainResource: Returning substitute data
默认	20:39:12.078382+0800	Nota4	0x14c0a0640 - [PID=61037] WebProcessProxy::didStartProvisionalLoadForMainFrame:
默认	20:39:12.078392+0800	Nota4	WebContent[61037] 0x10b05c000 - [pageID=48, frameID=4294967299, isMainFrame=1] DocumentLoader::startLoadingMainResource callback: Load canceled because of substitute data
默认	20:39:12.078423+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.078429+0800	Nota4	WebContent[61037]: [pageID=48 frameID=4294967299 isMainFrame=1] FrameLoader::setDocumentLoader: Setting document loader to 4479893504 (was 4479877120)
默认	20:39:12.078437+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.078459+0800	Nota4	WebContent[61037] Failed to look up the port for "com.apple.windowserver.active" (1)
默认	20:39:12.078490+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, isMainFrame=1] DocumentLoader::detachFromFrame
默认	20:39:12.078516+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::didCommitLoadForFrame: frameID=4294967299, isMainFrame=1
默认	20:39:12.078526+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, isMainFrame=1] DocumentLoader::stopLoading
默认	20:39:12.078574+0800	Nota4	WebContent[61037]: [pageID=48 frameID=4294967299 isMainFrame=1] FrameLoader::transitionToCommitted: Clearing provisional document loader (m_provisionalDocumentLoader=4479893504)
默认	20:39:12.078574+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.078594+0800	Nota4	WebContent[61037]: [pageID=48 frameID=4294967299 isMainFrame=1] FrameLoader::setProvisionalDocumentLoader: Setting provisional document loader to 0 (was 4479893504)
默认	20:39:12.078615+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.078632+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::unfreezeLayerTree: Removing a reason to freeze layer tree (reason=128, new=1, old=1)
默认	20:39:12.078660+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::unfreezeLayerTree: Removing a reason to freeze layer tree (reason=128, new=1, old=1)
默认	20:39:12.078697+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::unfreezeLayerTree: Removing a reason to freeze layer tree (reason=32, new=1, old=1)
默认	20:39:12.080205+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=15] ResourceLoader::willSendRequestInternal: calling completion handler
默认	20:39:12.080216+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=15 SubResourceLoader::willSendRequestInternal: resource load finished; calling completion handler
默认	20:39:12.080220+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=48, resourceID=48] WebLoaderStrategy::scheduleLoad: URL will be scheduled with the NetworkProcess
默认	20:39:12.080224+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=48, resourceID=48] WebLoaderStrategy::scheduleLoad: Resource is being scheduled with the NetworkProcess (priority=3, existingNetworkResourceLoadIdentifierToResume=0)
默认	20:39:12.080229+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=15] WebResourceLoader::WebResourceLoader
默认	20:39:12.080235+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::freezeLayerTree: Adding a reason to freeze layer tree (reason=128, new=129, old=1)
默认	20:39:12.080239+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.080244+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.080291+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=16] ResourceLoader::willSendRequestInternal: calling completion handler
默认	20:39:12.080297+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=16 SubResourceLoader::willSendRequestInternal: resource load finished; calling completion handler
默认	20:39:12.080303+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=48, resourceID=48] WebLoaderStrategy::scheduleLoad: URL will be scheduled with the NetworkProcess
错误	20:39:12.080415+0800	kernel	Sandbox: com.apple.WebKit.WebContent(61037) deny(1) file-issue-extension target:/Users/xt/Library/Containers/com.nota4.Nota4/Data/Documents/NotaLibrary/notes/70D69626-EFD7-4E5D-9F78-39C757A703D2/assets/37C49A18-321A-48E6-B0E1-DDF22323BEF9.png extension-class:com.apple.app-sandbox.read
默认	20:39:12.080343+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=48, resourceID=48] WebLoaderStrategy::scheduleLoad: Resource is being scheduled with the NetworkProcess (priority=3, existingNetworkResourceLoadIdentifierToResume=0)
错误	20:39:12.080502+0800	kernel	Sandbox: com.apple.WebKit.WebContent(61037) deny(1) file-issue-extension target:/Users/xt/Library/Containers/com.nota4.Nota4/Data/Documents/NotaLibrary/notes/70D69626-EFD7-4E5D-9F78-39C757A703D2/assets/16767AC6-9309-4785-898B-44ABD049B05D.png extension-class:com.apple.app-sandbox.read
默认	20:39:12.080377+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=16] WebResourceLoader::WebResourceLoader
默认	20:39:12.080414+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=17] ResourceLoader::willSendRequestInternal: calling completion handler
默认	20:39:12.080454+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=17 SubResourceLoader::willSendRequestInternal: resource load finished; calling completion handler
默认	20:39:12.080482+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=48, resourceID=48] WebLoaderStrategy::scheduleLoad: URL will be scheduled with the NetworkProcess
默认	20:39:12.080502+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=48, resourceID=48] WebLoaderStrategy::scheduleLoad: Resource is being scheduled with the NetworkProcess (priority=3, existingNetworkResourceLoadIdentifierToResume=0)
默认	20:39:12.080523+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=17] WebResourceLoader::WebResourceLoader
默认	20:39:12.080560+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=18] ResourceLoader::willSendRequestInternal: calling completion handler
默认	20:39:12.080609+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=18 SubResourceLoader::willSendRequestInternal: resource load finished; calling completion handler
默认	20:39:12.080643+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.080666+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=48, resourceID=48] WebLoaderStrategy::scheduleLoad: URL will be scheduled with the NetworkProcess
默认	20:39:12.080707+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
错误	20:39:12.080738+0800	Nota4	WebContent[61037] Could not create a sandbox extension for '<private>'
默认	20:39:12.080816+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=48, resourceID=48] WebLoaderStrategy::scheduleLoad: Resource is being scheduled with the NetworkProcess (priority=1, existingNetworkResourceLoadIdentifierToResume=0)
默认	20:39:12.080841+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=18] WebResourceLoader::WebResourceLoader
默认	20:39:12.080876+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=19] ResourceLoader::willSendRequestInternal: calling completion handler
默认	20:39:12.080883+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=19 SubResourceLoader::willSendRequestInternal: resource load finished; calling completion handler
默认	20:39:12.080933+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=48, resourceID=48] WebLoaderStrategy::scheduleLoad: URL will be scheduled with the NetworkProcess
错误	20:39:12.080984+0800	Nota4	WebContent[61037] Could not create a sandbox extension for '<private>'
默认	20:39:12.081017+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=48, resourceID=48] WebLoaderStrategy::scheduleLoad: Resource is being scheduled with the NetworkProcess (priority=1, existingNetworkResourceLoadIdentifierToResume=0)
默认	20:39:12.081043+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=19] WebResourceLoader::WebResourceLoader
错误	20:39:12.081588+0800	kernel	Sandbox: com.apple.WebKit.Networking(61011) deny(1) file-read-data /Users/xt/Library/Containers/com.nota4.Nota4/Data/Documents/NotaLibrary/notes/70D69626-EFD7-4E5D-9F78-39C757A703D2/assets/37C49A18-321A-48E6-B0E1-DDF22323BEF9.png
默认	20:39:12.081912+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=16] WebResourceLoader::didReceiveResponse: (httpStatusCode=200)
默认	20:39:12.081924+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=16] WebResourceLoader::didReceiveResource
默认	20:39:12.081935+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=16 SubResourceLoader::didFinishLoading
错误	20:39:12.081950+0800	kernel	Sandbox: com.apple.WebKit.Networking(61011) deny(1) file-read-data /Users/xt/Library/Containers/com.nota4.Nota4/Data/Documents/NotaLibrary/notes/70D69626-EFD7-4E5D-9F78-39C757A703D2/assets/16767AC6-9309-4785-898B-44ABD049B05D.png
默认	20:39:12.081985+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.081991+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.082036+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=17] WebResourceLoader::didReceiveResponse: (httpStatusCode=200)
默认	20:39:12.082067+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=17] WebResourceLoader::didReceiveResource
默认	20:39:12.082073+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=17 SubResourceLoader::didFinishLoading
默认	20:39:12.082257+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=15] WebResourceLoader::didReceiveResponse: (httpStatusCode=200)
默认	20:39:12.082295+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=15] WebResourceLoader::didReceiveResource
默认	20:39:12.082299+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=15 SubResourceLoader::didFinishLoading
默认	20:39:12.082303+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::unfreezeLayerTree: Removing a reason to freeze layer tree (reason=128, new=1, old=129)
默认	20:39:12.146967+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::freezeLayerTree: Adding a reason to freeze layer tree (reason=128, new=129, old=1)
默认	20:39:12.147007+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::unfreezeLayerTree: Removing a reason to freeze layer tree (reason=128, new=1, old=129)
默认	20:39:12.147372+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::freezeLayerTree: Adding a reason to freeze layer tree (reason=128, new=129, old=1)
默认	20:39:12.147378+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::unfreezeLayerTree: Removing a reason to freeze layer tree (reason=128, new=1, old=129)
默认	20:39:12.156744+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::didFinishDocumentLoadForFrame: frameID=4294967299, isMainFrame=1
默认	20:39:12.156764+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=18] WebResourceLoader::didFailResourceLoad
默认	20:39:12.156797+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.156802+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.159495+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=18 SubResourceLoader::didFail: (type=1, code=1)
默认	20:39:12.162493+0800	Nota4	WebContent[61037]: [webPageID=48, frameID=4294967299, resourceID=19] WebResourceLoader::didFailResourceLoad
默认	20:39:12.162525+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, resourceID=19 SubResourceLoader::didFail: (type=1, code=1)
默认	20:39:12.166452+0800	Nota4	WebContent[61037]: [webPageID=48] WebPage::unfreezeLayerTree: Removing a reason to freeze layer tree (reason=1, new=0, old=1)
默认	20:39:12.166467+0800	Nota4	WebContent[61037]: [pageID=48, frameID=4294967299, isMainFrame=1] LocalFrameView::fireLayoutRelatedMilestonesIfNeeded: Firing first visually non-empty layout milestone on the main frame
默认	20:39:12.166474+0800	Nota4	WebContent[61037]: [webFrameID=4294967299, webPageID=48] WebLocalFrameLoaderClient::dispatchDidReachLayoutMilestone: dispatching DidFirstLayoutForFrame
默认	20:39:12.166481+0800	Nota4	WebContent[61037]: [webFrameID=4294967299, webPageID=48] WebLocalFrameLoaderClient::dispatchDidReachLayoutMilestone: dispatching DidReachLayoutMilestone (milestones=DidFirstLayout, DidFirstVisuallyNonEmptyLayout)
默认	20:39:12.166485+0800	Nota4	WebContent[61037]: [webFrameID=4294967299, webPageID=48] WebLocalFrameLoaderClient::dispatchDidReachLayoutMilestone: dispatching DidFirstVisuallyNonEmptyLayoutForFrame
默认	20:39:12.166486+0800	Nota4	WebContent[61037]: [webFrameID=4294967299, webPageID=48] WebLocalFrameLoaderClient::completePageTransitionIfNeeded: dispatching didCompletePageTransition
默认	20:39:12.166490+0800	Nota4	WebContent[61037]: [pageID=48 frameID=4294967299 isMainFrame=1] FrameLoader::setState: main frame load completed
默认	20:39:12.166496+0800	Nota4	WebContent[61037]: Memory usage info dump at <private>:
默认	20:39:12.166507+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.166567+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.166572+0800	Nota4	WebContent[61037]:   <private>: 1
默认	20:39:12.166671+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.166707+0800	Nota4	WebContent[61037]:   <private>: 0
默认	20:39:12.166735+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.166784+0800	Nota4	WebContent[61037]:   <private>: 2
默认	20:39:12.166824+0800	Nota4	0x84a4bea18 - [pageProxyID=47, webPageID=48, PID=61037] WebPageProxy::didFinishLoadForFrame: frameID=4294967299, isMainFrame=1
默认	20:39:12.166845+0800	Nota4	WebContent[61037]:   <private>: 17
默认	20:39:12.166884+0800	Nota4	0x14c1280e0 - NavigationState will release its process network assertion soon because the page load completed
默认	20:39:12.166894+0800	Nota4	WebContent[61037]:   <private>: 0
默认	20:39:12.166929+0800	Nota4	0x14c118210 - [PID=61037, throttler=0x14c0a06d0] ProcessThrottler::Activity::invalidate: Ending foreground activity / 'Client navigation'
默认	20:39:12.166935+0800	Nota4	WebContent[61037]:   <private>: 79
默认	20:39:12.166970+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.166975+0800	Nota4	WebContent[61037]:   <private>: 0
默认	20:39:12.166995+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:12.167011+0800	Nota4	WebContent[61037]:   <private>: 80
默认	20:39:12.167047+0800	Nota4	0x14c1141f0 - GPUProcessProxy is taking a background assertion because a web process is requesting a connection
默认	20:39:12.167051+0800	Nota4	WebContent[61037]:   <private>: 104
默认	20:39:12.167093+0800	Nota4	WebContent[61037]:   <private>: 495680
默认	20:39:12.167108+0800	Nota4	WebContent[61037]: ProgressTracker::progressCompleted: frameID 4294967299, value 0.408661, tracked frames 1, originating frameID 4294967299, isMainLoad 1
默认	20:39:12.167140+0800	Nota4	WebContent[61037]: ProgressTracker::finalProgressComplete: value 0.408661, tracked frames 0, originating frameID 4294967299, isMainLoad 1, isMainLoadProgressing 0
默认	20:39:12.167160+0800	Nota4	WebContent[61037]: [pageID=48 frameID=4294967299 isMainFrame=1] FrameLoader::checkLoadCompleteForThisFrame: Finished frame load
默认	20:39:12.167197+0800	Nota4	WebContent[61037]: [renderingBackend=27] Created rendering backend for pageProxyID=47, webPageID=48
默认	20:39:12.167243+0800	Nota4	WebContent[61037] GPUProcessConnection::create - 0x10af55ea0
默认	20:39:12.167851+0800	Nota4	WebContent[61037]: [webFrameID=4294967299, webPageID=48] WebLocalFrameLoaderClient::dispatchDidReachLayoutMilestone: dispatching DidReachLayoutMilestone (milestones=DidFirstMeaningfulPaint)
默认	20:39:12.167917+0800	Nota4	WebContent[61037] 0x10af55ea0 - GPUProcessConnection::didInitialize
默认	20:39:12.171071+0800	Nota4	RemoteLayerTreeDrawingAreaProxy(50) Unhiding layer tree
默认	20:39:12.171169+0800	Nota4	0x14c148220 [pageProxyID=47, webPageID=48, PID=61037, DisplayID=1] RemoteLayerTreeDrawingAreaProxyMac::scheduleDisplayRefreshCallbacks
默认	20:39:13.462775+0800	runningboardd	Invalidating assertion 402-368-17028 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) from originator [osservice<com.apple.coreservices.launchservicesd>:368]
默认	20:39:13.472625+0800	Nota4	0x14c06c0c0 - [PID=0] WebProcessCache::setApplicationIsActive: (isActive=0)
默认	20:39:13.478133+0800	Nota4	<<<< Alt >>>> fpSupport_GetVideoRangeForCoreDisplayWithPreference: displayID 1 reported potentialHeadRoom=16 wideColorSupported=YES marz=NO almd=NO deviceAllowsHDR=YES isBuiltinPanel=YES externalPanel=YES prefersHDR10=NO
默认	20:39:13.492373+0800	runningboardd	Invalidating assertion 402-398-17029 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) from originator [osservice<com.apple.WindowServer(88)>:398]
默认	20:39:13.508225+0800	Nota4	[0x845925400] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:39:13.508258+0800	Nota4	[0x845926f80] invalidated because the current process cancelled the connection by calling xpc_connection_cancel()
默认	20:39:13.508615+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:13.508621+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:13.508796+0800	Nota4	WebContent[61037]: PerformanceMonitor::measureCPUUsageInActivityState: Process is using 11.3% CPU in state: <private>
默认	20:39:13.572391+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:39:13.572402+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:39:13.572468+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Set darwin role to: UserInteractiveNonFocal
默认	20:39:13.572480+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:39:13.572530+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:39:13.576033+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveNonFocal) (endowments: <private>)
默认	20:39:13.576487+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:39:13.577307+0800	Nota4	-[NSPersistentUIManager flushAllChanges]
默认	20:39:13.579782+0800	Nota4	-[NSPersistentUIManager flushAllChanges] finishing enqueued operations
默认	20:39:13.579806+0800	Nota4	-[NSPersistentUIManager flushAllChanges]_block_invoke asyncing to main queue
默认	20:39:13.579827+0800	Nota4	-[NSPersistentUIManager flushAllChanges]_block_invoke writing records
默认	20:39:15.167973+0800	Nota4	0x14c1280e0 NavigationState is releasing background process assertion because a page load completed
默认	20:39:15.168003+0800	Nota4	0x14c118240 - [PID=61037, throttler=0x14c0a06d0] ProcessThrottler::Activity::invalidate: Ending background activity / 'Page Load'
默认	20:39:18.531948+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [osservice<com.apple.coreservices.launchservicesd>:368] with description <RBSAssertionDescriptor| "frontmost:60949" ID:402-368-17062 target:60949 attributes:[
	<RBSDomainAttribute| domain:"com.apple.launchservicesd" name:"RoleUserInteractiveFocal" sourceEnvironment:"(null)">
	]>
默认	20:39:18.532131+0800	runningboardd	Assertion 402-368-17062 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:39:18.532723+0800	WindowServer	c752b[SetFrontProcess]: [DeferringManager] Updating policy {
    advicePolicy: .frontmost;
    frontmostProcess: 0x0-0x254254 (Nota4) mainConnectionID: B79A3;
} for reason: updated frontmost process
默认	20:39:18.532875+0800	WindowServer	c752b[SetFrontProcess]: [DeferringManager] Deferring events from frontmost process PSN 0x0-0x254254 (Nota4) -> <pid: 60949>
默认	20:39:18.533049+0800	WindowServer	new deferring rules for pid:398: [
    [398-5D2]; <keyboardFocus; Nota4:0x0-0x254254>; () -> <pid: 60949>; reason: frontmost PSN --> outbound target,
    [398-5D1]; <keyboardFocus; <frontmost>>; () -> <token: Nota4:0x0-0x254254; pid: 398>; reason: frontmost PSN,
    [398-5D0]; <keyboardFocus>; () -> <token: <frontmost>; pid: 398>; reason: Deferring to <frontmost>
]
默认	20:39:18.533152+0800	WindowServer	[keyboardFocus 0x8b5f445f0] setRules:forPID(398): [
    [398-5D2]; <keyboardFocus; Nota4:0x0-0x254254>; () -> <pid: 60949>; reason: frontmost PSN --> outbound target,
    [398-5D1]; <keyboardFocus; <frontmost>>; () -> <token: Nota4:0x0-0x254254; pid: 398>; reason: frontmost PSN,
    [398-5D0]; <keyboardFocus>; () -> <token: <frontmost>; pid: 398>; reason: Deferring to <frontmost>
]
默认	20:39:18.534835+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:39:18.538120+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [osservice<com.apple.WindowServer(88)>:398] with description <RBSAssertionDescriptor| "FUSBFrontmostProcess" ID:402-398-17063 target:60949 attributes:[
	<RBSDomainAttribute| domain:"com.apple.fuseboard" name:"Frontmost" sourceEnvironment:"(null)">,
	<RBSAcquisitionCompletionAttribute| policy:AfterApplication>
	]>
默认	20:39:18.538166+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:39:18.538263+0800	runningboardd	Assertion 402-398-17063 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:39:18.538259+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:39:18.538434+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Set darwin role to: UserInteractiveFocal
默认	20:39:18.538523+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:39:18.538626+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:39:18.563813+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:39:18.564146+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:39:18.564213+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:39:18.564266+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:39:18.564382+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:39:18.564691+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [osservice<com.apple.coreservices.launchservicesd>:368] with description <RBSAssertionDescriptor| "notification:60949" ID:402-368-17064 target:60949 attributes:[
	<RBSDomainAttribute| domain:"com.apple.launchservicesd" name:"LSNotification" sourceEnvironment:"(null)">
	]>
默认	20:39:18.564894+0800	runningboardd	Assertion 402-368-17064 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:39:18.565145+0800	Nota4	0x14c06c0c0 - [PID=0] WebProcessCache::setApplicationIsActive: (isActive=1)
默认	20:39:18.566184+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:39:18.566464+0800	Nota4	<<<< Alt >>>> fpSupport_GetVideoRangeForCoreDisplayWithPreference: displayID 1 reported potentialHeadRoom=16 wideColorSupported=YES marz=NO almd=NO deviceAllowsHDR=YES isBuiltinPanel=YES externalPanel=YES prefersHDR10=NO
默认	20:39:18.568262+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:39:18.568523+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:39:18.568538+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:39:18.568557+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:39:18.568648+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:39:18.571340+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app
默认	20:39:18.571727+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents
默认	20:39:18.571858+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/Info.plist
默认	20:39:18.572099+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:39:18.572622+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:39:18.572513+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app
默认	20:39:18.573167+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/MacOS/Nota4
默认	20:39:18.573340+0800	kernel	1 duplicate report for Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/MacOS/Nota4
默认	20:39:18.573347+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-xattr /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/MacOS/Nota4
默认	20:39:18.574290+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/Info.plist
默认	20:39:18.590889+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:18.590899+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:18.591036+0800	Nota4	WebContent[61037]: PerformanceMonitor::measureCPUUsageInActivityState: Process is using 0.2% CPU in state: <private>
默认	20:39:20.389580+0800	runningboardd	Invalidating assertion 402-368-17062 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) from originator [osservice<com.apple.coreservices.launchservicesd>:368]
默认	20:39:20.396596+0800	Nota4	0x14c06c0c0 - [PID=0] WebProcessCache::setApplicationIsActive: (isActive=0)
默认	20:39:20.400048+0800	Nota4	<<<< Alt >>>> fpSupport_GetVideoRangeForCoreDisplayWithPreference: displayID 1 reported potentialHeadRoom=16 wideColorSupported=YES marz=NO almd=NO deviceAllowsHDR=YES isBuiltinPanel=YES externalPanel=YES prefersHDR10=NO
默认	20:39:20.407469+0800	runningboardd	Invalidating assertion 402-398-17063 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) from originator [osservice<com.apple.WindowServer(88)>:398]
默认	20:39:20.424434+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:20.424443+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:39:20.424619+0800	Nota4	WebContent[61037]: PerformanceMonitor::measureCPUUsageInActivityState: Process is using 1.1% CPU in state: <private>
默认	20:39:20.496893+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:39:20.496905+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:39:20.496964+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Set darwin role to: UserInteractiveNonFocal
默认	20:39:20.496990+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:39:20.497055+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:39:20.498161+0800	Nota4	-[NSPersistentUIManager flushAllChanges]
默认	20:39:20.498219+0800	Nota4	-[NSPersistentUIManager flushAllChanges] finishing enqueued operations
默认	20:39:20.498234+0800	Nota4	-[NSPersistentUIManager flushAllChanges]_block_invoke asyncing to main queue
默认	20:39:20.498258+0800	Nota4	-[NSPersistentUIManager flushAllChanges]_block_invoke writing records
默认	20:39:20.500066+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveNonFocal) (endowments: <private>)
默认	20:39:20.500514+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:39:22.167659+0800	Nota4	WebContent[61037]: PerformanceMonitor::measurePostLoadMemoryUsage: Process was using 70107952 bytes of memory after the page load.
默认	20:39:24.564992+0800	runningboardd	Assertion did invalidate due to timeout: 402-368-17064 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])
默认	20:39:24.771411+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:39:24.771421+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:39:24.771446+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:39:24.771461+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:39:24.775753+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveNonFocal) (endowments: <private>)
默认	20:39:24.776778+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:39:27.168807+0800	Nota4	WebContent[61037]: PerformanceMonitor::measurePostLoadCPUUsage: Process was using 0.4% CPU after the page load.
默认	20:39:41.790214+0800	runningboardd	Invalidating assertion 402-398-16994 (target:[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005]) from originator [osservice<com.apple.WindowServer(88)>:398]
默认	20:39:41.791034+0800	runningboardd	Acquiring assertion targeting [xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] from originator [xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] with description <RBSAssertionDescriptor| "AppNap adapter assertion" ID:402-61005-17070 target:61005 attributes:[
	<RBSAcquisitionCompletionAttribute| policy:AfterApplication>,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"Enable" sourceEnvironment:"(null)">,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"PreventTimerThrottleTier5" sourceEnvironment:"(null)">
	]>
默认	20:39:41.791306+0800	runningboardd	Assertion 402-61005-17070 (target:[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005]) will be created as active
默认	20:39:41.792256+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring jetsam update because this process is not memory-managed
默认	20:39:41.792284+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring suspend because this process is not lifecycle managed
默认	20:39:41.792323+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring GPU update because this process is not GPU managed
默认	20:39:41.792371+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring memory limit update because this process is not memory-managed
默认	20:39:41.797545+0800	runningboardd	Invalidating assertion 402-61005-16988 (target:[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005]) from originator [xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005]
默认	20:39:41.798670+0800	gamepolicyd	Received state update for 61005 (xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005, running-NotVisible
默认	20:39:41.897852+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring jetsam update because this process is not memory-managed
默认	20:39:41.897880+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring suspend because this process is not lifecycle managed
默认	20:39:41.897900+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring GPU update because this process is not GPU managed
默认	20:39:41.897924+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Ignoring memory limit update because this process is not memory-managed
默认	20:39:41.897977+0800	runningboardd	[xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005] Set AppNap state: <RBMutableProcessAppNapState|0x8fc47b660 enabled:Y active:Y socket:Y disk:Y priority:Y cpu:Y timer:Tier5>
默认	20:39:41.905047+0800	gamepolicyd	Received state update for 61005 (xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005, running-NotVisible
默认	20:39:42.070899+0800	Nota4	WebContent[61037] Current memory footprint: 56 MB
默认	20:40:11.790769+0800	runningboardd	Invalidating assertion 402-398-16971 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) from originator [osservice<com.apple.WindowServer(88)>:398]
默认	20:40:11.792500+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] with description <RBSAssertionDescriptor| "AppNap adapter assertion" ID:402-60949-17079 target:60949 attributes:[
	<RBSAcquisitionCompletionAttribute| policy:AfterApplication>,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"Enable" sourceEnvironment:"(null)">,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"PreventTimerThrottleTier4" sourceEnvironment:"(null)">
	]>
默认	20:40:11.792649+0800	runningboardd	Assertion 402-60949-17079 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:40:11.798655+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:40:11.798713+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:40:11.798746+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:40:11.798846+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:40:11.803236+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveNonFocal) (endowments: <private>)
默认	20:40:11.803673+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:40:11.804025+0800	runningboardd	Invalidating assertion 402-60949-16970 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]
默认	20:40:11.804976+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:40:11.897643+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:40:11.897679+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:40:11.897707+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:40:11.897758+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:40:11.897895+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Set AppNap state: <RBMutableProcessAppNapState|0x8fcec1920 enabled:Y active:Y socket:Y disk:Y priority:Y cpu:Y timer:Tier4>
默认	20:40:11.906079+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveNonFocal) (endowments: <private>)
默认	20:40:11.907241+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:40:12.071628+0800	Nota4	WebContent[61037] Current memory footprint: 56 MB
默认	20:40:21.446321+0800	Nota4	WebContent[61037] 0x10a1a0200 - UserActivity::Impl::endActivity: description=App nap disabled for page due to user activity
默认	20:40:42.071679+0800	Nota4	WebContent[61037] Current memory footprint: 56 MB
默认	20:41:12.071202+0800	Nota4	WebContent[61037] Current memory footprint: 56 MB
默认	20:41:17.144540+0800	runningboardd	Resolved pid 61031 to [xpcservice<com.apple.spotlight.CSExattrCryptoService([xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005])(501)>{vt hash: 0}{definition:com.apple.spotlight.CSExattrCryptoService[standard][client]}:61031:61031]
默认	20:41:17.145348+0800	runningboardd	[xpcservice<com.apple.spotlight.CSExattrCryptoService([xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005])(501)>{vt hash: 0}{definition:com.apple.spotlight.CSExattrCryptoService[standard][client]}:61031:61031] is not RunningBoard jetsam managed.
默认	20:41:17.145409+0800	runningboardd	[xpcservice<com.apple.spotlight.CSExattrCryptoService([xpcservice<com.apple.appkit.xpc.openAndSavePanelService([app<application.com.nota4.Nota4.33353809.33353813(501)>:60949])(501)>{vt hash: 0}{definition:com.apple.appkit.xpc.openAndSavePanelService[standard][client]}:61005:61005])(501)>{vt hash: 0}{definition:com.apple.spotlight.CSExattrCryptoService[standard][client]}:61031:61031] This process will not be managed.
默认	20:41:42.071933+0800	Nota4	WebContent[61037] Current memory footprint: 56 MB
默认	20:41:52.690649+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [osservice<com.apple.coreservices.launchservicesd>:368] with description <RBSAssertionDescriptor| "frontmost:60949" ID:402-368-17102 target:60949 attributes:[
	<RBSDomainAttribute| domain:"com.apple.launchservicesd" name:"RoleUserInteractiveFocal" sourceEnvironment:"(null)">
	]>
默认	20:41:52.690849+0800	runningboardd	Assertion 402-368-17102 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:41:52.691375+0800	WindowServer	c752b[SetFrontProcess]: [DeferringManager] Updating policy {
    advicePolicy: .frontmost;
    frontmostProcess: 0x0-0x254254 (Nota4) mainConnectionID: B79A3;
} for reason: updated frontmost process
默认	20:41:52.691539+0800	WindowServer	c752b[SetFrontProcess]: [DeferringManager] Deferring events from frontmost process PSN 0x0-0x254254 (Nota4) -> <pid: 60949>
默认	20:41:52.691730+0800	WindowServer	new deferring rules for pid:398: [
    [398-5DB]; <keyboardFocus; Nota4:0x0-0x254254>; () -> <pid: 60949>; reason: frontmost PSN --> outbound target,
    [398-5DA]; <keyboardFocus; <frontmost>>; () -> <token: Nota4:0x0-0x254254; pid: 398>; reason: frontmost PSN,
    [398-5D9]; <keyboardFocus>; () -> <token: <frontmost>; pid: 398>; reason: Deferring to <frontmost>
]
默认	20:41:52.691801+0800	WindowServer	[keyboardFocus 0x8b5f445f0] setRules:forPID(398): [
    [398-5DB]; <keyboardFocus; Nota4:0x0-0x254254>; () -> <pid: 60949>; reason: frontmost PSN --> outbound target,
    [398-5DA]; <keyboardFocus; <frontmost>>; () -> <token: Nota4:0x0-0x254254; pid: 398>; reason: frontmost PSN,
    [398-5D9]; <keyboardFocus>; () -> <token: <frontmost>; pid: 398>; reason: Deferring to <frontmost>
]
默认	20:41:52.691870+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:41:52.691890+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:41:52.691931+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Set darwin role to: UserInteractiveFocal
默认	20:41:52.691984+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:41:52.692063+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:41:52.693222+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [osservice<com.apple.coreservices.launchservicesd>:368] with description <RBSAssertionDescriptor| "notification:60949" ID:402-368-17103 target:60949 attributes:[
	<RBSDomainAttribute| domain:"com.apple.launchservicesd" name:"LSNotification" sourceEnvironment:"(null)">
	]>
默认	20:41:52.693193+0800	WindowServer	chain did update (setDeferringRules) <keyboardFocus; display: null> containsEndOfChain: YES; [
    <token: <frontmost>; pid: 398>,
    <token: Nota4:0x0-0x254254; pid: 398>,
    <pid: 60949>,
    <token: viewbridge-key-window; pid: 60949>
]
默认	20:41:52.693305+0800	runningboardd	Assertion 402-368-17103 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:41:52.699193+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:41:52.700162+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] with description <RBSAssertionDescriptor| "AppNap adapter assertion" ID:402-60949-17104 target:60949 attributes:[
	<RBSAcquisitionCompletionAttribute| policy:AfterApplication>,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"Enable" sourceEnvironment:"(null)">,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"Inactive" sourceEnvironment:"(null)">,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"PreventDiskThrottle" sourceEnvironment:"(null)">,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"PreventSuppressedCPU" sourceEnvironment:"(null)">,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"PreventLowPriorirtyCPU" sourceEnvironment:"(null)">,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"PreventBackgroundSockets" sourceEnvironment:"(null)">,
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"PreventTimerThrottleTier0" sourceEnvironment:"(null)<…>
默认	20:41:52.700238+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:41:52.700269+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:41:52.700309+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:41:52.700345+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:41:52.700426+0800	runningboardd	Assertion 402-60949-17104 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:41:52.701956+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:41:52.704123+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app
默认	20:41:52.704680+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:41:52.705084+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:41:52.705102+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [osservice<com.apple.WindowServer(88)>:398] with description <RBSAssertionDescriptor| "FUSBFrontmostProcess" ID:402-398-17105 target:60949 attributes:[
	<RBSDomainAttribute| domain:"com.apple.fuseboard" name:"Frontmost" sourceEnvironment:"(null)">,
	<RBSAcquisitionCompletionAttribute| policy:AfterApplication>
	]>
默认	20:41:52.705164+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:41:52.705267+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:41:52.705359+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:41:52.705332+0800	runningboardd	Assertion 402-398-17105 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:41:52.705319+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:41:52.705424+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Set AppNap state: <RBMutableProcessAppNapState|0x8fc52b4e0 enabled:Y active:N socket:N disk:N priority:N cpu:N timer:Tier0>
默认	20:41:52.707803+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents
默认	20:41:52.708657+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:41:52.709166+0800	runningboardd	Invalidating assertion 402-60949-17079 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) from originator [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]
默认	20:41:52.709229+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:41:52.709362+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:41:52.709430+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:41:52.709501+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:41:52.726639+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:41:52.712374+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:41:52.734714+0800	Nota4	0x14c06c0c0 - [PID=0] WebProcessCache::setApplicationIsActive: (isActive=1)
默认	20:41:52.736452+0800	Nota4	<<<< Alt >>>> fpSupport_GetVideoRangeForCoreDisplayWithPreference: displayID 1 reported potentialHeadRoom=16 wideColorSupported=YES marz=NO almd=NO deviceAllowsHDR=YES isBuiltinPanel=YES externalPanel=YES prefersHDR10=NO
默认	20:41:52.738104+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/Info.plist
默认	20:41:52.738442+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app
默认	20:41:52.738790+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/MacOS/Nota4
默认	20:41:52.739065+0800	kernel	1 duplicate report for Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/MacOS/Nota4
默认	20:41:52.739069+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-xattr /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/MacOS/Nota4
默认	20:41:52.739612+0800	kernel	Sandbox: ContextStoreAgent(28911) allow file-read-data /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app/Contents/Info.plist
默认	20:41:52.762362+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:41:52.762496+0800	Nota4	WebContent[61037] 0x10a1a0200 - UserActivity::Impl::beginActivity: description=App nap disabled for page due to user activity
默认	20:41:52.762593+0800	Nota4	WebContent[61037]: PerformanceMonitor::measureCPUUsageInActivityState: Process is using 0.1% CPU in state: <private>
默认	20:41:52.763362+0800	runningboardd	Acquiring assertion targeting [app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] from originator [osservice<com.apple.WindowServer(88)>:398] with description <RBSAssertionDescriptor| "AppDrawing" ID:402-398-17106 target:60949 attributes:[
	<RBSDomainAttribute| domain:"com.apple.appnap" name:"AppDrawing" sourceEnvironment:"(null)">,
	<RBSAcquisitionCompletionAttribute| policy:AfterApplication>
	]>
默认	20:41:52.763147+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:41:52.763412+0800	runningboardd	Assertion 402-398-17106 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) will be created as active
默认	20:41:52.763156+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:41:52.763878+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:41:52.763922+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:41:52.763998+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:41:52.764039+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:41:52.768969+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:41:52.802584+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:41:52.802618+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:41:52.802645+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:41:52.802704+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:41:52.807908+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveFocal) (endowments: <private>)
默认	20:41:52.816080+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
默认	20:41:54.943348+0800	Nota4	0x14c06c0c0 - [PID=0] WebProcessCache::setApplicationIsActive: (isActive=0)
默认	20:41:54.947665+0800	Nota4	<<<< Alt >>>> fpSupport_GetVideoRangeForCoreDisplayWithPreference: displayID 1 reported potentialHeadRoom=16 wideColorSupported=YES marz=NO almd=NO deviceAllowsHDR=YES isBuiltinPanel=YES externalPanel=YES prefersHDR10=NO
默认	20:41:54.951036+0800	runningboardd	Invalidating assertion 402-368-17102 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) from originator [osservice<com.apple.coreservices.launchservicesd>:368]
默认	20:41:54.977746+0800	runningboardd	Invalidating assertion 402-398-17105 (target:[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949]) from originator [osservice<com.apple.WindowServer(88)>:398]
默认	20:41:54.978487+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:41:54.978497+0800	Nota4	PageClientImpl 0x14c000300 isViewVisible(): viewWindow 0x84754c600, window visible 1, view hidden 0, window occluded 0
默认	20:41:54.978668+0800	Nota4	WebContent[61037]: PerformanceMonitor::measureCPUUsageInActivityState: Process is using 1.3% CPU in state: <private>
默认	20:41:55.044511+0800	Nota4	-[NSPersistentUIManager flushAllChanges]
默认	20:41:55.044581+0800	Nota4	-[NSPersistentUIManager flushAllChanges] finishing enqueued operations
默认	20:41:55.044598+0800	Nota4	-[NSPersistentUIManager flushAllChanges]_block_invoke asyncing to main queue
默认	20:41:55.044610+0800	Nota4	-[NSPersistentUIManager flushAllChanges]_block_invoke writing records
默认	20:41:55.060334+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring jetsam update because this process is not memory-managed
默认	20:41:55.060347+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring suspend because this process is not lifecycle managed
默认	20:41:55.060374+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Set darwin role to: UserInteractiveNonFocal
默认	20:41:55.060396+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring GPU update because this process is not GPU managed
默认	20:41:55.060476+0800	runningboardd	[app<application.com.nota4.Nota4.33353809.33353813(501)>:60949] Ignoring memory limit update because this process is not memory-managed
默认	20:41:55.064327+0800	runningboardd	Calculated state for app<application.com.nota4.Nota4.33353809.33353813(501)>: running-active (role: UserInteractiveNonFocal) (endowments: <private>)
默认	20:41:55.064748+0800	gamepolicyd	Received state update for 60949 (app<application.com.nota4.Nota4.33353809.33353813(501)>, running-active-NotVisible
