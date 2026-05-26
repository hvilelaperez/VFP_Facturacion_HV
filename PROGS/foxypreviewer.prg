* FoxyPreviewer Version info
#DEFINE  FOXYPREVIEWER_VERSION    1.99
#DEFINE  FOXYPREVIEWER_VERSION2   "v1.99 2010.11.02"
#DEFINE  MAIN_LISTENER            "FOXYLISTENER"
#DEFINE  CRYPT_KEY                "?GotData?9FoxIt!!!"

#INCLUDE FoxyPreviewer.h

LPARAMETERS loPreviewContainer

SET TALK OFF
SET CONSOLE OFF

IF PCOUNT() = 0 OR VARTYPE(loPreviewContainer) = "C" && No parameters, call the general preview
				&& initialization

	LOCAL lcLocalPath
	lcLocalPath = ""
	IF VARTYPE(loPreviewContainer) = "C"
		lcLocalPath = loPreviewContainer
	ENDIF 



	TRY
		_oReportOutput["1"].PREVIEWCONTAINER = .NULL.
		* _oReportOutput.Remove("1")
	CATCH TO loExc
	ENDTRY



	IF UPPER(lcLocalPath) = "RELEASE"
		* Clean up 
		IF TYPE([_oReportOutput("1")]) = "O"
			_oReportOutput.Remove("1")
		ENDIF 

		* Restore the original _REPORTPREVIEW
		TRY 
			_REPORTPREVIEW = _Screen.oFoxyPreviewer.cOrigRepPreview
		CATCH 
		ENDTRY 
		RETURN 
	ENDIF 



	* Get settings information
	RELEASE _goHelper
	PUBLIC  _goHelper
	_goHelper = CREATEOBJECT("PreviewHelper")
	_goHelper.lExtended = .F.


	LOCAL loListener as FXLISTENER OF "PR_ReportListener.vcx" 
	IF UPPER(JUSTEXT(SYS(16))) = "APP"
		loListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx", SYS(16))
		IF NOT ("_GDIPLUS.VCX" $ SET("Classlib"))
			SET CLASSLIB TO "_GdiPlus.vcx" IN SYS(16) ADDITIVE 
		ENDIF
	ELSE 
		loListener = NEWOBJECT(MAIN_LISTENER, ADDBS(JUSTPATH(SYS(16))) + "PR_ReportListener.vcx")
		IF NOT ("_GDIPLUS.VCX" $ SET("Classlib"))
			SET CLASSLIB TO ADDBS(JUSTPATH(SYS(16))) + "_GdiPlus.vcx" ADDITIVE 
		ENDIF
	ENDIF

	IF NOT UPPER(JUSTFNAME(SYS(16))) $ SET("Procedure")
		SET PROCEDURE TO (SYS(16)) ADDITIVE 
	ENDIF


	* loListener.fxFeedbackClass = "FoxyTherm"
	loListener.fxFeedbackClass = _goHelper._cThermClass
	loListener.QuietMode = _goHelper.lQuietMode


	*!*	* This could be also:
	* http://spacefold.com/articles/tmm/UpdateListener.aspx
	*!*	LOCAL loFxTherm as FoxyTherm OF ADDBS(HOME()) + "FFC\PR_ReportListener.vcx" 
	*!*	loFxTherm = NEWOBJECT("FoxyTherm", "PR_ReportListener.vcx")
	*!*	* ? oy.FXS.count && listener doesn't have any FX objects yet,
	*!*	          && we can safely add one without worrying
	*!*	          && about removing any previous feedback object
	*!*	loListener.FXS.Add(loFxTherm)
	*!*	loFxTherm.thermPrecision = 0
	*!*	loFxTherm.thermFormCaption = "My Test Caption"
	*!*	loFxTherm.persistBetweenRuns = .T. && so we can check it afterwards


	* Additional information:
	* http://msdn.microsoft.com/en-us/library/ms949546(VS.80).aspx
	* http://fox.wikis.com/wc.dll?Wiki~DeployingReportBehavior90InRuntime

	* This is to remove a default listener reference to be replaced
	* Clean up 
	IF TYPE([_oReportOutput("1")]) = "O"
		_oReportOutput.Remove("1")
	ENDIF 


	LOCAL lcReportOutput
	lcReportOutput = _ReportOutput
	IF EMPTY(lcReportOutput) OR NOT FILE(lcReportOutput)
		lcReportOutput = "ReportOutput.App"
	ENDIF 
		

	IF FILE(lcReportOutput)
		DO (lcReportOutput) with 1, loListener
	ELSE 
		MESSAGEBOX("Could not find the 'ReportOutput.App' file. This file is needed to have the new features of FoxyPreviewer." + CHR(13) + ;
			"Please make sure to set the global variable '_REPORTOUTPUT' with the full path of this file " + ;
			"or save it in a folder that your app can reach", 48, "FoxyPreviewer not loaded!")
	ENDIF 



	*	#DEFINE PRINT_MODE    0
	*	#DEFINE PREVIEW_MODE  1
	*	#DEFINE OUTPUTAPP_LOADTYPE_RELOAD 2
	*	DO (_ReportOutput) WITH ;lcLo
	*	      PREVIEW_MODE , loListener, OUTPUTAPP_LOADTYPE_RELOAD

	LOCAL loSettings
	loSettings = CREATEOBJECT("Empty")
	ADDPROPERTY(loSettings, "cSuccessor" , NULL)
	ADDPROPERTY(loSettings, "lQuietMode" , NULL)
	ADDPROPERTY(loSettings, "lShowSearch", NULL)
	ADDPROPERTY(loSettings, "lShowSetup" , NULL)
	ADDPROPERTY(loSettings, "nThermType" , NULL)
	ADDPROPERTY(loSettings, "cLocalPath" , lcLocalPath) && IIF(EMPTY(lcLocalPath), NULL, lcLocalPath)
	ADDPROPERTY(loSettings, "cOrigRepPreview" , _REPORTPREVIEW)
	
	IF NOT PEMSTATUS(_Screen, "oFoxyPreviewer", 5)
		_Screen.AddProperty("oFoxyPreviewer", loSettings)
	ENDIF 


	* _REPORTPREVIEW identifies the preview container factory application.
	* This program is called by Visual FoxPro when:
	* • the report engine is assisted by a ReportListener object, and 
	* • the ReportListener has a ListenerType of 1, and 
	* • the ReportListener does not already have an object reference assigned to its .PreviewContainer property. 
	_ReportPreview = SYS(16)
	SET REPORTBEHAVIOR 90
	SET PATH TO JUSTPATH(SYS(16)) ADDITIVE 




	*!*	* Update the thermometer
	*!*	LOCAL loListenerFactory as FXLISTENER OF ADDBS(HOME()) + "ffc\PR_ReportListener.vcx"
	*!*	loListenerFactory = _oReportOutput("1")
	*!*	loListenerFactory.fxFeedbackClass = _goHelper._cThermClass


	IF TYPE([_oReportOutput("1")]) <> "O"
		MESSAGEBOX("Could not load the FOXYPREVIEWER report factory", 16, "Error")
		RETURN
	ENDIF 
	
	LOCAL loPrevListener
	loPrevListener = EVALUATE([_oReportOutput("1")])
	IF UPPER(loPrevListener.Class) <> MAIN_LISTENER
		MESSAGEBOX("Could not load the FOXYPREVIEWER report factory (2)", 16, "Error")
		RETURN
	ENDIF 
	
	RETURN
ENDIF PCOUNT() = 0 && End of initialization script



LOCAL loPreviewContainer AS FORM, ;
	loListener AS REPORTLISTENER, ;
	loExHandler AS ExtensionHandler OF SYS(16)

*-- Get a preview container from the
*-- .APP registered to handle object-assisted
*-- report previewing.
loPreviewContainer = NULL

TRY
	DO ("ReportPreview.App") WITH loPreviewContainer
CATCH
	DO HOME() + "ReportPreview.App" WITH loPreviewContainer
ENDTRY


RELEASE _goHelper
PUBLIC  _goHelper
_goHelper = CREATEOBJECT("PreviewHelper")
_goHelper.lExtended = .F.
* _goHelper.ClearCache()

TRY
	IF VARTYPE(_Screen.oFoxyPreviewer) = "O"
	
		WITH _Screen.oFoxyPreviewer
			IF NOT ISNULL(.lQuietMode)
				_goHelper.lQuietMode       = _Screen.oFoxyPreviewer.lQuietMode 
			ENDIF 

			IF NOT ISNULL(.cSuccessor)
				_goHelper.cSuccessor       = _Screen.oFoxyPreviewer.cSuccessor
			ENDIF 

			IF NOT ISNULL(.lShowSearch)
				_goHelper.lShowSearch      = _Screen.oFoxyPreviewer.lShowSearch
			ENDIF 

			IF NOT ISNULL(.lShowSetup)
				_goHelper.lShowSetup       = _Screen.oFoxyPreviewer.lShowSetup
			ENDIF 

			IF NOT ISNULL(.nThermType)
				_goHelper.nThermType       = _Screen.oFoxyPreviewer.nThermType
			ENDIF 
		ENDWITH 

	ENDIF 
ENDTRY 

* Create a PREVIEW listener
TRY
	loListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx") && , "ReportOutput.App")
CATCH
	loListener = CREATEOBJECT(MAIN_LISTENER)
ENDTRY

loListener.LISTENERTYPE = 1 && Preview
loListener.QUIETMODE = _goHelper.lQuietMode
TRY 
	loListener.fxFeedbackClass = _goHelper._cThermClass
CATCH
ENDTRY 

*-- Link the Listener and preview container
loListener.PREVIEWCONTAINER = loPreviewContainer

* Create an extension handler and hook it to the
* preview container. This will let you manipulate
* properties of the container and its Preview toolbar
loExHandler = NEWOBJECT('ExtensionHandler')
_goHelper._oExHandler = loExHandler

loPreviewContainer.SetExtensionHandler(loExHandler)

RELEASE loPreviewContainer, loListener, loExHandler
RETURN


DEFINE CLASS PreviewHelper AS CUSTOM
	cPrinterName = SET("Printer",3)

	lSaveToFile     = .T. && adds the save to file button
	lSendToEmail    = .T. && adds the send to email button
	lPrintVisible   = .T. && shows the print button in the toolbar
	lShowCopies     = .T. && shows the copies spinner
	lShowMiniatures = .T. && shows the miniatures page
	lPrinterPref    = .T. && shows the printer preferences button

	* Output types allowed in the "Save as.." button from the toolbar
	lSaveAsImage	= .T.
	lSaveAsHTML		= .T.
	lSaveAsRTF		= .T.
	lSaveAsXLS		= .T.
	lSaveAsPDF		= .T.
	lSaveasTXT      = .T. && Save as txt 11/08/2010 by mauriciobraga@ig.com.br

	lQuietMode      = .F.

	cDestFile       = ""   && the destination file (image, htm, pdf, etc)
	lPrinted        = .F.  && knows if the user printed the report
	lSaved          = .F.  && knows if the user saved the report to a file
	lEmailed 		= .F.  && knows if the user emailed the report

	nPageTotal      = 0 && Total pages of the current report
	nCopies         = 1 && The quantity of copies to be printed
	cTitle          = "" && PR_REPORTTITLE && The preview window title
	oListener = NULL
	cDefaultListener = MAIN_LISTENER 
	cSuccessor       = ""
	nCanvasCount = 1 && initial nr of pages rendered on the preview form.
&& Valid values are 1 (default), 2, or 4.

	nZoomLevel	= 5 && initial zoom level of the preview window. Possible values are:
&& 1-10%, 2-25%, 3-50%, 4-75%, 5-100% default, 6-150% ;
&& 7-200%, 8-300%, 9-500%, 10-whole page

	nWindowState = 0 && Normal

	nDockType	= 4 && .F. && false MEANS TO KEEP THE CURRENT DOCK SETTINGS FROM THE RESOURCE
*!*		–1 Undocks the toolbar or form.
*!*	 	 0 Positions the toolbar or form at the top of the main Visual FoxPro window.
*!*		 1 Positions the toolbar or form at the left side of the main Visual FoxPro window.
*!*		 2 Positions the toolbar or form at the right side of the main Visual FoxPro window.
*!*		 3 Positions the toolbar or form at the bottom of the main Visual FoxPro window.

	cFormIcon = PR_FORMICON
	lUseListener = .T.

	lEmailAuto = .T. 		&& Automatically generates the report output file
	cEmailType = "PDF" 		&& The file type to be used in Emails (PDF, RTF, HTML, XML or XLS)
	cEmailPRG  = ""
	nEmailMode = 1          && 1 = MAPI, 2 = CDOSYS, 3 = Custom procedure

	*!* 2010-09-17 - Jacques Parent - Add the cSaveDefName
	cSaveDefName  = ""		&& Default name of the save file.  Available in the SAVE AS dialog OR automatically used if lEmailAuto

	cSMTPServer   = ""
	nSMTPPort     = 25
	lSMTPUseSSL   = .F.
	cSMTPUserName = ""
	cSMTPPassword = ""

	cEmailTo      = ""
	cEmailSubject = ""
	cEmailBody    = ""
	cEmailFrom    = ""

	cEmailCC 		= ""
	cEmailBCC 		= ""
	cEmailReplyTo	= ""

	lAutoSendMail= .F.		&& Send an email automatically when processing the report

	nButtonSize   = 1 && 1=16x16 pixels (default), 2=32x32 pixels

	cCodePage  = "CP1252"	&& CodePage, to be used by PDF Listener
*!*	CP1250 Microsoft Windows Codepage 1250 (EE)
*!*	CP1251 Microsoft Windows Codepage 1251 (Cyrl)
*!*	CP1252 Microsoft Windows Codepage 1252 (ANSI)
*!*	CP1253 Microsoft Windows Codepage 1253 (Greek)
*!*	CP1254 Microsoft Windows Codepage 1254 (Turk)
*!*	CP1255 Microsoft Windows Codepage 1255 (Hebr)
*!*	CP1256 Microsoft Windows Codepage 1256 (Arab)
*!*	CP1257 Microsoft Windows Codepage 1257 (BaltRim)
*!*	CP1258 Microsoft Windows Codepage 1258 (Viet)

	lPDFasImage     = .F.

	nMaxMiniatureDisplay = 64	&& Number of miniature to display in the miniature form

	nPDFPageMode = 0 && Default = 0, 0 = Normal view, 1 = Show the outlines pane, 2 = Show the thumbnails pane
	cLanguage = PR_DEFAULTLANGUAGE

	nShowToolBar = 1 && 1 = Visible (default), 2 = Invisible, 3 = Use resource
	lShowSetup  = .T.
	lShowPrinters  = .T. && determines if the available printers combo will be shown
	lShowSearch    = .T. && determines if the Search buttons will be visible

	lSilent	= .F.		&& Stay silent AND write any messagebox to the cErrors properties
	cErrors = ""		&& Contains any error message

	lExtended      = .T. && Flag that tells if the report is being run automatically

	* Internal use properties
	_ClausenRangeFrom = 1
	_ClausenRangeTo = -1 && All pages

	_ClausenPrintRangeFrom = 0
	_ClausenPrintRangeTo   = 0

	_ClauselSummary = .F.
	_ClausecHeading = ""

	_cFRXName      = "" && the ReportFrxName
	_cFRXFullName  = ""

	_oReports = "" && Internal use, collection that contains the report names to be used
	_oClauses = ""
	_oAliases = ""
	_oNames = ""

	_oProofSheet = ""
	_oSettingsSheet = ""

	_cOriginalPrinter = SET("Printer",3)
	_lSendToPrinter = .F.	&& Flag that will tell the object to
		&& run the report again and send the output
		&& to another printer after the preview window is closed
	_lNoWait = .F.
	_OldReportOutput = ""
	_oExHandler = ""
	_oCaller = "" && The caller object, used in the APP mode, when called from an EXE
	_oParentForm = ""
	_DE_Name = "" && the dataenvironment name, to be used on cleanup
	_oReport = ""
	_lSendingEmail = .F.

	_cDefaultFolder = SYS(5) + SYS(2003)
	_lIsDotMatrix = .F.

	_oLang = ""
	_nBtSize = 0
	_aLanguages = ""
	_aLangLocal = ""
	_LangIndex  = ""

	* by Mauricio Braga
	cOutputPath = ""  && destination path 11/08/2010 by mauriciobraga@ig.com.br


	* Search properties
	_cOutputAlias     = ""
	_cTextToFind      = ""
	_nIndex           = 0 && the index number of the reports collection
	_lCanSearch       = .F.
	_lShowSearchAgain = .F.


	nPrinterPropType  = 1 && 1 = PRINTER PROMPT Printer dialog     2 = Current printer properties
	lDirectPrint      = .F. && Flag that directs the output directly to the printer, without preview

	_TopForm = .F.
	nVersion = FOXYPREVIEWER_VERSION
	cVersion = FOXYPREVIEWER_VERSION2
	nSearchPages = -1
	_cThermClass = "FOXYTHERM"
	nThermType   = 2 && 1 = Default     2 = Enhanced, with CTL32


	cDecryptProcedure = ""	&& The programmer can apply his own Scrambling method on the password string...
	cEncryptProcedure = ""	&& The programmer can apply his own Scrambling method on the password string...




PROCEDURE DoEncrypt
	LPARAMETERS tcString
	LOCAL lcEncrProc
	lcEncrProc = This.cEncryptProcedure

	IF EMPTY(lcEncrProc) && The programmer can apply his own Scrambling method on the password string...
		RETURN RC4(tcString, CRYPT_KEY)
	ELSE
		RETURN &lcEncrProc.(tcString)
	ENDIF 
ENDPROC 


PROCEDURE DoDecrypt
	LPARAMETERS tcString
	LOCAL lcDecrProc
	lcDecrProc = This.cDecryptProcedure

	IF EMPTY(lcDecrProc) && The programmer can apply his own Scrambling method on the password string...
		RETURN RC4(tcString, CRYPT_KEY)
	ELSE
		RETURN &lcDecrProc.(tcString)
	ENDIF 
ENDPROC 



	PROCEDURE INIT

		This.cErrors = ""

		IF _VFP.StartMode = 0 && Development
			LOCAL lcPath
			lcPath = ADDBS(JUSTPATH(This.Classlibrary))
			SET PROCEDURE TO (This.ClassLibrary) ADDITIVE 
			SET PATH TO (lcPath) ADDITIVE 
			SET PATH TO (lcPath) + "Images" ADDITIVE 

			IF NOT ("_GDIPLUS.VCX" $ SET("Classlib"))
				SET CLASSLIB TO lcPath + "_GdiPlus.vcx" ADDITIVE 
			ENDIF
			IF NOT ("PR_REPORTLISTENER.VCX" $ SET("Classlib"))
				SET CLASSLIB TO lcPath + "PR_ReportListener.vcx" ADDITIVE 
			ENDIF
			
		ELSE 
			IF NOT ("_GDIPLUS.VCX" $ SET("Classlib"))
				SET CLASSLIB TO "_GdiPlus.vcx" ADDITIVE 
			ENDIF
		ENDIF

		IF This.lExtended = .T.
			RELEASE _goHelper
			PUBLIC _goHelper
			_goHelper = THIS

			* Extract the HPDF library
			LOCAL lcClassPath, lcPDFFile, lcTestPath
			lcClassPath = IIF(EMPTY(This.ClassLibrary), "", ADDBS(JUSTPATH(This.ClassLibrary)))
			lcPDFFile = "libhpdf.dll"
			IF FILE(lcPDFFile) AND EMPTY(SYS(2000,lcPDFFile))
				* File is an embedded resource
				lcTestPath = lcClassPath + lcPDFFile && FULLPATH("libhpdf.dll")
				IF PR_PathFileExists(lcTestPath + CHR(0)) = 0
					STRTOFILE(FILETOSTR(lcPDFFile), lcClassPath + lcPDFFile)
				ENDIF
				
				IF NOT FILE(lcClassPath + lcPDFFile)
					STRTOFILE(FILETOSTR(lcPDFFile), ADDBS(HOME()) + lcPDFFile)
					SET PATH TO (HOME()) ADDITIVE 
				ENDIF
			ENDIF
		ENDIF

		This.UpdateSettings()
	ENDPROC


	PROCEDURE UpdateSettings
		LPARAMETERS tlInSession

		LOCAL lcClassPath, lcFile, lcUserSetFile, lcDefaultSetFile
		lcClassPath      = IIF(EMPTY(This.ClassLibrary), "", ADDBS(JUSTPATH(This.ClassLibrary)))

		IF (This.lExtended = .F.) AND ;
				TYPE("_Screen.oFoxyPreviewer.cLocalPath") = "C" AND ;
				NOT EMPTY(_Screen.oFoxyPreviewer.cLocalPath)
			lcClassPath = _Screen.oFoxyPreviewer.cLocalPath
		ENDIF 

		lcUserSetFile    = "FoxyPreviewer_Settings.dbf"
		lcDefaultSetFile = "FoxyPreviewer_DefaultSettings.dbf"
		lcFile           = lcClassPath + lcUserSetFile

		IF (NOT FILE(lcUserSetFile)) AND (FILE(lcDefaultSetFile))
			* Restore from the embedded resource
			IF PR_PathFileExists(lcUserSetFile + CHR(0)) = 0
				STRTOFILE(FILETOSTR(lcDefaultSetFile), lcFile)
				DO CPZERO WITH lcFile,0   && <= by Nick Porfyris [20100921]...
					&& "foxypreviewer_settings.dbf" MUST have CODE PAGE equal to ZERO, in order
					&& to save and retrieve properly the Greek and other international
					&& characters, so add the cpzero command
			ENDIF
			
			IF NOT FILE(lcFile)
				STRTOFILE(FILETOSTR(lcDefaultSetFile), ADDBS(HOME()) + lcUserSetFile)
				SET PATH TO (HOME()) ADDITIVE 
			ENDIF
		ENDIF
		
		LOCAL lnSelect, lcAlias
		lnSelect = SELECT()
		lcAlias  = SYS(2015)

		TRY

			IF FILE(lcFile)
				USE (lcFile) IN 0 AGAIN SHARED ALIAS (lcAlias) && FP_Settings
			ELSE 
				USE (JUSTFNAME(lcFile)) IN 0 AGAIN SHARED ALIAS (lcAlias) && FP_Settings
			ENDIF 

			SELECT (lcAlias) && FP_Settings
			LOCAL lcProp, lcType, luValue
			SCAN
				lcProp = EVALUATE(lcAlias + ".Property") && FP_Settings.Property
				lcType = UPPER(LEFT(lcProp, 1))
				luValue = EVALUATE(lcAlias + "." + lcType + "Value")

				IF lcType = "C"
					luValue = ALLTRIM(luValue)
				ENDIF

				* [2010-10-14] Now the user is free to add his own rows into the FoxyPreviewer_settings.dbf !...
				* _goHelper.&lcProp. = luValue			&&[20101014] by Nick Porfyris...
				IF VARTYPE(_goHelper.&lcProp.)=[U]		&& user define row, so skip it, avoiding the Error msg: "Property NOT FOUND!..."
				ELSE
					_goHelper.&lcProp. = luValue
				ENDIF
				* [2010-10-14]
				_goHelper.&lcProp. = luValue
			ENDSCAN

		CATCH TO loExc
			* LOCAL loExc AS EXCEPTION
			IF loExc.ERRORNO = 1 && File not found
				This.SetError("Could not locate the settings table." + CHR(13) + ;
					"Please check the folder permissions of the folder where you saved 'FoxyPreviewer.App', because this utility needs Read/Write permission in that folder." + ;
					"You may need to move the APP from that folder." + CHR(13) +  CHR(13) + ;
					"Loading default preview settings")

			ELSE
				MESSAGEBOX("Error in UpdateSettings" + CHR(13) + ;
					TRANSFORM(loExc.ERRORNO) + " - " + loExc.MESSAGE + CHR(13) + ;
					"Line: " + TRANSFORM(loExc.LINENO) + " - " + loExc.LINECONTENTS)
			ENDIF
		ENDTRY

		IF USED(lcAlias)
			USE IN (lcAlias)
		ENDIF

		SELECT (lnSelect)

		WITH THIS
			&& included test .F. to lSaveAsTXT && 11/08/2010 by mauriciobraga@ig.com.br
			IF TRANSFORM(.lSaveAsImage) + TRANSFORM(.lSaveAsPDF) + TRANSFORM(.lSaveAsRTF) + ;
					TRANSFORM(.lSaveAsXLS) + TRANSFORM(.lSaveAsHTML) + ;
					TRANSFORM(.lSaveasTXT) = ".F..F..F..F..F..F."
				.lSaveToFile = .F.
			ENDIF
		ENDWITH
	ENDPROC


	PROCEDURE nThermType_Assign
		LPARAMETERS tnType
		LOCAL lcThermClass
		IF tnType = 1
			lcThermClass = "FXTHERM"
		ELSE 
			lcThermClass = "FOXYTHERM"
		ENDIF
		_goHelper._cThermClass = lcThermClass
		_goHelper.nThermType   = tnType
	ENDPROC
	

	PROCEDURE cLanguage_Assign
		LPARAMETERS tcLanguage

		IF EMPTY(tcLanguage)
			tcLanguage = PR_DEFAULTLANGUAGE
		ENDIF

		IF tcLanguage = "ESPANIOL"
			tcLanguage = "SPANISH"
		ENDIF

		IF (This.cLanguage == tcLanguage) AND (VARTYPE(This._oLang) = "O")
			* We have the same language, no need to update
			RETURN
		ENDIF

		This.cLanguage = UPPER(ALLTRIM(tcLanguage))
		This.SetLanguage(tcLanguage)
	ENDPROC


	PROCEDURE SetLanguage
		LPARAMETERS tcLanguage

		LOCAL lcDBFFile, lnSelect

		lnSelect = SELECT()
		lcDBFFile = "FoxyPreviewer_Locs.dbf"

		TRY 
			USE (lcDBFFile) IN 0 AGAIN SHARED
		CATCH
			This.SetError("Could not load the localizations table.")
		ENDTRY 
		SELECT (lcDBFFile)
	
		* populate the Collection of available languages
		IF VARTYPE(This._aLanguages) <> "O"
			This._aLanguages = CREATEOBJECT("Collection")
			This._aLangLocal = CREATEOBJECT("Collection")
			SCAN
				This._aLanguages.ADD(LANGUAGE)
				This._aLangLocal.ADD(LocalLang)
			ENDSCAN
		ENDIF

		LOCATE FOR tcLanguage $ UPPER(LANGUAGE + LocalLang)	&& Allows searching using the English language name or the local. Eg. "FRENCH / FRANÇAIS"

		IF EOF() && Could not locate the desired language
			This.SetError(_goHelper.GetLoc("LANGNOTFOU") + " - " + tcLanguage + CHR(13) +;
				"Make sure that the desired language is available in FoxyPreviewer_Locs.dbf")

			GO TOP
		ENDIF

		This._LangIndex = RECNO()
		This.cCodePage  = "CP"+	cCodePage	&& CodePage, to be used by PDF Listener			&&  <== 20100728 Modified by Nick Porfyris

		SCATTER NAME oLang
		This._oLang = oLang
		USE IN (lcDBFFile)
		SELECT (lnSelect)
	ENDPROC

	PROCEDURE SetError
		LPARAMETERS cErrMsg

		IF NOT EMPTY(cErrMsg)
			This.cErrors = This.cErrors + IIF(EMPTY(This.cErrors), "", CHR(13)+CHR(10)) + cErrMsg
		ENDIF

		IF NOT This.lSilent
			LOCAL lcErrCaption
			TRY
				lcErrCaption = This.GetLoc("ERROR")
			CATCH
				lcErrCaption = "ERROR"
			ENDTRY 
			lcErrCaption = lcErrCaption + SPACE(20) + "-" + SPACE(20) + TRANSFORM(_goHelper.cVersion)
			MESSAGEBOX(cErrMsg, 16, lcErrCaption)
		ENDIF
	ENDPROC


	PROCEDURE GetLoc
		LPARAMETERS tcString
		LOCAL lcTransl
		TRY
			lcTransl = TRIM(EVALUATE("This._oLang." + tcString))
		CATCH
		
			IF UPPER(tcString) = "ERROR"
				lcTransl = "** ERROR **"
			ELSE
				lcTransl = ""
				This.SetError("Could not locate the string '" + ;
					tcString + "' in the localizations table")
				SET STEP ON 
			ENDIF 
		ENDTRY 
		RETURN lcTransl
	ENDPROC

	PROCEDURE DESTROY

		LOCAL loParent AS CUSTOM
		loParent = This._oCaller
		IF VARTYPE(loParent) = "O"
			TRY 
				loParent.lSaved 	= This.lSaved
				loParent.lPrinted 	= This.lPrinted
				loParent.cDestFile 	= This.cDestFile
				loParent.lEmailed	= This.lEmailed
				loParent.cErrors	= This.cErrors
				loParent.nVersion   = This.nVersion
				loParent.cVersion   = This.cVersion
			CATCH TO loExc
				SET STEP ON 
				This.SetError("Error updating the caller class." + CHR(13) + ;
					"Check if the file FOXUPREVIEWERCALLER.PRG matches the APP version.")
			ENDTRY
		ENDIF

		This._oReport  = NULL
