
SET TALK OFF
SET ECHO OFF
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
       
    cmd1=SQLEXEC(lnHandle," SELECT a.cliente,b.idsqm,a.producto as codigo,a.precio,a.fechamodifi,a.id FROM"+;
                          " preciostockclientes a,productos b WHERE a.producto=b.codigo and b.idsqm<>'' "+;
                          " and a.precio>0 order by 1,2 desc ,2","MyListax")     
    
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

CREATE CURSOR  error1(cliente c(4),idsqm c(5))

SELECT * FROM Mylistax INTO CURSOR  Espejo 


SELECT Mylistax
GO top
SCAN 

    a1=cliente
    a2=idsqm
    a3=precio
    
    SELECT * FROM espejo WHERE cliente=a1 AND idsqm=a2 INTO CURSOR pizza
    SELECT pizza
    cont=0
    SCAN FOR precio<>a3
       cont=cont+1
    ENDSCAN     
    IF cont>0
       SELECT error1
       APPEND BLANK
       replace cliente WITH a1
       replace idsqm WITH a2
    ENDIF 
    
    SELECT Mylistax      
    
ENDSCAN     
    
SELECT distinct cliente,idsqm FROM error1 INTO CURSOR resultado

SELECT resultado
BROWSE     

    
    
