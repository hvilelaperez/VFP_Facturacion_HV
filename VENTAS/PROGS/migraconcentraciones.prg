
SET DELETED ON
SET DATE BRITISH

SET DEFAULT TO f:\ventas
SET PATH TO DATA,PROGS,FORMULARIOS,INFORMES
SET PROCEDURE TO FUNCIONES

*** igualar amarres de Mysql en data de productos dbf*********

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0                               
   cmd2=SQLEXEC(lnHandle,"SELECT * FROM directos_reactivos ","Base01")                                                   
   SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
     MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Base01
GO top

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0  
   SCAN 
      a1=ALLTRIM(codigo)
      b1=concentracion
      c1=standard
      d1=CTOD('08/01/2014')
                                   
      cmd2=SQLEXEC(lnHandle,"UPDATE productos SET concentracionlab=?b1,standarlab=?c1,fechaconlab=?d1 WHERE TRIM(codigo)=?a1")                                                   
   
   ENDSCAN 
   
   SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
     MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDI