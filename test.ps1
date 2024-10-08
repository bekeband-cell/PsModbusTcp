# "Functions loading."
. .\PsModbusTcp.ps1

#Arguments from command line.
$computername = "127.0.0.1"
$portnumber = "502"
$MODBUS_address = '0'
$output_directory = ".\DATAS\"
$dirname = "DATASyyyyMM"
$filename = "yyyyMMdd"

$MHEdate = (Get-Date).tostring("yyyyMMddHHmmss") # example output 20161122. 
$YMdir = (Get-Date).tostring($dirname)
$YMDdir = (Get-Date).tostring($filename)

$logoname = 'LOG' + $MHEdate + '.csv'

$stopwatch = [system.diagnostics.stopwatch]::StartNew()
#$stopwatch.Elapsed

for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[ $i ] -eq "-c") { $computername = $args[ $i + 1 ] }
    if ($args[ $i ] -eq "-p") { $portnumber = $args[ $i + 1 ] }
    if ($args[ $i ] -eq "-d") { $dirname = $args[ $i + 1 ] }
    if ($args[ $i ] -eq "-f") { $filename = $args[ $i + 1 ] }
}

"MODBUS READING PROGRAM START:" 
"Date and time is: $((Get-Date).ToString())"

$dayfolder = $dirname + $output_directory
# .\Path
function MakePathIfNoExist {
    param (
        [Parameter(Mandatory = $true)][string]$PathString
    )
    if (Test-Path -Path "$PathString") {
        "$PathString exists!"
    }
    else {
        "$YMdir doesn't exist Create:"
        New-Item -Path "$PathString" -ItemType Directory
    }
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
                # here to write to file
                MakePathIfNoExist -PathString ".\$YMdir"

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