
SET DELETED ON
SET DATE BRITISH
SET TALK OFF

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=d3b14nfw123;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


OPEN DATABASE f:\newcompras\data\sqm.dbc SHARED

SELECT 0
USE pedidoimp SHARED

SELECT 0
USE iembarque SHARED

SELECT a.codigo,a.fechapedido,b.fecembarque,b.fecembarque-a.fechapedido as dias FROM pedidoimp as a ;
LEFT JOIN iembarque as b ON a.codigo=b.codigo ;
WHERE YEAR(a.fechapedido)=2015 AND a.anulado<>.t. AND a.tipoembarque<>'P' INTO CURSOR esoeso

LOCAL a1
a1=RECCOUNT()

SUM dias TO xdsumita

ad3=xdsumita/a1

=MESSAGEBOX(" Promedio es:"+ALLTRIM(STR(ad3,10,2)),16," ") 


SELECT pedidoimp
USE
SELECT iembarque
USE





 


