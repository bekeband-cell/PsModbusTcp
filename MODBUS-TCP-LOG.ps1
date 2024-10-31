# "Functions loading."
. .\PsModbusTcp.ps1

#Arguments from command line. These are default value as well.
$computername = "172.30.10.244"
$portnumber = "502"
$MODBUS_address = '0'
$output_directory = ".\DATAS\"
$dirname = "yyyyMM"
$filename = $dirname + "dd"
$samplesec = 6    # sample times (1..6 Sample per minute)
$samplecount = 3 # data save in sample times(6..24 x sample time)
$samplechannels = 8
$datacounter = 0
# here are the average values of channels
$avervalues = 0, 0, 0, 0, 0, 0, 0, 0
# average strategies of all channels. 0 = no average 1 = max. datas of samples 2 = average of samples
$averagestrategy = 2, 1, 2, 2, 2, 0, 0, 0

$ma4_values = 0, 0, 0, 0, 0, 0, 0
$ma20_values = 20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000
$dim0mAvalues = 0, 0, 0, 0, 0, 0, 0, 0
$dim20mAvalues = 0.4, 0.3, 10, 1.3, 0.3, 0.3, 0.4, 0.5
$GetMACAddress = 0

$one_channel = @(0, 0, 0, 0, 0, 0, 0, 0)

#[int32[][]]$channel_datas = 0, 0, 0, 0, 0, 0, 0, 0

# We are assume that 8 channels datas from MODBUS.
$fileheader = "Date,Chan1,Chan2,Chan3,Chan4,Chan5,Chan6,Chan7,Chan8`n"

# the avrage buffer.
#$channel_datas = New-Object 'int[,]' $samplecount, $samplechannels

$channel_datas = New-Object 'object[,]' $samplecount, $samplechannels

# counter of incoming samples
$samplecounter = 0

#flag to calculate the sample
$samplecalculate = 0

#clear the average buffer
$channel_datas.Clear()
# have to shift the input buffer?
$mustshift = 0

# GetSampleDatas() randomsample datas generator
function GetSampleDatas() {
    for ($i = 0; $i -lt $samplechannels; $i++) {
        $Minimum = $i * 1800
        $Maximum = $Minimum + 1000
        $value = Get-Random -Minimum $Minimum -Maximum $Maximum
        $one_channel[$i] = $value
    }
}

# MoveChannelDatas($pos) move the sample datas inthe sample buffer
function MoveChannelDatas($pos) {
    for ($i = 0; $i -lt $samplechannels; $i++) {
        $channel_datas[$pos, $i] = $one_channel[$i]
    }
}

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
    if ($args[ $i ] -eq "-e") { 
        $dirname = $args[ $i + 1 ]
        Write-Debug("DirName = $dirname") 
    }
    if ($args[ $i ] -eq "-f") { 
        $filename = $args[ $i + 1 ] 
        Write-Debug("FileName = $filename")
    }
    if ($args[ $i ] -eq "-g") { 
        $samplesec = MinMaxSetting 1 6 $args[ $i + 1 ]
        Write-Debug("Samplesec = $samplesec")
    }
    if ($args[ $i ] -eq "-l") { 
        $samplechannels = MinMaxSetting 1 8 $args[ $i + 1 ]
        Write-Debug("Samplechannels = $samplechannels")
    }
    if ($args[ $i ] -eq "-j") { 
        $samplecount = MinMaxSetting 2 24 $args[ $i + 1 ] 
        Write-Debug("Samplecount = $samplecount")
    }
    if ($args[ $i ] -eq "-k") { 
        $fileheader = $args[ $i + 1 ]
        Write-Debug("FileHeader = $fileheader")
    }
    if ($args[ $i ] -eq "-d") { 
        $DebugPreference = "Continue"
        Write-Debug("Debug ON.")
    }
    if ($args[ $i ] -eq "-n") { 
        $GetMACAddress = 1
        Write-Debug("GetMACAddress = 1")
    }
    if ($args[ $i ] -eq "-h") { 
        Quit("never mind.")
    }
}

$outstring = ""

$DebugPreference = "SilentlyContinue"
$DebugPreference = "Continue"

$secstep = 60 / $samplesec
Write-Debug("SecStep = $secstep")
$nextsamplesec = 0
$samplesec_counter = 0

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

if ($GetMACAddress) {
    Write-Host "$computername pinging."
    $test_ping = Test-Connection -Count 1 -Delay 1 -Quiet -ComputerName $computername
    if ($test_ping) {
        Write-Host "Test ping succesfully : "
        $read_mac_address = Read-HoldingRegisters -Address $computername -Port $portnumber -Reference 517 -Num 6
        if ($null -ne $read_mac_address) { 
            Write-Host "Test read MAC addres: $read_mac_address" 
        }
        else {
            Write-Host "Test read MAC addres not succesfully!" 
        }
    }
    else {
        Write-Host "Test ping failure!" 
    }
}
else {
    Write-Host "No MAC address was choice." 
}

# Start-Sleep -s 5
 
Write-Debug "Start ask for $computername"
Write-Debug "NextSampleSec = $nextsamplesec"

