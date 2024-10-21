

$ma4_values = 0, 0, 0, 0, 0, 0, 0
$ma20_values = 20000, 20000, 20000, 20000, 20000, 20000, 20000, 20000
$dim0mAvalues = 0, 0, 0, 0, 0, 0, 0, 0
$dim20mAvalues = 0.4, 0.3, 10, 1.3, 0.3, 0.3, 0.4, 0.5
$samplechannels = 8
$samplecount = 3

$channel_datas = New-Object 'object[,]' $samplechannels, $samplecount
$channel_datas[0, 0] = 7.7865

do {

    for ($i = 0; $i -lt $samplechannels; $i++) {

        for ($j = 0; $j -lt $samplecount; $j++) {
            Write-Host "$i , $j : $channel_datas "
           
        }

    }
    #    $channel_datas[1][1] = 10
    #    Start-Sleep -Milliseconds (100)


} while (0)