*		This.oListener = NULL

		This.ClearCache()

		* Just for safety, to ensure the helper object will not remain in memory
		RELEASE _goHelper
	ENDPROC



	PROCEDURE CloseSheets
		IF VARTYPE(This._oProofSheet) = "O"
			This._oProofSheet.RELEASE()
		ENDIF

		IF VARTYPE(This._oSettingsSheet) = "O"
			This._oSettingsSheet.RELEASE()
		ENDIF

	ENDPROC


	PROCEDURE AddReport(tcReport, tcClauses, tcAlias, tcName)
	* populates a collection object with the report files and clauses
	* This method can be called many times, providing an easy way to merge reports.
		IF EMPTY(tcName)
			tcName = tcReport
		ENDIF

		IF VARTYPE(This._oReports) <> "O"
			This._oReports = CREATEOBJECT("Collection")
			This._oClauses = CREATEOBJECT("Collection")
			This._oAliases = CREATEOBJECT("Collection")
			This._oNames = CREATEOBJECT("Collection")
		ENDIF
		This._oReports.ADD(tcReport)
		This._oClauses.ADD(EVL(tcClauses,""))
		This._oAliases.ADD(EVL(tcAlias,""))
		This._oNames.ADD(EVL(tcName,""))
	ENDPROC



	PROCEDURE CallReport(toListener AS REPORTLISTENER, tlKeepHandle)
	
		LOCAL lcReport, lcClauses, lcAlias, lcType, loListener AS REPORTLISTENER

		IF VARTYPE(toListener) = "O"
			loListener = toListener
		ELSE
			loListener = This.oListener
		ENDIF

		IF UPPER(ALLTRIM(SET("Printer", 3))) <> UPPER(This.cPrinterName)
			* MESSAGEBOX("Alterando Impressora para: " + This.cPrinterName)
			This.SetPrinter(This.cPrinterName)
		ENDIF

		* For the case of labels we'll not deal with merged reports
		IF LOWER(JUSTEXT(This._oReports(1))) = "lbx"
			loListener.PrintJobName = EVL(_goHelper._oNames(1), loListener.PrintJobName)

			lcReport = This._oReports(1)
			lcClauses = This._oClauses(1)
			lcAlias = This._oAliases(1)
			IF NOT EMPTY(lcAlias)
				SELECT (lcAlias)
			ENDIF
			LABEL FORM (lcReport) OBJECT loListener &lcClauses.
		ELSE
			LOCAL lcUser, N, lnCount
			lnCount = This._oReports.COUNT

			FOR N = 1 TO lnCount

				loListener.PrintJobName = JUSTSTEM(EVL(_goHelper._oNames(n), loListener.PrintJobName))

				_goHelper._nIndex = n
				lcType = LOWER(JUSTEXT(This._oReports(N)))

				DO CASE
				CASE lnCount = 1 OR lnCount = N
					lcUser = ""
				OTHERWISE
					lcUser = "NOPAGEEJECT" && + " NORESET"
				ENDCASE
				lcReport = This._oReports(N)
				lcClauses = This._oClauses(N)

				lcAlias = This._oAliases(N)
				IF NOT EMPTY(lcAlias)
					SELECT (lcAlias)
				ENDIF

				IF tlKeepHandle
					IF N = lnCount
						loListener.WaitForNextReport = .F. && last report, allow closing
					ELSE
						loListener.WaitForNextReport = .T.
					ENDIF
				ENDIF

				IF NOT FILE(FORCEEXT(lcReport, "FRX"))
					This.SetError(_goHelper.GetLoc("REPNOTFOUN") + ": " + lcReport)
					RETURN 
				ENDIF

				IF ((NOT This.lUseListener) AND This._lSendToPrinter) ;
						OR (_goHelper._lIsDotMatrix)
					SET REPORTBEHAVIOR 80
					lcClauses = CleanClauses(lcClauses)

					IF lcType = "lbx"
						LABEL FORM (lcReport) &lcClauses. &lcUser. TO PRINTER NOCONSOLE
					ELSE
						REPORT FORM (lcReport) &lcClauses. &lcUser. TO PRINTER NOCONSOLE
					ENDIF
				ELSE

					IF lcType = "lbx"
						LABEL FORM (lcReport) OBJECT loListener &lcClauses. &lcUser.
					ELSE
						REPORT FORM (lcReport) OBJECT loListener &lcClauses. &lcUser.
					ENDIF

				ENDIF

			ENDFOR
		ENDIF
	ENDPROC


	PROCEDURE RestorePrinter
		WITH THIS
			IF UPPER(._cOriginalPrinter) <> UPPER(SET("Printer",3)) && Current printer
				.SetPrinter(._cOriginalPrinter)
			ENDIF
		ENDWITH
	ENDPROC


	PROCEDURE RunReport(toParent)
		IF APRINTERS(gaPrinters) = 0
			This.SetError(This.GetLoc("ERRNOPRINTER"))
			RETURN .F.
		ENDIF


		WITH THIS
			.lPrinted = .F.
			._oCaller = toParent

			IF VARTYPE(.oListener) <> "O"
				* Create a PREVIEW listener
				TRY
				
					LOCAL lcListenerClass
					IF This.lExtended
						lcListenerClass = This.cDefaultListener
					ELSE 
						lcListenerClass = MAIN_LISTENER
					ENDIF 
					
					IF _VFP.StartMode = 0
						.oListener = NEWOBJECT(lcListenerClass, GetCurPath() + "PR_ReportListener.vcx")
					ELSE 
						TRY 
							.oListener = NEWOBJECT(lcListenerClass, "PR_ReportListener.vcx")
						CATCH 
							.oListener = NEWOBJECT(lcListenerClass, "PR_ReportListener.vcx", This.ClassLibrary)
						ENDTRY 
					
					ENDIF 
					
					TRY 
						.oListener.fxFeedbackClass = _goHelper._cThermClass
					CATCH
					ENDTRY 
	
					TRY 
						LOCAL lcSuccessor
						lcSuccessor = ALLTRIM(UPPER(.cSuccessor))
						IF NOT INLIST(lcSuccessor, "REPORTLISTENER", "_REPORTLISTENER", ;
							"FXLISTENER", "DBFLISTENER", "FULLJUSTIFYLISTENER", "FOXYLISTENER", ;
							MAIN_LISTENER)
							.oListener.Successor = CREATEOBJECT(.cSuccessor)
						ENDIF 
					CATCH
					ENDTRY 

				CATCH TO loExc 
					* LOCAL loExc as Exception 

					lcMsg = "SYS(16) : " + SYS(16) + CHR(13) + ;
					"GetCurPath() : " + GetCurPath() + CHR(13) + ;
					"File('PR_ReportListener.vcx') : " + TRANSFORM(File('PR_ReportListener.vcx')) + ;
					"This.ClassLibrary : " + This.ClassLibrary

					MESSAGEBOX("Error loading FoxyListener!" + CHR(13) + ;
						TRANSFORM(loExc.ERRORNO) + " - " + loExc.MESSAGE + CHR(13) + ;
						"Line: " + TRANSFORM(loExc.LINENO) + " - " + loExc.LINECONTENTS + CHR(13) + CHR(13) + ;
						lcMsg)
				
					.oListener = NEWOBJECT('FXLISTENER', "PR_ReportListener.vcx")
				ENDTRY
			ENDIF



			IF This.lDirectPrint
				This.oListener.OutputType = 0 && Send to Printer
				IF PEMSTATUS(This.oListener, "lStoreData", 5) 
					This.oListener.lStoreData = .F. && no need to generate the coordinates table
									&& used in the Search feature
				ENDIF 
				This.DoOutput()
				RETURN
			ENDIF 


			* Update the language setting if needed
			IF VARTYPE(This._oLang) <> "O"
				This.SetLanguage(This.cLanguage)
			ENDIF

			IF EMPTY(This.cDestFile)

				TRY
				    DO (_REPORTOUTPUT) WITH 3, .oListener
				CATCH
				    TRY
				        DO (ADDBS(HOME()) + "ReportOutput.App") WITH 3, .oListener
				    CATCH
				    	LOCAL lcOutputFile
				    	lcOutputFile = "ReportOutput.App"
				        DO (lcOutputFile) WITH 3, .oListener
				    ENDTRY
				ENDTRY

				.oListener.LISTENERTYPE = 1 && Preview

				LOCAL loPreviewContainer
				loPreviewContainer = NULL

				TRY
					DO ("ReportPreview.App") WITH loPreviewContainer
				CATCH
					DO HOME() + "ReportPreview.App" WITH loPreviewContainer
				ENDTRY

				* Create an extension handler and hook it to the
				* preview container. This will let you manipulate
				* properties of the container and its Preview toolbar
				LOCAL loExHandler AS ExtensionHandler OF SYS(16)
				loExHandler = NEWOBJECT('ExtensionHandler')
				loPreviewContainer.SetExtensionHandler(loExHandler)
				_goHelper._oExHandler = loExHandler

				loPreviewContainer.ZoomLevel = _goHelper.nZoomLevel
				loPreviewContainer.CanvasCount = _goHelper.nCanvasCount

				* Link the Listener and preview container
				.oListener.PREVIEWCONTAINER = loPreviewContainer

				* Run the report
				.CallReport()
			ENDIF
			IF NOT _goHelper._lNoWait
				This.DoOutput()
			ENDIF

			TRY
				.oListener.PREVIEWCONTAINER = NULL
			CATCH
			ENDTRY

		ENDWITH

	ENDPROC


	PROCEDURE DoOutput
		LPARAMETERS tlEmail

		WITH THIS
			LOCAL lcFileFormat
			lcFileFormat = ""

			* Prepare the output file
			IF NOT EMPTY(.cDestFile) AND NOT .lSaved
				.lSaveToFile = .T.
				lcFileFormat = LOWER(JUSTEXT(.cDestFile))

				* 1st step, try to delete a file with the same name
				TRY
					ERASE (.cDestFile)
				CATCH
				ENDTRY

			ENDIF

		ENDWITH

		DO CASE
		CASE This.lSaved

		CASE lcFileFormat = "pdf"
			* Using PDFx - by Luis Navas

			LOCAL lnType
			lnType = IIF(_goHelper.lPDFasImage, 2, 1)
				&& 1 = normal PDF, 2 = Image
			IF lnType = 1 THEN && Normal Pdf
				LOCAL loListener AS "PdfListener" OF "PR_Pdfx.vcx"
				loListener = NEWOBJECT('PdfListener', 'PR_PDFx.vcx')
				loListener.cCodePage = _goHelper.cCodePage &&CodePage
			ELSE &&PDF As Image
				LOCAL loListener AS "PDFasImageListener" OF "PR_Pdfx.vcx"
				loListener = NEWOBJECT('PDFasImageListener', 'PR_PDFx.vcx')
			ENDIF

			loListener.cTargetFileName = ALLTRIM(This.cDestFile)
			loListener.QUIETMODE   = _goHelper.lQuietMode
			loListener.fxFeedbackClass = _goHelper._cThermClass

			loListener.lCanPrint   = .T.
			loListener.lCanEdit    = .T.
			loListener.lCanCopy    = .T.
			loListener.lCanAddNotes= .T.
			loListener.lEncryptDocument = .F.
			loListener.cMasterPassword  = ""
			loListener.cUserPassword    = ""
			loListener.lOpenViewer      = .F.
			* by Luis Navas - To be Developed, not ready yet
			* loListener.MergeDocument=.MergeDocument.Value
			* loListener.MergeDocumentName=.MergeFileName.Value
			loListener.nPageMode = _goHelper.nPDFPageMode

			DEFINE WINDOW Window_HTML FROM 04,05 TO 27,75
			ACTIVATE WINDOW Window_HTML NOSHOW

			IF _goHelper.lExtended		
				This.CallReport(loListener, .T.) && flag to keep opened till last report
			ELSE && Generate PDF from the offline table
				LOCAL lcFullOutputAlias, lnWidth, lnHeight
				lcFullOutputAlias = _goHelper.oListener.GetFullFRXData()
				lnWidth  = _goHelper.oListener.GETPAGEWIDTH()
				lnHeight = _goHelper.oListener.GETPAGEHEIGHT()
				loListener.OutputFromData(_goHelper.oListener, lcFullOutputAlias, lnWidth, lnHeight)
			ENDIF 

			loListener = NULL

			RELEASE WINDOWS Window_HTML

			IF NOT FILE(This.cDestFile)
				This.SetError(_goHelper.GetLoc("ERR_CREATI"))
			ELSE
				This.lSaved = .T.
			ENDIF


		CASE INLIST(lcFileFormat, "htm", "html")

			* loListener2 = NewObject("UtilityReportListener", "PR_ReportListener.vcx")
			* loListener2.ListenerType = 5
			* loListener2.TargetFileName = This.cDestFile
			* This.CallReport(loListener2)
			* loListener2 = NULL

			* See if the MSXML4 component is installed
			LOCAL llError, loTestXML4
			llError = .F.
			TRY 
				loTestXML4  = CREATEOBJECT("MSXML2.XSLTEMPLATE.4.0")
			CATCH
				llError = .T.
				This.SetError(_goHelper.GetLoc("ERR_CREATI") + CHR(13) + "The MSXML4.0 library could not be loaded. Please check if it was properly installed.")
			ENDTRY 
			loTestXML4 = NULL

			IF NOT llError
				DEFINE WINDOW Window_HTML FROM 04,05 TO 27,75
				ACTIVATE WINDOW Window_HTML NOSHOW

				LOCAL loListener AS "HTMLListener" && OF HOME() + "FFC/PR_ReportListener.vcx"
				loListener = NEWOBJECT("PR_HTMLListener", "PR_ReportListener.vcx")
				loListener.TargetFileName = This.cDestFile
				loListener.QUIETMODE = _goHelper.lQuietMode
				loListener.fxFeedbackClass = _goHelper._cThermClass


				* Run the report
				This.CallReport(loListener)
				loListener = NULL

				RELEASE WINDOWS Window_HTML

				IF NOT FILE(This.cDestFile)
					This.SetError(_goHelper.GetLoc("ERR_CREATI"))
				ELSE
					This.lSaved = .T.
				ENDIF
			ENDIF 

		CASE INLIST(lcFileFormat, "rtf", "doc")
			* Using fixed and updated RTFListener by Vladimir Zhuravlev

			loRtfListener = NEWOBJECT("RTFreportlistener", "PR_RTFListener")
			loRtfListener.TargetFileName = This.cDestFile
			loRtfListener.fxFeedbackClass = _goHelper._cThermClass

			IF _goHelper.lExtended		
				This.CallReport(loRtfListener, .T.) && flag to keep opened till last report
			ELSE && Generate PDF from the offline table
				LOCAL lcOutputAlias, lnWidth, lnHeight
				lcOutputAlias = _goHelper.oListener.GetFullFRXData()
				lnWidth  = _goHelper.oListener.GETPAGEWIDTH()
				lnHeight = _goHelper.oListener.GETPAGEHEIGHT()
				loListener.OutputFromData(_goHelper.oListener, lcOutputAlias, lnWidth, lnHeight)
			ENDIF 

			loRtfListener = NULL

			IF NOT FILE(This.cDestFile)
				This.SetError(_goHelper.GetLoc("ERR_CREATI"))
			ELSE
				This.lSaved = .T.
			ENDIF


		CASE INLIST(lcFileFormat, "xls", "xml")
			LOCAL loReportListener AS "ExcelListener" && OF HOME() + "FFC/PR_ReportListener.vcx"
			loReportListener = NEWOBJECT("ExcelListener","pr_ExcelListener.vcx")
			loReportListener.LISTENERTYPE = 3	&& ?
			loReportListener.lOutputToCursor = .T.
			loReportListener.cWorkbookFile	= This.cDestFile
			loReportListener.cWorksheetName = "Sheet"
			loReportListener.QUIETMODE = _goHelper.lQuietMode
			loReportListener.fxFeedbackClass = _goHelper._cThermClass

			This.CallReport(loReportListener, .F.) && flag to keep opened till last report
			loReportListener = NULL

			IF NOT FILE(This.cDestFile)
				This.SetError(_goHelper.GetLoc("ERR_CREATI"))
			ELSE
				This.lSaved = .T.
			ENDIF


		CASE INLIST(lcFileFormat, "txt") && 11/08/2010 by mauriciobraga@ig.com.br

			SET REPORTBEHAVIOR 80
			* _ASCIIROWS = nLines
			* _ASCIICOLS = nChars
			REPORT FORM (This._oReports(1)) TO FILE (This.cDestFile) ASCII
			SET REPORTBEHAVIOR 90

			IF NOT FILE(This.cDestFile)
				This.SetError(_goHelper.GetLoc("ERR_CREATI"))
			ELSE
				This.lSaved = .T.
			ENDIF


		CASE INLIST(lcFileFormat, "csv", "xl5") && 11/08/2010 by mauriciobraga@ig.com.br

			* Adjust xl5 format to XLS
			IF lcFileFormat = "xl5"
				This.cDestFile = FORCEEXT(This.cDestFile, "xls")
			ENDIF

			LOCAL loReportListener AS REPORTLISTENER
			loReportListener = CREATEOBJECT("ExportListener")
			loReportListener.cDestFile = This.cDestFile

			REPORT FORM (This._oReports(1)) OBJECT loReportListener
			loReportListener = NULL

			IF NOT FILE(This.cDestFile)
				This.SetError(_goHelper.GetLoc("ERR_CREATI"))
			ELSE
				This.lSaved = .T.
			ENDIF


		CASE This.lDirectPrint

			* MESSAGEBOX("Default: " + This._cOriginalPrinter + CHR(13) + ;
				"Selected: " + This.cPrinterName)

			FOR N = 1 TO This.nCopies
				This.CallReport()
			ENDFOR
			This.lPrinted = .T.
			This.RestorePrinter()


		CASE This._lSendToPrinter

			TRY
				IF _VFP.StartMode = 0
					loListener = NEWOBJECT(MAIN_LISTENER, GetCurPath() + "PR_ReportListener.vcx")
				ELSE 
					TRY 
						loListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx")
					CATCH 
						loListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx", This.ClassLibrary)
					ENDTRY 
				ENDIF 
				loListener.fxFeedbackClass = _goHelper._cThermClass

				TRY 
					LOCAL lcSuccessor
					lcSuccessor = ALLTRIM(UPPER(.cDefaultListener))
					IF NOT INLIST(lcSuccessor, "REPORTLISTENER", "_REPORTLISTENER", ;
						"FXLISTENER", "DBFLISTENER", "FULLJUSTIFYLISTENER", "FOXYLISTENER", ;
						MAIN_LISTENER)
						loListener.Successor = CREATEOBJECT(This.cDefaultListener)
					ENDIF
				CATCH TO loExc
					SET STEP ON 
					loListener = NEWOBJECT('FXLISTENER', "PR_ReportListener.vcx")
				ENDTRY 

*!*					LOCAL loListener AS REPORTLISTENER
*!*					TRY
*!*						loListener = CREATEOBJECT(This.cDefaultListener)
*!*						* loListener = NEWOBJECT('FXLISTENER', "PR_ReportListener.vcx")
*!*					CATCH
*!*						loListener = NEWOBJECT('FXLISTENER', "PR_ReportListener.vcx")
*!*						* loListener = CREATEOBJECT("ReportListener")
*!*					ENDTRY
				loListener.LISTENERTYPE = 0 && Printer Output
				loListener.QUIETMODE = _goHelper.lQuietMode

*!*				IF _goHelper._ClausenPrintRangeFrom > 0
*!*					loListener.CommandClauses.PrintRangeFrom = _goHelper._ClausenPrintRangeFrom
*!*					loListener.CommandClauses.PrintRangeTo   = _goHelper._ClausenPrintRangeTo
*!*				ENDIF

				FOR N = 1 TO This.nCopies
					This.CallReport(loListener)
				ENDFOR

				This.lPrinted = .T.
				This.RestorePrinter()

			CATCH TO loException
				SET STEP ON 
			ENDTRY

		OTHERWISE

		ENDCASE

		IF _goHelper._lSendingEmail = .T.
			This.SendReportToEmail()
		ENDIF 

		* Restore the default directory
		SET DEFAULT TO (_goHelper._cDefaultFolder)

		This.ReportReleased()

	ENDPROC


PROCEDURE SendReportToEmail
	
		IF NOT FILE(This.cDestFile)
			This.SetError(_goHelper.GetLoc("ERR_CREATI"))
		ELSE

*!*	LOCAL hWindow, lcDelimiter, lcFiles, lcMsgSubj
*!*	hWindow = PR_GetActiveWindow()
*!*	lcDelimiter = ";"
*!*	lcMsgSubj = JUSTFNAME(This.cDestFile)
*!*	=PR_MAPISendDocuments (hWindow, lcDelimiter, (This.cDestFile), lcMsgSubj, 0)

*!*	IF EMPTY(This.cEmailPRG)
*!*		=SendMailEx(This.cDestFile)
*!*	ELSE
*!*		DO (This.cEmailPRG) WITH (This.cDestFile)
*!*	ENDIF

* nEmailMode && 1 = MAPI, 2 = CDOSYS, 3 = Custom procedure
			_goHelper.lEmailed = .T.

			TRY
				DO CASE
				CASE _goHelper.nEmailMode = 1 && MAPI
					=SendMailEx(This.cDestFile)	&&, This.lAutoSendMail
				CASE _goHelper.nEmailMode = 2 && CDOSYS
					DO SendCDOMail WITH (This.cDestFile), This.lAutoSendMail
				CASE _goHelper.nEmailMode = 3 AND (NOT EMPTY(This.cEmailPRG))&& Custom Procedure
					DO (This.cEmailPRG) WITH (This.cDestFile)	&&, This.lAutoSendMail

				OTHERWISE
					This.SetError(_goHelper.GetLoc("BADCONFIG"))
					_goHelper.lEmailed = .F.

				ENDCASE
			CATCH TO loMailEx
				_goHelper.lEmailed = .F.
			ENDTRY


*	lEmailAuto = .T. && Automatically generates the report output file
*	cEmailType = "PDF" && The file type to be used in Emails (PDF, RTF, HTML or XLS)
			IF _goHelper.lEmailAuto
				TRY
					DELETE FILE (This.cDestFile)
				CATCH
				ENDTRY
				_goHelper.lSaved = .F.
			ENDIF
		ENDIF
ENDPROC 



	PROCEDURE ReportReleased(toExt)

		TRY 
			This.oListener.EraseTempFiles()
			This.oListener = NULL
		CATCH 
		ENDTRY 


		UNBINDEVENTS(THIS)
		DOEVENTS
		IF VARTYPE(toExt) = "O"
			toExt = NULL
		ENDIF

		* if changed, restore the printer to the original
		IF UPPER(This._cOriginalPrinter) <> UPPER(This.cPrinterName)
			This.SetPrinter(This._cOriginalPrinter)
		ENDIF

		This.CloseSheets()

		* Restore the default folder if needed
		IF (VARTYPE(_goHelper) = "O") AND (SET("Default") + SYS(2003)) <> _goHelper._cDefaultFolder
			SET DEFAULT TO (_goHelper._cDefaultFolder)
		ENDIF
		This.ClearCache()

		RELEASE _goHelper

	ENDPROC


	PROCEDURE ClearCache
		* Trying to clear the report preview cache
		* If there is another Preview factory, disable it
		* http://spacefold.com/colin/archive/articles/reportpreview/rp_extend.html

		LOCAL lcFile
		lcFile = _REPORTPREVIEW

		TRY
			_oReportOutput["1"].PREVIEWCONTAINER = .NULL.
			* _oReportOutput.Remove("1")
		CATCH TO loExc
			* LOCAL loexc as Exception
			* MESSAGEBOX("Error: " + TRANSFORM(loexc.ErrorNo) + " - " + loexc.Message, 16, "Error")
		ENDTRY

		TRY
			RELEASE WINDOWS Window_Dummy
		CATCH
		ENDTRY


		* Prepare the new Report preview factory
		_REPORTPREVIEW = lcFile
		SET REPORTBEHAVIOR 90
	ENDPROC


	PROCEDURE SetPrinter(tcPrinterName)
		LOCAL lcPrinter, llReturn
		llReturn  = .T.
		lcPrinter = tcPrinterName
		LOCAL loExc as Exception 
		TRY
			SET PRINTER TO NAME '&lcPrinter'
		CATCH TO loExc
			SET STEP ON 
			This.SetError("Could not change the current printer." + CHR(13) + ;
				"Current Printer: " + SET("Printer", 3) + CHR(13) + ;
				"Failed Printer: " + tcPrinterName)
			llReturn = .F.
		ENDTRY
		RETURN llReturn
	ENDPROC
ENDDEFINE


