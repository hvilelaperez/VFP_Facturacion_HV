SET DELETED ON
SET DATE BRITISH
SET SAFETY OFF
SET ECHO OFF
SET TALK OFF





Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
                    
                    
Ba1=CTOD("01/08/2010")
Ba2=CTOD("31/08/2011")                    
mib=YEAR(DATE())-3                    

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

 cmd2=SQLEXEC(lnHandle,"SELECT codigoc,vendedor,SUM(neto) AS neto FROM factura WHERE estado<>'AN' AND (serie=1 or serie=4)"+;
						" AND moneda='M2' AND motivoguia=1 AND estado<>'AN' AND fecha BETWEEN ?ba1 AND ?ba2 "+;
						" GROUP BY 1,2 ORDER BY 1,2 ","Bass1")
                        
 cmd3=SQLEXEC(lnHandle,"SELECT codigoc,vendedor,SUM(neto) AS neto FROM boleta WHERE estado<>'AN' "+;
						" AND moneda='M2' AND motivoguia=1 AND  estado<>'AN' AND fecha BETWEEN ?ba1 AND ?ba2 "+;
						" GROUP BY 1,2 ORDER BY 1,2 ","Bass2")  
						
 cmd4=SQLEXEC(lnHandle,"SELECT codigoc,neto,tipodoc,serief,numerof,vendedor FROM ncredito WHERE fecha BETWEEN ?ba1 AND ?ba2 "+;
					   " AND serie=1 AND moneda='M2' AND estado<>'AN'  ","Bass3") 
					   
					   
 cmd5=SQLEXEC(lnHandle,"SELECT * FROM factura where YEAR(fecha)>=?MIb","Fa1")
       
 cmd6=SQLEXEC(lnHandle,"SELECT * FROM boleta where YEAR(fecha)>=?mib ","Bo1")
 
 cmd7=SQLEXEC(lnHandle,"SELECT * FROM clientes ","Cli")
 
 cmd7=SQLEXEC(lnHandle,"SELECT * FROM vendedores ","Ven")
      
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF



SELECT Bass3
GO top
SCAN
   xb1=tipodoc
   xb2=serief
   xb3=numerof
   
   DO case
      CASE xb1='F'
      	SELECT Fa1
      	GO top
      	LOCATE FOR serie=xb2 AND numero=xb3
      	IF FOUND()
        	xb4=Fa1.vendedor
        	SELECT Bass3
        	replace vendedor WITH xb4
      	ENDIF 
      CASE xb1='B'
      	SELECT Bo1
      	GO top
      	LOCATE FOR serie=xb2 AND numero=xb3
      	IF FOUND()
        	xb4=Fa1.vendedor
        	SELECT Bass3
        	replace vendedor WITH xb4
      	ENDIF       
    ENDCASE 
   SELECT Bass3
ENDSCAN 


SELECT Bass3
GO top
SCAN FOR EMPTY(vendedor)
    ra1=ALLTRIM(codigoc)
    SELECT cli
    GO top
    LOCATE FOR ALLTRIM(codigo)=ra1
    IF FOUND()
       rp1=cli.vendedor
       SELECT Bass3
       replace vendedor WITH rp1
    ENDIF 
    SELECT bass3
ENDSCAN 


SELECT codigoc,vendedor,SUM(neto) AS neto FROM bass3 GROUP BY 1,2 ORDER BY 1,2 INTO CURSOR bass3x

        
SELECT bass1
APPEND FROM DBF("Bass2")


SELECT codigoc,vendedor,SUM(neto) AS neto FROM bass1 GROUP BY 1,2 ORDER BY 1,2 INTO CURSOR master1 READWRITE 

SELECT bass3x
GO top
SCAN 
   bv1=ALLTRIM(codigoc)
   bv2=ALLTRIM(vendedor)
   bv3=neto
   
   SELECT master1
   GO top
   LOCATE FOR ALLTRIM(codigoc)=bv1 AND ALLTRIM(vendedor)=bv2
   IF FOUND()       
      replace neto WITH neto-bv3
   ELSE
      APPEND BLANK
      replace codigoc WITH bv1
      replace vendedor WITH bv2
      replace neto WITH bv3*-1
   ENDIF
   
   SELECT bass3x
ENDSCAN 

SELECT codigoc,vendedor,SUM(neto) AS neto FROM master1 GROUP BY 1,2 ORDER BY 1,2 INTO CURSOR misdatos READWRITE 

ALTER table Misdatos ADD MacroVen c(25)
ALTER table Misdatos ADD Nombre c(80)      


SELECT misdatos
GO top
 SCAN 
   abv1=ALLTRIM(codigoc)
   SELECT cli
   GO top
   LOCATE FOR ALLTRIM(codigo)=abv1
   IF FOUND()
      at1=ALLTRIM(cli.vendedor)
      atv2=ALLTRIM(STRCONV(cli.nombre,11))
      SELECT ven
      GO top
      LOCATE FOR ALLTRIM(codigo)=at1
      IF FOUND()
         at2=ven.nombre
         SELECT misdatos
         replace Macroven WITH at2
         replace nombre WITH ALLTRIM(codigoc)+' - '+atv2
      ENDIF
   ENDIF
   SELECT misdatos
  ENDSCAN 
  
  GO top
  BROWSE        
         
      
         
   
   



    
        
        
        
        
        
        
      
      
      
      
   

