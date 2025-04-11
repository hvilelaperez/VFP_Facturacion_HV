PUBLIC oMiForm
oMiForm = CREATEOBJECT("MiForm")
oMiForm.SHOW
RETURN

DEFINE CLASS MiForm AS FORM
  HEIGHT = 565
  WIDTH = 675
  AUTOCENTER = .T.
  CAPTION = "Ejemplo con Google Maps"
  NAME = "MiForm"
  SetPoint = ""
  SHOWWINDOW = 2

  ADD OBJECT cboDescrip AS COMBOBOX WITH ;
    ROWSOURCETYPE = 6, ROWSOURCE = "MisLugares.descri", ;
    HEIGHT = 24, LEFT = 12, TOP = 12, WIDTH = 330, ;
    STYLE = 0, NAME = "cboDescrip"

  ADD OBJECT cmdMostrar AS COMMANDBUTTON WITH ;
    TOP = 10, LEFT = 350, HEIGHT = 27, WIDTH = 112, ;
    CAPTION = "Mostrar mapa", NAME = "cmdMostrar"

  ADD OBJECT oleIE AS OLECONTROL WITH ;
    TOP = 48, LEFT = 12, HEIGHT = 500, WIDTH = 650, ;
    NAME = "oleIE", OLECLASS = "Shell.Explorer.2"

  PROCEDURE LOAD
    SYS(2333,1)
    THIS.SetPoint = SET("Point")
    SET POINT TO .
    SET SAFETY OFF
    *-- Creo el cursor con los datos
    CREATE CURSOR MisLugares (Descri C(40), Lat N(12,6), Lon N(12,6), Zoom I(4))
    INSERT INTO MisLugares VALUES ("Torre Eiffel (Francia)", 48.858333, 2.295000, 17)
    INSERT INTO MisLugares VALUES ("Basílica de San Pedro (Vaticano)", 41.902102, 12.456400, 16)
    INSERT INTO MisLugares VALUES ("Estatua de la  Libertad (EEUU)", 40.689360, -74.044400, 16)
    INSERT INTO MisLugares VALUES ("Estadio Monumental (Argentina)", -34.545277, -58.449722, 16)
    INSERT INTO MisLugares VALUES ("Estadio Azteca (Mexico)", 19.302900, -99.150400, 16)
    INSERT INTO MisLugares VALUES ("Estadio Camp Nou (España)", 41.380906, 2.123330, 16)
    INSERT INTO MisLugares VALUES ("Cementerio de aviones (EEUU)", 32.174247, -110.855874, 16)
  ENDPROC

  PROCEDURE DESTROY
    SET POINT TO (THIS.SetPoint)
  ENDPROC

  PROCEDURE cboDescrip.INIT
    THIS.LISTINDEX = 1
  ENDPROC

  PROCEDURE cmdMostrar.CLICK
    TEXT TO lcHtml NOSHOW TEXTMERGE
    <html> <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>Google Maps</title>
    <script src="http://maps.google.com/maps?file=api&v=2&key=123" type="text/javascript"></script>
    <script type="text/javascript">
    //<![CDATA[
    function load()
    { if (GBrowserIsCompatible())
      { var map = new GMap2(document.getElementById("map"),G_HYBRID_MAP);
      map.addControl(new GLargeMapControl());
      map.addControl(new GMapTypeControl());
      map.addControl(new GOverviewMapControl());
      map.setCenter(new GLatLng(<<ALLTRIM(STR(MisLugares.Lat,12,6))>>,
      <<ALLTRIM(STR(MisLugares.Lon,12,6))>>),<<TRANSFORM(MisLugares.Zoom)>>);
      map.setMapType(G_SATELLITE_MAP);
    } }
    //]]> </script> </head>
    <body scroll="no" bgcolor="#CCCCCC" topmargin="0" leftmargin="0"
    onload="load()" onunload="GUnload()">
    <div id="map" style="width:650px;height:500px"></div>
    </body> </html>
    ENDTEXT
    STRTOFILE(lcHtml,"MiHtml.htm")
    THISFORM.oleIE.Navigate2(FULLPATH("MiHtml.htm"))
  ENDPROC

ENDDEFINE