*-------------------------
DEFINE CLASS ExtensionHandler AS CUSTOM
*-- Ref to the Preview Container's Preview Form
	PreviewForm    = NULL
	lHighlightText = .F.

	IMGBTN_PREV		 = "pr_previous.bmp"
	IMGBTN_NEXT		 = "pr_next.bmp"
	IMGBTN_TOP		 = "pr_top.bmp"
	IMGBTN_BOTT		 = "pr_bottom.bmp"
	IMGBTN_MINI		 = "pr_Locate.bmp"
	IMGBTN_PRINT	 = "pr_Print.bmp"
	IMGBTN_PRINTPREF = "pr_PrintPref.bmp"
	IMGBTN_GOTOPG	 = "pr_gotopage.bmp"
	IMGBTN_1PG		 = "pr_1page.bmp"
	IMGBTN_2PG		 = "pr_2page.bmp"
	IMGBTN_4PG		 = "pr_4page.bmp"
	IMGBTN_CLOSE	 = "pr_close.bmp"
	IMGBTN_CLOSE2	 = "pr_close2.bmp"
	IMGBTN_SAVE		 = "pr_Save.bmp"
	IMGBTN_EMAIL	 = "pr_Mail.bmp"
	IMGBTN_SETUP	 = "pr_Gear.bmp"
	IMGBTN_SEARCH	 = "pr_Search.bmp"
	IMGBTN_SEARCHAGAIN = "pr_SearchAgain.bmp"
	IMGBTN_SEARCHBACK  = "pr_SearchBack.bmp"


	PROCEDURE STB_Handler(lEnabled)
* Here you work around the setting
* persistence problem in the Preview toolbar.
* The Preview toolbar class (frxpreviewtoolbar)
* already has code that you can use to enforce
* setting's persistence; it is just not called. Here,
* you call it.
		WITH This.PreviewForm.TOOLBAR
			.REFRESH()
* When you call frxpreviewtoolbar::REFRESH(), the
* toolbar caption is set to its Preview form,
* which differs from typical behavior. You must revert that
* to be consistent. If you did not do this,
* you would see " - Page 2" appended to the toolbar
* caption if you skipped pages.
			.CAPTION = This.PreviewForm.formCaption
		ENDWITH
	ENDPROC


	PROCEDURE AddBarsToMenu( cPopup, iNextBar )
* RELEASE BAR 8 OF (m.cPopup)

		DEFINE BAR 1 OF (m.cPopup) PROMPT _goHelper.GetLoc("MENUTOP")   PICTURE This.IMGBTN_TOP
		DEFINE BAR 2 OF (m.cPopup) PROMPT _goHelper.GetLoc("MENUPREV")  PICTURE This.IMGBTN_PREV
		DEFINE BAR 3 OF (m.cPopup) PROMPT _goHelper.GetLoc("MENUNEXT")  PICTURE This.IMGBTN_NEXT
		DEFINE BAR 4 OF (m.cPopup) PROMPT _goHelper.GetLoc("MENULAST")  PICTURE This.IMGBTN_BOTT
		DEFINE BAR 5 OF (m.cPopup) PROMPT _goHelper.GetLoc("MENUGOTO")  PICTURE This.IMGBTN_GOTOPG
		DEFINE BAR 8 OF (m.cPopup) PROMPT _goHelper.GetLoc("MENUSHOWPA")
		DEFINE BAR 10 OF (m.cPopup) PROMPT _goHelper.GetLoc("MENUTOOLB")
		DEFINE BAR 13 OF (m.cPopup) PROMPT _goHelper.GetLoc("MENUCLOSE")  PICTURE This.IMGBTN_CLOSE


		IF NOT EMPTY(_goHelper.GetLoc("CBOZOOMTTI"))
			DEFINE BAR 7 OF (m.cPopup) PROMPT _goHelper.GetLoc("CBOZOOMTTI")
		ENDIF


		ON SELECTION BAR 5 OF (m.cPopup) ;
			oRef.ExtensionHandler.ActionGotoPage()

		ON SELECTION BAR 13 OF (m.cPopup) ;
			oRef.ExtensionHandler.ActionClose()

		ON SELECTION BAR 10 OF (m.cPopup) oRef.ExtensionHandler.actionToolbarVisibility()

		IF _goHelper.lPrintVisible

			DEFINE BAR 15 ;
				OF (m.cPopup) ;
				PROMPT _goHelper.GetLoc("MENUPRINT") ;
				PICTURE This.IMGBTN_PRINT

			ON SELECTION BAR 15 OF (m.cPopup) ;
				oRef.ExtensionHandler.ActionPrintEx()

			* Printing preferences item
			IF _goHelper.lPrinterPref
				LOCAL lcImgPrintPref
				lcImgPrintPref = This.IMGBTN_PRINTPREF
				DEFINE BAR 16 ;
					OF (m.cPopup) ;
					PROMPT _goHelper.GetLoc("PRINTINGPR") PICTURE lcImgPrintPref

				ON SELECTION BAR 16 OF (m.cPopup) ;
					oRef.ExtensionHandler.DoCustomPrint()
			ENDIF


			* Save to file item
			IF _goHelper.lSaveToFile
				DEFINE BAR 17 ;
					OF (m.cPopup) ;
					PROMPT _goHelper.GetLoc("SAVEREPORT") ;
					PICTURE This.IMGBTN_SAVE

				LOCAL lcSaveMenu
				lcSaveMenu = SYS(2015)

				DEFINE POPUP (m.lcSaveMenu) SHORTCUT RELATIVE

				IF NOT _goHelper.lExtended && Original report


					* If the report is "Searchable", show the submenu
					* Otherwise, allow only to save as image
					IF _goHelper._lCanSearch
						ON BAR 17 OF (m.cPopup) ACTIVATE POPUP &lcSaveMenu.

						IF _goHelper.lSaveAsImage
							DEFINE BAR 1 OF (lcSaveMenu) PROMPT _goHelper.GetLoc("SAVEASIMAG") PICTURE "pr_Img.bmp"
							ON SELECTION BAR 1 OF (lcSaveMenu) oRef.ExtensionHandler.DoSaveType(1)
						ENDIF

						IF _goHelper.lSaveAsPDF
							DEFINE BAR 2 OF (lcSaveMenu) PROMPT _goHelper.GetLoc("SAVEASPDF")  PICTURE "pr_Pdf.bmp"
							ON SELECTION BAR 2 OF (lcSaveMenu) oRef.ExtensionHandler.DoSaveType(2)
						ENDIF
						IF _goHelper.lSaveAsRTF
							DEFINE BAR 4 OF (lcSaveMenu) PROMPT _goHelper.GetLoc("SAVEASRTF")  PICTURE "pr_Word.bmp"
							ON SELECTION BAR 4 OF (lcSaveMenu) oRef.ExtensionHandler.DoSaveType(4)
						ENDIF
						IF _goHelper.lSaveAsXLS
							DEFINE BAR 5 OF (lcSaveMenu) PROMPT _goHelper.GetLoc("SAVEASXLS")  PICTURE "pr_Excel.bmp"
							ON SELECTION BAR 5 OF (lcSaveMenu) oRef.ExtensionHandler.DoSaveType(5)
						ENDIF

					ELSE 
						ON SELECTION BAR 17 OF (m.cPopup) ;
								oRef.ExtensionHandler.DoSaveType(1)
					ENDIF 
				ELSE

					ON BAR 17 OF (m.cPopup) ACTIVATE POPUP &lcSaveMenu.

					IF _goHelper.lSaveAsImage
						DEFINE BAR 1 OF (lcSaveMenu) PROMPT _goHelper.GetLoc("SAVEASIMAG") PICTURE "pr_Img.bmp"
						ON SELECTION BAR 1 OF (lcSaveMenu) oRef.ExtensionHandler.DoSaveType(1)
					ENDIF
					IF _goHelper.lSaveAsPDF
						DEFINE BAR 2 OF (lcSaveMenu) PROMPT _goHelper.GetLoc("SAVEASPDF")  PICTURE "pr_Pdf.bmp"
						ON SELECTION BAR 2 OF (lcSaveMenu) oRef.ExtensionHandler.DoSaveType(2)
					ENDIF
					IF _goHelper.lSaveAsHTML
						DEFINE BAR 3 OF (lcSaveMenu) PROMPT _goHelper.GetLoc("SAVEASHTML") PICTURE "pr_Html.bmp"
						ON SELECTION BAR 3 OF (lcSaveMenu) oRef.ExtensionHandler.DoSaveType(3)
					ENDIF
					IF _goHelper.lSaveAsRTF
						DEFINE BAR 4 OF (lcSaveMenu) PROMPT _goHelper.GetLoc("SAVEASRTF")  PICTURE "pr_Word.bmp"
						ON SELECTION BAR 4 OF (lcSaveMenu) oRef.ExtensionHandler.DoSaveType(4)
					ENDIF
					IF _goHelper.lSaveAsXLS
						DEFINE BAR 5 OF (lcSaveMenu) PROMPT _goHelper.GetLoc("SAVEASXLS")  PICTURE "pr_Excel.bmp"
						ON SELECTION BAR 5 OF (lcSaveMenu) oRef.ExtensionHandler.DoSaveType(5)
					ENDIF

					IF _goHelper.lSaveasTXT && Create menu option Save as TXT && 11/08/2010 by mauriciobraga@ig.com.br
						DEFINE BAR 6 OF (lcSaveMenu) PROMPT _goHelper.GetLoc("SAVEASTXT")  PICTURE "pr_1page.bmp"
						ON SELECTION BAR 6 OF (lcSaveMenu) oRef.ExtensionHandler.DoSaveType(6)
					ENDIF
				ENDIF

			ENDIF
		ENDIF


		* Show the Send to email item
		IF _goHelper.lSendToEmail
*			DEFINE BAR 22 OF (m.cPopup) PROMPT '\-'

			DEFINE BAR 19 ;
				OF (m.cPopup) ;
				PROMPT _goHelper.GetLoc("SENDTOEMAI") ;
				PICTURE This.IMGBTN_EMAIL

			ON SELECTION BAR 19 OF (m.cPopup) ;
				oRef.ExtensionHandler.DoSendEmail()
		ENDIF 



		* Show miniatures
		IF _goHelper.lShowMiniatures
			DEFINE BAR 20 OF (m.cPopup) PROMPT '\-'

			DEFINE BAR 21 ;
				OF (m.cPopup) ;
				PROMPT _goHelper.GetLoc("MENUPROOF") ;
				PICTURE This.IMGBTN_MINI

			* It is a documented fact that, at the time
			* the popup is activated, there is an object
			* reference to the PreviewContainer instance
			* in scope in a variable called "oRef":
			ON SELECTION BAR 21 OF (m.cPopup) ;
				oRef.ExtensionHandler.DoProof()
		ENDIF


		* Show Search buttons
		IF _goHelper._lCanSearch AND _goHelper.lShowSearch
		
			IF NOT _goHelper.lShowMiniatures
				DEFINE BAR 24 OF (m.cPopup) PROMPT '\-'
			ENDIF 

			DEFINE BAR 25 ;
				OF (m.cPopup) ;
				PROMPT _goHelper.GetLoc("FIND") ;
				PICTURE This.IMGBTN_SEARCH

			ON SELECTION BAR 25 OF (m.cPopup) ;
				oRef.ExtensionHandler.DoSearch()


			IF _goHelper._lShowSearchAgain
				DEFINE BAR 26 ;
					OF (m.cPopup) ;
					PROMPT _goHelper.GetLoc("FINDBACK") ;
					PICTURE This.IMGBTN_SEARCHBACK

				DEFINE BAR 27 ;
					OF (m.cPopup) ;
					PROMPT _goHelper.GetLoc("FINDNEXT") ;
					PICTURE This.IMGBTN_SEARCHAGAIN

				ON SELECTION BAR 26 OF (m.cPopup) ;
					oRef.ExtensionHandler.DoSearchBack()

				ON SELECTION BAR 27 OF (m.cPopup) ;
					oRef.ExtensionHandler.DoSearchAgain()
			ENDIF 

		ENDIF


		* Show Setup
		IF _goHelper.lShowSetup
			DEFINE BAR 22 OF (m.cPopup) PROMPT '\-'

			DEFINE BAR 23 ;
				OF (m.cPopup) ;
				PROMPT _goHelper.GetLoc("SETUP") ;
				PICTURE This.IMGBTN_SETUP

			ON SELECTION BAR 23 OF (m.cPopup) ;
				oRef.ExtensionHandler.DoSetup()
		ENDIF


*** Teste
*!*			DEFINE BAR 30 ;
*!*					OF (m.cPopup) ;
*!*					PROMPT "Teste cursor"
*!*			ON SELECTION BAR 30 OF (m.cPopup) ;
*!*					oRef.ExtensionHandler.DoTeste()




		* Translating the Zoom and Page menu items for non English users
		IF UPPER(_goHelper.GetLoc("LANGUAGE")) <> "ENGLISH"

			PRIVATE lcZoom2, lcPages2
			lcZoom2  = SYS(2015)
			lcPages2 = SYS(2015)
			ON BAR 7 OF (m.cPopup) ACTIVATE POPUP &lcZoom2
			ON BAR 8 OF (m.cPopup) ACTIVATE POPUP &lcPages2

*------------------------------------------------------
* Define the Zoom popup:
* slightly adapted from the Report Preview project
* the author of this piece of code is MS, (Lisa Slater Nicholls)
* code extracted from the XSource.Zip file
*------------------------------------------------------
			DEFINE POPUP (m.lcZoom2) SHORTCUT RELATIVE

* Loop through all the array items, in case user is using a modified
* context menu (Joao Batista)
* oRef.ZoomLevels(10,1) = PR_CBOZOOMWHO
* oRef.ZoomLevels(11,1) = PR_CBOZOOMPGW

			LOCAL lcItem, i
			FOR i = 1 TO ALEN(oRef.ZoomLevels, 1) && Rows
				lcItem = LOWER(oRef.ZoomLevels(i, 1))
				IF (lcItem = "whole page") OR (i = 10)
					oRef.ZoomLevels(i, 1) = _goHelper.GetLoc("CBOZOOMWHO")
				ENDIF
				IF (lcItem = "fit to width") OR (i = 11)
					oRef.ZoomLevels(i, 1) = _goHelper.GetLoc("CBOZOOMPGW")
				ENDIF
			ENDFOR

			FOR i = 1 TO ALEN(oRef.ZoomLevels,1)
				DEFINE BAR m.i OF(m.lcZoom2) PROMPT oRef.ZoomLevels[m.i,1] && ZOOM_LEVEL_PROMPT
				ON SELECTION BAR m.i OF (m.lcZoom2) oRef.actionSetZoom( BAR() )
			ENDFOR
			* Set the mark:
			SET MARK OF BAR (oRef.ZoomLevel) OF (m.lcZoom2) TO .T.


			*------------------------------------------------------
			* Define the Page Count popup:
			*------------------------------------------------------
			DEFINE POPUP (m.lcPages2) SHORTCUT RELATIVE
			DEFINE BAR 1 OF (m.lcPages2) PROMPT _goHelper.GetLoc("ONEPGMENU")

			* Disable multi-page view for high zoom levels:
			LOCAL iPagesAllowed
			iPagesAllowed = oRef.ZoomLevels[ oRef.zoomLevel, 3 ] && ZOOM_LEVEL_CANVAS

			IF m.iPagesAllowed > 1
				DEFINE BAR 2 OF (m.lcPages2) PROMPT _goHelper.GetLoc("TWOPGMENU")
			ELSE
				DEFINE BAR 2 OF (m.lcPages2) PROMPT "\" + _goHelper.GetLoc("TWOPGMENU")
			ENDIF
			IF m.iPagesAllowed > 2
				DEFINE BAR 3 OF (m.lcPages2) PROMPT _goHelper.GetLoc("FOURPGMENU")
			ELSE
				DEFINE BAR 3 OF (m.lcPages2) PROMPT "\" + _goHelper.GetLoc("FOURPGMENU")
			ENDIF

			ON SELECTION BAR 1 OF (m.lcPages2) oRef.actionSetCanvasCount(1)
			ON SELECTION BAR 2 OF (m.lcPages2) oRef.actionSetCanvasCount(2)
			ON SELECTION BAR 3 OF (m.lcPages2) oRef.actionSetCanvasCount(4)

			* Set the mark:
			DO CASE
			CASE oRef.CanvasCount = 1
				SET MARK OF BAR 1 OF (m.lcPages2) TO .T.
			CASE oRef.CanvasCount = 2
				SET MARK OF BAR 2 OF (m.lcPages2) TO .T.
			CASE oRef.CanvasCount = 4
				SET MARK OF BAR 3 OF (m.lcPages2) TO .T.
			ENDCASE
		ENDIF

	ENDPROC


	PROCEDURE CheckHelperClass
		IF VARTYPE(_goHelper) <> "O"
			PUBLIC _goHelper
			_goHelper = CREATEOBJECT("PreviewHelper")
			_goHelper.lExtended = .F.
		ENDIF

		* Update the language setting if needed
		IF VARTYPE(_goHelper._oLang) <> "O"
			_goHelper.SetLanguage(_goHelper.cLanguage)
		ENDIF
	ENDPROC


	PROCEDURE ActionShowToolbar
		LPARAMETERS tnVisible
			&& 1 = Visible (default), 2 = Invisible, 3 = Use resource
		IF ISNULL( This.PreviewForm.TOOLBAR )
			This.PreviewForm.ToolbarIsVisible = .F.
			This.PreviewForm.CreateToolbar()
			This.UpdateToolbar()
		ENDIF
		DO CASE
		CASE tnVisible = 2
			* Hide the toolbar:
			This.PreviewForm.TOOLBAR.HIDE()
			This.PreviewForm.ToolbarIsVisible = .F.
		CASE tnVisible = 1
			* Show the toolbar:
			This.PreviewForm.ShowToolbar(.T.)
			This.PreviewForm.ToolbarIsVisible = .T.
		OTHERWISE
		* Do nothing
		ENDCASE
	ENDPROC


	PROCEDURE actionToolbarVisibility
	*--------------------------------------------------
	* .ActionToolbarVisibility() - called from menu
	*--------------------------------------------------
		IF ISNULL( This.PreviewForm.TOOLBAR )
			This.PreviewForm.ToolbarIsVisible = .F.
			This.PreviewForm.CreateToolbar()
			This.UpdateToolbar()
			RETURN 
		ENDIF
		IF This.PreviewForm.ToolbarIsVisible
			* Hide the toolbar:
			This.PreviewForm.TOOLBAR.HIDE()
			This.PreviewForm.ToolbarIsVisible = .F.
		ELSE
			* Show the toolbar:
			This.PreviewForm.ShowToolbar(.T.)
			This.PreviewForm.ToolbarIsVisible = .T.
		ENDIF
	ENDPROC


	PROCEDURE ActionGotoPage
	*-----------------------------------------------------------
	* ActionGoToPage()
	*-----------------------------------------------------------
		#DEFINE WINDOWTYPE_MODELESS		0
		#DEFINE WINDOWTYPE_MODAL		1

		LOCAL loForm, iPageNo
		loForm = CREATEOBJECT("CustomFrxGotoPageForm")
		loForm.oParentForm = This.PreviewForm

		IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
			This.PreviewForm.ShowToolbar(.F.)
			loForm.SHOW( WINDOWTYPE_MODAL )
			IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
				This.PreviewForm.ShowToolbar(.T.)
			ENDIF 
		ELSE
			loForm.SHOW( WINDOWTYPE_MODAL )
		ENDIF

		IF ISNULL(loForm)
			RETURN
		ENDIF 

		iPageNo = loForm.PAGENO
		RELEASE m.loForm

		ACTIVATE WINDOW (This.PreviewForm.NAME)

		IF m.iPageNo <> This.PreviewForm.currentPage
			This.PreviewForm.setCurrentPage( m.iPageNo )
		ENDIF
	ENDPROC


	PROCEDURE DoCustomPrint
	*-----------------------------------------------------------
	* DoCustomPrint()
	*-----------------------------------------------------------

		IF _goHelper.nPrinterPropType = 2
			IF UPPER(_goHelper._cOriginalPrinter) <> UPPER(_goHelper.cPrinterName)
				_goHelper.SetPrinter(_goHelper.cPrinterName)
			ENDIF 
			DO SetPrinterProps
		ELSE 
			IF UPPER(_goHelper._cOriginalPrinter) <> UPPER(_goHelper.cPrinterName)
				_goHelper.SetPrinter(_goHelper.cPrinterName)
			ENDIF

			* Ensure the proof sheet is closed
			_goHelper.CloseSheets()

			This.PreviewForm.oReport.COMMANDCLAUSES.PROMPT = .T.

			LOCAL loListener AS REPORTLISTENER
			loListener = This.PreviewForm.oReport
			=BINDEVENT(loListener, "OutputPage", THIS, "DialogPrinting")

			This.PreviewForm.oReport.ONPREVIEWCLOSE(.T.)

			IF NOT _goHelper.lExtended
				_goHelper.ClearCache()
			ENDIF

			This.RestoreParent()
		ENDIF 
	ENDPROC


	PROCEDURE DialogPrinting
		LPARAMETERS nPageNo, eDevice, nDeviceType, Par1, Par2, Par3, Par4
		UNBINDEVENTS(THIS)
		_goHelper.lPrinted = .T.
	ENDPROC


	PROCEDURE ActionClose
		This.PreviewForm.oReport.ONPREVIEWCLOSE(.F.)

		IF NOT _goHelper.lExtended
			_goHelper.ReportReleased()
		ENDIF

		This.PreviewForm.oReport = NULL
		This.PreviewForm = NULL

		TRY
			_goHelper.ClearCache()
		CATCH
		ENDTRY

		This.RestoreParent()
	ENDPROC


	PROCEDURE RestoreParent
		UNBINDEVENTS(THIS)
		TRY
			IF VARTYPE(_goHelper._oParentForm) = "O"
				LOCAL loForm AS FORM
				loForm = _goHelper._oParentForm
				loForm.CONTROLBOX = loForm.CONTROLBOX
				loForm.TITLEBAR = loForm.TITLEBAR
				loForm.CLOSABLE = .T.
				loForm.DRAW()
				loForm.PAINT()
			ENDIF
		CATCH
		ENDTRY
	ENDPROC


	PROCEDURE ActionPrint
		This.PreviewForm.oReport.ONPREVIEWCLOSE(.T.)
	ENDPROC


	PROCEDURE ActionPrintEx
	* Ensure the proof sheet is closed
		_goHelper.CloseSheets()

		_goHelper._lIsDotMatrix = IsDotMatrix(_goHelper.cPrinterName)

		IF (ALLTRIM(UPPER(_goHelper.cPrinterName)) = ALLTRIM(UPPER(_goHelper._cOriginalPrinter))) ;
				AND (_goHelper.lUseListener) ;
				AND (_goHelper._lIsDotMatrix = .F.)
				&& Default printer not changed, go ahead with the default behavior
			* Do the default behavior
			* Hide the Preview form
			This.PreviewForm.VISIBLE = .F.

			* Print the current report
			_goHelper.lPrinted = .T.

			* Decrease the nCopies property
			_goHelper.nCopies = _goHelper.nCopies - 1
			_goHelper._lSendToPrinter = .T.
			This.PreviewForm.oReport.ONPREVIEWCLOSE(.T.)

			IF NOT _goHelper.lExtended
				_goHelper.ClearCache()
			ENDIF
		ELSE
			&& Changed the printer, so finish the preview and
			&& print from outside the preview window
			_goHelper._lSendToPrinter = _goHelper.SetPrinter(_goHelper.cPrinterName)
			This.PreviewForm.oReport.ONPREVIEWCLOSE(.F.)
		ENDIF

		IF _goHelper._lNoWait
			_goHelper.DoOutput()
		ENDIF
	ENDPROC


	PROCEDURE DoSetup

		* Ensure the proof sheet is closed
		_goHelper.CloseSheets()

		IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
			This.PreviewForm.ShowToolbar(.F.)
			DO FORM PR_Settings.scx NAME _goHelper._oSettingsSheet
			IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
				This.PreviewForm.ShowToolbar(.T.)
			ENDIF 
		ELSE
			DO FORM PR_Settings.scx NAME _goHelper._oSettingsSheet
		ENDIF

		_goHelper._oSettingsSheet = NULL
		
		IF _Screen.Visible && NOT _goHelper._TopForm
			ACTIVATE WINDOW (This.PreviewForm.NAME)
		ENDIF 
	ENDPROC



	PROCEDURE SetImages

		WITH THIS

			IF _goHelper.nButtonSize = 1 && 16x16
				.IMGBTN_PREV	 = PR_IMGBTN_PREV
				.IMGBTN_NEXT	 = PR_IMGBTN_NEXT
				.IMGBTN_TOP		 = PR_IMGBTN_TOP
				.IMGBTN_BOTT	 = PR_IMGBTN_BOTT
				.IMGBTN_MINI	 = PR_IMGBTN_MINI
				.IMGBTN_PRINT	 = PR_IMGBTN_PRINT
				.IMGBTN_PRINTPREF = PR_IMGBTN_PRINTPREF
				.IMGBTN_GOTOPG	 = PR_IMGBTN_GOTOPG
				.IMGBTN_1PG		 = PR_IMGBTN_1PG
				.IMGBTN_2PG		 = PR_IMGBTN_2PG
				.IMGBTN_4PG		 = PR_IMGBTN_4PG
				.IMGBTN_CLOSE	 = PR_IMGBTN_CLOSE
				.IMGBTN_CLOSE2	 = PR_IMGBTN_CLOSE2
				.IMGBTN_SAVE	 = PR_IMGBTN_SAVE
				.IMGBTN_EMAIL	 = PR_IMGBTN_EMAIL
				.IMGBTN_SETUP	 = PR_IMGBTN_SETUP
				.IMGBTN_SEARCH	 = PR_IMGBTN_SEARCH
				.IMGBTN_SEARCHAGAIN = PR_IMGBTN_SEARCHAGAIN
				.IMGBTN_SEARCHBACK  = PR_IMGBTN_SEARCHBACK
				
			ELSE
				.IMGBTN_PREV	 = PR_IMGBTN_PREV_32
				.IMGBTN_NEXT	 = PR_IMGBTN_NEXT_32
				.IMGBTN_TOP		 = PR_IMGBTN_TOP_32
				.IMGBTN_BOTT	 = PR_IMGBTN_BOTT_32
				.IMGBTN_MINI	 = PR_IMGBTN_MINI_32
				.IMGBTN_PRINT	 = PR_IMGBTN_PRINT_32
				.IMGBTN_PRINTPREF = PR_IMGBTN_PRINTPREF_32
				.IMGBTN_GOTOPG	 = PR_IMGBTN_GOTOPG_32
				.IMGBTN_1PG		 = PR_IMGBTN_1PG_32
				.IMGBTN_2PG		 = PR_IMGBTN_2PG_32
				.IMGBTN_4PG		 = PR_IMGBTN_4PG_32
				.IMGBTN_CLOSE	 = PR_IMGBTN_CLOSE_32
				.IMGBTN_CLOSE2	 = PR_IMGBTN_CLOSE2_32
				.IMGBTN_SAVE	 = PR_IMGBTN_SAVE_32
				.IMGBTN_EMAIL	 = PR_IMGBTN_EMAIL_32
				.IMGBTN_SETUP	 = PR_IMGBTN_SETUP_32
				.IMGBTN_SEARCH	 = PR_IMGBTN_SEARCH_32
				.IMGBTN_SEARCHAGAIN = PR_IMGBTN_SEARCHAGAIN_32
				.IMGBTN_SEARCHBACK  = PR_IMGBTN_SEARCHBACK_32

			ENDIF

		ENDWITH

	ENDPROC


	PROCEDURE SHOW(iStyle)

		SET TALK OFF
		SET CONSOLE OFF

		* Ensure that we have a parent helper class
		This.CheckHelperClass()
		
		_goHelper.oListener = This.PreviewForm.oReport

		

		_goHelper._nBtSize = IIF(_goHelper.nButtonSize = 1, 22, 36)
		This.SetImages()

		WITH This.PreviewForm
			LOCAL llNoWait, llTopForm
			TRY
				llTopForm = This.PreviewForm.TopForm && to avoid the error "TopForm" property does not exist
			CATCH
			ENDTRY
			_goHelper._TopForm = llTopForm

			This.PreviewForm.ICON = _goHelper.cFormIcon

			* Replace the original Page number synchronization method
			BINDEVENT(This.PreviewForm, "SynchPageNo", THIS, "SynchPageNo", 1)

			* Replace the original Toolbar.Refresh method
			BINDEVENT(This.PreviewForm.TOOLBAR, "Refresh", THIS, "RefreshToolbar", 1)
			BINDEVENT(This.PreviewForm, "RenderPage", THIS, "RenderPage", 1)

			* Don't permit the parent top-level form to be closable
			IF llTopForm OR This.PreviewForm.SHOWWINDOW > 0 && In Top-Level or As Top-Level form
				LOCAL lcParentTitle, lcCaption, loForm AS FORM
				lcParentTitle = GetParentWindow()
				FOR EACH loForm IN _SCREEN.FORMS FOXOBJECT
					lcCaption = loForm.CAPTION
					IF lcCaption = lcParentTitle
				*		BINDEVENT(loForm, "QueryUnload", This, "ParentClosed")

						TRY
							IF loForm.CLOSABLE = .T.
								loForm.CLOSABLE = .F.
								BINDEVENT(This.PreviewForm, "QueryUnload", THIS, "RestoreParent")
								BINDEVENT(This.PreviewForm, "Destroy", THIS, "RestoreParent")
								_goHelper._oParentForm = loForm
							ENDIF
						CATCH
						ENDTRY

						EXIT
					ENDIF
				ENDFOR

			ENDIF

