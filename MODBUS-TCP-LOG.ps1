# "Functions loading."
. .\PsModbusTcp.ps1

#Arguments from command line. These are default value as well.
$computername = "172.30.10.244"
#$computername = "localhost"
$portnumber = "502"
$MODBUS_address = '0'
$output_directory = ".\DATAS\"
$dirname = "yyyyMM"
$filename = $dirname + "dd"
$samplesec = 6    # sample times (1..6 Sample per minute)
$samplecount = 30 # data save in sample times(2..30 x sample time)
$samplechannels = 2

# on/off channels
$onoffchannels = 1, 1, 0, 0, 0, 0, 0, 0 

$averagestrategy = 2, 1, 2, 2, 2, 0, 0, 0

# average strategies of all channels. 0 = no average 1 = max. datas of samples 2 = average of samples
$averagestrategy = 2, 2, 2, 2, 2, 0, 0, 0

#
$ma4_values = 0, 0, 0, 0, 0, 0, 0, 0
$ma20_values = 20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000
#
$maxvalues = 0, 0, 0, 0, 0, 0, 0, 0
$minvalues = 20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000

# integrsted values os channels.
$integralvalues = 0, 0, 0, 0, 0, 0, 0, 0

# 0 mA values of dimension 
$dim0mAvalues = 0, 0, 0, 0, 0, 0, 0, 0
# 20 mA values of dimension
$dim20mAvalues = 100, 50, 10, 1.3, 0.3, 0.3, 0.4, 0.5
# is that getting MAC address or is'nt
$GetMACAddress = 0

# one channel buffer
$one_channel = @(0, 0, 0, 0, 0, 0, 0, 0)

# file write out buffer.
$out_buffer = 0, 0, 0, 0, 0, 0, 0, 0

# We are assume that 8 channels datas from MODBUS.
$fileheader = "Date,Klorbenzol,Merkaptan,Chan3,Chan4,Chan5,Chan6,Chan7,Chan8`n"

# the avrage buffer.
#$channel_datas = New-Object 'int[,]' $samplecount, $samplechannels
# maximálisan bállítható mintaszám.
$max_samplecount = 30

$channel_datas = New-Object 'object[,]' ($max_samplecount * 6), $samplechannels

# counter of incoming samples
$samplecounter = 0

#flag to calculate the sample
$samplecalculate = 0

#clear the average buffer
$channel_datas.Clear()
# have to shift the input buffer?
$mustshift = 0
#We have to wait the whole minute and 0 sec?
$NoWaitStartTime = 0

