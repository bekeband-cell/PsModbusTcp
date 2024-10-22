

$ma4_values = 20, 0, 0, 0, 0, 0, 0
$ma20_values = 20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000
$dim0mAvalues = 0, 0, 0, 0, 0, 0, 0, 0
$dim20mAvalues = 0.4, 0.3, 10, 1.3, 0.3, 0.3, 0.4, 0.5
$maxvalues = 0, 0, 0, 0, 0, 0, 0, 0
$minvalues = 20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000
$integralvalues = 0, 0, 0, 0, 0, 0, 0, 0
$avervalues = 0, 0, 0, 0, 0, 0, 0, 0
$averagestrategy = 0, 1, 0, 1, 0, 0, 0, 0
$samplechannels = 8
$samplecount = 3
$one_channel = @(0, 0, 0, 0, 0, 0, 0, 0)
$samplecounter = 0

$channel_datas = New-Object 'int[,]' $samplecount, $samplechannels
$channel_datas.Clear()

$DebugPreference = "Continue"

function GetSampleDatas() {
    for ($i = 0; $i -lt $samplechannels; $i++) {
        $Minimum = $i * 1800
        $Maximum = $Minimum + 1000
        $value = Get-Random -Minimum $Minimum -Maximum $Maximum
        <#        $channel_datas[$i] = $value
        if ($value -gt $maxvalues[$i]) {
            $maxvalues[$i] = $value
        }
        if ($value -lt $minvalues[$i]) {
            $minvalues[$i] = $value
        }
        $integralvalues[$i] += $value#>
        $one_channel[$i] = $value
    }
}

function ShiftChannelDatas {
    for ($j = 1; $j -lt ($samplecount); $j++) {
        for ($i = 0; $i -lt $samplechannels; $i++) {
            $channel_datas[($j - 1), $i] = $channel_datas[$j, $i]
        }
    }
}
function MoveChannelDatas($pos) {
    for ($i = 0; $i -lt $samplechannels; $i++) {
        $channel_datas[$pos, $i] = $one_channel[$i]
    }
}

function getValueFromRaw($rawvalue, $minraw, $maxraw, $minvalue, $maxvalue) {
    Write-Debug "getValueFromRaw($rawvalue, $minraw, $maxraw, $minvalue, $maxvalue)"
    if ($rawvalue -lt $minraw) { return "LoERR" }    
    if ($rawvalue -gt $maxraw) { return "HiERR" }
    $slope = ($maxvalue - $minvalue) / ($maxraw - $minraw)
    Write-Debug "Slope = $slope"
    return (($rawvalue - $minraw) * $slope) + $minvalue
}

do {
    Start-Sleep -Milliseconds 1000
    GetSampleDatas
    Write-Debug "Sample($samplecounter) -> One Channel : $one_channel"
    if ($samplecounter -ge ($samplecount)) {
        ShiftChannelDatas
        MoveChannelDatas ($samplecounter - 1)
    }
    else {
        MoveChannelDatas $samplecounter
    }
    $samplecounter++
    Write-Debug "Channel Datas : $channel_datas"

    for ($i = 0; $i -lt $samplechannels; $i++) { 
        if ($averagestrategy[$i] -eq 0) {
            # average strategy = still value
            $rawdata = $channel_datas[2, $i]
        }
        if ($averagestrategy[$i] -eq 1) {
            #averagestrategy = max. value
            $rawdata = $maxvalues[$i]
        }
        if ($averagestrategy[$i] -eq 2) {
            #averagevalue = avreage value
    
        }
    
        $value = getValueFromRaw  $rawdata $ma4_values[$i] $ma20_values[$i] $dim0mAvalues[$i] $dim20mAvalues[$i] 
        Write-Debug "getValueFromRaw = $value"
    
    }


}while ($samplecounter -lt 4)

<#do {
    Write-Debug "One Channel : $one_channel"
    for ($j = 0; $j -lt $samplecount; $j++) {
        for ($i = 0; $i -lt $samplechannels; $i++) {
            $Minimum = $i * 1800
            $Maximum = $Minimum + 1000
            $value = Get-Random -Minimum $Minimum -Maximum $Maximum
            $channel_datas[$j, $i] = $value
            if ($value -gt $maxvalues[$i]) {
                $maxvalues[$i] = $value
            }
            if ($value -lt $minvalues[$i]) {
                $minvalues[$i] = $value
            }
            $integralvalues[$i] += $value
        }
    }
}while (0)

for ($i = 0; $i -lt $samplechannels; $i++) {
    $avervalues[$i] = $integralvalues[$i] / $samplecount
}

Write-Debug "Channel Datas : $channel_datas"
Write-Debug "MAX Datas : $maxvalues"
Write-Debug "MIN Datas : $minvalues"
Write-Debug "Integral values : $integralvalues"
Write-Debug "Average values : $avervalues"


for ($i = 0; $i -lt $samplechannels; $i++) { 
    if ($averagestrategy[$i] -eq 0) {
        # average strategy = still value
        $rawdata = $channel_datas[2, $i]
    }
    if ($averagestrategy[$i] -eq 1) {
        #averagestrategy = max. value
        $rawdata = $maxvalues[$i]
    }
    if ($averagestrategy[$i] -eq 2) {
        #averagevalue = avreage value

    }

    $value = getValueFromRaw  $rawdata $ma4_values[$i] $ma20_values[$i] $dim0mAvalues[$i] $dim20mAvalues[$i] 
    Write-Debug "getValueFromRaw = $value"

}#>