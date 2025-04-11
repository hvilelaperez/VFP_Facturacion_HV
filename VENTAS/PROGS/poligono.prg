DIMENSION poly[5,2]
poly[1,1]= 0
poly[1,2]= 50
poly[2,1]= 50
poly[2,2]= 100
poly[3,1]= 100
poly[3,2]= 50
poly[4,1]= 50
poly[4,2]= 0
poly[5,1]=0
poly[5,2]=50
frmMyForm = CREATEOBJECT('Form')  
frmMyForm.AddObject('shpLine','Line')  
frmMyForm.AddObject('cmdCmndBtn1','cmdMyCmndBtn1')  
frmMyForm.shpLine.Top = 20  
frmMyForm.shpLine.Left = 125 
frmMyForm.shpLine.PolyPoints = "poly"
frmMyForm.shpLine.Visible = .T.  
frmMyForm.cmdCmndBtn1.Visible =.T.  
frmMyForm.Show
READ EVENTS  
DEFINE CLASS cmdMyCmndBtn1 AS CommandButton  
   Caption = '\<Quit'  
   Cancel = .T.  
   Left = 125  
   Top = 150  
   Height = 25  
   PROCEDURE Click
      CLEAR EVENTS  
ENDDEFINE
 
