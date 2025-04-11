
SET DELETED ON
SET DATE BRITISH

LOCAL CnxUnifi01

*CnxUnifi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ; 
           		"SERVER=192.168.1.179;" + ;                                                               		
           		"PORT=3306;" + ;
           		"UID=sistemas;" + ;
           		"PWD=d3b14nfw123;" + ;           		
           		"DATABASE=sqmdata;" + ;                             
           		"OPTIONS=0;"

CnxUnifi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ; 
           		"SERVER=192.168.1.221;" + ;                                                               		
           		"PORT=3306;" + ;
           		"UID=sistemas;" + ;
           		"PWD=informatica;" + ;           		
           		"DATABASE=indicolor;" + ;                             
           		"OPTIONS=0;"
           		        			           			           			           		
lnHandle = SQLSTRINGCONNECT(CnxUnifi01)
IF lnHandle > 0      
    *cmd2=SQLEXEC(lnHandle,"SELECT asrctdoc,SUBSTRING(TRIM(asrcndoc),1,3) as serie ,SUBSTRING(TRIM(asrcndoc),5,10) as numero,idunico "+;
                          "FROM conta2016 WHERE  TIPLIB='RV' AND SUBSTRING(ASRCCCTA,1,2)='12' AND ASRCTDOC IN ('FA','B','NC','ND') "+;
                          "AND mes>5 AND ano=16 ORDER BY asrctdoc,asrcndoc ","Midata")  
                                                  
    *cmd3=SQLEXEC(lnHandle,"SELECT asrctdoc,SUBSTRING(TRIM(asrcndoc),1,3) as serie ,SUBSTRING(TRIM(asrcndoc),5,10) as numero,idunico "+;
                          "FROM conta2016 WHERE  TIPLIB='RV' AND SUBSTRING(ASRCCCTA,1,2)='13' AND ASRCTDOC IN ('FA','B','NC','ND') "+;
                          "AND mes>3 AND ano=16 ORDER BY asrctdoc,asrcndoc ","Midata")        &&& SOLO INDICOLOR                                            
   SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
     MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT Midata
GO top
lnHandle = SQLSTRINGCONNECT(CnxUnifi01)
IF lnHandle > 0      
   SCAN    
        vserie=VAL(serie)
        vnumero=VAL(numero)
        superid=idunico
                        
        DO CASE 
           CASE ALLTRIM(asrctdoc)='FA'        
                cmd2=SQLEXEC(lnHandle,"UPDATE factura SET idcontable=?superid WHERE serie=?vserie and numero=?vnumero") && Factura
           CASE ALLTRIM(asrctdoc)='B'               
                cmd2=SQLEXEC(lnHandle,"UPDATE boleta SET idcontable=?superid WHERE serie=?vserie and numero=?vnumero") && Boleta
           CASE ALLTRIM(asrctdoc)='NC'    
       			cmd2=SQLEXEC(lnHandle,"UPDATE ncredito SET idcontable=?superid WHERE serie=?vserie and numero=?vnumero") && ncredito
       	   CASE ALLTRIM(asrctdoc)='ND' 	
       			cmd2=SQLEXEC(lnHandle,"UPDATE ndebito SET idcontable=?superid WHERE serie=?vserie and numero=?vnumero") && ndebito
        ENDCASE        			        
   ENDSCAN
   
   SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
     MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF
   
   
