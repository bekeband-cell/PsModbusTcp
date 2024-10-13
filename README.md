# PsModbusTcp
A set of simple Powershell methods to work with MODBUS protocol over TCP transport

## Status
Only reading/writing registers implemented at this point. This is used mainly fro research/dev work. Code may be updated if a need arises. Pull requests are welcome.


Parancssoros opciók:

-c computername 'A MODBUS eszköz neve, vagy IP címe. Alapérték: "localhost"'
-p portnumber A MODBUS/TCP port száma: Alapérték: 502
-d dirname A kimeneti könyvtár nevének mintája. 
-f filename 
-g samplesec Az adatok lekérdezédének gyakorisága 10 másodpercekben. Határok: 1...30, azaz a gyakoriságot 10 és 300 másodperc között lehet állítani.
-j samplecount Az adatok gyűjtésének és mentésének gyakorisága a lekérdezések függvényéban. Határok: 6..24. A trend mentés és adatgyűjtés kiszámítása: adatmentés ideje samplecount * samplesec * 10. Pl.: samplesec = 2 samplecount = 10 Így az adatgyűjtés ideje 2 * 10 * 10 = 200 sec = 3 perc 20 mp. 
-k 
