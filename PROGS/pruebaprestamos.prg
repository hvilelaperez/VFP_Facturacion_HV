SET DELETED ON
SET DATE BRITISH


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
                                        
lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
    cmd1=SQLEXEC(lnHandle,"SELECT a.fecha,a.serie,a.numero,a.guiaserie,a.guianum,d.codigo as cliente,b.producto as Codigo,c.Nombre as Nproducto,d.Nombre as Cadena,a.fecha,b.um,b.cantidad,b.cantidevuelta,c.idsqm "+;
                          "FROM factura a,detafacturas b,productos c,clientes d "+;
                          "WHERE a.unico=b.unico and b.producto=c.codigo and a.codigoc=d.codigo and a.serie=2 and a.saldo>1 "+;                          
                          "and a.estado<>'AN' ","Prestamosx")    
                                                 
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT cliente,SUBSTR(cadena,1,50) as Cadena,codigo,ALLTRIM(nproducto) as nproducto ,fecha,;
       TRANSFORM(serie,"@l 999")+"-"+TRANSFORM(numero,"@l 999999") as Factura,;
       TRANSFORM(guiaserie,"@l 999")+"-"+TRANSFORM(guianum,"@l 999999") as Guia,;
       cantidad,cantidevuelta,cantidad-cantidevuelta as saldo ,um FROM Prestamosx;
       INTO CURSOR prestamos
       
SELECT Prestamos
BROWSE 

