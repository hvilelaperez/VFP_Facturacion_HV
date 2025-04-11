SET DELETED ON
SET DATE BRITISH

SET DEFAULT TO f:\ventas
SET PATH TO DATA,PROGS,FORMULARIOS,INFORMES
SET PROCEDURE TO FUNCIONES


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0      
                         
    cmd1=SQLEXEC(lnHandle,"SELECT codigo,ruc,nombre,activo,vendedor, 0*0 as estado FROM clientes WHERE activo=1 and Vendedor='OF' "+;
                          " AND origen<>'C' order by 1 ","MiSaldo")
                          
    cmd3=SQLEXEC(lnHandle,"SELECT codigoc FROM Factura WHERE estado<>'AN' group by 1 ","BaseFactura")
    cmd4=SQLEXEC(lnHandle,"SELECT codigoc FROM Boleta WHERE estado<>'AN' group by 1 ","BaseBoleta")
                       
   SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
     MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT basefactura
GO top
SCAN
   a1=ALLTRIM(codigoc)
   SELECT misaldo
   GO top
   LOCATE FOR a1=ALLTRIM(codigo)
   IF FOUND()
      replace estado WITH '1'
   ENDIF    
   
   SELECT basefactura
ENDSCAN 

SELECT baseboleta
GO top
SCAN
   a1=ALLTRIM(codigoc)
   SELECT misaldo
   GO top
   LOCATE FOR a1=ALLTRIM(codigo)
   IF FOUND()
      replace estado WITH '1'
   ENDIF    
   
   SELECT baseboleta
ENDSCAN 

SELECT misaldo
GO top

*Mititulo1='HAN HECHO COMPRAS '
*REPORT FORM ensayoclientesoficina FOR estado='1' TO PRINTER PROMPT NODIALOG PREVIEW 

Mititulo1='NO    HAN HECHO COMPRAS '
REPORT FORM ensayoclientesoficina FOR estado='0' TO PRINTER PROMPT NODIALOG PREVIEW