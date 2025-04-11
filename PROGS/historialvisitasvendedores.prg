
SET DELETED ON
SET DATE BRITISH
LOCAL Mystring_ofi01,fechaini,fechafin
SET SAFETY OFF

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sqmsistemas;" + ;
                    "PWD=t1s9m.2712;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

fechainicio=CTOD("01/07/2016")
fechafin=CTOD("31/07/2016")

CREATE CURSOR van1 (vendedor c(30),cod_cli c(7),nombre c(70),veces n(3,0),historial c(100))

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0
    cmd1=SQLEXEC(lnHandle,"SELECT c.nombre as vendedor,a.cod_cli,b.nombre,COUNT(*) AS veces,CAST(GROUP_CONCAT(fecha ORDER BY fecha) AS CHAR(100)) AS historial "+;
						  "FROM w_visitascliente a,clientes b,vendedores c WHERE a.cod_cli=b.codigo AND a.cod_ven=c.codigo AND "+;
						  "fecha BETWEEN ?fechainicio AND ?fechafin GROUP BY 1,2 ORDER BY a.cod_ven,a.cod_cli","Mydat")
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])    
ENDIF    
         
SELECT van1
ZAP IN van1
APPEND FROM DBF("Mydat")
GO top
SELECT Mydat
USE

SELECT van1
REPLACE ALL NOMBRE WITH STRCONV(NOMBRE,11)
GO TOP

REPORT FORM visitasaclientes TO PRINTER PROMPT NODIALOG PREVIEW



