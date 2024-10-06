$job = Start-Job -ScriptBlock { Test-Connection -ComputerName ("127.0.0.1") }
$Results = Receive-Job $job -Wait
$Results