*!*		LOCAL lcDE_Name && DataEnvironment name, to be used on cleanup
*!*		lcDE_Name = This.PreviewForm.oReport.CommandClauses.DE_Name
*!*		_goHelper._DE_Name = lcDE_Name
*!*		* _goHelper._oReport = This.PreviewForm.oReport

			llNoWait = llTopForm OR ;
				This.PreviewForm.oReport.COMMANDCLAUSES.NOWAIT
			_goHelper._lNoWait = llNoWait

			IF VARTYPE(_goHelper.nDockType) = "N" AND ;
					_goHelper.nDockType <> 4 && false or 4 MEANS TO KEEP THE CURRENT DOCK SETTINGS FROM THE RESOURCE
				This.PreviewForm.TOOLBAR.DOCK(_goHelper.nDockType)
*!*	–1 Undocks the toolbar or form.
*!*	 0 Positions the toolbar or form at the top of the main Visual FoxPro window.
*!*	 1 Positions the toolbar or form at the left side of the main Visual FoxPro window.
*!*	 2 Positions the toolbar or form at the right side of the main Visual FoxPro window.
*!*	 3 Positions the toolbar or form at the bottom of the main Visual FoxPro window.
			ENDIF

*


			 This.PreviewForm.oReport.CommandClauses.InWindow = ""

			* Defining the previewform.WindowState
			* 0 = Normal, 1 = Minimized, 2 = Maximized
			This.PreviewForm.WINDOWSTATE = _goHelper.nWindowState

			LOCAL loListener
			loListener = This.PreviewForm.oReport

			_goHelper.nPageTotal = .PAGETOTAL
			_goHelper._cFRXName  = .FrxFileName
			*!*	_goHelper._cFRXFullName = loListener.CommandClausesFile

			* Retrieve report clauses
			_goHelper._ClausenRangeFrom = loListener.COMMANDCLAUSES.RangeFrom
			_goHelper._ClausenRangeTo = loListener.COMMANDCLAUSES.RangeTo && -1 = All pages
			_goHelper._ClauselSummary = loListener.COMMANDCLAUSES.SUMMARY
			_goHelper._ClausecHeading = loListener.COMMANDCLAUSES.HEADING

		ENDWITH

		* Check if we can do searches in this preview session
		LOCAL loRL as ReportListener 
		loRL = This.PreviewForm.oReport
		
		IF PEMSTATUS(loRL, "cOutputAlias", 5)
			_goHelper._lCanSearch = .T.
		ENDIF 

		This.UpdateToolbar()

		DODEFAULT(iStyle)
	ENDPROC

*!* Only works after SP1, so we keep calling "UpdateToolbar()" directly
*!*	PROCEDURE InitializeToolBar()
*!*		This.UpdateToolBar()
*!*	ENDPROC



	PROCEDURE SynchPageNo
*-----------------------------------------------
* .SynchPageNo()
* Code from the ReportPreview source project
*-----------------------------------------------
* Modified 20100618 Nick Porfirys
* Now  displays:	"Page - PageTotal" when user selects 1Page mode						i.e.: "Page 5 - 1500"
* 			or:	"Pages from %FP% to %LP%" when user selectes 2Page or 4Page mode	i.e.: "Pages from 5 to 6" or "Pages from 5 to 8"
*
		LOCAL iCurrentPage, cMessage
		WITH This.PreviewForm
			iCurrentPage = .currentPage + .startOffset

			IF EMPTY( .oReport.COMMANDCLAUSES.WINDOW )
				IF .CanvasCount > 1

					LOCAL lastPage
					lastPage  = MIN( m.iCurrentPage + .CanvasCount-1, .PAGETOTAL )

*/my... displays "Pages from %FP% to %LP%"
*.Caption = .formCaption + " - " + PR_PAGECAPTIO + TRANSFORM( m.iCurrentPage ) + " - " + TRANSFORM( m.lastPage )
					cMessage= _goHelper.GetLoc("MINILABEL") + " "	&& "Pages from %FP% to %LP%"
					.CAPTION = .formCaption + " - " + STRTRAN(STRTRAN(cMessage, "%FP%", TRANSFORM(m.iCurrentPage)), "%LP%", TRANSFORM(m.lastPage))
*\my...
				ELSE
*/ my... displays "Page - PageTotal"
*.Caption = .formCaption + " - " + PR_PAGECAPTIO + transform( m.iCurrentPage )
					.CAPTION = .formCaption + " - " + _goHelper.GetLoc("PAGECAPTIO") + " " + TRANSFORM( m.iCurrentPage ) + " - " + TRANSFORM( .PAGETOTAL  )
*\ my...
				ENDIF
			ENDIF
		ENDWITH
	ENDPROC


	PROCEDURE RefreshToolbar

		WITH This.PreviewForm.TOOLBAR
			FOR EACH loControl IN .CONTROLS
				.SETALL("AutoSize",.T.,"cmd")
				.SETALL("AutoSize",.F.,"cmd")
				.SETALL("Height",_goHelper._nBtSize) &&,"cmd")
				
*				.SetAll("Width",_goHelper._nBtSize,"cmdReport") &&,"cmd")
				IF LOWER(loControl.BASECLASS) = "commandbutton"
					loControl.WIDTH = _goHelper._nBtSize
					loControl.HEIGHT = _goHelper._nBtSize
				ENDIF
			
				IF INLIST(LOWER(loControl.BASECLASS), "combobox", "spinner")
					loControl.HEIGHT = _goHelper._nBtSize - 3
				ENDIF

				IF LOWER(loControl.Name) = "cntsearch1"
					This.CmdSearchVisibility() && Update the Search buttons container
				ENDIF 				
			ENDFOR
		ENDWITH
	ENDPROC




	PROCEDURE UpdateToolbar

		WITH This.PreviewForm

			.AllowPrintfromPreview = .F. && Force this value,
				&& dont worry, because we'll add manually a new "Print" button

			LOCAL lcReportName, lcTitle

			IF NOT _goHelper.lExtended
				BINDEVENT(THIS, "Destroy", _goHelper, "ReportReleased")
				lcReportName = _goHelper._cFRXName
				This.PreviewForm.CAPTION = lcReportName
			ELSE
				lcReportName = JUSTSTEM(_goHelper._oNames(1)) && _oReports(1))
				lcTitle = IIF(EMPTY(_goHelper.cTitle), lcReportName, _goHelper.cTitle)

				* [2010-10-14] Nick Porfyris
				IF LEN(lcTitle) > 200
					lcTitle = LEFT(lcTitle,200) + "... "
				ENDIF
				* [2010-10-14]
				.Caption     = lcTitle
				.FormCaption = lcTitle

				This.PreviewForm.CAPTION = lcTitle
				This.PreviewForm.formCaption = lcTitle
			ENDIF

			This.SynchPageNo()

			WITH .TOOLBAR AS TOOLBAR
				LOCAL lnSize
				lnSize = _goHelper._nBtSize

				WITH .cntNext
					.WIDTH = lnSize * 2 + 2
					.HEIGHT = lnSize

					.cmdForward.WIDTH   = lnSize
					.cmdForward.HEIGHT  = lnSize
					.cmdForward.PICTURE = This.IMGBTN_NEXT
					.cmdForward.TOOLTIPTEXT = _goHelper.GetLoc("MENUNEXT")

					.cmdBottom.WIDTH  = lnSize
					.cmdBottom.HEIGHT = lnSize
					.cmdBottom.LEFT = lnSize + 1
					.cmdBottom.PICTURE      = This.IMGBTN_BOTT
					.cmdBottom.TOOLTIPTEXT = _goHelper.GetLoc("MENULAST")
				ENDWITH
				WITH .cntPrev
					.WIDTH = lnSize * 2 + 2
					.HEIGHT = lnSize

					.cmdTop.WIDTH    = lnSize
					.cmdTop.HEIGHT   = lnSize
					.cmdTop.PICTURE  = This.IMGBTN_TOP
					.cmdTop.TOOLTIPTEXT = _goHelper.GetLoc("MENUTOP")

					.cmdBack.WIDTH   = lnSize
					.cmdBack.HEIGHT  = lnSize
					.cmdBack.LEFT    = lnSize + 1
					.cmdBack.PICTURE = This.IMGBTN_PREV
					.cmdBack.TOOLTIPTEXT = _goHelper.GetLoc("MENUPREV")

					LOCAL loCmdGoto AS COMMANDBUTTON
					IF UPPER(_goHelper.GetLoc("LANGUAGE")) <> "ENGLISH"
						* Replace the GoToPage button
						This.PreviewForm.TOOLBAR.cmdGotoPage.VISIBLE = .F.
						.ADDOBJECT("cmdGoto1", "cmdGotoEx")
						loCmdGoto = .cmdGoTo1
						loCmdGoto.LEFT = .WIDTH
						.WIDTH = .WIDTH + lnSize
					ELSE
						* Keep the original Goto button
						loCmdGoto = This.PreviewForm.TOOLBAR.cmdGotoPage
					ENDIF

					loCmdGoto.WIDTH   = lnSize
					loCmdGoto.HEIGHT  = lnSize
					loCmdGoto.PICTURE = This.IMGBTN_GOTOPG
					loCmdGoto.TOOLTIPTEXT = _goHelper.GetLoc("MENUGOTO")

				ENDWITH

				IF _goHelper.lShowMiniatures && shows the miniatures page
					.ADDOBJECT("cmdProof1","cmdProof")
					.cmdProof1.TOOLTIPTEXT = _goHelper.GetLoc("MINIATURES")
				ENDIF

				LOCAL loCombo AS COMBOBOX
				loCombo = .cboZoom

				IF UPPER(_goHelper.GetLoc("LANGUAGE")) <> "ENGLISH"

					* Translate toolbar buttons ToolTips to non English language
					IF NOT EMPTY(_goHelper.GetLoc("CBOZOOMTTI"))
						.cboZoom.TOOLTIPTEXT = _goHelper.GetLoc("CBOZOOMTTI")
					ELSE
						.cboZoom.TOOLTIPTEXT = "Zoom"
					ENDIF

					* Translate the combo items
					LOCAL N, lcItem
					FOR N = 1 TO loCombo.LISTCOUNT
						lcItem = LOWER(loCombo.LISTITEM(N))

						IF (lcItem = "whole page") OR (N = 10)
							loCombo.LISTITEM(N) = _goHelper.GetLoc("CBOZOOMWHO")
						ENDIF
						IF (lcItem = "fit to width") OR (N = 11)
							loCombo.LISTITEM(N) = _goHelper.GetLoc("CBOZOOMPGW")
						ENDIF
					ENDFOR
					loCombo.WIDTH = loCombo.WIDTH + 10

					WITH .opgPageCount
						.opt1.TOOLTIPTEXT = _goHelper.GetLoc("ONEPGTTIP")
						.opt2.TOOLTIPTEXT = _goHelper.GetLoc("TWOPGTTIP")
						.opt3.TOOLTIPTEXT = _goHelper.GetLoc("FOURPGTTIP")
					ENDWITH
				ENDIF

				WITH .opgPageCount AS OPTIONGROUP
					.opt1.HEIGHT  = lnSize
					.opt2.HEIGHT  = lnSize
					.opt3.HEIGHT  = lnSize
					.opt1.WIDTH   = lnSize
					.opt2.WIDTH   = lnSize
					.opt3.WIDTH   = lnSize
					.opt2.LEFT    = lnSize
					.opt3.LEFT    = lnSize * 2
					.opt1.PICTURE = This.IMGBTN_1PG
					.opt2.PICTURE = This.IMGBTN_2PG
					.opt3.PICTURE = This.IMGBTN_4PG

					.HEIGHT = lnSize
					.WIDTH = lnSize * 3
				ENDWITH

	*			.Refresh()

				IF _goHelper.lPrintVisible

					* Show the printers Combo
					IF _goHelper.lShowPrinters
						.ADDOBJECT("cmbPrinters1", "cmbPrinters")
						.cmbPrinters1.HEIGHT = loCombo.HEIGHT
						.cmbPrinters1.FONTSIZE = loCombo.FONTSIZE
						.cmbPrinters1.TOOLTIPTEXT = _goHelper.GetLoc("AVAILABLEP")
					ENDIF

					* Show the copies spinner
					IF _goHelper.lShowCopies AND _goHelper.lExtended
						.ADDOBJECT("cntCopies1","cntCopies")
					ENDIF

					* Show the Save to file button
					IF _goHelper.lSaveToFile && AND _goHelper.lExtended
						.ADDOBJECT("cmdSave1", "cmdSave")
						.cmdSave1.TOOLTIPTEXT = _goHelper.GetLoc("SAVEREPORT")

						.ADDOBJECT("cmbSave1", "cmbSave")

						LOCAL lnCmbIndex
						lnCmbIndex = 0
						WITH .CmbSave1
							IF _goHelper.lSaveAsImage
								lnCmbIndex = lnCmbIndex + 1
								.ADDITEM(_goHelper.GetLoc("SAVEASIMAG"))
								.PICTURE[lnCmbIndex] = "pr_Img.bmp"
								.LIST[.NewIndex, 2] = '1'
							ENDIF


							IF _goHelper.lExtended OR _goHelper._lCanSearch
								IF _goHelper.lSaveAsPDF
									lnCmbIndex = lnCmbIndex + 1
									.ADDITEM(_goHelper.GetLoc("SAVEASPDF"))
									.PICTURE[lnCmbIndex] = "pr_Pdf.bmp"
									.LIST[.NewIndex, 2] = '2'
								ENDIF
								IF _goHelper.lSaveAsRTF
									lnCmbIndex = lnCmbIndex + 1
									.ADDITEM(_goHelper.GetLoc("SAVEASRTF"))
									.LIST[.NewIndex, 2] = '4'
									.PICTURE[lnCmbIndex] = "pr_Word.bmp"
								ENDIF
								IF _goHelper.lSaveAsXLS
									lnCmbIndex = lnCmbIndex + 1
									.ADDITEM(_goHelper.GetLoc("SAVEASXLS"))
									.LIST[.NewIndex, 2] = '5'
									.PICTURE[lnCmbIndex] = "pr_Excel.bmp"
								ENDIF
							ENDIF 

							IF _goHelper.lExtended
								IF _goHelper.lSaveAsHTML
									lnCmbIndex = lnCmbIndex + 1
									.ADDITEM(_goHelper.GetLoc("SAVEASHTML"))
									.LIST[.NewIndex, 2] = '3'
									.PICTURE[lnCmbIndex] = "pr_HTML.bmp"
								ENDIF

								IF _goHelper.lSaveasTXT && 11/08/2010 by mauriciobraga@ig.com.br
									lnCmbIndex = lnCmbIndex + 1
									.ADDITEM(_goHelper.GetLoc("SAVEASTXT"))
									.LIST[.NewIndex, 2] = '6'
									.PICTURE[lnCmbIndex] = "pr_1page.bmp"
								ENDIF
							ENDIF

						ENDWITH

					ENDIF  && _goHelper.lSaveToFile

					* Show the Send to Email button
					IF _goHelper.lSendToEmail && AND _goHelper.lExtended
						.ADDOBJECT("cmdEmail1", "cmdEmail")
						.cmdEmail1.TOOLTIPTEXT = _goHelper.GetLoc("SENDTOEMAI")

					ENDIF && _goHelper.lSendToEmail

					* Show the Printer preferences button
					IF _goHelper.lPrinterPref && AND _goHelper.lExtended
						.ADDOBJECT("cmdPrinterProps1", "cmdPrinterProps")
						.cmdPrinterProps1.TOOLTIPTEXT = _goHelper.GetLoc("PRINTINGPR")
					ENDIF

					* Replace the original Print button
					.ADDOBJECT("cmdPrint1", "cmdPrintEx")
					.cmdPrint1.TOOLTIPTEXT = _goHelper.GetLoc("PRINTREPOR")

				ENDIF


				IF _goHelper.lShowSetup
					.ADDOBJECT("cmdSetup1", "cmdSetup")
					.cmdSetup1.TOOLTIPTEXT = _goHelper.GetLoc("SETUP")
				ENDIF

				IF _goHelper._lCanSearch AND _goHelper.lShowSearch &&AND (_goHelper._oReports.Count = 1)

					.ADDOBJECT("cntSearch1",      "cntSearch")
					.cntSearch1.cmdSearch1.TOOLTIPTEXT = _goHelper.GetLoc("FIND")
					.cntSearch1.cmdSearchBack1.TOOLTIPTEXT = _goHelper.GetLoc("FINDBACK")
					.cntSearch1.cmdSearchAgain1.TOOLTIPTEXT = _goHelper.GetLoc("FINDNEXT")
					.cntSearch1.cmdSearchBack1.Visible = .F.
					.cntSearch1.cmdSearchAgain1.Visible = .F.
					.cntSearch1.Width = .cntSearch1.cmdSearch1.Width				

*!*						.ADDOBJECT("cmdSearch1",      "cmdSearch")
*!*						.cmdSearch1.TOOLTIPTEXT = _goHelper.GetLoc("FIND")

*!*						.ADDOBJECT("cmdSearchBack1", "cmdSearchBack")
*!*						.cmdSearchBack1.TOOLTIPTEXT = _goHelper.GetLoc("FINDBACK")
*!*						.cmdSearchBack1.Visible = .F.
*!*		
*!*						.ADDOBJECT("cmdSearchAgain1", "cmdSearchAgain")
*!*						.cmdSearchAgain1.TOOLTIPTEXT = _goHelper.GetLoc("FINDNEXT")
*!*						.cmdSearchAgain1.Visible = .F.
				ENDIF

				* Replace the original Close button
				.cmdClose.VISIBLE = .F.
				.ADDOBJECT("cmdExit1", "cmdExit")
				.CmdExit1.TOOLTIPTEXT  = _goHelper.GetLoc("CLOSEREPOR")


				IF _goHelper.nButtonSize = 2
					IF _goHelper.lSaveToFile && AND _goHelper.lExtended
						.CmbSave1.FONTSIZE = 11
					ENDIF
					IF _goHelper.lShowPrinters
						.cmbPrinters1.FONTSIZE = 11
					ENDIF
					.cboZoom.FONTSIZE = 11
					.cboZoom.WIDTH = 115
				ENDIF

				IF _goHelper.lShowCopies AND _goHelper.lExtended AND _goHelper.lPrintVisible
					.cntCopies1.SpnCopies1.FONTSIZE = .cboZoom.FONTSIZE
					.cntCopies1.LblCopies1.FONTSIZE = .cboZoom.FONTSIZE
					.cntCopies1.AdjustControls()
				ENDIF

				.REFRESH()

			ENDWITH

			This.ActionShowToolbar(_goHelper.nShowToolBar)

		ENDWITH
	ENDPROC


	PROCEDURE ParentClosed
		UNBINDEVENTS(THIS)
		This.ActionClose()
		_goHelper.ReportReleased(THIS)
	ENDPROC


	PROCEDURE DoProof()
		_goHelper._oProofSheet = CREATEOBJECT("ProofSheet")
		_goHelper._oProofSheet.SetReport( This.PreviewForm.oReport )
		_goHelper._oProofSheet.Caption = _goHelper.GetLoc("GLOBALPREV")
		_goHelper._oProofSheet.nMaxMiniatureItem = _goHelper.nMaxMiniatureDisplay

		IF VARTYPE(_goHelper._oParentForm) = "O"
			ACTIVATE WINDOW (_goHelper._oParentForm.NAME)

			IF _Screen.Visible && NOT _goHelper._TopForm
				ACTIVATE WINDOW (This.PreviewForm.NAME)
			ENDIF 
		ENDIF

		_goHelper._oProofSheet.SetProofCaption()
		_goHelper._oProofSheet.SHOW(1)

		* read the selected page and move to it,
		* using the .SetCurrentPage() method of
		* the default preview container:

		IF VARTYPE(NVL(_goHelper._oProofSheet,"")) = "O"
			LOCAL loExc as Exception 
			TRY
				LOCAL lnPage
				lnPage = _goHelper._oProofSheet.CurrentPage
				This.PreviewForm.setCurrentPage(lnPage)
				_goHelper._oProofSheet = ""
			CATCH TO loExc
				SET STEP ON 
			ENDTRY
		ENDIF 
	ENDPROC


*----------------------------------------------------------------------
* SEARCH MODULE
*----------------------------------------------------------------------

PROCEDURE CmdSearchVisibility
	LPARAMETERS tlVisible

	LOCAL loToolbar as Toolbar 
	loToolBar = This.PreviewForm.Toolbar

	IF NOT ISNULL(loToolBar) AND VARTYPE(loToolbar) = "O"

		WITH loToolBar.cntSearch1

			IF PCOUNT() = 0  && No parameters passed, just update the size of the controls
				tlVisible = loToolBar.cntSearch1.cmdSearchAgain1.Visible
				LOCAL lnWidth
				lnWidth = _goHelper._nBtSize
				.cmdSearch1.Width = lnWidth
				.cmdSearchBack1.Width = lnWidth
				.cmdSearchAgain1.Width = lnWidth
			ENDIF 

			.cmdSearchAgain1.Visible = tlVisible
			.cmdSearchBack1.Visible  = tlVisible

			IF tlVisible
				LOCAL lcText, lnSize
				lcText = ": '" + ALLTRIM(_goHelper._cTextToFind) + "'"
				lnSize = _goHelper._nBtSize
				.cmdSearchBack1.Left = lnSize + 1
				.cmdSearchBack1.ToolTipText = _goHelper.GetLoc("FINDBACK") + lcText
				.cmdSearchAgain1.Left = (lnSize * 2) + 2
				.cmdSearchAgain1.ToolTipText = _goHelper.GetLoc("FINDNEXT") + lcText
				.Width = .cmdSearch1.Width + .cmdSearchBack1.Width + .cmdSearchAgain1.Width + 2
			ELSE
				.Width = .cmdSearch1.Width				
			ENDIF 
		ENDWITH 
	
		_goHelper._lShowSearchAgain = tlVisible
	ENDIF 
ENDPROC 


PROCEDURE DoSearch
	* Prompt the user for some text to find, find the first instance of it, and
	* highlight it.

	* Ensure the proof sheet is closed
	_goHelper.CloseSheets()

	This.ClearBox()

	LOCAL lcText, lcReportAlias, lcAlias
	lcReportAlias = ALIAS()
	lcAlias = This.PreviewForm.oReport.cOutputAlias
	* lcAlias = _goHelper._cOutputAlias

	IF EMPTY(lcAlias)
		MESSAGEBOX("Search feature is currently unavailable for this report.", 48, "FoxyPreviewer error")
		RETURN 
	ENDIF	
		

	WITH This
		* lcText = INPUTBOX('Find:', 'Find Text')
		* _goHelper._cTextToFind = lcText
		
		IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
			This.PreviewForm.ShowToolbar(.F.)
			DO FORM PR_Search.scx WITH _goHelper._cTextToFind, This.PreviewForm
			IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
				This.PreviewForm.ShowToolbar(.T.)
			ENDIF 
		ELSE
			DO FORM PR_Search.scx WITH _goHelper._cTextToFind, This.PreviewForm
		ENDIF

		IF _Screen.Visible && _goHelper._TopForm
			ACTIVATE WINDOW (This.PreviewForm.NAME)
		ENDIF 

		
		
		* DO FORM PR_Search.scx WITH _goHelper._cTextToFind
		lcText = _goHelper._cTextToFind

		INKEY(.2)
		DOEVENTS 

		IF NOT EMPTY(lcText)
			LOCAL llError
			TRY
				SELECT (lcAlias)
			CATCH
				MESSAGEBOX("Search feature is currently unavailable for this report.", 48, "FoxyPreviewer error")
				llError = .T.
			ENDTRY 
			IF llError
				RETURN
			ENDIF 
					
			_goHelper._cTextToFind = lcText
			LOCATE FOR UPPER(lcText) $ UPPER(CONTENTS)
			.HandleFind(FOUND())
		ELSE 
			This.CmdSearchVisibility(.F.)
		ENDIF 
	ENDWITH
	
	* Restore original alias
	TRY 
		SELECT (lcReportAlias)
	CATCH
	ENDTRY 
ENDPROC 


