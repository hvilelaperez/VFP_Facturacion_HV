
SET ECHO OFF
SET DATE TO BRITISH 


!* Creo un cursor que es el que ingresare en la hoja de calculo
*!* cargo el campo Numero con aleatorios, el campo texto con sys(2015)

CREATE CURSOR curPrueba (Numero N(10),Texto C(254)) && Creo el curso

FOR lnContador=1 TO 10 && Ingreso 10 Registros aleatorios
INSERT INTO curPrueba(Numero,Texto) values(INT(RAND()*500+1),SYS(2015))
ENDFOR

*!* CREO EL OBJETO DE EXECEL
tmpsheet = GetObject('','excel.sheet') 
XLApp = tmpsheet.application
XLApp.ActiveWindow.DisplayZeros = .f. &&No muestra las celdas en valor 0
XLApp.ActiveWindow.DisplayGridlines = .f. &&No muestra las líneas de división
XLApp.Visible = .t. &&Aplicacion visible
XLApp.WorkBooks.Add() &&Agrega una Hoja de calculo
XLSheet = XLApp.ActiveSheet

*!* RECORRO EL CURSOR E INGRESO EN EXCEL
GOTO TOP IN curPrueba
SCAN 
XLSheet.cells(RECNO('curPrueba'),1)=curPrueba.Numero
XLSheet.cells(RECNO('curPrueba'),2)=ALLTRIM(curPrueba.Texto)
ENDSCAN

*!* FORMATO DE COLUMNAS TITULO
XLSheet.Rows("1:1").Insert
XLSheet.cells(1,1)='NUMERO' && Titulo celda fila 1 y columna 1
XLSheet.cells(1,2)='TEXTO' && Titulo celda fila 1 y columna 2

WITH XLSheet.Range("A1:B1")
.HorizontalAlignment=-4108 && xlCenter &&Aliniar al centro *
.VerticalAlignment=-4108 && xlCenter 
.Font.Bold=.t.
.Font.Size=14
.Font.Name='Arial'
ENDWITH

*!* AUSTANDO CELDAS
XLSheet.Columns().AutoFit

*XLApp.Active.Worksheet.SaveAs("C:\Demo01.xls"), -4143, "", "", .F., .F.)
*XLApp.WorkBooks.Close

tmpsheet = .NULL.
RELEASE tmpsheet 

