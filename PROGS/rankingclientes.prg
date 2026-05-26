
SET DELETED ON
SET DATE BRITISH

PUBLIC Mystring,Finit1,Fullback1

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

finit1=CTOD("01/01/2009")
fullback1=CTOD("31/12/2009")

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd0=SQLEXEC(lnHandle," SELECT fecha,venta FROM tcoficial ","TipoCambio")

 	cmd1=SQLEXEC(lnHandle," SELECT a.codigoc as Cliente,SUM(neto) as Subtotal "+;
						  " FROM factura a  WHERE a.estado<>'AN' and (a.serie=1 or a.serie=4)  and "+;
						  " a.fecha>=?finit1 and a.fecha<=?fullback1 "+;
						  " and a.motivoguia=1 and a.moneda='M2' group by 1 order by 2 desc ","Cursor1x")
						  
 	cmd2=SQLEXEC(lnHandle," SELECT a.codigoc as Cliente,SUM(neto) as Subtotal,a.fecha "+;
						  " FROM factura a  WHERE a.estado<>'AN' and (a.serie=1 or a.serie=4) and "+;
						  " a.fecha>=?finit1 and a.fecha<=?fullback1 "+;
						  " and a.motivoguia=1 and a.moneda='M1' group by 1 order by 2 desc ","Cursor1xB")

    cmd3=SQLEXEC(lnHandle," SELECT a.codigoc as Cliente,SUM(neto) as Subtotal "+;
						  " FROM boleta a  WHERE a.estado<>'AN'  and "+;
						  " a.fecha>=?finit1 and a.fecha<=?fullback1 "+;						  
						  " and a.motivoguia=1 and a.moneda='M2' group by 1 order by 2 desc ","Bom1x")
						  
    cmd4=SQLEXEC(lnHandle," SELECT a.codigoc as Cliente,SUM(neto) as Subtotal,a.fecha "+;
						  " FROM boleta a  WHERE a.estado<>'AN'  and "+;
						  " a.fecha>=?finit1 and a.fecha<=?fullback1 "+;						  
						  " and a.motivoguia=1 and a.moneda='M1' group by 1 order by 2 desc ","Bom1xB")
						  
						  
    cmd5=SQLEXEC(lnHandle," SELECT * from clientes ","Xclientes")
						  
						  
   SQLDISCONNECT(lnHandle)
ELSE
   AERROR(laErr)
   MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

**** Convierte a US$ los valores en Soles *******

SELECT Cursor1xB
GO top
SCAN
    as1=Cursor1xB.Fecha
    SELECT TipoCambio
    GO top
    LOCATE FOR as1=Tipocambio.Fecha
    IF FOUND()
       as2=Tipocambio.venta
       SELECT Cursor1xB
         replace Cursor1xB.subtotal WITH ROUND(Cursor1xB.subtotal/as2,2)
    ENDIF  
    SELECT Cursor1xB
ENDSCAN 


SELECT Bom1xB
GO top
SCAN
    as1=Bom1xB.Fecha
    SELECT TipoCambio
    GO top
    LOCATE FOR as1=Tipocambio.Fecha
    IF FOUND()
       as2=Tipocambio.venta
       SELECT Bom1xB
         replace Bom1xB.subtotal WITH ROUND(Bom1xB.subtotal/as2,2)
    ENDIF  
    SELECT Bom1xB
ENDSCAN 


*************************************************


SELECT Cursor1x
APPEND FROM DBF("Bom1x")
APPEND FROM DBF("Cursor1xB")
APPEND FROM DBF("Bom1xB")

SELECT cliente,SUM(subtotal) as Subtotal FROM Cursor1x GROUP BY cliente ORDER BY 2 DESC INTO CURSOR prefinal readwrite	

SELECT 000 as Pos,a.cliente,CAST(STRCONV(b.nombre,11) as c(75)) as nombre,b.vendedor,a.subtotal,000.00 as Pcte,b.credito FROM Prefinal as a LEFT JOIN Xclientes as b ;
       ON a.cliente=b.codigo INTO CURSOR final READWRITE 
       
       
SELECT final
SUM ALL subtotal TO aatotal

GO top
SCAN
  
  replace pos with RECNO()
  replace Pcte WITH ROUND((subtotal/aatotal)*100,2)
  
ENDSCAN 
GO TOP 

BROWSE 

       