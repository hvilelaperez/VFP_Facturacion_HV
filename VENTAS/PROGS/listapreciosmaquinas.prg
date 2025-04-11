

SET DELETED ON
SET SAFETY OFF
SET ECHO OFF
SET TALK OFF

SET DEFAULT TO f:\newcompras\data
OPEN DATABASE sqm.dbc shared


PUBLIC Mystring

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0    
   cmd1=SQLEXEC(lnHandle," Select * from clientes ","Xclientes")
   SQLDISCONNECT(lnHandle)        
ELSE
   AERROR(laErr)
   MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT 0
USE productos SHARED

SELECT 0
USE tipoprodu SHARED 

SELECT a.codigo,b.nombre as Mitipo,a.nombre,a.factorgan,a.uflete,a.udesa,a.fobstd,ROUND((a.fobstd+a.uflete)*a.udesa,2) as Cimport,;
       ROUND(((ROUND((a.fobstd+a.uflete)*a.udesa,2))*a.factorgan/100),2)+(ROUND((a.fobstd+a.uflete)*a.udesa,2)) as Pstock;       
       FROM sqm!productos as a ;
       LEFT JOIN sqm!tipoprodu as b ON a.tipoproducto=b.codigo ;
       WHERE a.actfacimp=.t.;
       INTO CURSOR alfa ORDER BY a.codigo


SELECT alfa
 
REPORT FORM c:\newcompras\reports\listapreciostockmaq.frx PREVIEW 
REPORT FORM c:\newcompras\reports\listapreciostockmaq.frx NOCONSOLE TO PRINTER PROMPT 

CLOSE DATABASES
       
       
       