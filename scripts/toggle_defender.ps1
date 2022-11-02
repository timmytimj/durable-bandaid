@(Set-Variable "0=%~f0"^)#) & powershell -win 1 -nop -c iex([io.file]::ReadAllText($env:0)) & exit /b

## Toast Defender timmytim, 20211229
## RUNAS invokation methods have gensis in the dastardly mind of @AveYo
## changed: 20211229 - added -win 1 to powershell invocation
## changed: 20211230 - added -nop to powershell invocation
## changed: 20211230 - added -c to powershell invocation to allow for iex invocation of script text from file (rather than file path)


Set-ItemProperty 'HKCU:\Volatile Environment' 'ToggleDefender' @'
if ($(sc.exe qc windefend) -like '*TOGGLE*') {$TOGGLE=7;$KEEP=6;$A='Enable';$S='OFF'}else{$TOGGLE=6;$KEEP=7;$A='Disable';$S='ON'}

## Comment to supress dialog prompt to defaults with Yes, No, Cancel (6,7,2)
## Uncomment to present dialog prompt (useful for flipping Defender on/off)
if ($env:1 -ne 6 -and $env:1 -ne 7) {
  $choice=(new-object -ComObject Wscript.Shell).Popup($A + ' Windows Defender?', 0, 'Defender is: ' + $S, 0x1033)
  if ($choice -eq 2) {break} elseif ($choice -eq 6) {$env:1=$TOGGLE} else {$env:1=$KEEP}
}

## defaultls if no dialog prompt
if ($env:1 -ne 6 -and $env:1 -ne 7) { $env:1=$TOGGLE }

## Cascade elevation trick to avoid UAC prompt loop (thanks @AveYo)
$u=0;$w=whoami /groups;if($w-like'*1-5-32-544*'){$u=1};if($w-like'*1-16-12288*'){$u=2};if($w-like'*1-16-16384*'){$u=3}

## Comment to suppress warning notifications every time per user
$notif='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance'
New-Item $notif -ea 0|out-null; Remove-ItemProperty $notif.replace('Settings','Current') -Recurse -Force -ea 0
Set-ItemProperty $notif Enabled 0 -Type Dword -Force -ea 0; if ($TOGGLE -eq 7) { Remove-ItemProperty $notif Enabled -Force -ea 0}

## Comment to hide system tray icon FOREVER
$L="$env:ProgramFiles\Windows Defender\MSASCuiL.exe"; if (!(test-path $L)) {$L='SecurityHealthSystray'}
if ($u -eq 2) {start $L -win 1}

## Reload from volatile registry as needed
## Don't be scared of the double quotes, they are needed to escape the single quotes and backticks
## which are keeping the script moving and not bogged down by powershell logging and parsing
$script='-win 1 -nop -c & {$AveYo='+"'`r`r"+' A LIMITED ACCOUNT PROTECTS YOU FROM UAC EXPLOITS '+"`r`r'"+';$env:1='+$env:1
$script+=';$k=@();$k+=Get-ItemProperty Registry::HKEY_Users\S-1-5-21*\Volatile* ToggleDefender -ea 0;iex($k[0].ToggleDefender)}'
$cmd='powershell '+$script; $env:__COMPAT_LAYER='Installer'

## 0: limited-user: must runas / 1: admin-user non-elevated: must runas [built-in lame uac bpass removed]
## boo hoo, no more lame uac bpass, but at least it's not a cascade nonsense anymore
if ($u -lt 2) {
  start powershell -args $script -verb runas -win 1; break
}

