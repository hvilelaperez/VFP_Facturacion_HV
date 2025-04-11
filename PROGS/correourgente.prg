
	#DEFINE LF_CR CHR(10)+CHR(13)
	#DEFINE TABU CHR(9) 
	
	SELECT 0
	USE f:\facturas.dbf 
	GO top
	SCAN 
										        
	    strBody=""    
	    
    	 IF ALLTRIM(Facturas.tipo)="F"
    	    cMitipo="Factura"
    	 ELSE 
    	    cMitipo="Boleta"
         ENDIF 
         
		strProfile = "outlook"
		strPassword = ""	
		strRecipient ="cservat@sociedadquimica.com.pe"
		strSubject = " Observacion Urgente"
	
		strBody = strBody + "Estimado Cliente"+LF_CR
		strBody = strBody + "Hemos detectado en nuestro sistema que por error el dia de ayer Jueves 01 de Octubre de los corrientes"+CHR(10)
		strBody = strBody + "la "+ALLTRIM(cMitipo)+" "+ALLTRIM(facturas.factura)+ " consigna número de Guia "+ALLTRIM(facturas.guia)+", cuando debería consignar el número "+ALLTRIM(facturas.guia2)+CHR(10)
		strBody = strBody + "Por tal motivo estamos procediendo a enviarles una carta rectificatoria para subsanar el error encontrado."+CHR(10)
		strBody = strBody +LF_CR
		strBody = strBody + "Atentamente," +LF_CR
		strBody = strBody + "Cecilia Servat" + CHR(10)
		strBody = strBody + "Ventas - Sociedad Quimica Mercantil S.A."+LF_CR
		strBody = strBody + LF_CR
		strBody = strBody + LF_CR

		theApp = CreateObject("Outlook.Application")
		theNameSpace = theApp.GetNameSpace("MAPI")
		theNameSpace.Logon(strProfile , strPassword)
		theMailItem = theApp.CreateItem(0)

		theMailItem.Recipients.Add( strRecipient )
		theMailItem.Subject = strSubject
		theMailItem.Body = strBody
		theMailItem.Send
		theNameSpace.Logoff
				
   ENDSCAN 		
   
   
   