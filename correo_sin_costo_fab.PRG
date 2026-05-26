SET NOTIFY OFF
SET SAFETY OFF
SET EXCLUSIVE OFF
SET DELETED ON
SET DEFAULT TO ..\ventas
SET PATH TO ..\ventas,..\ventas\PROGS,..\ventas\librerias

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
	"SERVER=192.168.1.179;" + ;
	"PORT=3306;" + ;
	"UID=sistemas;" + ;
	"PWD=d3b14nfw123;" + ;
	"DATABASE=sqmdata;" + ;
	"OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle <= 0
	WAIT WINDOW 'No se ha podido contectar con el servidor de Base de datos ...' TIMEOUT 2
	Return
ENDIF

cmd1 = SQLEXEC(lnHandle, "SELECT s.UNICO, s.fingreso, s.origen, s.producto AS cod_prod, p.nombre AS nombre_fab, s.qing AS cant_fabrica, s.lotefab AS lote_fab, s.costo, "+ ;
							"i.cod_insumo, i.cant_insumo, i.nombre_insumo, i.lote_insumo, i.origen_insumo, i.costo_insumo, i.costo_insumo "+ ;
							"FROM vtalotes s inner JOIN masteringresos g ON s.UNICO = g.UNICO inner JOIN productos p ON p.codigo = s.producto "+ ;
							"inner JOIN "+ ;
							"(SELECT d.producto AS cod_insumo, d.cantidad AS cant_insumo, p.nombre AS nombre_insumo, s.lotefab AS lote_insumo, s.origen AS origen_insumo, s.costo AS costo_insumo, d.UNICO "+ ;
							"FROM detallesalidas d inner JOIN vtalotes s ON s.ID= d.unicoorigen inner JOIN productos p ON p.codigo= d.producto) i ON g.contrapartida= i.UNICO "+ ;
							"WHERE s.tipoorigen = 'F' AND s.qsaldov > 0 AND s.costo = 0 and s.fingreso= '"+ DTOS(DATE())+"'  Order by 3", "cFabSinCosto")
SQLDISCONNECT(lnHandle)

SELECT cFabSinCosto
GO Top
IF !EOF()
	#Define LF_CR Chr(10)+Chr(13)
	#Define TABU Chr(9)
	
	strSubject= 'AVISO - LOTE FABRICADO CON COSTO 0.00'
	strBody   = ''
	DO WHILE !EOF()
		mOrigen = Origen
		strBody = "SE HA FABRICADO :ORIGEN "+ ALLTRIM(mOrigen)+ " LOTE FAB.:"+ ALLTRIM(Lote_Fab)+ " la cantidad de "+ ALLTRIM(STR(cant_fabrica, 10, 2))+ " KG DEL PRODUCTO "+ ALLTRIM(Nombre_fab)+ ;
				" CODIGO "+ ALLTRIM(cod_prod)+ " COSTO 0"+ LF_CR
		SCAN WHILE Origen= mOrigen
			strBody = strBody+ cod_insumo+ "  "+ PADR(ALLTRIM(nombre_insumo), 40, "_")+ " LOTE "+ ALLTRIM(lote_insumo)+ "  "+ ALLTRIM(origen_insumo)+ " COSTO "+ ALLTRIM(STR(costo_insumo, 10, 2))+ LF_CR
		ENDSCAN
		
		Try
			Local lcSchema, loConfig, loMsg, loError, lcErr
			lcErr = ""
			lcSchema = "http://schemas.microsoft.com/cdo/configuration/"
			loConfig = Createobject("CDO.Configuration")
			With loConfig.Fields
				.Item(lcSchema + "smtpserver") = "smtp.gmail.com"
				.Item(lcSchema + "smtpserverport") = 465 && ó 587
				.Item(lcSchema + "sendusing") = 2
				.Item(lcSchema + "smtpauthenticate") = .T.
				.Item(lcSchema + "smtpusessl") = .T.
				.Item(lcSchema + "sendusername") = "automailer@sociedadquimica.com.pe"
				.Item(lcSchema + "sendpassword") = "robot123"
				.Update
			Endwith
			
			loMsg = Createobject ("CDO.Message")
			With loMsg
				.Configuration = loConfig
				.From = "automailer@sociedadquimica.com.pe (SQM.FAB/Aviso)"
				.To = "importaciones@sociedadquimica.com.pe; yanco@sociedadquimica.com.pe"
				.Subject = strSubject
				.TextBody = strBody
				.Send()
			Endwith
		Catch To loError
			lcErr = [Error: ] + Str(loError.ErrorNo) + Chr(13) + ;
				[Linea: ] + Str(loError.Lineno) + Chr(13) + ;
				[Mensaje: ] + loError.Message
		Finally
			Release loConfig, loMsg
			Store .Null. To loConfig, loMsg
			If Empty(lcErr)
				*MESSAGEBOX("El mensaje se envió con éxito", 64, "Aviso")
			Else
				Messagebox(lcErr, 16 , "Error")
			Endif
		ENDTRY
		
		SELECT cFabSinCosto
	ENDDO
ENDIF
USE IN cFabSinCosto

RETURN