PROCEDURE DoSearchAgain
	This.ClearBox()
	
	LOCAL lcText, lcAlias, lcReportAlias
	lcReportAlias = ALIAS()
	lcAlias = This.PreviewForm.oReport.cOutputAlias
	lcText  = _goHelper._cTextToFind

	IF NOT EMPTY(lcText)
		SELECT (lcAlias)
		IF NOT EOF()
			SKIP +1
		ENDIF 
		LOCATE REST FOR UPPER(lcText) $ UPPER(CONTENTS)
		IF EOF()
			* Search from beginning
			LOCATE FOR UPPER(lcText) $ UPPER(CONTENTS)
		ENDIF 
		This.HandleFind(FOUND(), .T.) && The 2nd parameter means that we are calling
									&& SearchAgain
	ENDIF
	
	* Restore original alias
	TRY 
		SELECT (lcReportAlias)
	CATCH
	ENDTRY 

ENDPROC 



PROCEDURE DoSearchBack
	This.ClearBox()
	
	LOCAL lcText, lcAlias, lcReportAlias
	lcReportAlias = ALIAS()
	lcAlias = This.PreviewForm.oReport.cOutputAlias
	lcText  = UPPER(_goHelper._cTextToFind)

	IF NOT EMPTY(lcText)
		SELECT (lcAlias)

		DO WHILE .T.
			SKIP -1
			IF BOF()
				GO BOTTOM 
			ENDIF 

			IF lcText $ UPPER(CONTENTS)
				EXIT
			ENDIF 
		ENDDO 
		This.HandleFind(.T., .T.) && The 2nd parameter means that we are calling
									&& SearchAgain
	ENDIF
	SELECT (lcReportAlias)
ENDPROC 


* Handle whether the object was found or not.
PROCEDURE HandleFind
	LPARAMETERS tlFound, tlAgain

	IF tlFound
		This.lHighlighttext = .T.
		This.CmdSearchVisibility(.T.)
	ELSE

		IF NOT tlAgain
			This.CmdSearchVisibility(.F.)
		ENDIF 

		MESSAGEBOX(_goHelper.GetLoc("NOTFOUND"), ;
			48, CHRTRAN(_goHelper.GetLoc("FINDTEXT"),":",""))
		GO TOP 
		This.lHighlighttext = .F.
		RETURN 
	ENDIF

	IF PAGE <> This.PreviewForm.CurrentPage
		This.lHighlighttext = .T.
		This.PreviewForm.TempStopRepaint = .T.
		This.PreviewForm.setCurrentPage( PAGE )
	ENDIF 

	This.ScrollToObject(Left/10, Top/10, Width/10, Height/10)
	=INKEY(.2)
	DOEVENTS  
	This.lHighlighttext = .T.
	This.PreviewForm.RenderPages()
ENDPROC 


PROCEDURE ClearBox
	TRY 
		LOCAL loForm as Form
		loForm = This.PreviewForm
		IF VARTYPE(loForm.LineTop) = "O" 
			loForm.RemoveObject("lineTop")
		ENDIF 
		IF VARTYPE(loForm.LineBott) = "O" 
			loForm.RemoveObject("lineBott")
		ENDIF 
		IF VARTYPE(loForm.LineLeft) = "O" 
			loForm.RemoveObject("lineLeft")
		ENDIF 
		IF VARTYPE(loForm.LineRight) = "O" 
			loForm.RemoveObject("lineRight")
		ENDIF 
	CATCH
	ENDTRY 
ENDPROC 


* By Doug Hennig
* We may need to scroll the form if the specified object isn't currently visible.
PROCEDURE ScrollToObject
	LPARAMETERS tnLeft, tnTop, tnWidth, tnHeight
	LOCAL lnNewTop, lnNewLeft, lnVPos, lnHPos, ;
			lnVpTop, lnVpLeft, lnVpWidth, lnVpHeight

	WITH This.PreviewForm as Form
		lnVpTop    = .ViewPortTop 
		lnVpLeft   = .ViewPortLeft 
		lnVpWidth  = .ViewPortWidth 
		lnVpHeight = .ViewPortHeight 

		lnNewTop   = lnVpTop
		lnNewLeft  = lnVpLeft
		lnVPos     = tnTop  + tnHeight + This.PreviewForm.Canvas1.Top
		lnHPos     = tnLeft + tnWidth  + This.PreviewForm.Canvas1.Left

		IF NOT BETWEEN(lnVPos - 20, lnVpTop , lnVpTop + lnVpHeight)
			lnNewTop = lnVPos - lnVpHeight /2
		ENDIF
		IF NOT BETWEEN(lnHPos, lnVpLeft, lnVpLeft + lnVpWidth)
			lnNewLeft = lnHPos - lnVpWidth /2
		ENDIF
	
		IF lnNewTop <> lnVpTop OR lnNewLeft <> lnVpLeft
			.SetViewPort(lnNewLeft, lnNewTop)
		ENDIF
	ENDWITH
ENDPROC



PROCEDURE HighLightObject
	LPARAMETERS tnL , tnT, tnW , tnH

	LOCAL lnPixelsPerDPI960, lnHWnd, lnX, lnY, lnWidth, lnHeight

	WITH This.PreviewForm

		* Adjust coordinates
		lnPixelsPerDPI960 = .getpixelsperdpi960()
		lnX = .canvas1.Left + INT(tnL * lnPixelsPerDPI960) - 2
		lnY = .canvas1.Top  + INT(tnT * lnPixelsPerDPI960) - 2
		lnWidth  = INT(tnW * lnPixelsPerDPI960) + 8
		lnHeight = INT(tnH * lnPixelsPerDPI960) + 8

		* Draw the box
		LOCAL loForm as Form
		loForm = This.PreviewForm

		loForm.AddObject("lineTop"  , "Line")
		loForm.AddObject("lineBott" , "Line")
		loForm.AddObject("lineLeft" , "Line")
		loForm.AddObject("lineRight", "Line")
	
		LOCAL lnColor
		lnColor = RGB(255,64,64)

		.TempStopRepaint = .T.
		WITH loForm.LineTop as Line 
			.Width       = lnWidth
			.BorderColor = lnColor
			.BorderWidth = 0
			.Top         = lnY
			.Left        = lnX
			.Height      = 0
			.Visible     = .T.
		ENDWITH 

		.TempStopRepaint = .T.
		WITH loForm.LineBott as Line
			.Width       = lnWidth
			.BorderColor = lnColor
			.BorderWidth = 0
			.Top         = (lnY + lnHeight)
			.Left        = lnX
			.Height      = 0
			.Visible     = .T.
		ENDWITH 

		.TempStopRepaint = .T.
		WITH loForm.LineLeft as Line 
			.Width       = 0
			.BorderColor = lnColor
			.BorderWidth = 0
			.Top         = lnY
			.Left        = lnX
			.Height      = lnHeight
			.Visible     = .T.
		ENDWITH 

		.TempStopRepaint = .T.
		WITH loForm.LineRight as Line 
			.Width = 0
			.BorderColor = lnColor
			.BorderWidth = 0
			.Top         = lnY
			.Left        = lnX + lnWidth
			.Height      = lnHeight
			.Visible     = .T.
		ENDWITH 

	ENDWITH 
	This.lHighlightText = .F.
ENDPROC


PROCEDURE RenderPage
	LPARAMETERS tiPage, toCanvas
	This.ClearBox()
	IF This.lHighlightText
		SELECT (this.PreviewForm.oReport.cOutputAlias)
		This.lHighlightText = .F.
		This.highlightobject(left,top,width,height)
	ELSE
	ENDIF 
ENDPROC 
*----------------------------------------------------------------------
* End of SEARCH MODULE
*----------------------------------------------------------------------



	PROCEDURE PAINT
	ENDPROC


	PROCEDURE DoSave(tnIndex)
		This.DoSaveType(tnIndex)

		IF _goHelper._lNoWait AND ; && Top form
			NOT EMPTY(_goHelper.cDestFile) && Selected a file output
			_goHelper.DoOutput()
		ENDIF
	ENDPROC


	PROCEDURE DoSaveType(tnType)

		IF VARTYPE(_goHelper.oListener) <> "O"
			_goHelper.oListener	= This.PreviewForm.oReport
		ENDIF 


		LOCAL lcFile, lcReportName

		TRY
*			lcReportName = JUSTSTEM(_goHelper._oReports(1)) &&  Output File Name
			lcReportName = _goHelper.oListener.PrintJobName &&  Output File Name
		CATCH
			lcReportName = ""
		ENDTRY
		IF EMPTY(_goHelper.cOutputPath) OR DIRECTORY(_goHelper.cOutputPath)
			*!* 2010-09-17 - Jacques Parent - Add the cSaveDefName
			*!* 2010-09-27 - Jacques Parent - Correction;  Was not used if _goHelper.cOutputPath was empty
			IF EMPTY(_goHelper.cSaveDefName)
				lcFile = IIF(EMPTY(_goHelper.cOutputPath), "", ADDBS(_goHelper.cOutputPath)) + lcReportName && Output Path + Output File Name
			ELSE
				lcFile = IIF(EMPTY(_goHelper.cOutputPath), "", ADDBS(_goHelper.cOutputPath)) + _goHelper.cSaveDefName && Output Path + Output File Name
			ENDIF
		ELSE
			lcFile = ""
		ENDIF

		DO CASE
		CASE tnType = 1 && Image file
			lcFile = PUTFILE(_goHelper.GetLoc("SAVEASIMAG") + "...", lcFile, "Png;Bmp;Jpg;Gif;Tif;Emf")
			IF NOT EMPTY(lcFile) && Invalid File Name
				LOCAL loListener
				loListener = This.PreviewForm.oReport
				_goHelper.lSaved = Report2Pic(loListener, lcFile, JUSTEXT(lcFile))
				loListener = NULL
				RETURN 
			ENDIF

		CASE tnType = 2 && PDF
			lcFile = PUTFILE(_goHelper.GetLoc("SAVEASPDF") + "...", lcFile, "Pdf")
			IF NOT _goHelper.lExtended AND NOT EMPTY(lcFile)
				This.DoMakePDFOffline(lcFile)	
				RETURN 
			ENDIF 

		CASE tnType = 3 && HTML
			lcFile = PUTFILE(_goHelper.GetLoc("SAVEASHTML") + "...", lcFile, "Htm;Html")

		CASE tnType = 4 && RTF
			lcFile = PUTFILE(_goHelper.GetLoc("SAVEASRTF") + "...", lcFile, "Rtf;Doc")
			IF NOT _goHelper.lExtended AND NOT EMPTY(lcFile)
				This.DoMakeRTFOffline(lcFile)	
				RETURN 
			ENDIF 

		CASE tnType = 5 && XLS
			lcFile = PUTFILE(_goHelper.GetLoc("SAVEASXLS") + "...", lcFile, "Xls;Xml")
			IF NOT _goHelper.lExtended AND NOT EMPTY(lcFile)
				This.DoMakeXLSOffline(lcFile)	
				RETURN 
			ENDIF 


		CASE tnType = 6 && TXT
			lcFile = PUTFILE(_goHelper.GetLoc("SAVEASTXT") + "...", lcFile, "Txt;Csv;Xl5")
		OTHERWISE
		ENDCASE

		IF NOT EMPTY(lcFile) && Invalid File Name
			_goHelper.cDestFile = lcFile
			* Close the preview form completely
			This.ActionClose()
		ENDIF

		* CLOSE DEBUGGER

	ENDPROC


	PROCEDURE DoMakePDFOffline
		LPARAMETERS tcFile
		_goHelper.cDestFile = tcFile
		&& Generate PDF from the offline table
		LOCAL loListener AS "PdfListener" OF "PR_Pdfx.vcx"
		loListener = NEWOBJECT('PdfListener', 'PR_PDFx.vcx')
		loListener.cCodePage = _goHelper.cCodePage &&CodePage
		loListener.nPageMode = _goHelper.nPDFPageMode
		loListener.cTargetFileName = tcFile

		LOCAL lcOutputDBF, lnWidth, lnHeight
		lcOutputDBF = _goHelper.oListener.GetFullFRXData()

		IF NOT EMPTY(lcOutputDBF)
			lnWidth  = _goHelper.oListener.GETPAGEWIDTH()
			lnHeight = _goHelper.oListener.GETPAGEHEIGHT()
			loListener.OutputFromData(_goHelper.oListener, lcOutputDBF, lnWidth, lnHeight)
			loListener = NULL
		ENDIF 

		IF NOT FILE(tcFile)
			_goHelper.SetError(_goHelper.GetLoc("ERR_CREATI"))
			RETURN .F.
		ELSE
			_goHelper.lSaved = .T.
			RETURN .T.
		ENDIF
	ENDPROC 


	PROCEDURE DoMakeRTFOffline
		LPARAMETERS tcFile
		_goHelper.cDestFile = tcFile

		&& Generate RTF from the offline table
		LOCAL loRTFListener as ReportListener 
		loRtfListener = NEWOBJECT("RTFreportlistener", "PR_RTFListener")
		loRtfListener.TargetFileName = tcFile
		loRtfListener.fxFeedbackClass = _goHelper._cThermClass
		

		LOCAL lcOutputDBF, lnWidth, lnHeight
		lcOutputDBF = _goHelper.oListener.GetFullFRXData()

		IF NOT EMPTY(lcOutputDBF)
			lnWidth  = _goHelper.oListener.GETPAGEWIDTH()
			lnHeight = _goHelper.oListener.GETPAGEHEIGHT()
			loRTFListener.OutputFromData(_goHelper.oListener, lcOutputDBF, lnWidth, lnHeight)
			loRTFListener = NULL
		ENDIF 

		IF NOT FILE(tcFile)
			_goHelper.SetError(_goHelper.GetLoc("ERR_CREATI"))
			RETURN .F.
		ELSE
			_goHelper.lSaved = .T.
			RETURN .T.
		ENDIF
	ENDPROC 



	PROCEDURE DoMakeXLSOffline
		LPARAMETERS tcFile
		_goHelper.cDestFile = tcFile

		&& Generate XLS (XML worksheet) from the offline table
		LOCAL loXLSListener AS "ExcelListener" && OF HOME() + "FFC/PR_ReportListener.vcx"
		loXLSListener = NEWOBJECT("ExcelListener","pr_ExcelListener.vcx")
		loXLSListener.cWorkbookFile	= tcFile
		loXLSListener.cWorksheetName = "Sheet"

		LOCAL lcOutputDBF, lnWidth, lnHeight
		lcOutputDBF = _goHelper.oListener.GetFullFRXData()

		IF NOT EMPTY(lcOutputDBF)
			loXLSListener.OutputFromData(_goHelper.oListener)
			loXLSListener = NULL
		ENDIF 

		IF NOT FILE(tcFile)
			_goHelper.SetError(_goHelper.GetLoc("ERR_CREATI"))
			RETURN .F.
		ELSE
			_goHelper.lSaved = .T.
			RETURN .T.
		ENDIF
	ENDPROC 


	PROCEDURE DoSendEmail

		* Ensure the proof sheet is closed
		_goHelper.CloseSheets()

		LOCAL lcFile, lcFolder, lcExtensions

		IF _goHelper.lExtended
			lcExtensions = "Pdf;Rtf;Xls;Xml;Png;Tiff;Bmp;Gif;Emf;Jpg;Htm"
		ELSE
			lcExtensions = "Pdf;Rtf;Xls;Xml;Png;Tiff;Bmp;Gif;Emf;Jpg"
		ENDIF 
		
		*	lEmailAuto = .T. && Automatically generates the report output file
		*	cEmailType = "PDF" && The file type to be used in Emails (PDF, RTF, HTML, XML or XLS)
		IF _goHelper.lEmailAuto
			lcFolder = ADDBS(GETENV("TEMP"))

*			IF _goHelper.lExtended
				*!* 2010-09-17 - Jacques Parent - Add the cSaveDefName
				IF EMPTY(_goHelper.cSaveDefName)
					IF _goHelper.lExtended
						lcFile = FORCEEXT(JUSTSTEM(JUSTFNAME(;
						_goHelper.oListener.PrintJobName)), _goHelper.cEmailType) && EVL(_goHelper._oNames(n), loListener.PrintJobName)
					ELSE 
					
						IF NOT (LOWER(_goHelper.cEmailType) $ LOWER(lcExtensions))
							_goHelper.cEmailType = "PDF"
						ENDIF 
						lcFile = lcFolder + FORCEEXT(JUSTSTEM(JUSTFNAME(_goHelper._cFRXName)), _goHelper.cEmailType)

					ENDIF 
				ELSE
					lcFile = lcFolder + FORCEEXT(_goHelper.cSaveDefName, _goHelper.cEmailType)
				ENDIF
*			ELSE
*				lcFile = lcFolder + FORCEEXT(JUSTFNAME(_goHelper._cFRXName), "tif")
*			ENDIF 
		ELSE
			*!* 2010-09-17 - Jacques Parent - Add the cSaveDefName
			lcFile = PUTFILE(_goHelper.GetLoc("SAVEAS"), _goHelper.cSaveDefName, lcExtensions)
		ENDIF

		IF EMPTY(lcFile)
			RETURN
		ENDIF

		_goHelper.cDestFile = lcFile
		_goHelper._lSendingEmail = .T.


		LOCAL lcFileFormat
		lcFileFormat = LOWER(JUSTEXT(lcFile))

		DO CASE
		CASE INLIST(lcFileFormat, "png", "bmp", "jpg", "gif", "tif", "emf")
			LOCAL loListener
			loListener = This.PreviewForm.oReport
			_goHelper.lSaved = Report2Pic(loListener, lcFile, JUSTEXT(lcFile))
			loListener = NULL
			IF NOT FILE(_goHelper.cDestFile)
				_goHelper.SetError(_goHelper.GetLoc("ERR_CREATI"))
			ELSE
				_goHelper.lSaved = .T.
			ENDIF
			_goHelper.SendReportToEmail()


		CASE (lcFileFormat =  "pdf") AND (NOT _goHelper.lExtended)
			IF This.DoMakePDFOffline(lcFile)
				_goHelper.SendReportToEmail()
			ENDIF 

		CASE (lcFileFormat =  "rtf") AND (NOT _goHelper.lExtended)
			IF This.DoMakeRTFOffline(lcFile)
				_goHelper.SendReportToEmail()
			ENDIF 

		OTHERWISE

		ENDCASE


		* Close the preview form completely
		IF _goHelper.lExtended
			This.ActionClose()
		ENDIF 

		IF _goHelper._lNoWait AND ; && Top form
			NOT EMPTY(_goHelper.cDestFile) && Selected a file output
			_goHelper.DoOutput()
		ENDIF

	ENDPROC


	PROCEDURE HandledKeyPress( nKeyCode, nShiftAltCtrl )
		RETURN .F.
	ENDPROC


	PROCEDURE RELEASE
		RETURN .T.
	ENDPROC

	PROCEDURE DESTROY
	ENDPROC

ENDDEFINE
*-- END CODE


* Included controls classes

DEFINE CLASS BoxLine AS Line
	.Width = 0
	.BorderWidth = 0
	.Height = 0
	.Visible = .T.
ENDDEFINE

DEFINE CLASS cmdReport AS COMMANDBUTTON
	CAPTION = ""
	WIDTH   = _goHelper._nBtSize + 2 && 24
	HEIGHT  = _goHelper._nBtSize && 22
	SPECIALEFFECT = 2 && Hot tracking

	PROCEDURE INIT
*		This.Width = _goHelper._nBtSize + 2
*		This.Height = _goHelper._nBtSize
	ENDPROC

ENDDEFINE

DEFINE CLASS cntCopies AS CONTAINER
	BACKSTYLE = 0 && Transparent
	BORDERWIDTH = 0
	HEIGHT = 23
	WIDTH = 30
	VISIBLE = .T.

	ADD OBJECT SpnCopies1 AS spnCopies
	ADD OBJECT LblCopies1 AS lblCopies

	PROCEDURE INIT
		* This.AdjustControls()
	ENDPROC

	PROCEDURE AdjustControls
		WITH THIS
			LOCAL lcCopiesCaption
			lcCopiesCaption = _goHelper.GetLoc("COPIES")
			.LblCopies1.CAPTION = lcCopiesCaption
			.LblCopies1.AUTOSIZE = .T.
			.LblCopies1.TOP = (_goHelper._nBtSize - .LblCopies1.HEIGHT) / 2
			.LblCopies1.TOOLTIPTEXT = lcCopiesCaption
			.SpnCopies1.TOOLTIPTEXT = lcCopiesCaption
			.TOOLTIPTEXT = lcCopiesCaption

			LOCAL lnTxtWidth
			lnTxtWidth = TXTWIDTH(lcCopiesCaption, ;
				.LblCopies1.FONTNAME, ;
				.LblCopies1.FONTSIZE) * ;
				FONTMETRIC(6, .LblCopies1.FONTNAME,.LblCopies1.FONTSIZE)
			.LblCopies1.LEFT = 2
			.SpnCopies1.LEFT = lnTxtWidth + 4
			.SpnCopies1.WIDTH = .SpnCopies1.WIDTH + IIF(.SpnCopies1.FONTSIZE > 10,4,0)
			.WIDTH = lnTxtWidth + 2 + .SpnCopies1.WIDTH + 2
		ENDWITH
	ENDPROC

	PROCEDURE Enabled_Assign
		LPARAMETERS tlEnabled
		LOCAL loControl as CommandButton 
		FOR EACH loControl IN This.Controls
			loControl.Enabled = tlEnabled
		ENDFOR 
	ENDPROC 

ENDDEFINE


DEFINE CLASS spnCopies AS SPINNER
	WIDTH   = 42
	HEIGHT  = 22
	SPECIALEFFECT = 2 && Hot tracking
	INCREMENT = 1
	SPINNERHIGHVALUE = 99
	SPINNERLOWVALUE = 1
	KEYBOARDHIGHVALUE = 99
	KEYBOARDLOWVALUE = 1
	VISIBLE = .T.

	PROCEDURE INIT
		This.VALUE = _goHelper.nCopies
	ENDPROC

	PROCEDURE INTERACTIVECHANGE
		_goHelper.nCopies = This.VALUE
	ENDPROC
ENDDEFINE


DEFINE CLASS lblCopies AS LABEL
	AUTOSIZE = .T.
	BACKSTYLE = 0 && Transparent
	TOP = 2
	VISIBLE = .T.
ENDDEFINE


DEFINE CLASS cmdSave AS cmdReport
	PICTURE     = PR_IMGBTN_SAVE
	VISIBLE     = .T.

	PROCEDURE CLICK
	* This.Parent.PreviewForm.ExtensionHandler.DoSave()

*!*			IF _goHelper.lExtended = .F. && Original report
*!*				This.PARENT.PreviewForm.ExtensionHandler.DoSave(1)
*!*			ELSE
			This.PARENT.CmbSave1.VALUE = ""
			This.PARENT.CmbSave1.SETFOCUS()
			KEYBOARD "{ALT+DNARROW}"
*!*			ENDIF
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_SAVE
	ENDPROC

ENDDEFINE


DEFINE CLASS cmbSave AS COMBOBOX
	HEIGHT      = 1
	WIDTH       = 1
	VISIBLE     = .T.
	nIndex      = 0

	PROCEDURE DROPDOWN
		This.VALUE = ""
		This.nIndex = 0
	ENDPROC

	PROCEDURE VALID
		IF NOT EMPTY(This.VALUE)
			LOCAL lnIndex
			lnIndex = VAL(This.LIST(This.LISTINDEX,2))
			This.nIndex = lnIndex
			This.VALUE = ""
			This.PARENT.PreviewForm.ExtensionHandler.DoSave(lnIndex)
		ENDIF
	ENDPROC

ENDDEFINE


DEFINE CLASS cmdPrinterProps AS cmdReport
	PICTURE     = PR_IMGBTN_PRINTPREF
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.PreviewForm.ExtensionHandler.DoCustomPrint()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_PRINTPREF
	ENDPROC

ENDDEFINE


DEFINE CLASS cmdSetup AS cmdReport
	PICTURE     = PR_IMGBTN_SETUP
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.PreviewForm.ExtensionHandler.DoSetup()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_SETUP
	ENDPROC

ENDDEFINE


DEFINE CLASS cmdEmail AS cmdReport
	PICTURE     = PR_IMGBTN_EMAIL
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.PreviewForm.ExtensionHandler.DoSendEmail()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_EMAIL
	ENDPROC

ENDDEFINE


DEFINE CLASS cmdExit AS cmdReport
	PICTURE     = PR_IMGBTN_CLOSE
	VISIBLE     = .T.

	PROCEDURE CLICK
		* Hide the Preview form
		This.PARENT.PreviewForm.VISIBLE = .F.
		_goHelper.lPrinted = .F.

		* Ensure the proof sheet is closed
		_goHelper.CloseSheets()

		* Close the report window
	
		This.PARENT.PreviewForm.ExtensionHandler.ActionClose()
	ENDPROC

	PROCEDURE MOUSEENTER
		LPARAMETERS nButton, nShift, nXCoord, nYCoord
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_CLOSE2
	ENDPROC

	PROCEDURE MOUSELEAVE
		LPARAMETERS nButton, nShift, nXCoord, nYCoord
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_CLOSE
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_CLOSE
	ENDPROC
ENDDEFINE



DEFINE CLASS cmdPrintEx AS cmdReport
	PICTURE     = PR_IMGBTN_PRINT
	VISIBLE     = .T.

	PROCEDURE INIT
		This.TOOLTIPTEXT = PR_PRINTREPOR
	ENDPROC

	PROCEDURE RIGHTCLICK
	* This.Parent.PreviewForm.ExtensionHandler.DoCustomPrint()
	ENDPROC

	PROCEDURE CLICK
		This.PARENT.PreviewForm.ExtensionHandler.ActionPrintEx()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_PRINT
	ENDPROC
ENDDEFINE


DEFINE CLASS cmdGotoEx AS cmdReport
	PICTURE     = PR_IMGBTN_GOTOPG
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.PARENT.PreviewForm.ExtensionHandler.ActionGotoPage()
	ENDPROC

	PROCEDURE INIT
	ENDPROC

ENDDEFINE


DEFINE CLASS cntSearch AS CONTAINER
	BACKSTYLE = 0 && Transparent
	BORDERWIDTH = 0
	HEIGHT = 23
	WIDTH = 30
	VISIBLE = .T.

	ADD OBJECT CmdSearch1      AS cmdSearch
	ADD OBJECT CmdSearchAgain1 AS cmdSearchAgain
	ADD OBJECT CmdSearchBack1  AS cmdSearchBack

	PROCEDURE AdjustControls
	ENDPROC
	
	PROCEDURE Enabled_Assign
		LPARAMETERS tlEnabled
		LOCAL loControl as CommandButton 
		FOR EACH loControl IN This.Controls
			loControl.Enabled = tlEnabled
		ENDFOR 
	ENDPROC 
	
ENDDEFINE


DEFINE CLASS cmdSearch AS cmdReport
	PICTURE     = PR_IMGBTN_SEARCH
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.Parent.PreviewForm.ExtensionHandler.DoSearch()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.Parent.PreviewForm.ExtensionHandler.IMGBTN_SEARCH
	ENDPROC
