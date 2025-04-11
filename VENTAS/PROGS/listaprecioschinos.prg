

SET DELETED ON
SET EXCLUSIVE OFF
SET talk OFF
SET ECHO OFF
SET DATE BRITISH

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
	cmd1=SQLEXEC(lnHandle,"SELECT codigo,nombre,idsqm FROM Productos","AuxProd")
	cmd2=SQLEXEC(lnHandle,"SELECT * FROM Clases","AuxClases") 
	                                          
  	SQLDISCONNECT(lnHandle)        
ELSE
   	AERROR(laErr)
    	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

                    

OPEN DATABASE f:\newcompras\data\sqm.dbc SHARED

SELECT c.Nombre as Tipo,a.codigo,a.nombre,;
	   ROUND(((ROUND((iif(a.actprelocal,a.prelocal,((a.precioxlista+b.fletestandar)*b.factordes))),2))*(1+(a.factorgan/100))),2) as Pstock, ;    
	   ROUND(IIF(a.actprelocal,a.prelocal,((a.precioxlista+b.fletestandar)*b.factordes)),2) as Costo,;
	   a.factorgan,;	   
       IIF(b.fletestandar2=0,0,ROUND(iif(a.actprelocal,a.prelocal,((a.precioxlista+b.fletestandar2)*b.factordes)),2)) as Costo2,a.colorindex;       
       FROM sqm!productos as a ;
       LEFT JOIN sqm!proveedores as b ON a.proveedor=b.codigo ;
       LEFT JOIN sqm!tipoprodu as c ON a.tipoproducto=c.codigo ; 
       WHERE a.activo=.t. ORDER by 2,1 INTO CURSOR listax READWRITE 
       

SELECT b.idsqm,a.* FROM Listax as a LEFT JOIN AuxProd as b ON a.codigo=b.codigo INTO CURSOR Lista2 READWRITE 

SELECT lista2
DELETE FOR VAL(SUBSTR(ALLTRIM(idsqm),4,2))>=50
DELETE FOR EMPTY(idsqm)

SELECT CAST(0 as n(1,0)) as Standar,CAST(b.clase as c(70)) as Clase,a.* FROM Lista2 as a LEFT JOIN Auxclases as b ;
       ON a.idsqm=b.idsqm INTO CURSOR Lista3 READWRITE 

SELECT Auxclases
GO top
SCAN FOR !EMPTY(Standar)
     Lx1=ALLTRIM(Auxclases.Standar)
     SELECT Lista3
     LOCATE FOR ALLTRIM(Lista3.codigo)=Lx1
     IF FOUND()
        replace Lista3.Standar WITH 1
     ENDIF 
     
     SELECT Auxclases  
ENDSCAN 

SELECT lista3
DELETE FOR standar=0
GO top
BROWSE 






