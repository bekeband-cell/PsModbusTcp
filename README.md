# PsModbusTcp

A set of simple Powershell methods to work with MODBUS protocol over TCP transport

## Status

Only reading/writing registers implemented at this point. This is used mainly fro research/dev work. Code may be updated if a need arises. Pull requests are welcome.

Parancssoros opciók:

-c computername 'A MODBUS eszköz neve, vagy IP címe. Alapérték: "localhost"'
-p portnumber A MODBUS/TCP port száma: Alapérték: 502
-d dirname A kimeneti könyvtár nevének mintája.
-f filename
-g samplesec Az adatok lekérdezésének gyakorisága 10 másodpercekben. Határok: 1...6, azaz a gyakoriságot 10 és 60 másodperc között lehet állítani.
-j samplecount Az adatok gyűjtésének és mentésének gyakorisága a lekérdezések függvényéban. Határok: 2..30. A trend mentés minden itt megadott minta olvasásakor megtörténik. Ezért, ha pl. a mintavétel gyakorisága 5 percenként (12 mp-ként történik), és a mentés minden 10. mintaával történik, (-j 10), akkor 120 mp-ként ment egy trend adatot.

-k