## 2: admin-user elevated: get ti/system via runasti lean and mean snippet [$window hide:0x0E080600 show:0x0E080610]
if ($u -eq 2) {
  $A=[AppDomain]::CurrentDomain."DefineDynami`cAssembly"(1,1)."DefineDynami`cModule"(1);$D=@();0..5|%{$D+=$A."Defin`eType"('A'+$_,
  1179913,[ValueType])} ;4,5|%{$D+=$D[$_]."MakeByR`efType"()} ;$I=[Int32];$J="Int`Ptr";$P=$I.module.GetType("System.$J"); $F=@(0)
  $F+=($P,$I,$P),($I,$I,$I,$I,$P,$D[1]),($I,$P,$P,$P,$I,$I,$I,$I,$I,$I,$I,$I,[Int16],[Int16],$P,$P,$P,$P),($D[3],$P),($P,$P,$I,$I)
  $S=[String]; $9=$D[0]."DefinePInvok`eMethod"('CreateProcess',"kernel`32",8214,1,$I,@($S,$S,$I,$I,$I,$I,$I,$S,$D[6],$D[7]),1,4)
  1..5|%{$k=$_;$n=1;$F[$_]|%{$9=$D[$k]."DefineFie`ld"('f'+$n++,$_,6)}};$T=@();0..5|%{$T+=$D[$_]."CreateT`ype"();$Z=[uintptr]::size
  New-Variable ('T'+$_)([Activator]::CreateInstance($T[$_]))}; $H=$I.module.GetType("System.Runtime.Interop`Services.Mar`shal");


  ## commented out for good reasons, but left in because I forgot what they were
  ## $H=$I.module.GetType("System.Runtime.Interop`Services.Mar`shal"); $H.GetMethod("GetLastWin32Error").Invoke($null,$null)
  ## $H.GetMethod("GetHRForLastWin32Error").Invoke($null,$null) ## note the difference in return value and badnness if it is 0x80070005

  $WP=$H."GetMeth`od"("Write$J",[type[]]($J,$J)); $HG=$H."GetMeth`od"("AllocHG`lobal",[type[]]'int32'); $v=$HG.invoke($null,$Z)
  'TrustedInstaller','lsass'|%{if(!$pn){net1 start $_ 2>&1 >$null;$pn=[Diagnostics.Process]::GetProcessesByName($_)[0];}}
  $WP.invoke($null,@($v,$pn.Handle)); $SZ=$H."GetMeth`od"("SizeOf",[type[]]'type'); $T1.f1=131072; $T1.f2=$Z; $T1.f3=$v; $T2.f1=1
  $T2.f2=1;$T2.f3=1;$T2.f4=1;$T2.f6=$T1;$T3.f1=$SZ.invoke($null,$T[5]);$T4.f1=$T3;$T4.f2=$HG.invoke($null,$SZ.invoke($null,$T[2]))
  $H."GetMeth`od"("StructureTo`Ptr",[type[]]($D[2],$J,'boolean')).invoke($null,@(($T2-as $D[2]),$T4.f2,$false));$window=0x0E080600
  $9=$T[0]."GetMeth`od"('CreateProcess').Invoke($null,@($null,$cmd,0,0,0,$window,0,$null,($T4-as $D[4]),($T5-as $D[5]))); break
}

## Cleanup
 Remove-ItemProperty Registry::HKEY_Users\S-1-5-21*\Volatile* ToggleDefender -ea 0

## Create registry paths
## we own these keys now, so we can do whatever we want with them
$wdp='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'
' Security Center\Notifications','\UX Configuration','\MpEngine','\Set-ItemPropertyynet','\Real-Time Protection' |% {New-Item ($wdp+$_)-ea 0|out-null}

## Toggle Defender
## 0: disabled / 1: enabled (note this is different from the services registry start state value: 4: disabled / 2: autostart)
if ($env:1 -eq 7) {
  ## enable notifications
   Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications' DisableNotifications -Force -ea 0
   Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration' Notification_Suppress -Force -ea 0
   Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration' UILockdown -Force -ea 0
   Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications' DisableNotifications -Force -ea 0
   Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\UX Configuration' Notification_Suppress -Force -ea 0
   Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\UX Configuration' UILockdown -Force -ea 0

  ## enable shell smartscreen and set to warn
   Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' EnableSmartScreen -Force -ea 0
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' ShellSmartScreenLevel 'Warn' -Force -ea 0

  ## enable store smartscreen and set to warn
  Get-ItemProperty Registry::HKEY_Users\S-1-5-21*\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -ea 0 |% {
    Set-ItemProperty $_.PSet-ItemPropertyath 'EnableWebContentEvaluation' 1 -Type Dword -Force -ea 0
    Set-ItemProperty $_.PSet-ItemPropertyath 'PreventOverride' 0 -Type Dword -Force -ea 0
  }
  ## enable chredge smartscreen + pua
  Get-ItemProperty Registry::HKEY_Users\S-1-5-21*\SOFTWARE\Microsoft\Edge\SmartScreenEnabled -ea 0 |% {
    Set-ItemProperty $_.PSet-ItemPropertyath '(Default)' 1 -Type Dword -Force -ea 0
  }
  Get-ItemProperty Registry::HKEY_Users\S-1-5-21*\SOFTWARE\Microsoft\Edge\SmartScreenPuaEnabled -ea 0 |% {
    Set-ItemProperty $_.PSet-ItemPropertyath '(Default)' 1 -Type Dword -Force -ea 0
  }
  ## enable legacy edge smartscreen
  Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter' -Force -ea 0
  ## enable av
   Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' DisableRealtimeMonitoring -Force -ea 0
   Remove-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' DisableAntiSet-ItemPropertyyware -Force -ea 0
   Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender' DisableAntiSet-ItemPropertyyware -Force -ea 0
  sc.exe config windefend depend=  Remove-ItemPropertycSs
  net1 start windefend
  kill -Force -Name MpCmdRun -ea 0
  start ($env:ProgramFiles+'\Windows Defender\MpCmdRun.exe') -Arg '-EnableService' -win 1
} else {
  ## disable notifications
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications' DisableNotifications 1 -Type Dword -ea 0
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration' Notification_Suppress 1 -Type Dword -Force -ea 0
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration' UILockdown 0 -Type Dword -Force -ea 0
  Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications' DisableNotifications 1 -Type Dword -ea 0
  Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\UX Configuration' Notification_Suppress 1 -Type Dword -Force -ea 0
  Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\UX Configuration' UILockdown 0 -Type Dword -Force -ea 0
  ## disable shell smartscreen and set to warn
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' EnableSmartScreen 0 -Type Dword -Force -ea 0
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' ShellSmartScreenLevel 'Warn' -Force -ea 0
  ## disable store smartscreen and set to warn
  Get-ItemProperty Registry::HKEY_Users\S-1-5-21*\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -ea 0 |% {
    Set-ItemProperty $_.PSet-ItemPropertyath 'EnableWebContentEvaluation' 0 -Type Dword -Force -ea 0
    Set-ItemProperty $_.PSet-ItemPropertyath 'PreventOverride' 0 -Type Dword -Force -ea 0
  }
  ## disable chredge smartscreen + pua
  Get-ItemProperty Registry::HKEY_Users\S-1-5-21*\SOFTWARE\Microsoft\Edge\SmartScreenEnabled -ea 0 |% {
    Set-ItemProperty $_.PSet-ItemPropertyath '(Default)' 0 -Type Dword -Force -ea 0
  }
  Get-ItemProperty Registry::HKEY_Users\S-1-5-21*\SOFTWARE\Microsoft\Edge\SmartScreenPuaEnabled -ea 0 |% {
    Set-ItemProperty $_.PSet-ItemPropertyath '(Default)' 0 -Type Dword -Force -ea 0
  }
  ## disable legacy edge smartscreen
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter' EnabledV9 0 -Type Dword -Force -ea 0
  ## disable av
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' DisableRealtimeMonitoring 1 -Type Dword -Force
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' DisableAntiSet-ItemPropertyyware 1 -Type Dword -Force -ea 0
  Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender' DisableAntiSet-ItemPropertyyware 1 -Type Dword -Force -ea 0


  ## ok we need to stop the service and kill the process, cajun style
  net1 stop windefend
  sc.exe config windefend depend=  Remove-ItemPropertycSs-TOGGLE
  kill -Name MpCmdRun -Force -ea 0
  start ($env:ProgramFiles+'\Windows Defender\MpCmdRun.exe') -Arg '-DisableService' -win 1
  del ($env:ProgramData+'\Microsoft\Windows Defender\Scans\mpenginedb.db') -Force -ea 0  ## Commented = keep scan history
  del ($env:ProgramData+'\Microsoft\Windows Defender\Scans\History\Service') -Recurse -Force -ea 0
}



