
SET ECHO OFF 
SET TALK OFF
SET DELETED ON
SET DATE BRITISH

PUBLIC autil1,autil2

a1=CTOD("01/12/2009")
b1=CTOD("31/12/2009")

autil1=a1
autil2=b1

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"



lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

   *cmd0=SQLEXEC(lnHandle,"SELECT * FROM factura WHERE estado='AN' and YEAR(fecha)>=2010 ","AnuFactura")
    cmd1=SQLEXEC(lnHandle,"SELECT * FROM boleta WHERE (condipag='OB' or condipag='MG') and YEAR(fecha)>=2011","Myboleta")
    *cmd0=SQLEXEC(lnHandle,"SELECT * FROM boleta WHERE estado='AN' and YEAR(fecha)>=2010 ","AnuBoleta")
                                                                                                                 
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


*SELECT anufactura
*GO top

*lnHandle = SQLSTRINGCONNECT(Mystring)
*IF lnHandle > 0
*SCAN
*    as=TRANSFORM(serie,"@l 999")+TRANSFORM(numero,"@l 999999")
*    cmd1=SQLEXEC(lnHandle,"DELETE FROM conta_saldos WHERE tipdoc='F' and numdoc=?as")
    
*ENDSCAN
    
*SQLDISCONNECT(lnHandle)    
    
*ELSE
*    AERROR(laErr)
*    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
*ENDIF   


    
*SELECT Myboleta
*GO top
*brow

*lnHandle = SQLSTRINGCONNECT(Mystring)
*IF lnHandle > 0
*SCAN
 *   as=TRANSFORM(serie,"@l 999")+TRANSFORM(numero,"@l 999999")
 *   cmd1=SQLEXEC(lnHandle,"UPDATE conta_saldos SET saldo=0 WHERE tipdoc='B' and numdoc=?as")
    
*ENDSCAN
    
*SQLDISCONNECT(lnHandle)    
    
*ELSE
*    AERROR(laErr)
*    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
*ENDIF 



*SELECT anuboleta
*GO top

*lnHandle = SQLSTRINGCONNECT(Mystring)
*IF lnHandle > 0
*SCAN
*    as=TRANSFORM(serie,"@l 999")+TRANSFORM(numero,"@l 999999")
*    cmd1=SQLEXEC(lnHandle,"DELETE FROM conta_saldos WHERE tipdoc='B' and numdoc=?as")
    
*ENDSCAN
    
*SQLDISCONNECT(lnHandle)    
*    
*ELSE
 *   AERROR(laErr)
 *   MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
*ENDIF   



