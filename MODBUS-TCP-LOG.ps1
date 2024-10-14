# "Functions loading."
. .\PsModbusTcp.ps1

#Arguments from command line. These are default value as well.
$computername = "localhost"
$portnumber = "502"
$MODBUS_address = '0'
$output_directory = ".\DATAS\"
$dirname = "yyyyMM"
$filename = $dirname + "dd"
$samplesec = 1    # sample times (1..30 x10 sec)
$samplecount = 30 # data save in sample times(6..24 x sample time)

$datacounter = 0

# We are assume that 8 channels datas from MODBUS.
# $fileheader = "Date`tChan1`tChan2`tChan3`tChan4`tChan5`tChan6`tChan7`tChan8"
$fileheader = "Date`tChan1`tChan2`tChan3"

$stopwatch = [system.diagnostics.stopwatch]::StartNew()
#$stopwatch.Elapsed

function MinMaxSetting($min, $max, $value) {
    if (($value -gt $max)) {
        return $max
    }
    else {
        if ($value -lt $min) {
            return $min;
        }
        else {
            return $value
        }
    }
 
}

Function Quit($Text) {
    Write-Host "Quiting because: " $Text
    Break Script
} 

# $samplesec = MinMaxSetting 1 30 "3"

for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[ $i ] -eq "-c") { 
        $computername = $args[ $i + 1 ] 
        Write-Debug("ComputerName = $computername") 
    }
    if ($args[ $i ] -eq "-p") { 
        $portnumber = $args[ $i + 1 ] 
        Write-Debug("PortNumber = $portnumber") 
    }
    if ($args[ $i ] -eq "-d") { 
        $dirname = $args[ $i + 1 ]
        Write-Debug("DirName = $dirname") 
    }
    if ($args[ $i ] -eq "-f") { 
        $filename = $args[ $i + 1 ] 
        Write-Debug("FileName = $filename")
    }
    if ($args[ $i ] -eq "-g") { 
        $samplesec = MinMaxSetting 1 30 $args[ $i + 1 ]
        Write-Debug("Samplesec = $samplesec")
    }
    if ($args[ $i ] -eq "-j") { 
        $samplecount = MinMaxSetting 6 24 $args[ $i + 1 ] 
        Write-Debug("Samplecount = $samplecount")
    }
    if ($args[ $i ] -eq "-k") { 
        $fileheader = $args[ $i + 1 ]
        Write-Debug("FileHeader = $fileheader")
    }
    if ($args[ $i ] -eq "-h") { 
        Quit("never mind.")
    }
}

"MODBUS READING PROGRAM START:" 
"Date and time is: $((Get-Date).ToString())"

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

do {
    #    Test the computer ping.
    #    Write-Host "MODBUS cliens pinging " $computername
    #    $test_ping = Test-Connection -Count 1 -Delay 1 -Quiet -ComputerName $computername
    #    $test_ping = Test-NetConnection -Port $portnumber -ComputerName $computername
    #    Write-Host "Ping succeed." -ForegroundColor Green 
    #    $test_ping = Test-Connection -Count 1 -Delay 1 -Quiet -ComputerName $computername
    Start-Sleep -Milliseconds ($samplesec * 1000)
    Write-Host "$computername pinging."
    $test_ping = Test-Connection -Count 1 -Delay 1 -Quiet -ComputerName $computername

    if ($test_ping) {
        Write-Host "$computername ping: " -NoNewline
        Write-Host " OK." -ForegroundColor Green
        $read_return = Read-HoldingRegisters -Address $computername -Port $portnumber -Reference $MODBUS_address -Num 8
            
        if ($null -ne $read_return) {
            Write-Host "Succesfully read from MODBUS client." -ForegroundColor Green

            if ($datacounter -lt $samplecount) {
                $datacounter++
            }
            else {
                $datacounter = 0
                Write-Host "Computer: " $computername " Date: " $((Get-Date).ToString())

                Write-Debug "datacounter = samplecount. Write csv file."
            }

            Write-Host "Readed data: " $read_return
            # here to write to file
            # filename making
                 
            $YMdir = $output_directory + (Get-Date).tostring($dirname)
            $YMDdir = $YMdir + '\' + (Get-Date).tostring($filename)
                
            $logoname = $YMDdir + '.csv'

            MakePathIfNoExist -PathString "$YMdir"

            if (Test-Path -Path "$logoname") {
                Write-Debug "$logoname exists!"
            }
            else {
                New-Item -Path . -Name "$logoname" -ItemType "file" -Value "$fileheader"
                #                MakePathIfNoExist -PathString "$logoname"
            }

        }
        else {
            Write-Host "No read from MODBUS client." -ForegroundColor Red
            $datacounter = 0
        }

    }
    else {
        Write-Debug "$computername ping" -NoNewline
        Write-Debug "Eerror!" -ForegroundColor Red
        $datacounter = 0
    }
    #Write-Host "MODBUS cliensek pingelése " + $servers[$i]
    #    Test-Connection -ComputerName $servers[$i] -Count 2

    

}while (1)



#Read-HoldingRegisters -Address 127.0.0.1 -Port 502 -Reference 0 -Num 8