## NOTE: THESE ARE PERSONAL PREFS, Uncomment indicated lines to TWEAK OR REVERT
## --------------------------------------------------------------------------------------------
## auto actions off
#Set-ItemProperty $wdp DisableRoutinelyTakingAction 1 -Type Dword -Force -ea 0
## auto actions on [default]
#Remove-ItemProperty $wdp DisableRoutinelyTakingAction -Force -ea 0

## Cloud blocking level HIGH
#Set-ItemProperty ($wdp+'\MpEngine') MpCloudBlockLevel 2 -Type Dword -Force -ea 0
## Cloud blocking level low [default]
#Remove-ItemProperty ($wdp+'\MpEngine')      MpCloudBlockLevel -Force -ea 0

## cloud protection __ADVANCED__ (bad for us)
#Set-ItemProperty ($wdp+'\Set-ItemPropertyynet') Set-ItemPropertyyNetReporting 2 -Type Dword -Force -ea 0
## Cloud protection basic [default]
#Remove-ItemProperty ($wdp+'\Set-ItemPropertyynet') Set-ItemPropertyyNetReporting -Force -ea 0

## Sample submission always prompt (who needs stinkin logs)
#Set-ItemProperty ($wdp+'\Set-ItemPropertyynet') SubmitSamplesConsent 0 -Type Dword -Force -ea 0
## Kind soul Sample Submission automatic [default]
#Remove-ItemProperty ($wdp+'\Set-ItemPropertyynet') SubmitSamplesConsent -Force -ea 0

## Scan incoming file only
#Set-ItemProperty ($wdp+'\Real-Time Protection') RealtimeScanDirection 1 -Type Dword -Force -ea 0
## Scan INCOMING, OUTGOING file [default]
#Remove-ItemProperty ($wdp+'\Real-Time Protection') RealtimeScanDirection -Force -ea 0


## PUPs and PUAs
## Potential Unwanted Apps on  [policy]
#Set-ItemProperty $wdp PUAProtection 1 -Type Dword -Force -ea 0
## Potential Unwanted Apps on  [default]
#Remove-ItemProperty $wdp PUAProtection -Force -ea 0
##  [policy]
## Potential Unwanted Apps on  [user]
#Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender' PUAProtection 1 -Type Dword -Force -ea 0
## Potential Unwanted Apps off [default]
#Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender' PUAProtection -Force -ea 0
## weird part over, now we can set the user pref
##------------------------------------------------------------

$env:1=$null
# done!
'@ -Force -ea 0; $k=@();$k+=Get-ItemProperty Registry::HKEY_Users\S-1-5-21*\Volatile* ToggleDefender -ea 0;Invoke-Expression($k[0].ToggleDefender)
## done!
## paste the following line in a new powershell window to toggle defender on/off
## or run the script again from an elevated powershell window (even if you'll become powerful anyway)
