
$test_ping = Test-NetConnection -Port 502 -ComputerName "127.0.0.1"

Write-Host $test_ping


# .\Path
function MakePathIfNoExist {
    param (
        [Parameter(Mandatory = $true)][string]$PathString
    )
    if (Test-Path -Path "$PathString") {
        Write-Debug "$PathString exists!"
    }
    else {
        Write-Debug "$YMdir doesn't exist Create:"
        New-Item -Path "$PathString" -ItemType Directory

    }
}

MakePathIfNoExist -PathString "\\172.30.100.11\termeles\Emerson Reports\GAZELEMZOK\LAPOS\file.txt"



"\\172.30.100.11\termeles\Emerson Reports\GAZELEMZOK\LAPOS\file.txt"

#$job = Start-Job -ScriptBlock { Test-Connection -ComputerName ("127.0.0.1") }
#$Results = Receive-Job $job -Wait
#$Results