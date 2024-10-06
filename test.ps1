# "Functions loading."
. .\PsModbusTcp.ps1


Greet-User -Name "MODBUS reading program START."

$stopwatch = [system.diagnostics.stopwatch]::StartNew()
#$stopwatch.Elapsed

$servers = "127.0.0.1", "34.2.3.1", "234.1.0.1"

do {
 
    for ($i = 0; $i -lt $servers.Length; $i++) {

        Write-Host "MODBUS cliens pinging " + $servers[$i]
        $share = Test-Connection -Count 1 -Delay 1 -Quiet -ComputerName $servers[$i]
        if ($share) {
            "command succeeded"
            $share #| Foreach-Object { ... }
        }
        else {
            "command failed"
        }
        #Write-Host "MODBUS cliensek pingelése " + $servers[$i]
        #    Test-Connection -ComputerName $servers[$i] -Count 2
    }



    Start-Sleep -Milliseconds 1000

}while (0)



#Read-HoldingRegisters -Address 127.0.0.1 -Port 502 -Reference 0 -Num 8