
SET DELETED ON
SET DATE BRITISH
LOCAL Mystring_ofi01,fini,ffin


Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sqmsistemas;" + ;
                    "PWD=t1s9m.2712;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
                    
fini=CTOD('09/05/2016')                    
ffin=CTOD('18/05/2016')

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0
    cmd1=SQLEXEC(lnHandle,"SELECT SUM(Final.cantidad) as Packs,SUM(Final.q1) as Kilos "+;
                          "FROM (SELECT a.unico,a.numero,b.producto,SUM(b.cantidad) AS q1,SUM(IF((b.cantidad)>=25,b.cantidad/25 ,1)) AS cantidad "+;
                          "FROM guiasremision a,detaguiasremision b,productos c,tipoproductos d "+;
                          "WHERE a.unico=b.unico AND b.producto=c.codigo AND c.tipoproducto=d.codigo "+;
                          "AND fecha BETWEEN ?fini AND ?ffin AND anulada<>1 AND d.escolorante=1 GROUP BY 1,2,3) AS Final ","MyDat")
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF    
         

SELECT MyDat
BROWSE
