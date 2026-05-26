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
    cmd2=SQLEXEC(lnHandle,"SELECT * FROM kardex WHERE cliente='COMPRA LOCAL'","Mydat1")
    cmd3=SQLEXEC(lnHandle,"SELECT * FROM masteringresos WHERE tipo='W' and fecha>='2009-04-01'","Mydat2")                                                                       
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT fecha,STR(YEAR(fecha),4)+"-"+TRANSFORM(MONTH(fecha),"@l 99")+"-"+TRANSFORM(nummensual,"@l 999") as Guiaentrada, ;
       referenciacliente,notadecreditodev,contrapartida,observaciones FROM Mydat2;
       INTO CURSOR Mydat3

SELECT a.*,b.guiaentrada,b.referenciacliente FROM Mydat1 as a LEFT JOIN mydat3 as b ;
       ON ALLTRIM(a.numero)=ALLTRIM(b.guiaentrada) INTO CURSOR resultado


SELECT resultado
BROWSE 


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
	SELECT resultado
	GO top
	*SCAN
	   a1=id
	   a2='COMPRA LOCAL '+ALLTRIM(referenciacliente)
       *cmd3=SQLEXEC(lnHandle,"update kardex set cliente=?a2 where id=?a1")                             
    
	*ENDSCAN 
                                                
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF   
