
SET DELETED ON
SET ECHO OFF
SET TALK OFF
SET DATE BRITISH



USE F:\COMERCIO\FILES\boMPQUIM SHARED

SELECT FCMPNSFA,FCMPNCFA,FCMPDFEC,FCMPMSAL FROM boMPQUIM WHERE  FCMPXANU<>1 AND FCMPMSAL="VENTA" INTO CURSOR why

SELECT bompquim 
USE

PUBLIC Mystring 

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"



SELECT Why
GO top


	lnHandle = SQLSTRINGCONNECT(Mystring)
	IF lnHandle > 0
	   SCAN  
          a1=WHY.FCMPNSFA
          a2=Why.FCMPNCFA
            
    	 ******* cmd1=SQLEXEC(lnHandle,"UPDATE boleta SET motivoguia=1 where serie=?a1 and numero=?a2 ")    
    	  
       ENDSCAN 	  
                                             
    	SQLDISCONNECT(lnHandle)
	ELSE
    	AERROR(laErr)
    	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	ENDIF

