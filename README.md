# PsModbusTcp

A set of simple Powershell methods to work with MODBUS protocol over TCP transport

## Status

Only reading/writing registers implemented at this point. This is used mainly fro research/dev work. Code may be updated if a need arises. Pull requests are welcome.

Parancssoros opciók:

-c computername 'A MODBUS eszköz neve, vagy IP címe. Alapérték: "localhost"'
-p portnumber A MODBUS/TCP port száma: Alapérték: 502
-d debug mód. (Csak tesztelésre)
-g samplesec Az adatok lekérdezésének gyakorisága percenként másodpercekben. Határok: 1...6, azaz az 1-es gyakoriság 60 sec-es mintavételt jelent, a 6-os 10 sec-os mintavételt.
-j samplecount Az adatok gyűjtésének és mentésének gyakorisága a lekérdezések függvényéban. Határok: 2..30. A trend mentés minden itt megadott minta olvasásakor megtörténik. Ezért, ha pl. a mintavétel gyakorisága 5 percenként (12 mp-ként történik), és a mentés minden 10. mintával történik, (-j 10), akkor 120 mp-ként ment egy trend adatot.
-m nem várja meg a mintavétel kezdetével az egész percet és másodpercet. (Csak tesztelési célra)
-o a kimeneti könyvtár neve, ahova a csv fájl keletkezik.
Jelenleg a