do {
    # Sleep samplesec times
    Start-Sleep -Milliseconds (4000)
    $second = (Get-Date).Second

    if (1) {
        #if ($second -eq ($nextsamplesec)) {
        Write-Debug "$second -eq ($nextsamplesec)"
        $nextsamplesec = ++$samplesec_counter * $secstep
        if ($samplesec_counter -eq $samplesec) {
            $samplesec_counter = 0
            $nextsamplesec = 0
        }
        Write-Debug "Second = $second"

        #    Test the computer ping.
        Write-Debug "$computername pinging."
        $test_ping = Test-Connection -Count 1 -Delay 1 -Quiet -ComputerName $computername

        if ($test_ping) {

            $datestring = Get-Date -Format "yyyy.MM.dd HH:mm:ss"
            Write-Debug "$computername ping: OK. Date: $datestring" 
            
            $one_channel = Read-HoldingRegisters -Address $computername -Port $portnumber -Reference $MODBUS_address -Num 8
    
            if ($null -ne $one_channel) {
                $datestring = Get-Date -Format "yyyy.MM.dd HH:mm:ss"

                Write-Debug "Succesfully read from MODBUS client. Sample($samplecounter) -> one Channel : $one_channel"
                Write-Debug "Before shift channel datas : $channel_datas"
                if ($mustshift) {
                    ShiftChannelDatas
                    Write-Debug "After shift channel datas : $channel_datas"
                    MoveChannelDatas ($samplecount - 1)
                }
                else {
                    MoveChannelDatas $samplecounter
                }

                Write-Debug "Sample($samplecounter) -> Channel Datas : $channel_datas"
                if ($samplecounter -eq ($samplecount - 1)) {
                    $mustshift = 1
                    $samplecalculate = 1
                    $samplecounter = 0
                }
                else {
                    $samplecounter++
                }

                <#if ($samplecounter -eq ($samplecount - 1)) {
                    MoveChannelDatas $samplecounter
                    $samplecounter = 0 
                    $samplecalculate = 1
                }
                else {
                    MoveChannelDatas $samplecounter
                    $samplecounter++
                }#>



                # We have to calculate the average value
                if ($samplecalculate) {
                    Write-Debug "Samplecalculate forced." 
                    $samplecalculate = 0
                }


                <#if ($datacounter -lt $samplecount) {
                    Write-Debug "$datacounter -lt $samplecount" 
                }
                else {
                    $datacounter = 0
                    Write-Debug "$datacounter -eq $samplecount"
                    Write-Debug "Write trend file: "
                    Write-Host "Computer: " $computername " Date: " $((Get-Date).ToString())
                    Write-Debug "datacounter = samplecount. Write csv file."
                    $YMdir = $output_directory + (Get-Date).tostring($dirname)
                    $YMDdir = $YMdir + '\' + (Get-Date).tostring($filename)
                    
                    $logoname = $YMDdir + '.csv'
    
                    MakePathIfNoExist -PathString "$YMdir"
                    if (Test-Path -Path "$logoname") {
                        Write-Debug "$logoname exists!"
                        $datestring = Get-Date -Format "yyyy.MM.dd HH:mm:ss"
                        $outstring = $datestring
                        foreach ($data in $read_return) {
                            $outstring += ',' + $data
                        }
                        Add-Content -Path $logoname -Value $outstring
                    }
                    else {
                        New-Item -Path . -Name "$logoname" -ItemType "file" -Value "$fileheader"
                        #                MakePathIfNoExist -PathString "$logoname"
                    }

                }
                $datacounter++#>
                <#                if ($datacounter -lt $samplecount) {
                    $datacounter++
                }
                else {
                    $datacounter = 0
                    Write-Host "Computer: " $computername " Date: " $((Get-Date).ToString())

                    Write-Debug "datacounter = samplecount. Write csv file."
                    $YMdir = $output_directory + (Get-Date).tostring($dirname)
                    $YMDdir = $YMdir + '\' + (Get-Date).tostring($filename)
                    
                    $logoname = $YMDdir + '.csv'
    
                    MakePathIfNoExist -PathString "$YMdir"
    
                    if (Test-Path -Path "$logoname") {
                        Write-Debug "$logoname exists!"
                        $datestring = Get-Date -Format "yyyy.MM.dd HH:mm:ss"
                        $outstring = $datestring
                        foreach ($data in $read_return) {
                            $outstring += ',' + $data
                        }
                        Add-Content -Path $logoname -Value $outstring
                    }
                    else {
                        New-Item -Path . -Name "$logoname" -ItemType "file" -Value "$fileheader"
                        #                MakePathIfNoExist -PathString "$logoname"
                    }

                }

            Write-Host "Readed data: " $read_return
            # here to write to file
            # filename making#>
                 

            }
            else {
                Write-Host "No read from MODBUS client." -ForegroundColor Red
                $datacounter = 0
            }

        }
        else {
            Write-Debug "$computername ping" 
            Write-Debug "Error!" 
            $datacounter = 0
        }
        #Write-Host "MODBUS cliensek pingelése " + $servers[$i]
        #    Test-Connection -ComputerName $servers[$i] -Count 2
    
    }
}while (1)



#Read-HoldingRegisters -Address 127.0.0.1 -Port 502 -Reference 0 -Num 8