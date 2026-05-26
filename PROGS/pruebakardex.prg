
SET DATE BRITISH
SET DELETED ON
SET TALK OFF
SET ECHO OFF

lcStringCnxRemoto = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sqmsistemas;" + ;
                    "PWD=t1s9m.2712;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"                                                                                                
                                           
SQLSETPROP(0,"DispLogin" , 3 )
lnHandle = SQLSTRINGCONNECT(lcStringCnxRemoto)
IF lnHandle>0          
  	cmd1=SQLEXEC(lnHandle," SELECT id,fecha,numero,ingreso,salida,saldo FROM kardex WHERE producto='0210F3'","xxx")      
    SQLDISCONNECT(lnHandle)
ELSE
   AERROR(laErr)
   MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT a.*,00000.00 as Rem FROM xxx as a INTO CURSOR yyy READWRITE 
SELECT yyy
GO top
newsaldo=saldo
SCAN
  IF RECNO()=1
       IF INGRESO>0
          REPLACE REM WITH INGRESO	
          NEWSALDO=INGRESO
       ENDIF 
  ELSE         
    IF ingreso=0
       replace rem WITH newsaldo-salida
       NEWSALDO=NEWSALDO-SALIDA
    ELSE 
       replace rem WITH newsaldo+ingreso
       NEWSALDO=NEWSALDO+INGRESO
    ENDIF      
  ENDIF   
ENDSCAN 

BROWSE

SELECT YYY 
GO top
LOCAL RPTA
RPTA=MESSAGEBOX("DESEA CORREGIR SALDOS",36,"")
IF RPTA=6
   lnHandle = SQLSTRINGCONNECT(lcStringCnxRemoto)
		IF lnHandle>0  
		
		   SCAN   
			    A1SALDO=yyy.REM     
			    A1ID=yyy.ID
	  			**cmd3=SQLEXEC(lnHandle,"UPDATE KARDEX SET SALDO=?A1SALDO WHERE ID=?A1ID")        		   
  		   ENDSCAN 	
  		   
   			SQLDISCONNECT(lnHandle)
		ELSE
   			AERROR(laErr)
   			MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
		ENDIF
ENDIF 