ENDDEFINE


DEFINE CLASS cmdSearchAgain AS cmdReport
	PICTURE     = PR_IMGBTN_SEARCHAGAIN
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.Parent.PreviewForm.ExtensionHandler.DoSearchAgain()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.Parent.PreviewForm.ExtensionHandler.IMGBTN_SEARCHAGAIN
	ENDPROC

ENDDEFINE



DEFINE CLASS cmdSearchBack AS cmdReport
	PICTURE     = PR_IMGBTN_SEARCHBACK
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.Parent.PreviewForm.ExtensionHandler.DoSearchBack()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.Parent.PreviewForm.ExtensionHandler.IMGBTN_SEARCHBACK
	ENDPROC

ENDDEFINE






DEFINE CLASS cmbPrinters AS COMBOBOX
	WIDTH = 200
	COLUMNCOUNT = 2
	COLUMNLINES = .F.
	ROWSOURCETYPE = 0 && None
	COLUMNWIDTHS = "220,140"
	STYLE = 2 && DropDown List
	VISIBLE = .T.
	_cOriginalPrinter = ""

	PROCEDURE INIT

		LOCAL ARRAY laPrinters(1)
		=APRINTERS(laPrinters)

		LOCAL lcDefPrintern, lcCurrPrinter, N
		lcDefPrinter = SET("Printer",3)

		WITH THIS AS COMBOBOX

			FOR N = 1 TO ALEN(laPrinters) STEP 2
				lcCurrPrinter = laPrinters(N)
				IF UPPER(ALLTRIM(lcDefPrinter)) = UPPER(ALLTRIM(lcCurrPrinter))
					lcDefPrinter = lcCurrPrinter
					.ADDITEM(lcCurrPrinter)
					.LIST(.NEWINDEX, 2) = laPrinters(N+1)
					EXIT
				ENDIF
			ENDFOR

			FOR N = 1 TO ALEN(laPrinters) STEP 2
				lcCurrPrinter = laPrinters(N)
				IF NOT (UPPER(ALLTRIM(lcDefPrinter)) = UPPER(ALLTRIM(lcCurrPrinter)))
					.ADDITEM(lcCurrPrinter)
					.LIST(.NEWINDEX, 2) = laPrinters(N+1)
				ENDIF
			ENDFOR

			* .Value = lcDefPrinter
			.LISTINDEX = 1
			._cOriginalPrinter = lcDefPrinter

			LOCAL lcItem
			FOR N = 1 TO .LISTCOUNT
				lcItem = .LIST(N,1)
				IF LEFT(lcItem,1) = "\"
					.LIST(N,1) = "\\" + lcItem
				ENDIF

				lcItem = .LIST(N,2)
				IF LEFT(lcItem,1) = "\"
					.LIST(N,2) = "\\" + lcItem
				ENDIF
			ENDFOR

		ENDWITH

		IF _goHelper.lExtended = .F.
			BINDEVENT(THIS, "Enabled", THIS, "DisableCombo", 1)
		ENDIF

	ENDPROC

	PROCEDURE DisableCombo
		This.ENABLED = .F.
	ENDPROC


	PROCEDURE VALID
		LOCAL lcValue, lcOrigPrinter
		lcValue = This.VALUE
		lcOrigPrinter = _goHelper._cOriginalPrinter

		IF LEFT(lcValue,1) = "\" AND SUBSTR(lcValue,2,1) <> "\"
			lcValue = "\" + lcValue
		ENDIF

		IF ALLTRIM(UPPER(lcValue)) <> ALLTRIM(UPPER(lcOrigPrinter))
			_goHelper.cPrinterName = lcValue
		ENDIF
	ENDPROC

ENDDEFINE

DEFINE CLASS cmdProof AS cmdReport
	PICTURE = PR_IMGBTN_MINI
	VISIBLE = .T.

	PROCEDURE CLICK()
		This.PARENT.PreviewForm.ExtensionHandler.DoProof()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_MINI
	ENDPROC
ENDDEFINE


DEFINE CLASS cntCanvas AS Container
	BackStyle = 0 
	BorderWidth = 0
ENDDEFINE



**************************************************
*-- Class:        frxgotopageform
*-- ParentClass:  frmReport
*-- BaseClass:    form
*
DEFINE CLASS CustomFrxGotoPageForm AS frmReport

	HEIGHT = 92
	WIDTH = 345
	SHOWWINDOW = 1
	DOCREATE = .T.
	AUTOCENTER = .T.
	BORDERSTYLE = 2
	CLOSABLE = .F.
	MAXBUTTON = .F.
	MINBUTTON = .F.
	ALWAYSONTOP = .T.
	ALLOWOUTPUT = .F.
*-- Provides the current page number for report output.
	PAGENO = 0
*-- Provides a PageTotal for report output.
	PAGETOTAL = 0
	oParentForm = (.NULL.)
	NAME = "frxgotopageform"

	ADD OBJECT shp1 AS SHAPE WITH ;
		TOP = 15, ;
		LEFT = 12, ;
		HEIGHT = 66, ;
		WIDTH = 224, ;
		BACKSTYLE = 0, ;
		ZORDERSET = 0, ;
		STYLE = 3, ;
		NAME = "Shp1"

	ADD OBJECT spnpageno AS SPINNER WITH ;
		HEIGHT = 21, ;
		INPUTMASK = "9999", ;
		LEFT = 64, ;
		TOP = 36, ;
		WIDTH = 126, ;
		ZORDERSET = 1, ;
		NAME = "spnPageno"

	ADD OBJECT lblcaption AS LABEL WITH ;
		LEFT = 20, ;
		TOP = 8, ;
		ZORDERSET = 2, ;
		STYLE = 3, ;
		NAME = "lblCaption", ;
		AUTOSIZE = .T.

	ADD OBJECT cmdok AS cmdReport WITH ;
		TOP = 15, ;
		LEFT = 248, ;
		WIDTH = 84, ;
		HEIGHT = 25, ;
		DEFAULT = .T., ;
		ZORDERSET = 3, ;
		NAME = "cmdOK", ;
		SPECIALEFFECT = 0 && 3D


	ADD OBJECT cmdcancel AS cmdReport WITH ;
		TOP = 47, ;
		LEFT = 248, ;
		WIDTH = 84, ;
		HEIGHT = 25, ;
		ZORDERSET = 4, ;
		NAME = "cmdCancel", ;
		SPECIALEFFECT = 0, ; && 3D
		CANCEL = .F.



	PROCEDURE SHOW
		LPARAMETERS nStyle
		*-----------------------------------------
		* Fix for SP1: Handle positioning in top-level form
		* See frxPreviewForm::ActionGoToPage()
		* Addresses bug# 474691
		*-----------------------------------------
		This.PAGENO    = This.oParentForm.currentPage
		This.PAGETOTAL = This.oParentForm.PAGETOTAL

		This.CAPTION   = _goHelper.GetLoc("REPORTTITL")
		This.lblcaption.CAPTION = _goHelper.GetLoc("GOTOPG_CAP") + " (1-" + TRANSFORM(This.PAGETOTAL) + ")"

		IF This.oParentForm.SHOWWINDOW = 2 && as top-level form
			*-----------------------------------
			* If parent preview window is a top-level form,
			* center the child window in the view port:
			*-----------------------------------
			This.AUTOCENTER = .F.
			This.LEFT = This.oParentForm.VIEWPORTLEFT + INT(This.oParentForm.WIDTH/2  - This.WIDTH/2)
			This.TOP  = This.oParentForm.VIEWPORTTOP  + INT(This.oParentForm.HEIGHT/2 - This.HEIGHT/2)
		ELSE
			This.AUTOCENTER = .T.
		ENDIF
*--------------

		This.spnpageno.SPINNERLOWVALUE = 1
		This.spnpageno.SPINNERHIGHVALUE = This.PAGETOTAL

		This.spnpageno.KEYBOARDLOWVALUE = 1
		This.spnpageno.KEYBOARDHIGHVALUE = This.PAGETOTAL

		This.spnpageno.VALUE = This.PAGENO

		DODEFAULT(m.nStyle)
	ENDPROC

	PROCEDURE INIT
		This.cmdok.CAPTION     = _goHelper.GetLoc("GOTOPG_OK")
		This.cmdcancel.CAPTION = _goHelper.GetLoc("CANCEL")
	ENDPROC

	PROCEDURE spnpageno.LOSTFOCUS
		IF This.VALUE < This.SPINNERLOWVALUE
			This.VALUE = 1
		ENDIF
		IF This.VALUE > This.SPINNERHIGHVALUE
			This.VALUE = This.SPINNERHIGHVALUE
		ENDIF
		DODEFAULT()
	ENDPROC

	PROCEDURE cmdok.CLICK
		This.PARENT.PAGENO = This.PARENT.spnpageno.VALUE
		This.PARENT.HIDE()
	ENDPROC

	PROCEDURE cmdcancel.CLICK
		This.PARENT.HIDE()
		Thisform.Release()
	ENDPROC

ENDDEFINE
*-- EndDefine: frxgotopageform
**************************************************


**************************************************
*-- Class:        frmReport
*-- ParentClass:  form
*-- BaseClass:    form
*-- Author:       CChalom
DEFINE CLASS frmReport AS FORM
	ICON 	 = PR_FORMICON
	SHOWTIPS = .T.
ENDDEFINE
*-- EndDefine: frxgotopageform
**************************************************


**************************************************
*-- Class:        proofshape
*-- ParentClass:  shape
*-- BaseClass:    shape
*-- Author:       Colin Nicholls
DEFINE CLASS proofshape AS SHAPE
	HEIGHT = 110
	WIDTH = 85

*-- Provides the current page number for report output.
	PAGENO = 0
	NAME = "proofshape"

	PROCEDURE MOUSELEAVE
		LPARAMETERS nButton, nShift, nXCoord, nYCoord
		This.MOUSEPOINTER = 0 && Default
		* This.ResetToDefault("BorderColor")
	ENDPROC

	PROCEDURE MOUSEENTER
		LPARAMETERS nButton, nShift, nXCoord, nYCoord
		This.MOUSEPOINTER = 15 && Hand
		* This.BorderColor = RGB(255,0,0) && Red
		This.PARENT.nCurrShape = This.PAGENO
	ENDPROC

	PROCEDURE CLICK
		THISFORM.currentPage = This.PAGENO
		THISFORM.HIDE()
		ACTIVATE SCREEN
	ENDPROC
ENDDEFINE
*-- EndDefine: proofshape
**************************************************


**************************************************
*-- Class:        PageSetBtn
*-- ParentClass:  Commandbutton
*-- BaseClass:    Commandbutton
*-- Author:       Jacques Parent
DEFINE CLASS PageSetBtn AS COMMANDBUTTON
	HEIGHT 	= _goHelper._nBtSize
	WIDTH 	= _goHelper._nBtSize
	CAPTION	= ""
	cType	= "NEXT"

	PROCEDURE CLICK
		DO CASE
		CASE This.cType == "FIRST"
			This.PARENT.nPageSet = 1

		CASE This.cType == "PREV"
			This.PARENT.nPageSet = This.PARENT.nPageSet - 1

		CASE This.cType == "NEXT"
			This.PARENT.nPageSet = This.PARENT.nPageSet + 1

		CASE This.cType == "LAST"
			This.PARENT.nPageSet = CEILING(This.PARENT.nPages / This.PARENT.nMaxMiniatureItem)

		ENDCASE

		This.PARENT.RefreshPageBtn()
	ENDPROC

	PROCEDURE REFRESH
		DO CASE
		CASE This.cType == "FIRST"
			This.ENABLED = NOT (This.PARENT.nPageSet == 1)

		CASE This.cType == "PREV"
			This.ENABLED = NOT (This.PARENT.nPageSet == 1)

		CASE This.cType == "NEXT"
			This.ENABLED = NOT (This.PARENT.nPageSet == CEILING(This.PARENT.nPages / This.PARENT.nMaxMiniatureItem))

		CASE This.cType == "LAST"
			This.ENABLED = NOT (This.PARENT.nPageSet == CEILING(This.PARENT.nPages / This.PARENT.nMaxMiniatureItem))

		ENDCASE
	ENDPROC

ENDDEFINE
*-- EndDefine: PageSetBtn
**************************************************


#DEFINE SPACE_PIXELS 10
**************************************************
*-- Class:        proofsheet
*-- ParentClass:  form
*-- BaseClass:    form
*-- Author:       Colin Nicholls
DEFINE CLASS proofsheet AS frmReport
	HEIGHT 				= 274
	WIDTH 				= 622
	SCROLLBARS 			= 3
	DOCREATE 			= .T.
	AUTOCENTER 			= .T.
	SHOWWINDOW 			= 1 && In Top-Level Form
	DESKTOP				= .T.

	currentPage 		= 0
	REPORTLISTENER 		= .NULL.
	lstarted 			= .F.
	nPages 				= 1
	lpainted 			= .F.
	nCurrShape 			= 0
	NAME 				= "proofsheet"

	nPageSet			= 1
	lShowDone			= .F.
	linactive           = .F.

	nOtherThenProofObj	= 0
	nMaxMiniatureItem	= 64

	OldEscFunction		= ""


	PROCEDURE INIT
		This.ADDOBJECT("PageSetFirst","PageSetBtn")
		This.nOtherThenProofObj = This.nOtherThenProofObj + 1

		WITH This.PageSetFirst
			.TOP  		= 3
			.LEFT 		= SPACE_PIXELS

			.CAPTION 	= ""
			.PICTURE 	= PR_IMGBTN_TOP
			.TOOLTIPTEXT= _goHelper.GetLoc("MINIFIRSTT")

			.cType		= "FIRST"
			.VISIBLE 	= .F.
		ENDWITH

		This.ADDOBJECT("PageSetPrev","PageSetBtn")
		This.nOtherThenProofObj = This.nOtherThenProofObj + 1

		WITH This.PageSetPrev
			.TOP  		= 3
			.LEFT 		= This.PageSetFirst.LEFT + This.PageSetFirst.WIDTH + 2

			.CAPTION 	= ""
			.PICTURE 	= PR_IMGBTN_PREV
			.TOOLTIPTEXT= _goHelper.GetLoc("MINIPREVTI")

			.cType		= "PREV"
			.VISIBLE 	= .F.
		ENDWITH

		This.ADDOBJECT("PageSetNext","PageSetBtn")
		This.nOtherThenProofObj = This.nOtherThenProofObj + 1

		WITH This.PageSetNext
			.TOP  		= 3
			.LEFT 		= This.PageSetPrev.LEFT + This.PageSetPrev.WIDTH + 2

			.CAPTION 	= ""
			.PICTURE 	= PR_IMGBTN_NEXT
			.TOOLTIPTEXT= _goHelper.GetLoc("MININEXTTI")

			.cType		= "NEXT"
			.VISIBLE 	= .F.
		ENDWITH

		This.ADDOBJECT("PageSetLast","PageSetBtn")
		This.nOtherThenProofObj = This.nOtherThenProofObj + 1

		WITH This.PageSetLast
			.TOP  		= 3
			.LEFT 		= This.PageSetNext.LEFT + This.PageSetNext.WIDTH + 2

			.CAPTION 	= ""
			.PICTURE 	= PR_IMGBTN_BOTT
			.TOOLTIPTEXT= _goHelper.GetLoc("MINILASTTI")

			.cType		= "LAST"
			.VISIBLE 	= .F.
		ENDWITH


		This.ADDOBJECT("PageSetCaption","Label")
		This.nOtherThenProofObj = This.nOtherThenProofObj + 1

		WITH This.PageSetCaption
			.LEFT 		= This.PageSetLast.LEFT + This.PageSetLast.WIDTH + 10
			.AUTOSIZE 	= .T.

			.CAPTION 	= ""
			.FONTNAME	= "Arial"
			.FONTSIZE	= 10
			.FONTBOLD 	= .T.

			.TOP  		= This.PageSetNext.TOP + ((This.PageSetNext.HEIGHT-.HEIGHT)/2)

			.VISIBLE 	= .F.
		ENDWITH

		*!* Let the form be deactivated with the EACAPE key
		This.OldEscFunction = ON("KEY", "ESCAPE")
		ON KEY LABEL ESCAPE _VFP.ACTIVEFORM.RELEASE()

	ENDPROC

	PROCEDURE RefreshPageBtn
		This.PageSetNext.REFRESH()
		This.PageSetPrev.REFRESH()
	ENDPROC

	PROCEDURE SetReport
		LPARAMETERS oReport
		This.REPORTLISTENER = m.oReport
		This.nPages = m.oReport.OUTPUTPAGECOUNT
	ENDPROC

	PROCEDURE RESIZE

		IF This.WINDOWSTATE = 1 && Minimized
			This.linactive = .T.
		ELSE
			IF This.linactive = .T.
				This.lShowDone = .F.
				This.PAINT()
				This.linactive = .F.
			ENDIF
		ENDIF

		This.SHOW()
	ENDPROC

	PROCEDURE ACTIVATE
		This.lShowDone = .F.
	ENDPROC

	PROCEDURE QUERYUNLOAD
		This.HIDE()
		ACTIVATE SCREEN
	ENDPROC

	PROCEDURE nPageSet_assign
		LPARAMETERS vNewValue

		DO CASE
		CASE  (This.nPageSet == CEILING(This.nPages / This.nMaxMiniatureItem)) ;
				AND (vNewValue <> CEILING(This.nPages / This.nMaxMiniatureItem))
			* We have to display ALL miniatures

			FOR i = This.nOtherThenProofObj+1 TO This.OBJECTS.COUNT
				IF NOT This.OBJECTS[i].VISIBLE
					This.OBJECTS[i].VISIBLE = .T.
				ENDIF
			ENDFOR

		CASE (This.nPageSet <> CEILING(This.nPages / This.nMaxMiniatureItem)) ;
				AND (vNewValue == CEILING(This.nPages / This.nMaxMiniatureItem))
				*!* We have to display only some miniatures

			FOR i = This.nOtherThenProofObj+1 TO This.OBJECTS.COUNT

				IF i > This.nPages - ((CEILING(This.nPages / This.nMaxMiniatureItem)-1) * ;
						This.nMaxMiniatureItem) + This.nOtherThenProofObj
				* IF I > This.nPages - (This.nPageSet * This.nMaxMiniatureItem) + This.nOtherThenProofObj
					This.OBJECTS[i].VISIBLE = .F.
				ENDIF
			ENDFOR

		ENDCASE

		This.nPageSet = vNewValue

		This.SetProofCaption()

		This.SHOW()
	ENDPROC

	PROCEDURE SetProofCaption
	*!* ---------------------- *!*
	*!* Calculate the caption! *!*
	*!* ---------------------- *!*
		LOCAL cMessage, nFirstPage, nLastPage

		nFirstPage 	= ((This.nPageSet-1) * This.nMaxMiniatureItem) + 1
		nLastPage  	= MIN(This.nPageSet * This.nMaxMiniatureItem, This.nPages)

		cMessage	= _goHelper.GetLoc("MINILABEL")	&& "Pages from %FP% to %LP%"

		This.PageSetCaption.CAPTION = STRTRAN(STRTRAN(cMessage, "%FP%", TRANSFORM(nFirstPage)), "%LP%", TRANSFORM(nLastPage))
	ENDPROC

	PROCEDURE ReportListener_Assign
		LPARAMETERS oNewValue
		This.REPORTLISTENER = oNewValue
		This.DoResizeProofSheet()
	ENDPROC

	PROCEDURE nMaxMiniatureItem_Assign
		LPARAMETERS nNewItem
		This.nMaxMiniatureItem = nNewItem
		This.DoResizeProofSheet()
	ENDPROC

	PROCEDURE DoResizeProofSheet
		IF NOT ISNULL(This.REPORTLISTENER)
			*!* Recalculating the Proof Page size to display the max miniature at one time
			nProofWidth  = This.REPORTLISTENER.GETPAGEWIDTH() / 96
			nProofHeight = This.REPORTLISTENER.GETPAGEHEIGHT() / 96

			*!* Calculating the max col
			nMaxScreenWToConsidere = (_SCREEN.WIDTH /5) * 4		&& 4/5;  Just for "estetics"
			nMaxScreenHToConsidere = (_SCREEN.HEIGHT/5) * 4		&& 4/5;  Just for "estetics"

			nDiv = nProofWidth+SPACE_PIXELS
			nNbCol = INT((nMaxScreenWToConsidere - SPACE_PIXELS) / nDiv)

			IF nNbCol >= This.nPages
				*!* The width does need to be so large...
				*!* We will keep only the space needed do display the pages!
				nNbCol = This.nPages
			ENDIF

			*!* Now, calculating the width to set the form
			This.WIDTH = SPACE_PIXELS + (nNbCol * (nProofWidth+SPACE_PIXELS))


			*!* -------------------
			*!* Now for the hight
			*!* -------------------
			*!* Calculating number of row...
			*!* We will keep in mind that if there is less item to display than the miximum possible
			*!* then we dont need to reserve the whole place
			nNbRow = CEILING(MIN(This.nMaxMiniatureItem, This.nPages)/ nNbCol)


			*!* Checking if we must display nav btn or not
			IF CEILING(This.nPages / This.nMaxMiniatureItem) > 1
				nBaseHeight = _goHelper._nBtSize + SPACE_PIXELS
			ELSE
				nBaseHeight = SPACE_PIXELS
			ENDIF

			*!* Now, calculating the height to set the form
			This.HEIGHT = MIN(nMaxScreenHToConsidere, nBaseHeight + (nNbRow * (nProofHeight+SPACE_PIXELS)))


			*!* Is the Height sufficient to display all of the miniatures?
			*!* If not, there will be a vertical scrool bar and we must reserve space for that.
			IF This.HEIGHT < nBaseHeight + (nNbRow * (nProofHeight+SPACE_PIXELS))
				*!* Add some space for the scrool bar to the WIDTH
				This.WIDTH = This.WIDTH + 20
			ENDIF

			This.AUTOCENTER = .T.	&& Auto center the proof sheet
		ENDIF
	ENDPROC

	PROCEDURE PAINT
		IF (NOT ISNULL(This.REPORTLISTENER))

			IF NOT This.lShowDone
				FOR i = ((This.nPageSet - 1) * This.nMaxMiniatureItem) + 1 TO This.nPageSet * This.nMaxMiniatureItem
					IF TYPE("This.Objects[i - ((This.nPageSet - 1) * This.nMaxMiniatureItem) + This.nOtherThenProofObj]") == "O"
						IF i > This.nPages
							* This.Objects[i - ((This.nPageSet - 1) * This.nMaxMiniatureItem) + This.nOtherThenProofObj].Visible = .F.
							EXIT
						ELSE
							This.OBJECTS[i - ((This.nPageSet - 1) * This.nMaxMiniatureItem) + This.nOtherThenProofObj].TOOLTIPTEXT = ;
								_goHelper.GetLoc("PAGECAPTIO") + " " + TRANSFORM(i)

							This.REPORTLISTENER.OUTPUTPAGE( m.i, This.OBJECTS[i - ((This.nPageSet - 1) * This.nMaxMiniatureItem) + This.nOtherThenProofObj],2)
						ENDIF
					ELSE
						EXIT
					ENDIF
				ENDFOR

				This.lShowDone = .T.
			ENDIF

			*!*	FOR i = 1 to min(64, This.nPages)
			*!*		This.ReportListener.OutputPage( m.i, This.Objects[m.i],2)
			*!*	ENDFOR
		ENDIF
	ENDPROC

	PROCEDURE SHOW
		LPARAMETERS nStyle

		IF CEILING(This.nPages / This.nMaxMiniatureItem) > 1
			*!* Since we have multi pages set, then we must display NAV buttons.

			IF NOT This.lstarted
				This.PageSetFirst.VISIBLE 	= .T.
				This.PageSetPrev.VISIBLE 	= .T.
				This.PageSetNext.VISIBLE 	= .T.
				This.PageSetLast.VISIBLE 	= .T.
				This.PageSetCaption.VISIBLE = .T.
			ENDIF

			iRowOffset = SPACE_PIXELS * 3 + IIF(_goHelper._nBtSize > 24, _goHelper._nBtSize - 20, 0)	&& Set the start to let some place to the NAV buttons
		ELSE
			*!* There is only one page set, so there is no need to display navigation button!
			*!* They are alerady
			iRowOffset = SPACE_PIXELS	&& Set the start to the top!
		ENDIF

		iColOffset = SPACE_PIXELS


		nProofWidth  = This.REPORTLISTENER.GETPAGEWIDTH() / 96
		nProofHeight = This.REPORTLISTENER.GETPAGEHEIGHT() / 96

		iColCount  = INT((THISFORM.WIDTH - iColOffset)/ (nProofWidth + SPACE_PIXELS))	&& Number of column that can fit in the space allowed

		nCurCol = 1

		This.lShowDone = .F.

		FOR i = ((This.nPageSet - 1) * This.nMaxMiniatureItem) + 1 TO MIN(This.nPageSet * This.nMaxMiniatureItem, This.nPages)
			* Calculate the objectID here to facilitate reading the code
			nObjectID = i - ((This.nPageSet - 1) * This.nMaxMiniatureItem) + This.nOtherThenProofObj

			IF NOT This.lstarted
				This.ADDOBJECT(SYS(2015),"ProofShape")
				This.OBJECTS[nObjectID].VISIBLE = .T.

				This.OBJECTS[nObjectID].WIDTH  = nProofWidth
				This.OBJECTS[nObjectID].HEIGHT = nProofHeight
			ENDIF

			* Arrange shapes on form:
			TRY
				This.OBJECTS[nObjectID].TOP  	= iRowOffset
				This.OBJECTS[nObjectID].LEFT 	= SPACE_PIXELS + ((nCurCol-1) * (nProofWidth+SPACE_PIXELS))		&& iColOffset

				This.OBJECTS[nObjectID].PAGENO = m.i

				nCurCol = nCurCol + 1

				IF nCurCol > iColCount
					nCurCol = 1
					iRowOffset = iRowOffset + SPACE_PIXELS + This.OBJECTS[nObjectID].HEIGHT
				ENDIF
			CATCH
			ENDTRY
		ENDFOR

		This.lstarted = .T.
		DODEFAULT(nStyle)
	ENDPROC

	PROCEDURE DESTROY
		LOCAL cEscFunction
		This.REPORTLISTENER = NULL

		* Put back the ESCAPE KEY action with ON KEY LABEL
		EscFunction = This.OldEscFunction
		ON KEY LABEL ESCAPE &EscFunction
	ENDPROC
ENDDEFINE
*-- EndDefine: proofsheet
**************************************************



*********************************************************************
FUNCTION PR_ScreenToClient(HWND, cPoint)
*********************************************************************
	DECLARE INTEGER ScreenToClient IN user32 AS PR_ScreenToClient INTEGER HWND, STRING @cPoint
	RETURN PR_ScreenToClient(m.hWND, @m.cPoint)
ENDFUNC

