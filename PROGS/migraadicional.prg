SET DELETED ON
SET DATE BRITISH


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;	
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
                    
                    

SELECT 0
USE f:\comercio\files\gemdquim shared 

SELECT gempsnum,gemdtart+gemdcprv+"0"+gemdccol+gemdcvar as codigo,;
       CAST(IIF(gomdcprc='I','01'+gemdcprv+"0"+TRANSFORM(gomdanol,"@l 99")+TRANSFORM(gomdcorl,"@l 999"),;
                        ALLTRIM(gomdcprc)+"-"+TRANSFORM(gomdanol,"@l 99")+"-"+TRANSFORM(gomdcorl,"@l 999")) as c(11)) as Generado ; 
       FROM gemdquim WHERE YEAR(gempdfec)=2008 AND !EMPTY(gomdcprc) INTO CURSOR base 

SELECT gemdquim
USE 


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd2=SQLEXEC(lnHandle,"SELECT * from vtalotes where fingreso>='2008-01-01' and origen=' -00-000'","Mydatai")
                         
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF



SELECT Mydatai
GO top
SCAN 
  a1=ALLTRIM(producto)
  a2=unico
  SELECT base
  GO top
  LOCATE FOR a1=ALLTRIM(codigo) AND a2=gempsnum
  IF FOUND()
     a3=generado
     SELECT Mydatai
     replace origenx WITH a3     
  ENDIF 
  SELECT Mydatai
ENDSCAN   
  
  
SELECT Mydatai
GO TOP   
lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
   SCAN 
      v1=origenx
      v2=id
     ********** cmd2=SQLEXEC(lnHandle,"update vtalotes set origenx=?v1 where id=?v2")
   ENDSCAN  
                         
    SQLDISCONNECT(lnHandle)    
      
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF  
   



