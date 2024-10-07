# "Functions loading."
. .\PsModbusTcp.ps1


"MODBUS READING PROGRAM START:" 
"Date and time is: $((Get-Date).ToString())"

#Arguments from command line.
$computername = "127.0.0.1"
$portnumber = "502"
$MODBUS_address = '0'
$output_directory = ".\DATAS\"
$dirname = "yyyyMM"
$filename = "yyyyMMdd"

$dayfolder = $dirname + $output_directory

$MHEdate = (Get-Date).tostring("yyyyMMddHHmmss") # example output 20161122. 

$logoname = 'LOG' + $MHEdate + '.csv'
$OutputFile1 = Join-Path $output_directory $logoname
"query output file is ---> " > $OutputFile1

$stopwatch = [system.diagnostics.stopwatch]::StartNew()
#$stopwatch.Elapsed

$servers = "127.0.0.1", "34.2.3.1", "234.1.0.1"

if (Test-Path -Path $dayfolder) {
    "Path exists!"
}
else {
    "Path doesn't exist."
}

do {
    #Test the computer ping.
    Write-Host "MODBUS cliens pinging " $computername
    #    $test_ping = Test-Connection -Count 1 -Delay 1 -Quiet -ComputerName $computername
    #    $test_ping = Test-NetConnection -Port $portnumber -ComputerName $computername
    if (1) {
        Write-Host "Ping succeed." -ForegroundColor Green 
        $cont_dataread = 1
        do {

            Start-Sleep -Milliseconds 1000
            $read_return = Read-HoldingRegisters -Address $computername -Port $portnumber -Reference $MODBUS_address -Num 8
 
            if ($null -ne $read_return) {
                Write-Host "Succesfully read from MODBUS client." -ForegroundColor Green
                Write-Host "Computer: " $computername " Date: " $((Get-Date).ToString())
                Write-Host "Readed data: " $read_return
            }
            else {
                Write-Host "No read from MODBUS client." -ForegroundColor Red
                $cont_dataread = 0
            }
        }while ($cont_dataread)


    }
    else {
        Write-Host "Ping failed." -ForegroundColor Red
    }
    #Write-Host "MODBUS cliensek pingelése " + $servers[$i]
    #    Test-Connection -ComputerName $servers[$i] -Count 2

    

}while (1)



#Read-HoldingRegisters -Address 127.0.0.1 -Port 502 -Reference 0 -Num 8