*********************************************************************
FUNCTION PR_GetCursorPos(cPoint)
*********************************************************************
	DECLARE INTEGER GetCursorPos IN user32 AS PR_GetCursorPos STRING @cPoint
	RETURN PR_GetCursorPos(@m.cPoint)
ENDFUNC

*********************************************************************
FUNCTION PR_PathFileExists(pszPath)
*********************************************************************
	DECLARE INTEGER PathFileExists IN shlwapi AS PR_PathFileExists STRING pszPath
	RETURN PR_PathFileExists(@m.pszPath)
ENDFUNC

*********************************************************************
FUNCTION PR_GetFocus()
*********************************************************************
	DECLARE INTEGER GetFocus IN user32 AS PR_GetFocus
	RETURN PR_GetFocus()
ENDFUNC

*********************************************************************
FUNCTION PR_GetWindowText(HWND, lpString, cch)
*********************************************************************
	DECLARE INTEGER GetWindowText IN user32;
		AS PR_GetWindowText ;
		INTEGER HWND, STRING @lpString, INTEGER cch
	RETURN PR_GetWindowText(HWND, @lpString, cch)
ENDFUNC

*********************************************************************
FUNCTION PR_GetActiveWindow()
*********************************************************************
	DECLARE INTEGER GetActiveWindow IN user32 AS PR_GetActiveWindow
	RETURN PR_GetActiveWindow()
ENDFUNC

*********************************************************************
FUNCTION PR_MAPISendDocuments(ulUIParam, lpszDelimChar, lpszFullPaths, lpszFileNames, ulReserved)
*********************************************************************
	DECLARE INTEGER MAPISendDocuments IN mapi32;
		AS PR_MAPISendDocuments ;
		INTEGER ulUIParam, STRING lpszDelimChar,;
		STRING lpszFullPaths, STRING lpszFileNames,;
		INTEGER ulReserved
	RETURN PR_MAPISendDocuments(ulUIParam, lpszDelimChar, lpszFullPaths, lpszFileNames, ulReserved)
ENDFUNC

********************************************************************
PROCEDURE CleanClauses(tcClauses)
********************************************************************
	LOCAL lcClauses
	lcClauses = STRTRAN(tcClauses, "NOCONSOLE", "")
	lcClauses = STRTRAN(lcClauses, "noconsole", "")
	lcClauses = STRTRAN(lcClauses, "PREVIEW", "")
	lcClauses = STRTRAN(lcClauses, "preview", "")
	RETURN lcClauses
ENDPROC

********************************************************************
PROCEDURE IsDotMatrix(tcPrinter)
********************************************************************
	#DEFINE DC_BINS 6
	#DEFINE DMBIN_TRACTOR 8
	LOCAL lnBins, lcBuff
	lcBuff = SPACE(512)
	lnBins = PR_DeviceCapabilities (tcPrinter, NULL, DC_BINS, @lcBuff, NULL)

	RETURN (CHR(DMBIN_TRACTOR) + CHR(0)) $ LEFT(lcBuff, lnBins * 2)
ENDPROC

*********************************************************************
FUNCTION PR_DeviceCapabilities(sPrinter, sPort, nCapability, sReturn, pDevMode)
*********************************************************************
	DECLARE LONG DeviceCapabilities IN WinSpool.drv AS PR_DeviceCapabilities ;
		STRING @ sPrinter, STRING @ sPort, ;
		INTEGER nCapability, STRING @ sReturn, STRING @ pDevMode

	RETURN PR_DeviceCapabilities(sPrinter, sPort, nCapability, @sReturn, pDevMode)
ENDFUNC

*********************************************************************
FUNCTION PR_MessageBeep(nType)
* http://msdn.microsoft.com/en-us/library/ms680356(VS.85).aspx
*********************************************************************
    DECLARE INTEGER MessageBeep in Win32API AS PR_MessageBeep integer
	RETURN PR_MessageBeep(nType)
ENDFUNC

*********************************************************************
PROCEDURE GetParentWindow
*********************************************************************
* Returns the Windows handle from the active form
	LOCAL hWindow
	hWindow = PR_GetFocus()
	RETURN GetWinText(hWindow)
ENDPROC

*********************************************************************
FUNCTION  GetWinText(hWindow)
*********************************************************************
	LOCAL lnBufsize, lcBuffer
	lnBufsize = 1024
	lcBuffer = REPLI(CHR(0), lnBufsize)
	lnBufsize = PR_GetWindowText(hWindow, @lcBuffer, lnBufsize)
	RETURN  IIF(lnBufsize=0, "", LEFT(lcBuffer,lnBufsize))

*********************************************************************
PROCEDURE SendMailEx(tcAttachment, tcRecipient, tcSubject, tcText)
*********************************************************************
* Procedure to send email attachment using Mapi
	LOCAL lcAttachment, lcRecipient, lcSubject, lcText
	lcAttachment  = EVL(tcAttachment, "")
	lcRecipient   = EVL(tcRecipient, "")
	lcSubject     = EVL(tcSubject, "")
	lcText        = EVL(tcText, "")


* http://www.atoutfox.org/articles.asp?ACTION=FCONSULTER&ID=0000000120
* By Mike Gagnon
* À titre d’exemple voici comment utiliser les appels API pour faire appel au simple MAPI.
* Le code suivant est gracieuseté d’Anatoliy Mogylevets de www.news2news.com/vfp.
* The code below is a courtesy of Anatoliy Mogylevets, from www.news2news.com/vfp
* It received some few tweaks in order to accept attachments

* MAPISendMail function
* http://msdn.microsoft.com/en-us/library/dd296721(VS.85).aspx

	#DEFINE MAPI_ORIG        0
	#DEFINE MAPI_TO          1
	#DEFINE MAPI_DIALOG      8
	#DEFINE SUCCESS_SUCCESS  0

	DO DeclMapi

	LOCAL hSession
	hSession = getNewSession()
	IF hSession = 0
* ? "Unable to log on."
		RETURN
	ENDIF

	LOCAL loRcpEmail, loSndBuf, lcRcpBuf, loSubject, loNoteText,;
		loRcpBuf, lcMapiMessage, lnResult


	LOCAL lcAttachment
	lcAttachment = tcAttachment


* MapiFileDesc Structure
* http://msdn.microsoft.com/en-us/library/dd296737(v=VS.85).aspx
*!*	typedef struct {
*!*	  ULONG  ulReserved;
*!*	  ULONG  flFlags;
*!*	  ULONG  nPosition;
*!*	  LPSTR  lpszPathName;
*!*	  LPSTR  lpszFileName;
*!*	  LPVOID lpFileType;
*!*	} MapiFileDesc, *lpMapiFileDesc

	LOCAL loAttach, loAttPath, loAttName
	LOCAL lcAttStruct
	loAttPath = CREATEOBJECT("PChar", lcAttachment)
	loAttName = CREATEOBJECT("PChar", JUSTFNAME(lcAttachment))

	lcAttStruct = ;
		num2dword( 0 ) +;
		num2dword( 0 ) +;
		num2dword( 0 ) +;
		num2dword( loAttPath.getAddr() ) +; && AttachmentPathName
	num2dword( loAttName.getAddr() ) +; && AttachmentName
	num2dword( 0 )
	loAttach = CREATEOBJECT ("PChar", lcAttStruct)

	* populating message recipient, subject and body
	loSubject  = CREATEOBJECT ("PChar", lcSubject)
	loNoteText = CREATEOBJECT ("PChar", lcText)

	* initializing buffer with single recipient data
	IF NOT EMPTY(lcRecipient)
		loRcpEmail = CREATEOBJECT ("PChar", lcRecipient)
		lcRcpBuf = num2dword(0) +;
			num2dword(MAPI_TO) +;
			num2dword(loRcpEmail.getAddr()) +;
			REPLI(CHR(0), 12)
		loRcpBuf = CREATEOBJECT ("PChar", lcRcpBuf)
	ENDIF

	* initializing buffer with sender data -- practically empty
	loSndBuf = CREATEOBJECT ("PChar", REPLI(CHR(0), 24))
	* merging all parts to a message buffer -- no file attachments


	* MapiMessage Structure
	* http://msdn.microsoft.com/en-us/library/dd296732(v=VS.85).aspx
	*!*	typedef struct {
	*!*	  ULONG           ulReserved;
	*!*	  LPSTR           lpszSubject;
	*!*	  LPSTR           lpszNoteText;
	*!*	  LPSTR           lpszMessageType;
	*!*	  LPSTR           lpszDateReceived;
	*!*	  LPSTR           lpszConversationID;
	*!*	  FLAGS           flFlags;
	*!*	  lpMapiRecipDesc lpOriginator;
	*!*	  ULONG           nRecipCount;
	*!*	  lpMapiRecipDesc lpRecips;
	*!*	  ULONG           nFileCount;
	*!*	  lpMapiFileDesc  lpFiles;
	*!*	} MapiMessage, *lpMapiMessage

	lcMapiMessage = num2dword(0) +;
		num2dword(loSubject.getAddr()) +;
		num2dword(loNoteText.getAddr()) +;
		num2dword(0) + num2dword(0) + num2dword(0) + num2dword(0) +;
		num2dword(loSndBuf.getAddr()) +;
		num2dword(IIF(EMPTY(lcRecipient), 0, 1)) +;
		num2dword(IIF(EMPTY(lcRecipient), 0, loRcpBuf.getAddr())) +;
		num2dword(IIF(EMPTY(lcAttachment), 0, 1)) +;
		num2dword(IIF(EMPTY(lcAttachment), 0, loAttach.getAddr()))

	* sending the message with or without a confirmation dialog
	lnResult = MAPISendMail(hSession, 0, @lcMapiMessage, MAPI_DIALOG, 0) && Confirm dialog
	*lnResult = MAPISendMail(hSession, 0, @lcMapiMessage, 0, 0)


	IF lnResult <> SUCCESS_SUCCESS
	* 1 MAPI_E_USER_ABORT
	* 2 MAPI_E_FAILURE
	* 3 MAPI_E_LOGIN_FAILURE
	* 5 MAPI_E_INSUFFICIENT_MEMORY
	* 6 MAPI_E_ACCESS_DENIED
	* 9 MAPI_E_TOO_MANY_FILES
	*10 MAPI_E_TOO_MANY_RECIPIENTS
	*15 MAPI_E_BAD_RECIPTYPE
	*18 MAPI_E_TEXT_TOO_LARGE
	*14 MAPI_E_UNKNOWN_RECIPIENT
	* ...
	* ? "Error returned:", lnResult
	ELSE
	* ? "Sent initiated successfully!"
	ENDIF

	* closing current MAPI session
	= MAPILogoff (hSession, 0, 0, 0)

ENDPROC






FUNCTION  getNewSession()

	* creates a new MAPI session and returns its handle
	#DEFINE MAPI_LOGON_UI           1
	#DEFINE MAPI_NEW_SESSION        2
	#DEFINE MAPI_USE_DEFAULT       64
	#DEFINE MAPI_FORCE_DOWNLOAD  4096 && 0x1000
	#DEFINE MAPI_PASSWORD_UI   131072 && 0x20000

	LOCAL lnResult, lnSession, lcStoredPath
	lcStoredPath = SYS(5) + SYS(2003)
	lnSession = 0
	lnResult = MAPILogon (0, "", "",;
		MAPI_USE_DEFAULT+MAPI_NEW_SESSION, 0, @lnSession)

	* sometimes you need to restore default path - Outlook Express
	SET DEFAULT TO (lcStoredPath)

	RETURN IIF(lnResult=SUCCESS_SUCCESS, lnSession, 0)


FUNCTION  num2dword (lnValue)
	RETURN BINTOC(lnValue, "4RS")

	* for some structures you need not just strings but pointers to strings
	* to be assigned to structure fields;
	* this class implements such "dual" strings

DEFINE CLASS PChar AS CUSTOM
	PROTECTED HMEM

	PROCEDURE  INIT (lcString)
		This.HMEM = 0
		IF NOT EMPTY(lcString)
			This.setValue (lcString)
		ENDIF

	PROCEDURE  DESTROY
		This.ReleaseString

	FUNCTION getAddr  && returns a pointer to the string
		RETURN This.HMEM

	FUNCTION getValue && returns string value

		LOCAL lnSize, lcBuffer
		lnSize = This.getAllocSize()
		lcBuffer = SPACE(lnSize)
		IF This.HMEM <> 0
			DECLARE RtlMoveMemory IN kernel32 AS Heap2Str;
				STRING @, INTEGER, INTEGER
			= Heap2Str (@lcBuffer, This.HMEM, lnSize)
		ENDIF

		RETURN lcBuffer

	FUNCTION getAllocSize  && returns allocated memory size (string length)
		DECLARE INTEGER GlobalSize IN kernel32 INTEGER HMEM
		RETURN IIF(This.HMEM=0, 0, GlobalSize(This.HMEM))

	PROCEDURE setValue (lcString) && assigns new string value
		#DEFINE GMEM_FIXED   0

		This.ReleaseString
		DECLARE INTEGER GlobalAlloc IN kernel32 INTEGER, INTEGER
		DECLARE RtlMoveMemory IN kernel32 AS Str2Heap;
			INTEGER, STRING @, INTEGER

		LOCAL lnSize
		lcString = lcString + CHR(0)
		lnSize = LEN(lcString)
		This.HMEM = GlobalAlloc (GMEM_FIXED, lnSize)
		IF This.HMEM <> 0
			= Str2Heap (This.HMEM, @lcString, lnSize)
		ENDIF


	PROCEDURE ReleaseString  && releases allocated memory
		IF This.HMEM <> 0
			DECLARE INTEGER GlobalFree IN kernel32 INTEGER
			= GlobalFree (This.HMEM)
			This.HMEM = 0
		ENDIF
	ENDPROC

ENDDEFINE


PROCEDURE  DeclMapi
	DECLARE INTEGER MAPILogon IN mapi32;
		INTEGER ulUIParam, STRING lpszProfileName,;
		STRING lpszPassword, INTEGER flFlags,;
		INTEGER ulReserved, INTEGER @lplhSession

	DECLARE INTEGER MAPILogoff IN mapi32;
		INTEGER lhSession, INTEGER ulUIParam,;
		INTEGER flFlags, INTEGER ulReserved

	DECLARE INTEGER MAPISendMail IN mapi32;
		INTEGER lhSession, INTEGER ulUIParam, STRING @lpMessage,;
		INTEGER flFlags, INTEGER ulReserved
	RETURN


	* CDO email class from by VFP guru Sergey Berezniker
	* http://www.berezniker.com/content/pages/visual-foxpro/cdo-2000-class-sending-emails


	* The easiest way to configure CDOSYS is to configure Outlook Express.
	* You do not ever need to use it, but if you configure it to send e-mail,
	* CDO has the registry entries it needs so that you do not need to configure it explicitly.

	* CDO2000.prg
	* by Sergey Berezniker
	#DEFINE cdoSendPassword "http://schemas.microsoft.com/cdo/configuration/sendpassword"
	#DEFINE cdoSendUserName "http://schemas.microsoft.com/cdo/configuration/sendusername"
	#DEFINE cdoSendUsingMethod "http://schemas.microsoft.com/cdo/configuration/sendusing"
	#DEFINE cdoSMTPAuthenticate "http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"
	#DEFINE cdoSMTPConnectionTimeout "http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout"
	#DEFINE cdoSMTPServer "http://schemas.microsoft.com/cdo/configuration/smtpserver"
	#DEFINE cdoSMTPServerPort "http://schemas.microsoft.com/cdo/configuration/smtpserverport"
	#DEFINE cdoSMTPUseSSL "http://schemas.microsoft.com/cdo/configuration/smtpusessl"
	#DEFINE cdoURLGetLatestVersion "http://schemas.microsoft.com/cdo/configuration/urlgetlatestversion"
	#DEFINE cdoAnonymous 0	&& Perform no authentication (anonymous)
	#DEFINE cdoBasic 1	&& Use the basic (clear text) authentication mechanism.
	#DEFINE cdoSendUsingPort 2	&& Send the message using the SMTP protocol over the network.
	#DEFINE cdoXMailer "urn:schemas:mailheader:x-mailer"


DEFINE CLASS cdo2000 AS CUSTOM
	PROTECTED aErrors[1], nErrorCount, oMsg, oCfg, cXMailer
	nErrorCount = 0

	* Message attributes
	oMsg = NULL
	cFrom = ""
	cReplyTo = ""
	cTo = ""
	cCC = ""
	cBCC = ""
	cAttachment = ""

	cSubject = ""
	cHtmlBody = ""
	cTextBody = ""
	cHtmlBodyUrl = ""

	cCharset =  "" && _goHelper.cLanguage && <================ ="GREEK" (i.e. the current language) by Nick Porfyris [20100921]...


	* Configuration object fields values
	oCfg = NULL
	cServer = ""
	nServerPort = 25
	* Use SSL connection
	lUseSSL = .F.
	nConnectionTimeout = 30			&& Default 30 sec's
	nAuthenticate = cdoAnonymous
	cUserName = ""
	cPassword = ""
	* Do not use cache for cHtmlBodyUrl
	lURLGetLatestVersion = .T.

	* Optional. Creates your own X-MAILER field in the header
	cXMailer = "VFP CDO 2000(CDOSYS) mailer Ver 1.1 2009"

	PROTECTED PROCEDURE INIT
		This.aErrors = NULL

		LOCAL lcCharSet
		IF INLIST(ALLTRIM(UPPER(_goHelper.cLanguage)),"ENGLISH", "FRENCH", "PORTUGUESE", ;
			"ALBANIAN", "CATALAN", "DANISH", "DUTCH", "FAEROESE", "FINNISH", "GALICIAN", ;
			"GERMAN", "ICELANDIC", "ITALIAN", "NORWEGIAN", "SPANISH", "SWEDISH") 
			lcCharset = "" && _goHelper.cLanguage && <================ ="GREEK" (i.e. the current language) by Nick Porfyris [20100921]...
		ELSE 
			* lcCharset = _goHelper.cLanguage && (i.e. the current language) by Nick Porfyris [20100921]...
			&& extract the 9999 from the CP9999...
			lcCharSet = "windows-" + RIGHT(ALLTRIM(_goHelper.cCodePage),4)
		ENDIF 
		This.cCharSet = lcCharset

	ENDPROC

	* Send message
	PROCEDURE SEND

		WITH THIS
			.ClearErrors()
			.oCfg = CREATEOBJECT("CDO.Configuration")
			.oMsg = CREATEOBJECT("CDO.Message")
			.oMsg.Configuration = This.oCfg
		ENDWITH

		* Fill message attributes
		LOCAL lnind, laList[1], loHeader, laDummy[1]

		IF This.SetConfiguration() > 0
			RETURN This.GetErrorCount()
		ENDIF

		IF EMPTY(This.cFrom)
			This.AddError("ERROR : From is Empty.")
		ENDIF
		IF EMPTY(This.cSubject)
			This.AddError("ERROR : Subject is Empty.")
		ENDIF

		IF EMPTY(This.cTo) AND EMPTY(This.cCC) AND EMPTY(This.cBCC)
			This.AddError("ERROR : To,CC and BCC all are Empty.")
		ENDIF

		IF This.GetErrorCount() > 0
			RETURN This.GetErrorCount()
		ENDIF

		This.SetHeader()

		WITH This.oMsg

			.FROM     = This.cFrom
			.ReplyTo  = This.cReplyTo

			.TO       = This.cTo
			.CC       = This.cCC
			.BCC      = This.cBCC
			.Subject  = This.cSubject

			* Create HTML body from external HTML (file, URL)
			IF NOT EMPTY(This.cHtmlBodyUrl)
				.CreateMHTMLBody(This.cHtmlBodyUrl)
			ENDIF

			* Send HTML body. Creates TextBody as well
			IF NOT EMPTY(This.cHtmlBody)
				.HtmlBody = This.cHtmlBody
			ENDIF

			* Send Text body. Could be different from HtmlBody, if any
			IF NOT EMPTY(This.cTextBody)
				.TextBody = This.cTextBody
			ENDIF

			IF NOT EMPTY(.HtmlBody)
				.HtmlBodyPart.Charset = This.cCharset
			ENDIF

			IF NOT EMPTY(.TextBody)
				.TextBodyPart.Charset = This.cCharset
			ENDIF

			* Process attachments
			IF NOT EMPTY(This.cAttachment)
			* Accepts comma or semicolon
			* VFP 7.0 and later
			*FOR lnind=1 TO ALINES(laList, This.cAttachment, [,], [;])
			* VFP 6.0 and later compatible
				FOR lnind=1 TO ALINES(laList, CHRTRAN(This.cAttachment, [,;], CHR(13) + CHR(13)))
					lcAttachment = ALLTRIM(laList[lnind])
					* Ignore empty values
					IF EMPTY(laList[lnind])
						LOOP
					ENDIF

					* Make sure that attachment exists
					IF ADIR(laDummy, lcAttachment) = 0
						This.AddError(_goHelper.GetLoc("ATACHNOTFO") + " - " + lcAttachment)
					ELSE
						* The full path is required.
						IF 	UPPER(lcAttachment) <> UPPER(FULLPATH(lcAttachment))
							lcAttachment = FULLPATH(lcAttachment)
						ENDIF
						.AddAttachment(lcAttachment)
					ENDIF
				ENDFOR
			ENDIF

			IF NOT EMPTY(This.cCharset)
				.BodyPart.Charset = This.cCharset
			ENDIF

		ENDWITH

		IF This.GetErrorCount() > 0
			RETURN This.GetErrorCount()
		ENDIF
		This.oMsg.SEND()

		RETURN This.GetErrorCount()
	ENDPROC

	* Clear errors collection
	PROCEDURE ClearErrors()
		This.nErrorCount = 0
		DIMENSION This.aErrors[1]
		This.aErrors[1] = NULL
		RETURN This.nErrorCount
	ENDPROC

	* Return # of errors in the error collection
	PROCEDURE GetErrorCount
		RETURN This.nErrorCount
	ENDPROC

	* Return error by index
	PROCEDURE GetError
		LPARAMETERS tnErrorno
		IF	tnErrorno <= This.GetErrorCount()
			RETURN This.aErrors[tnErrorno]
		ELSE
			RETURN NULL
		ENDIF
	ENDPROC

	* Populate configuration object
	PROTECTED PROCEDURE SetConfiguration

		* Validate supplied configuration values
		IF EMPTY(This.cServer)
			This.AddError(_goHelper.GetLoc("SMTPNOTSPE")) && "ERROR: SMTP Server isn't specified.")
		ENDIF
		IF NOT INLIST(This.nAuthenticate, cdoAnonymous, cdoBasic)
			This.AddError(_goHelper.GetLoc("BADAUTHPRO")) && Invalid Authentication protocol ")
		ENDIF
		IF This.nAuthenticate = cdoBasic ;
				AND (EMPTY(This.cUserName) OR EMPTY(This.cPassword))
			This.AddError(_goHelper.GetLoc("INFOREQUIR")) && User name/Password is required for basic authentication")
		ENDIF

		IF 	This.GetErrorCount() > 0
			RETURN This.GetErrorCount()
		ENDIF

		WITH This.oCfg.FIELDS

			* Send using SMTP server
			.ITEM(cdoSendUsingMethod)       	= cdoSendUsingPort
			.ITEM(cdoSMTPServer)        		= This.cServer
			.ITEM(cdoSMTPServerPort)			= This.nServerPort
			.ITEM(cdoSMTPConnectionTimeout)	 	= This.nConnectionTimeout

			.ITEM(cdoSMTPAuthenticate)  		= This.nAuthenticate
			IF This.nAuthenticate = cdoBasic
				.ITEM(cdoSendUserName)    	  	= This.cUserName
				.ITEM(cdoSendPassword)    	  	= This.cPassword
			ENDIF
			.ITEM(cdoURLGetLatestVersion) 	  	= This.lURLGetLatestVersion
			.ITEM(cdoSMTPUseSSL) 				= This.lUseSSL

			.UPDATE()
		ENDWITH

		RETURN This.GetErrorCount()

	ENDPROC

*----------------------------------------------------
* Add message to the error collection
	PROTECTED PROCEDURE AddError
		LPARAMETERS tcErrorMsg
		This.nErrorCount = This.nErrorCount + 1
		DIMENSION This.aErrors[This.nErrorCount]
		This.aErrors[This.nErrorCount] = tcErrorMsg
		RETURN This.nErrorCount
	ENDPROC

*----------------------------------------------------
* Format an error message and add to the error collection
	PROTECTED PROCEDURE AddOneError
		LPARAMETERS tcPrefix, tnError, tcMethod, tnLine
		LOCAL lcErrorMsg, laList[1]
		IF INLIST(tnError, 1427,1429)
			AERROR(laList)
			lcErrorMsg = ALLTRIM(TRANSFORM(laList[7], "@0") + ;
				"  " + laList[4]  + "  " + laList[3])
		ELSE
			lcErrorMsg = ALLTRIM(MESSAGE())
		ENDIF
		lcErrorMsg = CHRTRAN(lcErrorMsg, CHR(0), "")
	
		This.AddError("#" + TRANSFORM(tnError) + " - " + ;
			ALLTRIM(tcMethod) + " - " + lcErrorMsg)
		RETURN This.nErrorCount
	ENDPROC

*----------------------------------------------------
* Simple Error handler. Adds VFP error to the objects error collection
	PROTECTED PROCEDURE ERROR
		LPARAMETERS tnError, tcMethod, tnLine
*!*			This.AddError("VFP Error: " + TRANSFORM(tnError) + " # " + ;
*!*				tcMethod + " # " + TRANSFORM(tnLine) + " # " + MESSAGE())
		This.AddOneError("", tnError, tcMethod, tnLine )
		RETURN This.nErrorCount
	ENDPROC

*-------------------------------------------------------
* Set mail header fields, if necessary. For now sets X-MAILER, if specified
	PROTECTED PROCEDURE SetHeader
		LOCAL loHeader
		IF NOT EMPTY(This.cXMailer)
			loHeader = This.oMsg.FIELDS
			WITH loHeader
				.ITEM(cdoXMailer) =  This.cXMailer
				.UPDATE()
			ENDWITH
		ENDIF
	ENDPROC

ENDDEFINE




* ExportListener helper class, to generate the CSV and XL5 outputs
DEFINE CLASS ExportListener AS REPORTLISTENER
	cDestFile = ""
	LISTENERTYPE = 3

	FUNCTION BEFOREREPORT
		LOCAL lcType
		lcType = LOWER(JUSTEXT(This.cDestFile))
		DO CASE
		CASE INLIST(lcType, "xls", "xl5")
			COPY TO FORCEEXT(This.cDestFile, "xls") TYPE XL5

		CASE lcType = "csv"
			COPY TO (This.cDestFile) DELIMITED WITH CHARACTER ";"
		OTHERWISE
		ENDCASE

		NODEFAULT
		This.DESTROY()
	ENDFUNC
ENDDEFINE



