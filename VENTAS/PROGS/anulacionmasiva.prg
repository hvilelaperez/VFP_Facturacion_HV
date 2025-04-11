	   
	   LOCAL a1,b1,Mystring_ofi01x
	   a1=377
	   b1=450
	   
       Mystring_ofi01x = "DRIVER={MySQL ODBC 3.51 Driver};" + ; 
           		         "SERVER=192.168.1.179;" + ;                                                               		
           		         "PORT=3306;" + ;
           		         "UID=sistemas;" + ;
           		         "PWD=d3b14nfw123;" + ;           		
           		         "DATABASE=sqmdata;" + ;                             
           		         "OPTIONS=0;"
           		
	   	   	   	   
	   lnHandle = SQLSTRINGCONNECT(MyString_ofi01x)
	   IF lnHandle > 0
	  
		  cmd1=SQLEXEC(lnHandle,"SELECT MAX(unico) as Uni FROM factura ","Mymax") 	
    	  SQLDISCONNECT(lnHandle)         
	   ELSE
	      AERROR(laErr)
	      MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	   ENDIF		  	    		    	    
            	 	      
	   SELECT Mymax
	   Pv1x=Mymax.Uni+1
	   Pv1=Pv1x
	   
	   lnHandle = SQLSTRINGCONNECT(MyString_ofi01x)
	   IF lnHandle > 0
	    FOR i=a1 TO b1	       
		   Pv2='XXXX'
		   Pv3=DATE()
		   Pv4=3
		   Pv5=i
	      	    
	       cmd2=SQLEXEC(lnHandle,"INSERT INTO factura (unico,serie,numero,fecha,estado,codigoc) values "+;
	                               "(?Pv1,?Pv4,?Pv5,?Pv3,'AN',?Pv2)")	  
           Pv1=Pv1+1	                               
	    ENDFOR                                 
    	  SQLDISCONNECT(lnHandle)         
	   ELSE
	      AERROR(laErr)
	      MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	   ENDIF
	   
	   
	   