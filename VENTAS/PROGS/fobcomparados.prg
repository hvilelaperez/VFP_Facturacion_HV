
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
    cmd1=SQLEXEC(lnHandle," SELECT a.idsqm,concat(' // ',b.colorindex) as clase,a.codigo,a.proveedor,a.nombre,b.standar FROM productos a, clases b WHERE "+;
                          " a.idsqm=b.idsqm and a.idsqm<>'' ORDER BY a.idsqm,a.codigo ","Bruno") 						      					       
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT bruno
DELETE FOR proveedor='10' OR proveedor='W0'
 

OPEN DATABASE f:\newcompras\data\sqm.dbc SHARED

SELECT 0
USE productos SHARED
SELECT 0
USE proveedores SHARED 


SELECT bruno
GO top
SCAN
    Asd=ALLTRIM(bruno.standar)
    Ase=bruno.clase
    SELECT productos
    GO top
    LOCATE FOR ALLTRIM(productos.codigo)=Asd
    IF FOUND() AND !EMPTY(asd)
       IF productos.concentracion>0
          Mypcte='  '+ALLTRIM(STR(productos.concentracion,4,0))+'%'                    
          SELECT Bruno 
          replace Clase WITH ALLTRIM(ase)+Mypcte 
          ?clase
       ELSE && Sino es 0 se asume 100%
          replace bruno.clase WITH ALLTRIM(ase)+' '+'100%'
       ENDIF         
    ENDIF 
    
    SELECT bruno    
ENDSCAN 

SELECT a.*,IIF(b.upreciocarg<>0,(b.upreciocarg+c.fletestandar),0) as Fobflete,b.ufechacotiza,c.shortname FROM Bruno as a ;
       LEFT JOIN productos as b ON a.codigo=b.codigo ;
       LEFT JOIN proveedores as c on a.proveedor=c.codigo;
       INTO CURSOR Bruno2
       
SELECT productos
USE

SELECT proveedores
USE 

CLOSE DATABASES

SELECT distinct proveedor,shortname FROM Bruno2 ORDER BY proveedor INTO CURSOR resumen

CREATE CURSOR Mymaster(Idsqm c(5),Mygenerico C(80))

SELECT resumen
SCAN 
 
    nfield0="_"+ALLTRIM(proveedor)+'b'              
    nfield1="_"+ALLTRIM(proveedor)+'c'
 	ALTER TABLE Mymaster ADD COLUMN (nfield0)  N(10,2) NOT null
    ALTER TABLE Mymaster ADD COLUMN (nfield1)  D  	 	 	 	 
 	 
ENDSCAN 

PUBLIC MyccW,vFOB3,vFOB4,vFOB5,vFOB6,vFOB7,vFOB8,vFOB9,vFOB10,vFOB11,vFOB12,vFOB13,vFOB14,vFOB15,vFOB16,vFOB17,vFOB18
PUBLIC vFOB19,vFOB20,vFOB21,vFOB22
PUBLIC Sht1,Sht2,Sht3,Sht4,Sht5,Sht6,Sht7,Sht8,Sht9,Sht10

SELECT Mymaster
MyccW=FCOUNT()

FOR j=3 TO MyccW 
    dj="vFOB"+ALLTRIM(STR(j,2,0))
    di=FIELD(j)    
    &dj=di          
ENDFOR 

SELECT resumen
GO top
i=0
SCAN 
    i=i+1
    dxj='Sht'+ALLTRIM(STR(i,2,0))
    dxi=Resumen.Shortname
    &dxj=dxi
ENDSCAN 


SELECT bruno2
GO top
SCAN
    as1=ALLTRIM(bruno2.idsqm)
    SELECT Mymaster
    GO top
    LOCATE FOR ALLTRIM(Mymaster.idsqm)=as1
    
    IF FOUND()
       sfield0="_"+ALLTRIM(Bruno2.proveedor)+'b'
       sfield1="_"+ALLTRIM(Bruno2.proveedor)+'c' 
       replace (sfield0) WITH bruno2.fobflete
       replace (sfield1) WITH bruno2.ufechacotiza    
          
    ELSE
       APPEND BLANK
       replace idsqm WITH as1
       replace Mygenerico WITH Bruno2.clase
       
       sfield0="_"+ALLTRIM(Bruno2.proveedor)+'b'
       sfield1="_"+ALLTRIM(Bruno2.proveedor)+'c' 
       
       replace (sfield0) WITH bruno2.fobflete
       replace (sfield1) WITH bruno2.ufechacotiza       
           
    ENDIF 
    SELECT bruno2
    
ENDSCAN     
    
SELECT Mymaster
    
    


