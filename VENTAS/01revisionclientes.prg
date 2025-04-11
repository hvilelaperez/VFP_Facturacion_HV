
SET DELETED ON
SET DATE BRITISH
SET TALK OFF

LOCAL cuenta1,cuenta2

cuenta1=0
cuenta2=0

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=d3b14nfw123;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle > 0
                                                       
    cmd1=SQLEXEC(lnHandle,"SELECT DISTINCT codigoc FROM factura WHERE YEAR(fecha)=2015 AND estado<>'AN'","Base2015") 
    cmd2=SQLEXEC(lnHandle,"SELECT DISTINCT codigoc FROM factura WHERE YEAR(fecha)=2014 AND estado<>'AN'","Base2014")     
						  						  						      					       
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Base2014
as11=RECCOUNT()

SELECT Base2015
as12=RECCOUNT()
GO TOP
SCAN
  v_ASDxp=ALLTRIM(codigoc)
  SELECT Base2014
  LOCATE FOR ALLTRIM(codigoc)=v_asdxp
  IF !FOUND()
     cuenta1=cuenta1+1
  ENDIF 
  SELECT Base2015
ENDSCAN 
  
SELECT Base2014
GO TOP
SCAN
  v_ASDxp1=ALLTRIM(codigoc)
  SELECT Base2015
  LOCATE FOR ALLTRIM(codigoc)=v_asdxp1
  IF !FOUND()
     cuenta2=cuenta2+1
  ENDIF 
  SELECT Base2014
ENDSCAN 
  
     
=MESSAGEBOX("Clientes 2014: "+ALLTRIM(STR(as11,6,0))+ " Clientes 2015: "+ ALLTRIM(STR(as12,6,0))+"  Nuevos 2015: "+ALLTRIM(STR(cuenta1,6,0))+"  Perdidos 2015: "+ALLTRIM(STR(cuenta2,6,0)),16,"AVISO")





