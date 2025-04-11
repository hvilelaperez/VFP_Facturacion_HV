
SET DELETED ON
SET DATE BRITISH
SET SAFETY OFF
SET TALK OFF 
SET ECHO OFF


PUBLIC Mystring

LOCAL My90
My90=DATE()-90
	

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


CREATE CURSOR estudio (codigo c(7), nombre c(60), activo n(1,0),venta90  n(10,2),Lince n(10,2),Sp n(10,2),st1 n(10,2),st2 n(10,2))

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0      
	   cmd2=SQLEXEC(lnHandle,"SELECT a.codigo,a.nombre,a.activo FROM productos a,tipoproductos b WHERE a.tipoproducto=b.codigo "+;
	                         " and  b.escolorante =1 order by a.codigo ","Mibase")
        
       *cmd2=SQLEXEC(lnHandle,"SELECT a.codigo,a.nombre,a.activo FROM productos a WHERE a.tipoproducto='02' "+;
	                         " and  a.proveedor<>'F0' and proveedor <>'W0' order by a.tipoproducto,a.color ","Mibase")	                         
                     	                         
	   SQLDISCONNECT(lnHandle)
ELSE
    	AERROR(laErr)
	    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT estudio
APPEND FROM DBF("Mibase")
GO top
SELECT Mibase
USE


SELECT estudio
GO top
lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0 

   SCAN
        as1=ALLTRIM(estudio.codigo)
   
        cmd4=SQLEXEC(lnHandle,"SELECT b.producto as Codigo,SUM(b.cantidad) as Todventa FROM detaguiasremision b, "+;
	                          " guiasremision a "+;
                              " WHERE a.unico=b.unico AND a.fecha>=?My90 and a.anulada<>1 and a.motivoguia=1 "+;
                              " AND TRIM(b.producto)=?as1 GROUP BY 1 ","Ventas90") 
        
        cmd0=SQLEXEC(lnHandle,"SELECT SUM(a.qsaldov)  "+;
	                         " as Disponible FROM vtalotes a  WHERE "+;
	                         " TRIM(a.producto)=?as1 AND a.qsaldov>0 AND a.ubicacion<>'P' and a.sobrepedido<>1 "+;
	                         " ORDER BY a.producto ","MyDat0")  
	                                               
        cmd0=SQLEXEC(lnHandle,"SELECT SUM(a.qsaldov)  "+;
	                         " as Disponible FROM vtalotes a  WHERE "+;
	                         " TRIM(a.producto)=?as1 AND a.qsaldov>0 AND a.ubicacion='P' and a.sobrepedido<>1 "+;
	                         " ORDER BY a.producto ","MyDat1")                      
                              
                              
        SELECT Ventas90
        IF ISNULL(Todventa)
          ass1=0
        ELSE
          ass1=Todventa/3
        ENDIF 
        SELECT estudio
        replace venta90 WITH ass1  
        
        SELECT Mydat0
        IF ISNULL(disponible)
          ass2=0
        ELSE
          ass2=Disponible
        ENDIF
        SELECT estudio
        replace lince WITH ass2
        
        SELECT Mydat1
        IF ISNULL(disponible)
          ass3=0
        ELSE
          ass3=Disponible
        ENDIF
        SELECT estudio
        replace sp WITH ass3  
        
                              	 
   ENDSCAN 
   
	   SQLDISCONNECT(lnHandle)
ELSE
    	AERROR(laErr)
	    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF



SELECT estudio
GO top
SCAN
   IF activo=0
     IF lince+sp=0
        DELETE
     ENDIF 
   ENDIF      
   
   IF venta90>0
      IF venta90<=Lince
         as1=(Lince-venta90)
         IF as1>25
            as2=INT(as1/25)*25
            replace st1 WITH as2           
            replace st2 WITH lince-as2             
         ELSE
            replace st1 WITH 0
            replace st2 WITH lince          
         ENDIF            
       ELSE
          replace st1 WITH 0
          replace st2 WITH lince  
       ENDIF  
    ELSE
        DO case
           CASE lince<=35
                replace st1 WITH 0
                replace st2 WITH lince
           OTHERWISE 
                at1=INT(lince/25)
                at2=MOD(lince,25)
                IF at2<=10
                 replace st1 WITH (at1-1)*25
                 replace st2 WITH lince-st1
                ELSE             
                 replace st1 WITH at1*25
                 replace st2 WITH lince-st1              
                ENDIF  
        ENDCASE 
    
        
    ENDIF 
ENDSCAN          
   
GO top


*REPORT FORM infopadron TO PRINTER PROMPT 

REPORT FORM infopadron PREVIEW 

