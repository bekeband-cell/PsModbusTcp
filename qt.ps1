
$test_ping = Test-NetConnection -Port 502 -ComputerName "127.0.0.1"

Write-Host $test_ping

#$job = Start-Job -ScriptBlock { Test-Connection -ComputerName ("127.0.0.1") }
#$Results = Receive-Job $job -Wait
#$Results