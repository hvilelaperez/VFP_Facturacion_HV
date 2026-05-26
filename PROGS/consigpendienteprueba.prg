
SET DELETED ON
SET DATE BRITISH
SET TALK OFF
SET ECHO OFF

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
                    
                                                         
lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
       
    cmd1=SQLEXEC(lnHandle,"SELECT a.fecha,a.nummensual,a.origen,a.guia,a.factura,a.cliente,a.referenciacliente,a.notadecreditodev,"+;
                          "b.producto,c.nombre,b.qing,b.um,b.costo,b.moneda,b.devuelto FROM masteringresos a,vtalotes b,productos c "+;
                          "WHERE a.unico=b.unico and b.producto=c.codigo and a.tipo=9  and a.consigpendiente=1 and b.xdevolver=1 "+;
                          " order by a.origen,b.producto","Myinfo")                                                                                                                                                         					    					     					  
    IF cmd1>0
    
    ELSE 
        AERROR(laErr)
	    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
    ENDIF 
                                            
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT fecha,STR(YEAR(fecha),4)+"-"+TRANSFORM(MONTH(fecha),"@l 99")+"-"+TRANSFORM(nummensual,"@l 999") as Guiaentrada, ;
       origen,guia,factura,cliente,referenciacliente,notadecreditodev,producto,nombre,qing,um,costo,moneda,devuelto,;
       qing-devuelto as saldo FROM Myinfo ;
       INTO CURSOR Myinfo2

SELECT Myinfo2
BROWSE

REPORT FORM consignacionpendiente PREVIEW 
REPORT FORM consignacionpendiente NOCONSOLE TO PRINTER PROMPT 