* Helper functions
PROCEDURE Report2Pic(toListener, tcDestFile, tcFileFormat)

	IF VARTYPE(toListener) <> "O"
		ERROR "Report Listener could not be accessed"
		RETURN .F.
	ENDIF

	IF VARTYPE(tcFileFormat) = "L"
		tcFileFormat = JUSTEXT(tcDestFile)
	ENDIF
	tcFileFormat = LOWER(tcFileFormat)

	LOCAL lnPageCount, lnFileType, lnDeviceType
	lnPageCount = _goHelper.nPageTotal && toListener.PageTotal

	DO CASE
	*!*	100 - imagem de tipo EMF
	*!*	101 - imagem de tipo TIFF
	*!*	102 - imagem de tipo JPEG
	*!*	103 - imagem de tipo GIF
	*!*	104 - imagem de tipo PNG
	*!*	105 - imagem de tipo BMP

	CASE tcFileFormat = "emf"
		lnFileType = 100

	CASE tcFileFormat = "tiff" OR tcFileFormat = "tif"
		lnFileType = 101

		#DEFINE OutputNothing -1
		#DEFINE OutputTIFF 101
		#DEFINE OutputTIFFAdditive (OutputTIFF+100)

		LOCAL lnPageNo
		FOR lnPageNo = 1 TO lnPageCount
			IF (lnPageNo == 1)
				lnDeviceType = OutputTIFF
			ELSE
				lnDeviceType = OutputTIFFAdditive
			ENDIF
			toListener.OUTPUTPAGE(lnPageNo,tcDestFile,lnDeviceType)
		ENDFOR
		RETURN


	CASE tcFileFormat = "jpeg" OR tcFileFormat = "jpg"
		lnFileType = 102

	CASE tcFileFormat = "gif"
		lnFileType = 103

	CASE tcFileFormat = "png"
		lnFileType = 104

	CASE tcFileFormat = "bmp" OR  tcFileFormat = "bitmap"
		lnFileType = 105

	ENDCASE

	ERASE (tcDestFile)

	LOCAL lcPathFile, lcDestFile, lcIndex, llSuccess
	llSuccess = .T.
	lcPathFile = ADDBS(JUSTPATH(tcDestFile)) + JUSTSTEM(tcDestFile)

	FOR lnPageNo = 1 TO lnPageCount
		IF lnPageCount = 1
			lcIndex = ""
		ELSE
			lcIndex = TRANSFORM(lnPageNo)
		ENDIF
		lcDestFile = FORCEEXT((lcPathFile + lcIndex),tcFileFormat)
		toListener.OUTPUTPAGE(lnPageNo, lcDestFile, lnFileType)
		IF NOT FILE(lcDestFile)
			llSuccess = .F.
		ENDIF
	ENDFOR
	RETURN llSuccess
ENDPROC



PROCEDURE SendCDOMail
	LPARAMETERS tcFile, tlDoNotEditMessage
	
	_goHelper.lEmailed = .F.

	LOCAL llCancelled
	IF NOT tlDoNotEditMessage
		DO FORM PR_SendMail.scx WITH tcFile TO llCancelled
	ENDIF
	IF llCancelled
		RETURN
	ENDIF 

	IF EMPTY(_goHelper.cEmailTo)
		_goHelper.SetError(_goHelper.GetLoc("DESTNOTDEF"))
		RETURN
	ENDIF

	IF EMPTY(_goHelper.cSMTPServer)
		_goHelper.SetError(_goHelper.GetLoc("SMTPNOTSPE"))
		RETURN
	ENDIF

	IF EMPTY(_goHelper.cEmailFrom)
		_goHelper.SetError(_goHelper.GetLoc("FROMEMPTY"))
		RETURN
	ENDIF

	IF EMPTY(_goHelper.cEmailSubject)
		_goHelper.SetError(_goHelper.GetLoc("SUBJEMPTY"))
		RETURN
	ENDIF

	*!*	_goHelper properties
	*!*		lEmailAuto = .T. 		&& Automatically generates the report output file
	*!*		cEmailType = "PDF" 		&& The file type to be used in Emails (PDF, RTF, HTML or XLS)
	*!*		cEmailPRG  = ""

	*!*		cSMTPServer   = ""
	*!*		nSMTPPort     = 25
	*!*		lSMTPUseSSL   = .F.
	*!*		cSMTPUserName = ""
	*!*		cSMTPPassword = ""

	LOCAL loMail AS cdo2000
	loMail = CREATEOBJECT("Cdo2000")

	WITH loMail
		.cServer     = _goHelper.cSMTPServer   && "smtp.live.com"
		.nServerPort = _goHelper.nSMTPPort     && 25
		.lUseSSL     = _goHelper.lSMTPUseSSL   && .T.

		*!* .nAuthenticate = 1 	&& cdoBasic
		*!* .cUserName   = _goHelper.cSMTPUserName && "yourAccount@live.com"
		*!* .cPassword   = _goHelper.cSMTPPassword && "yourPassword"

*!*			IF EMPTY(_goHelper.cSMTPUserName) AND EMPTY(_goHelper.cSMTPPassword)
*!*				.nAuthenticate = 0 	&& cdoAnonymous
*!*			ELSE
*!*				.nAuthenticate 	= 1 	&& cdoBasic
*!*				.cUserName   	= _goHelper.cSMTPUserName && "yourAccount@live.com"
*!*				.cPassword   	= _goHelper.cSMTPPassword && "yourPassword"
*!*			ENDIF


		IF EMPTY(_goHelper.cSMTPUserName) AND EMPTY(_goHelper.cSMTPPassword)
			.nAuthenticate = 0 	&& cdoAnonymous
		ELSE
			.nAuthenticate 	= 1 	&& cdoBasic
			.cUserName   	= _goHelper.cSMTPUserName && "yourAccount@live.com"
			*.cPassword   	= _goHelper.cSMTPPassword && "yourPassword"			&& ======> by Nick Porfyris... [20101014]
			.cPassword   	= _goHelper.DoDecrypt(_goHelper.cSMTPPassword) && "yourPassword"	&& ======> by Nick Porfyris... [20101014]
		ENDIF



		*.cFrom = "yourlAccount@live.com"
		.cFrom    = _goHelper.cEmailFrom    && .cUserName
		.cTo      = _goHelper.cEmailTo      && "vfpimaging@hotmail.com" && "somebody@otherdomain.com, somebodyelse@otherdomain.com"
		.cCC      = _goHelper.cEmailCC
		.cBCC     = _goHelper.cEmailBCC
		.cSubject = _goHelper.cEmailSubject && "FOXYPREVIEWER email"
		.cReplyTo = _goHelper.cEmailReplyTo

		*!* * Uncomment next lines to send HTML body
		*!* *.cHtmlBody = "<html><body><b>This is an HTML body<br>" + ;
		*!* *		"It'll be displayed by most email clients</b></body></html>"
		*!*
		*!* .cTextBody = _goHelper.cEmailBody
		*!* && "This is a text body." + CHR(13) + CHR(10) + ;
		*!* && "It'll be displayed if HTML body is not present or by text only email clients"


		IF EMPTY(_goHelper.cEmailBody)
			_goHelper.cEmailBody = "<HTML><BR></HTML>"
		ENDIF

		IF UPPER(LEFT(_goHelper.cEmailBody, 6)) == "<HTML>"
			.cHtmlBody = _goHelper.cEmailBody
		ELSE
			.cTextBody = _goHelper.cEmailBody
			&& "This is a text body." + CHR(13) + CHR(10) + ;
			&& "It'll be displayed if HTML body is not present or by text only email clients"
		ENDIF

		* Attachments are optional
		.cAttachment = tcFile && "myreport.pdf, myspreadsheet.xls"
	ENDWITH

	IF loMail.SEND() > 0
		LOCAL lcMailErr
		lcMailErr = ""
		FOR i=1 TO loMail.GetErrorCount()
			* ? i, loMail.Geterror(i)
			lcMailErr = lcMailErr + loMail.GetError(i) + CHR(13)
		ENDFOR
		_goHelper.SetError(_goHelper.GetLoc("ERRSENDMAI") + ":" + CHR(13) + ;
			lcMailErr + CHR(13) + _goHelper.GetLoc("MSGNOTSENT"))
	ELSE
		_goHelper.lEmailed = .T.
		* MESSAGEBOX("Email sent.")
	ENDIF

	RETURN

ENDPROC




********************************************************************
PROCEDURE SetPrinterProps
*********************************************************************
* Code from Barbara Peisch
* Allows changing the current printer settings
* Using the Printer perferences dialog
* http://www.foxite.com/archives/0000158197.htm

	* Lets the user set all possible printer properties
	LOCAL lcRptFile, lhWindow, lcOrigDevMode, lcModifiedDevMode, lcPrinter, lhPrinter

	* These constants come from the Windows.h file
	#DEFINE IDOK     1
	#DEFINE IDCANCEL 2

	#DEFINE DM_OUT_BUFFER 2
	#DEFINE DM_IN_BUFFER  8
	#DEFINE DM_IN_PROMPT  4

	DECLARE INTEGER OpenPrinter IN winspool.drv ;
		STRING pPrinterName, ;
		INTEGER @phPrinter, ;
		INTEGER pDefault

	DECLARE INTEGER GetActiveWindow IN user32

	DECLARE INTEGER DocumentProperties IN winspool.drv ;
		INTEGER hWnd, ;
		INTEGER hPrinter, ;
		STRING pDeviceName, ;
		STRING @pDevModeOutput, ;
		STRING @pDevModeInput, ;
		INTEGER fMode

	DECLARE INTEGER ClosePrinter IN winspool.drv INTEGER hPrinter

	lcPrinter = SET("Printer", 3)
	IF NOT EMPTY(lcPrinter)
		lhWindow = GetActiveWindow()

		lhPrinter = 0
		OpenPrinter(lcPrinter, @lhPrinter, 0)
		IF lhPrinter = 0
			Messagebox("Could not open printer.", 48, "Error")
			RETURN
		ENDIF

		lcRptFile = SYS(2015)+".FRX"

		TRY
			* Use a unique file name so we can use this in a multi-user situation
			* Using a cursor instead of a physical file doesn't work, but we can
			* create the FRX from a cursor.
			CREATE CURSOR TempCur (Temp C (10))
			CREATE REPORT (JUSTSTEM(lcRptFile)) FROM TempCur
			USE IN TempCur
			USE (lcRptFile) EXCLUSIVE ALIAS RptFile

			* Use SYS(1037,2) to read the printer settings instead of DocumentProperties
			SYS(1037,2)

			* We only want to save the original settings the first time
			lcOldExpr = EXPR
			lcOldTag  = TAG
			lcOldTag2 = TAG2
			lcOrigDevMode     = TAG2
			lcDevMode = TAG2
			lcModifiedDevMode = TAG2

			* Show printer settings dialog.
			lnResult = DocumentProperties(lhWindow, lhPrinter, lcPrinter, @lcModifiedDevMode, @lcOrigDevMode, DM_IN_PROMPT+DM_IN_BUFFER+DM_OUT_BUFFER)

			IF lnResult <> IDCANCEL
			* Set the printer to the new options
				SELECT RptFile
				replace expr WITH '', ;
					tag WITH '', ;
					TAG2 WITH lcModifiedDevMode
				lcDevMode = lcModifiedDevMode
				SYS(1037,3)		&& Writes the printer settings out to the printer
			ENDIF
		CATCH TO loException
		FINALLY 
			* Get rid of the temporary FRX
			IF USED("RptFile")
				USE IN RptFile
			ENDIF 
			IF FILE(lcRptFile)
				ERASE (JUSTSTEM(lcRptFile)+".*")
			ENDIF 

			* Close the printer handle
			IF NOT EMPTY(lhPrinter)
				ClosePrinter(lhPrinter)
			ENDIF 
		ENDTRY 
	ENDIF

ENDPROC 





* GDIPLUS FUNCTIONS BORROWED FROM THE GDIPLUSX LIBRARY FROM VFPX
*********************************************************************
FUNCTION xfcGdipDrawString(graphics, str, length, thefont, layoutRect, StringFormat, brush)
*********************************************************************
	DECLARE Long GdipDrawString IN GDIPLUS.DLL AS xfcGdipDrawString Long graphics, String str, Long length, Long thefont, String @layoutRect, Long StringFormat, Long brush
	RETURN xfcGdipDrawString(m.graphics, m.str, m.length, m.thefont, @m.layoutRect, m.StringFormat, m.brush)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipMeasureString(graphics, str, length, thefont, layoutRect, StringFormat, boundingBox, codepointsFitted, linesFilled)
*********************************************************************
	DECLARE Long GdipMeasureString IN GDIPLUS.DLL AS xfcGdipMeasureString Long graphics, String str, Long length, Long thefont, String @layoutRect, Long StringFormat, String @boundingBox, Long @codepointsFitted, Long @linesFilled
	RETURN xfcGdipMeasureString(m.graphics, m.str, m.length, m.thefont, @m.layoutRect, m.StringFormat, @m.boundingBox, @m.codepointsFitted, @m.linesFilled)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipRestoreGraphics(graphics, State)
*********************************************************************
	DECLARE Long GdipRestoreGraphics IN GDIPLUS.DLL AS xfcGdipRestoreGraphics Long graphics, Long State
	RETURN xfcGdipRestoreGraphics(m.graphics, m.State)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSaveGraphics(graphics, State)
*********************************************************************
	DECLARE Long GdipSaveGraphics IN GDIPLUS.DLL AS xfcGdipSaveGraphics Long graphics, Long @State
	RETURN xfcGdipSaveGraphics(m.graphics, @m.State)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetPixelOffsetMode(graphics, PixOffsetMode)
*********************************************************************
	DECLARE Long GdipSetPixelOffsetMode IN GDIPLUS.DLL AS xfcGdipSetPixelOffsetMode Long graphics, Long PixOffsetMode
	RETURN xfcGdipSetPixelOffsetMode(m.graphics, m.PixOffsetMode)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetRenderingOrigin(graphics, x, y)
*********************************************************************
	DECLARE Long GdipSetRenderingOrigin IN GDIPLUS.DLL AS xfcGdipSetRenderingOrigin Long graphics, Long x, Long y
	RETURN xfcGdipSetRenderingOrigin(m.graphics, m.x, m.y)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetSmoothingMode(graphics, SmoothingMd)
*********************************************************************
	DECLARE Long GdipSetSmoothingMode IN GDIPLUS.DLL AS xfcGdipSetSmoothingMode Long graphics, Long SmoothingMd
	RETURN xfcGdipSetSmoothingMode(m.graphics, m.SmoothingMd)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatAlign(StringFormat, Align)
*********************************************************************
	DECLARE Long GdipSetStringFormatAlign IN GDIPLUS.DLL AS xfcGdipSetStringFormatAlign Long StringFormat, Long Align
	RETURN xfcGdipSetStringFormatAlign(m.StringFormat, m.Align)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatFlags(StringFormat, flags)
*********************************************************************
	DECLARE Long GdipSetStringFormatFlags IN GDIPLUS.DLL AS xfcGdipSetStringFormatFlags Long StringFormat, Long flags
	RETURN xfcGdipSetStringFormatFlags(m.StringFormat, m.flags)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetTextRenderingHint(graphics, mode)
*********************************************************************
	DECLARE Long GdipSetTextRenderingHint IN GDIPLUS.DLL AS xfcGdipSetTextRenderingHint Long graphics, Long mode
	RETURN xfcGdipSetTextRenderingHint(m.graphics, m.mode)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetWorldTransform(graphics, matrix)
*********************************************************************
	DECLARE Long GdipSetWorldTransform IN GDIPLUS.DLL AS xfcGdipSetWorldTransform Long graphics, Long matrix
	RETURN xfcGdipSetWorldTransform(m.graphics, m.matrix)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipStringFormatGetGenericTypographic(StringFormat)
*********************************************************************
	DECLARE Long GdipStringFormatGetGenericTypographic IN GDIPLUS.DLL AS xfcGdipStringFormatGetGenericTypographic Long @StringFormat
	RETURN xfcGdipStringFormatGetGenericTypographic(@m.StringFormat)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipTransformPoints(graphics, destSpace, srcSpace, pPoint, Count)
*********************************************************************
	DECLARE Long GdipTransformPoints IN GDIPLUS.DLL AS xfcGdipTransformPoints Long graphics, Long destSpace, Long srcSpace, String @pPoint, Long Count
	RETURN xfcGdipTransformPoints(m.graphics, m.destSpace, m.srcSpace, @m.pPoint, m.Count)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipTransformPointsI(graphics, destSpace, srcSpace, pPoint, Count)
*********************************************************************
	DECLARE Long GdipTransformPointsI IN GDIPLUS.DLL AS xfcGdipTransformPointsI Long graphics, Long destSpace, Long srcSpace, String @pPoint, Long Count
	RETURN xfcGdipTransformPointsI(m.graphics, m.destSpace, m.srcSpace, @m.pPoint, m.Count)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipTranslateClip(graphics, dx, dy)
*********************************************************************
	DECLARE Long GdipTranslateClip IN GDIPLUS.DLL AS xfcGdipTranslateClip Long graphics, Single dx, Single dy
	RETURN xfcGdipTranslateClip(m.graphics, m.dx, m.dy)
ENDFUNC


*********************************************************************
FUNCTION xfcGdipCloneStringFormat(StringFormat, newFormat)
*********************************************************************
	DECLARE Long GdipCloneStringFormat IN GDIPLUS.DLL AS xfcGdipCloneStringFormat Long StringFormat, Long @newFormat
	RETURN xfcGdipCloneStringFormat(m.StringFormat, @m.newFormat)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipCreateStringFormat(formatAttributes, language, StringFormat)
*********************************************************************
	DECLARE Long GdipCreateStringFormat IN GDIPLUS.DLL AS xfcGdipCreateStringFormat Integer formatAttributes, Integer language, Long @StringFormat
	RETURN xfcGdipCreateStringFormat(m.formatAttributes, m.language, @m.StringFormat)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipDeleteStringFormat(StringFormat)
*********************************************************************
	DECLARE Long GdipDeleteStringFormat IN GDIPLUS.DLL AS xfcGdipDeleteStringFormat Long StringFormat
	RETURN xfcGdipDeleteStringFormat(m.StringFormat)
ENDFUNC




*********************************************************************
FUNCTION xfcGdipGetStringFormatAlign(StringFormat, Align)
*********************************************************************
	DECLARE Long GdipGetStringFormatAlign IN GDIPLUS.DLL AS xfcGdipGetStringFormatAlign Long StringFormat, Long @Align
	RETURN xfcGdipGetStringFormatAlign(m.StringFormat, @m.Align)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatDigitSubstitution(StringFormat, language, substitute)
*********************************************************************
	DECLARE Long GdipGetStringFormatDigitSubstitution IN GDIPLUS.DLL AS xfcGdipGetStringFormatDigitSubstitution Long StringFormat, Integer @language, Long @substitute
	RETURN xfcGdipGetStringFormatDigitSubstitution(m.StringFormat, @m.language, @m.substitute)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatFlags(StringFormat, flags)
*********************************************************************
	DECLARE Long GdipGetStringFormatFlags IN GDIPLUS.DLL AS xfcGdipGetStringFormatFlags Long StringFormat, Long @flags
	RETURN xfcGdipGetStringFormatFlags(m.StringFormat, @m.flags)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatHotkeyPrefix(StringFormat, hkPrefix)
*********************************************************************
	DECLARE Long GdipGetStringFormatHotkeyPrefix IN GDIPLUS.DLL AS xfcGdipGetStringFormatHotkeyPrefix Long StringFormat, Long @hkPrefix
	RETURN xfcGdipGetStringFormatHotkeyPrefix(m.StringFormat, @m.hkPrefix)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatLineAlign(StringFormat, Align)
*********************************************************************
	DECLARE Long GdipGetStringFormatLineAlign IN GDIPLUS.DLL AS xfcGdipGetStringFormatLineAlign Long StringFormat, Long @Align
	RETURN xfcGdipGetStringFormatLineAlign(m.StringFormat, @m.Align)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatTabStopCount(StringFormat, Count)
*********************************************************************
	DECLARE Long GdipGetStringFormatTabStopCount IN GDIPLUS.DLL AS xfcGdipGetStringFormatTabStopCount Long StringFormat, Long @Count
	RETURN xfcGdipGetStringFormatTabStopCount(m.StringFormat, @m.Count)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatTabStops(StringFormat, Count, firstTabOffset, tabStops)
*********************************************************************
	DECLARE Long GdipGetStringFormatTabStops IN GDIPLUS.DLL AS xfcGdipGetStringFormatTabStops Long StringFormat, Long Count, Single @firstTabOffset, String @tabStops
	RETURN xfcGdipGetStringFormatTabStops(m.StringFormat, m.Count, @m.firstTabOffset, @m.tabStops)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatTrimming(StringFormat, trimming)
*********************************************************************
	DECLARE Long GdipGetStringFormatTrimming IN GDIPLUS.DLL AS xfcGdipGetStringFormatTrimming Long StringFormat, Long @trimming
	RETURN xfcGdipGetStringFormatTrimming(m.StringFormat, @m.trimming)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatAlign(StringFormat, Align)
*********************************************************************
	DECLARE Long GdipSetStringFormatAlign IN GDIPLUS.DLL AS xfcGdipSetStringFormatAlign Long StringFormat, Long Align
	RETURN xfcGdipSetStringFormatAlign(m.StringFormat, m.Align)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatDigitSubstitution(StringFormat, language, substitute)
*********************************************************************
	DECLARE Long GdipSetStringFormatDigitSubstitution IN GDIPLUS.DLL AS xfcGdipSetStringFormatDigitSubstitution Long StringFormat, Integer language, Long substitute
	RETURN xfcGdipSetStringFormatDigitSubstitution(m.StringFormat, m.language, m.substitute)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatFlags(StringFormat, flags)
*********************************************************************
	DECLARE Long GdipSetStringFormatFlags IN GDIPLUS.DLL AS xfcGdipSetStringFormatFlags Long StringFormat, Long flags
	RETURN xfcGdipSetStringFormatFlags(m.StringFormat, m.flags)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatHotkeyPrefix(StringFormat, hkPrefix)
*********************************************************************
	DECLARE Long GdipSetStringFormatHotkeyPrefix IN GDIPLUS.DLL AS xfcGdipSetStringFormatHotkeyPrefix Long StringFormat, Long hkPrefix
	RETURN xfcGdipSetStringFormatHotkeyPrefix(m.StringFormat, m.hkPrefix)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatLineAlign(StringFormat, Align)
*********************************************************************
	DECLARE Long GdipSetStringFormatLineAlign IN GDIPLUS.DLL AS xfcGdipSetStringFormatLineAlign Long StringFormat, Long Align
	RETURN xfcGdipSetStringFormatLineAlign(m.StringFormat, m.Align)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatMeasurableCharacterRanges(StringFormat, rangeCount, ranges)
*********************************************************************
	DECLARE Long GdipSetStringFormatMeasurableCharacterRanges IN GDIPLUS.DLL AS xfcGdipSetStringFormatMeasurableCharacterRanges Long StringFormat, Long rangeCount, String ranges
	RETURN xfcGdipSetStringFormatMeasurableCharacterRanges(m.StringFormat, m.rangeCount, m.ranges)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatTabStops(StringFormat, firstTabOffset, Count, tabStops)
*********************************************************************
	DECLARE Long GdipSetStringFormatTabStops IN GDIPLUS.DLL AS xfcGdipSetStringFormatTabStops Long StringFormat, Single firstTabOffset, Long Count, String tabStops
	RETURN xfcGdipSetStringFormatTabStops(m.StringFormat, m.firstTabOffset, m.Count, m.tabStops)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatTrimming(StringFormat, trimming)
*********************************************************************
	DECLARE Long GdipSetStringFormatTrimming IN GDIPLUS.DLL AS xfcGdipSetStringFormatTrimming Long StringFormat, Long trimming
	RETURN xfcGdipSetStringFormatTrimming(m.StringFormat, m.trimming)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipStringFormatGetGenericDefault(StringFormat)
*********************************************************************
	DECLARE Long GdipStringFormatGetGenericDefault IN GDIPLUS.DLL AS xfcGdipStringFormatGetGenericDefault Long @StringFormat
	RETURN xfcGdipStringFormatGetGenericDefault(@m.StringFormat)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipStringFormatGetGenericTypographic(StringFormat)
*********************************************************************
	DECLARE Long GdipStringFormatGetGenericTypographic IN GDIPLUS.DLL AS xfcGdipStringFormatGetGenericTypographic Long @StringFormat
	RETURN xfcGdipStringFormatGetGenericTypographic(@m.StringFormat)
ENDFUNC


*********************************************************************
PROCEDURE GetCurPath
*********************************************************************
LOCAL lcProc, lnPos, lcFile, lcPath
lcProc = SYS(16)
IF "PROCEDURE" $ lcProc
	lnPos = AT(" ", lcProc, 2)
	IF lnPos > 0
		lcFile = SUBSTR(lcProc, lnPos + 1)
		lcPath = ADDBS(JUSTPATH(lcFile))
	ENDIF 
ELSE 
	lcPath = ADDBS(JUSTPATH(lcProc))
ENDIF
RETURN lcPath









*********************************************************************
FUNCTION RC4
*********************************************************************
*!*    Objet : Implémention en VisualFoxPro de l'algorithme de cryptage RC4
*!*    Auteur : C.Chenavier
*!*    Version : 1.00 - 12/03/2006
*!*    RC4 signifie Rivest Cipher 4
*!*    Il a été conçu en 1987 par Ron Rivest de RSA Security.
*!*    Attention, le nom "RC4" est une marque déposée.
*!*    Algorithme : http://en.wikipedia.org/wiki/RC4
*!*    Les tests ont été réalisés grâce à l'article:
*!*    http://en.wikisource.org/wiki/RC4_test_vectors
*!*    Source: http://www.atoutfox.org/articles.asp?ACTION=FCONSULTER&ID=0000000299

LPARAMETERS cTexte, cClef

LOCAL I, J, K, nLongClef, nInt, cResult
LOCAL ARRAY aInt(256)

FOR I = 1 TO 256
    aInt(I) = I-1
ENDFOR

J = 0
M.nLongClef = LEN(M.cClef)
FOR I = 1 TO 256
    J = BITAND(J + aInt(I) + ASC(SUBSTR(M.cClef, MOD(I-1,M.nLongClef)+1, 1)), 255)
    M.nInt = aInt(I)
    aInt(I) = aInt(J+1)
    aInt(J+1) = M.nInt
ENDFOR

I = 1
J = 0
M.cResult = ''
FOR K = 1 TO LEN(M.cTexte)
    I = BITAND(I, 255) + 1
    J = BITAND(J + aInt(I), 255)
    M.nInt = aInt(I)
    aInt(I) = aInt(J+1)
    aInt(J+1) = M.nInt
    M.cResult = M.cResult + CHR(BITXOR(ASC(SUBSTR(M.cTexte, K, 1)), ;
                                       aInt(BITAND(aInt(I) + M.nInt, 255)+1)))
ENDFOR

RETURN M.cResult