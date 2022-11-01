Clear-Host

Write-Host -ForegroundColor Red "0 -> Use the GUI [default]"
Write-Host -ForegroundColor Green "1 -> Never check for updates [(not usually) recommended]"
Write-Host -ForegroundColor Red "2 -> Notify about new updates [lies]"
Write-Host -ForegroundColor Red "3 -> Auto download and notify [deception]"
Write-Host -ForegroundColor Red "4 -> Auto download and update [bad news]"

Write-Host -ForegroundColor Yellow "Type any _character_ to exit"
Write-Host
switch(Read-Host "Choose NEW Window Update Settings"){
       0 {$UpdateValue = 0}
       1 {$UpdateValue = 1}
       2 {$UpdateValue = 2}
       3 {$UpdateValue = 3}
       4 {$UpdateValue = 4}
       Default{Exit}
}

$WUP = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
$AUP = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

If(Test-Path -Path $WUP) {
    ri -Path $WUP -Recurse
}


If ($UpdateValue -gt 0) {
    ni -Path $WUP
    ni -Path $AUP
}

If ($UpdateValue -eq 1) {
    sp -Path $AUP -Name NoAutoUpdate -Value 1
}

If ($UpdateValue -eq 2) {
    sp -Path $AUP -Name NoAutoUpdate -Value 0
    sp -Path $AUP -Name AUOptions -Value 2
    sp -Path $AUP -Name ScheduledInstallDay -Value 0
    sp -Path $AUP -Name ScheduledInstallTime -Value 3
}

If ($UpdateValue -eq 3) {
    sp -Path $AUP -Name NoAutoUpdate -Value 0
    sp -Path $AUP -Name AUOptions -Value 3
    sp -Path $AUP -Name ScheduledInstallDay -Value 0
    sp -Path $AUP -Name ScheduledInstallTime -Value 3
}

If ($UpdateValue -eq 4) {
    sp -Path $AUP -Name NoAutoUpdate -Value 0
    sp -Path $AUP -Name AUOptions -Value 4
    sp -Path $AUP -Name ScheduledInstallDay -Value 0
    sp -Path $AUP -Name ScheduledInstallTime -Value 3
}