function ShiftChannelDatas {
    for ($j = 1; $j -lt ($samplecount); $j++) {
        for ($i = 0; $i -lt $samplechannels; $i++) {
            $channel_datas[($j - 1), $i] = $channel_datas[$j, $i]
        }
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

function getValueFromRaw($rawvalue, $minraw, $maxraw, $minvalue, $maxvalue) {
    Write-Debug "getValueFromRaw($rawvalue, $minraw, $maxraw, $minvalue, $maxvalue)"
    if ($rawvalue -lt $minraw) { return "LoERR" }    
    if ($rawvalue -gt $maxraw) { return "HiERR" }
    $slope = ($maxvalue - $minvalue) / ($maxraw - $minraw)
    Write-Debug "Slope = $slope"
    return (($rawvalue - $minraw) * $slope) + $minvalue
}

for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[ $i ] -eq "-o") { 
        $output_directory = $args[ $i + 1 ]
        Write-Debug("Output directory = $output_directory") 
    }
    if ($args[ $i ] -eq "-c") { 
        $computername = $args[ $i + 1 ] 
        Write-Debug("ComputerName = $computername") 
    }
    if ($args[ $i ] -eq "-p") { 
        $portnumber = $args[ $i + 1 ] 
        Write-Debug("PortNumber = $portnumber") 
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
        $samplecount = MinMaxSetting 2 $max_samplecount $args[ $i + 1 ] 
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
    if ($args[ $i ] -eq "-m") { 
        $NoWaitStartTime = 1
        Write-Debug("NoWaitStartTime = 1")
    }
    if ($args[ $i ] -eq "-h") { 
        Quit("never mind.")
    }
}

$outstring = ""

$secstep = 60 / $samplesec
Write-Debug("SecStep = $secstep")
$nextsamplesec = 0
$samplesec_counter = 0


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
 
if ($NoWaitStartTime -eq 0) {
    Write-Host "Waiting for 00:00 sec:min"
    $counter = 0
    while (((Get-Date).Second -ne 0) -or ((Get-Date).Minute % 10) -ne 0) {
        #    while (((Get-Date).Second -ne 0)) {
        $sec = (Get-Date).Second
        $min = (Get-Date).Minute
        Start-Sleep -Milliseconds (500)
        Write-Debug  "Sec : $sec, Min = $min" 
        if ($counter -ge 10) {
            Write-Host "Sec : $sec, Min = $min"
            $counter = 0
        }
        else {

        }
        $counter++
    }
}

# Start-Sleep -Milliseconds 1000

Write-Host "Start program at $((Get-Date).ToString())"
Write-Debug "Start ask for $computername"
$nextsamplesec += $secstep
Write-Debug "NextSampleSec = $nextsamplesec"

do {
    # Sleep samplesec times
    #    

    $second = (Get-Date).Second

    #if (1) {
    if ($second -eq ($nextsamplesec)) {
        Write-Debug "$second -eq ($nextsamplesec)"
        $nextsamplesec += $secstep
        if ($nextsamplesec -ge 60) {
            $nextsamplesec -= 60
        }
        if ($samplesec_counter -eq $samplesec) {
            $samplesec_counter = 0
            $nextsamplesec = 0
        }
        Write-Debug "Second = $second"

        #    Test the computer ping.
        #        Write-Debug "$computername pinging."
        #        $test_ping = Test-Connection -Count 1 -Delay 1 -Quiet -ComputerName $computername
        $test_ping = 1
        if ($test_ping) {

            $datestring = Get-Date -Format "yyyy.MM.dd HH:mm:ss"
            Write-Debug "$computername ping: OK. Date: $datestring" 
            
            $one_channel = Read-HoldingRegisters -Address $computername -Port $portnumber -Reference $MODBUS_address -Num 8
    
            if ($null -ne $one_channel) {
                $datestring = Get-Date -Format "yyyy.MM.dd HH:mm:ss"

                Write-Host "Data ready. Sample($samplecounter) Time: $((Get-Date).ToString()) -> one Channel : $one_channel"
                #                Write-Debug "Before shift channel datas : $channel_datas"
                if ($mustshift) {
                    ShiftChannelDatas
                    #                    Write-Debug "After shift channel datas : $channel_datas"
                    MoveChannelDatas ($samplecount - 1)
                }
                else {
                    MoveChannelDatas $samplecounter
                }

                #                Write-Debug "Sample($samplecounter) -> Channel Datas : $channel_datas"
                if ($samplecounter -eq ($samplecount - 1)) {
                    $mustshift = 1
                    $samplecalculate = 1
                    $samplecounter = 0
                }
                else {
                    $samplecounter++
                }

                # We have to calculate the average value
                if ($samplecalculate) {
                    Write-Debug "Samplecalculate forced." 
                    $samplecalculate = 0

                    for ($i = 0; $i -lt $samplechannels; $i++) { 
                        if ($averagestrategy[$i] -eq 0) {
                            # average strategy = still value
                            $rawdata = $channel_datas[2, $i]
                        }
                        if ($averagestrategy[$i] -eq 1) {
                            #averagestrategy = max. value
                            for ($j = 0; $j -lt $samplecount; $j++) {
                                if ($channel_datas[$j, $i] -gt $maxvalues[$i]) {
                                    $maxvalues[$i] = $channel_datas[$j, $i]
                                }
                                if ($channel_datas[$j, $i] -lt $minvalues[$i]) {
                                    $minvalues[$i] = $channel_datas[$j, $i]
                                }
                            }
                            $rawdata = $maxvalues[$i]
                        }
                        if ($averagestrategy[$i] -eq 2) {
                            #averagevalue = avreage value
                            for ($j = 0; $j -lt $samplecount; $j++) {
                                
                                $integralvalues[$i] += $channel_datas[$j, $i]
                            }
                            $rawdata = $integralvalues[$i] / $samplecount
                            $integralvalues[$i] = 0
                        }
                        $value = getValueFromRaw  $rawdata $ma4_values[$i] $ma20_values[$i] $dim0mAvalues[$i] $dim20mAvalues[$i]
                        $out_buffer[$i] = $value 
                        Write-Debug "Outbuffer = $out_buffer"
                    }            

                    Write-Debug "Write trend file: "
                    Write-Host "Computer: " $computername " Date: " $((Get-Date).ToString())
                    Write-Host "datacounter = samplecount. Write csv file."
                    $YMdir = $output_directory + (Get-Date).tostring($dirname)
                    $YMDdir = $YMdir + '\' + (Get-Date).tostring($filename)
                    
                    $logoname = $YMDdir + '.csv'
    
                    MakePathIfNoExist -PathString "$YMdir"
                    if (Test-Path -Path "$logoname") {
                        Write-Debug "$logoname exists!"
                        $datestring = Get-Date -Format "yyyy.MM.dd HH:mm:ss"
                        $outstring = $datestring
                        $i = 0
                        foreach ($data in $out_buffer) {
                            if ($onoffchannels[$i]) {
                                $outstring += ',' + $data
                            }
                            else {
                                $outstring += ',N/A'
                            }

                            $i++
                        }
                        Write-Host "Computer: " $computername " : "  $outstring
                        try {
                            Add-Content -Path $logoname -Value $outstring
                        }
                        catch {
                            Write-Host "File write Error: $computername" 
                        }

                    }
                    else {
                        Write-Debug "Outfile Name = $logoname, file = $fileheader"
                        New-Item -Path $logoname -ItemType "file" -Value $fileheader
                        # MakePathIfNoExist -PathString "$logoname" -Path $YMdir 
                    }
                }

            }
            else {
                Write-Host "No read from MODBUS client." -ForegroundColor Red
            }

        }
        else {
            Write-Debug "$computername ping" 
            Write-Debug "Error!" 
            $datacounter = 0
        }
    
    }
}while (1)

