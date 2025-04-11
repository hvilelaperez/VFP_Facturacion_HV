CLEAR ALL
CLEAR
PUBLIC oForm
oForm=CREATEOBJECT("WordSearch")
oForm.show(1)
*!*     IF _vfp.StartMode>0
*!*               READ events
*!*     ENDIF 
 
#DEFINE wdCharacter         1       
#DEFINE wdWord     2       
#DEFINE wdSentence         3       
#DEFINE wdParagraph        4       
#DEFINE wdLine       5       
#DEFINE wdStory     6       
#DEFINE wdScreen   7       
#DEFINE wdSection  8       
#DEFINE wdColumn  9       
#DEFINE wdRow      10     
#DEFINE wdWindow  11     
#DEFINE wdCell       12     
#DEFINE wdCharacterFormatting    13     
#DEFINE wdParagraphFormatting   14     
#DEFINE wdTable     15     
#DEFINE wdItem      16     
 
 
#DEFINE wdCellAlignVerticalTop      0       
#DEFINE wdCellAlignVerticalCenter  1       
#DEFINE wdCellAlignVerticalBottom 3       
 
 
#DEFINE wdBorderTop        -1      
#DEFINE wdBorderLeft       -2      
#DEFINE wdBorderBottom   -3      
#DEFINE wdBorderRight      -4      
#DEFINE wdBorderHorizontal         -5      
#DEFINE wdBorderVertical   -6      
#DEFINE wdBorderDiagonalDown    -7      
#DEFINE wdBorderDiagonalUp        -8      
#DEFINE emptyenum          0       
 
 
#DEFINE wdSectionBreakNextPage 2       
#DEFINE wdSectionBreakContinuous         3       
#DEFINE wdSectionBreakEvenPage 4       
#DEFINE wdSectionBreakOddPage  5       
#DEFINE wdLineBreak         6       
#DEFINE wdPageBreak       7       
#DEFINE wdColumnBreak    8       
#DEFINE wdLineBreakClearLeft      9       
#DEFINE wdLineBreakClearRight     10     
#DEFINE wdTextWrappingBreak     11     
 
DEFINE CLASS WordSearch as Form
          left=310
          height=600
          width=500
          allowoutput=.t.
          oWord=0
          fFirstPage=.t.
          nPuzNo=0
          ShowWindow=2
          left=SYSMETRIC(1)*5/8
          ADD OBJECT cmdDoit as CommandButton WITH left=100,;
                   caption="\<Generate Puzzles"
          ADD OBJECT cmdQuit as CommandButton WITH left=300,;
                   caption="\<Quit"
          ADD OBJECT edtText as editbox WITH ;
                   top = 50,;
                   height = thisform.Height-100,;
                   width=thisform.Width,;
                   Anchor=15,;
                   maxlength=3000
         
          PROCEDURE init
*                  RAND(1)        && remove this for diff seed value each run
                   WITH this.edtText
                             .Visible=1
                             .Height=thisform.Height-100
                             .Width=thisform.Width
TEXT TO cvar NOSHOW
Aimee, Bible, Sprint, Chicken, Acts, Gordon, Jesus, KCC, Rice, NewHope, Wedding, Worship, Softball, Zippys
GUESTS wendy
martin
ENDTEXT
*martin, franklin, duncan
*kyla robert
                             .Value=cVar
                   ENDWITH
          PROCEDURE Destroy
                   CLEAR EVENTS
                   IF _vfp.StartMode>0
                             QUIT
                   ENDIF
          PROCEDURE cmdQuit.Click
                   thisform.Release
          PROCEDURE CreateWordDoc
                   this.oWord=CREATEOBJECT("Word.Application")
                   WITH this.oWord as Word.Application
                             .Visible=.t.
                             .Top=0
                             .WindowState= 0  && wdWindowStateNormal
                             .Width=SYSMETRIC(1)/2
                             .Height=SYSMETRIC(2)-12
                             .Documents.Add
                             WITH .ActiveDocument.PageSetup as WORD.PageSetup
*!*                                            .FooterDistance=0
*!*                                            .HeaderDistance=0
                                      .TopMargin=20
                                      .BottomMargin=30
                                      .LeftMargin=20
                                      .RightMargin=20
                             ENDWITH
                  
                             .ActiveWindow.ActivePane.View.Type= 3  && wdPrintView
                             .ActiveWindow.ActivePane.View.SeekView= 1  && wdSeekPrimaryHeader
                             WITH .Selection as WORD.Selection
                                      .Font.Name="Arial"
                                      .Font.Size=24
                                      .Font.Bold=1
                                      .ParagraphFormat.Alignment= 1  && wdAlignParagraphCenter
                                      .TypeText("Aimee and Gordon Wedding Reception")
                                      .TypeParagraph
                                      .Font.Size=14
                                      .TypeText("ASL Word Search")
                                      .Font.Name="Arial"
                                      .Font.Size=12
                                      .TypeParagraph
                                      .ParagraphFormat.Alignment= 0  && wdAlignParagraphLeft
                                      .TypeText("Find all the hidden words. As a bonus, your name is hidden in a word search on your table but someone else may have your paper. But who?... Good luck! ")
                                      .Font.Italic=1
                                      .TypeText("Mahalo and God Bless, Aimee & Gordon ;o)")
                                      .Font.Italic=0
                                     
                             ENDWITH
                             .ActiveWindow.ActivePane.View.SeekView= 4  && wdSeekPrimaryFooter
                             WITH .Selection as WORD.Selection
                                      .Font.Name="Arial"
                                      .Font.Size=6
                                      .ParagraphFormat.Alignment= 2  && wdAlignParagraphRight
                                      .TypeText("June 30, 2007")
*                                     .TypeText("Word Search by Calvin Hsia & Visual FoxPro http://blogs.msdn.com/calvin_hsia/archive/2006/01/10/511258.aspx")
                             ENDWITH
                             .ActiveWindow.ActivePane.View.SeekView=0 && wdSeekMainDocument
 
                   ENDWITH
*!*                         CANCEL
*!*                         RETURN .f.
*                  oWord.Documents.Close(false)
          PROCEDURE click
                   IF !thisform.edtText.visible
                             thisform.Cls
                             thisform.edtText.visible=1
                             thisform.cmdDoit.visible=1
                   ENDIF
          PROCEDURE cmdDoit.Click
                   LOCAL i,j
                   thisform.CreateWordDoc
                   thisform.edtText.visible=.f.
                   this.Visible=.f.
                   nFixedWords=0
                   nLines=ALINES(aa,UPPER(thisform.edtText.value))         && create an array elem for each line of text
                   CREATE CURSOR words (word c(10))                            && a table to store the words
                   FOR i = 1 TO nLines                               && each line of text
                             FOR j = 1 TO GETWORDCOUNT(aa[i])       && each word on the line
                                      cWord=GETWORDNUM(aa[i],j)
                                      cTemp=""
                                      FOR k = 1 TO LEN(cWord)
                                                IF ISALPHA(SUBSTR(cWord,k,1))    && make sure only alpha chars are used
                                                          cTemp=cTemp+SUBSTR(cWord,k,1)
                                                ENDIF
                                      ENDFOR
                                      IF LEN(cTemp) >= 3 && only words > min length
                                                IF cTemp="GUESTS"
                                                          INSERT INTO words VALUES (cTemp)        && create placeholder record
                                                          nFixedWords=RECCOUNT()
                                                ELSE
                                                          IF  nFixedWords= 0  && still processing Fixed words
                                                                   INSERT INTO words VALUES (cTemp)
                                                          ELSE
                                                                   GO nFixedWords
                                                                   thisform.Caption="Guest="+cTemp
                                                                   REPLACE word WITH cTemp
                                                                   thisform.nPuzNo=thisform.nPuzNo+1
                                                                   thisform.GenPuzzle (cTemp)
                                                                   SELECT words
                                                          ENDiF
                                                ENDIF
                                      ENDIF
                             ENDFOR
                   ENDFOR
                   thisform.oWord.Selection.HomeKey(wdStory)       && move to top of doc
*                  thisform.Release
          PROCEDURE GenPuzzle(cName)
*                  LIST
                   SELECT distinct word,LEN(ALLTRIM(word)) as len, 100 as x, 100 as y,9 as dir;
                               FROM words ORDER BY 2 descending INTO CURSOR WordList READWRITE
                   nMax=MAX(WordList.len,15) && size of sq must be >= longest word
*                  ?"nmax",nMax
                   fGotit = .f.
                   FOR nTries = 1 TO 10
*                           ?"Trying to fit "+TRANSFORM(RECCOUNT())+" in square",TRANSFORM(nTries)+" x "+TRANSFORM(nTries)
                             IF thisform.fitit(10,10,cName)        && if success
                                      fGotit=.t.
                                      EXIT
                             ELSE
                                      ?" failed to generate for '",cName, "' Retry # ",nTries
                             ENDIF
                   ENDFOR
                   IF !fGotit
                             ?"Failed for ",cName
                   ENDIF
          PROCEDURE FitIt(numX as Integer, numY as Integer,cName)
                   LOCAL nTried,nLen,x0,y0,fGotit,nDir,ch,fFits,i,j,nRows,nCols
                   DIMENSION aGrid[numX,numY]      && Each element is a character
                   DIMENSION aTried[numX,numY]     && track direction tried for each cell in bitfield
                   aGrid=" "       && int all cells to space
                   thisform.Cls   && erase the form
                   UPDATE wordlist SET x=0,y=0,dir=0         && init recorded word positions
                   SCAN
                             aTried=0       && set all elements to 0
                             nTried=0       && number of tries to fit this particular word
                             DO WHILE .t.
                                      nLen = LEN(ALLTRIM(word))
                                      IF nTried < 4 * numX * numY        && for the first few attempts, try random placement
                                                DO WHILE .t.  && get random direction: dx,dy = 0 or +=1: but both can't be 0
                                                          nDir = INT(RAND()*9)         && get a random direction
                                                          IF nDir != 4   && 4 is dx=0 and dy=0
                                                                   EXIT
                                                          ENDIF
                                                ENDDO
                                                x0=INT(RAND()*numX)+1   && Random starting point in the grid
                                                y0=INT(RAND()*numY)+1
                                                IF BITTEST(aTried[x0,y0],nDir)       && if this dir was tried, lets try another
                                                          nTried=nTried+1
                                                          LOOP
                                                ENDIF
                                      ELSE   && if failed to fit the first few attempts randomly: try systematically
                                                fGotit=.f.
                                                FOR x0 = 1 TO numX          && each row,col
                                                          FOR y0 = 1 TO numY
                                                                   FOR nDir = 0 TO 8    && each direction
                                                                             IF nDir !=4    && 4 is dx=0 and dy=0
                                                                                      IF !BITTEST(aTried[x0,y0],nDir)      && if this dir is untried, lets try it
                                                                                                fGotit=.t.
                                                                                                EXIT
                                                                                      ENDIF
                                                                             ENDIF
                                                                   ENDFOR
                                                                   IF fGotit
                                                                             EXIT
                                                                   ENDIF
                                                          ENDFOR
                                                          IF fGotit
                                                                   EXIT
                                                          ENDIF
                                                ENDFOR
                                                IF !fGotit
                                                          RETURN .f.    && couldn't fit anywhere
                                                ENDIF
                                      ENDIF
                                      dx=nDir%3-1 && -1, 0, 1
                                      dy=INT(nDir/3)-1     && -1, 0, 1
                                      aTried[x0,y0]=BITSET(aTried[x0,y0],nDir) && set bit indicating direction tried
                                      nTried=nTried+1
                                      IF BETWEEN(x0 + dx*nLen,1,numX) AND BETWEEN(y0 + dy * nLen,1, numY)  && if enough room for word in grid
                                                fFits = .t.
                                                fHadBlank = .f.
                                                FOR i = 0 TO nLen-1 && now see if existing letters in grid match word
                                                          ch = aGrid[x0+dx*i,y0+dy * i]
                                                          IF ch = " "     && track empty squares (so "ear" not placed in "hear"
                                                                   fHadBlank = .t.
                                                          ELSE
                                                                   IF  ch != SUBSTR(word,i+1,1)        && the existing letter doesn't match the word
                                                                             fFits = .f.
                                                                             EXIT
                                                                   ENDIF
                                                          ENDIF
                                                ENDFOR
                                                IF fHadBlank AND fFits        && had a blank: we have a fit
                                                          FOR i = 0 TO nLen-1 && now place word in grid
                                                                   aGrid[x0+dx*i,y0+dy * i] = SUBSTR(word,i+1,1)
                                                                   thisform.Print(SUBSTR(word,i+1,1),15*(x0+dx*i),20*(y0+dy * i))
                                                                   REPLACE x WITH x0,y WITH y0,Dir WITH nDir       && record position
                                                          ENDFOR
                                                          EXIT && go on to next word
                                                ENDIF
                                      ENDIF
                             ENDDO
                   ENDSCAN                          && finish looping on all words
******Start grid
                   WITH this.oWord as WORD.Application
                             IF !this.fFirstPage
                                      .Selection.EndKey(wdStory)
                                      .Selection.InsertBreak(wdPageBreak)
                             ENDIF
                             this.fFirstPage = .f.
                             .ActiveWindow.ActivePane.View.SeekView=0 && wdSeekMainDocument
                            
                             WITH .Selection as WORD.Selection
                                      .TypeParagraph
                                      .Font.Name="Gallaudet"      && comment out this line for english font
                                      .Font.Size=55
                                      .Font.Bold=0  && do you want ASL font bold?
                             ENDWITH
                             .ActiveDocument.Tables.Add(.Selection.Range,10,10)
                             WITH .ActiveDocument.Tables((this.nPuzNo-1)*2+1) as WORD.Table
                                      .Borders(wdBorderLeft).LineStyle= 1  && wdLineStyleSingle
                                      .Borders(wdBorderRight).LineStyle= 1  && wdLineStyleSingle
                                      .Borders(wdBorderTop).LineStyle= 1  && wdLineStyleSingle
                                      .Borders(wdBorderBottom).LineStyle= 1  && wdLineStyleSingle
                                      .Borders(wdBorderHorizontal).LineStyle= 1  && wdLineStyleSingle
                                      .Borders(wdBorderVertical).LineStyle= 1  && wdLineStyleSingle
                                      .TopPadding=0
                                      .BottomPadding=0
                                      .LeftPadding=0
                                      .RightPadding=0
                                      .Rows.Alignment= 1  && wdAlignRowCenter
                                      .Rows.HeightRule= 2  && wdRowHeightExactly
                                      .Rows.Height=53
                                      .Spacing=0
                             ENDWITH
                             oSelection=.Selection
                             FOR j = 1 TO 10
                                      FOR i = 1 TO 10
                                                oSelection.ParagraphFormat.Alignment=1  && wdAlignParagraphCenter
          *                                     oSelection.Range.Cells.VerticalAlignment= 1 && wdCellAlignVerticalCenter         
                                                IF aGrid[i,j]=' '
                                                          cChar=CHR(65+RAND()*26) && random letter
                                                ELSE
                                                          cChar=aGrid[i,j]
                                                ENDIF
          *                                     cChar=CHR(65+MOD(i,26))
                                                oSelection.TypeText(cChar)
                                                IF i *j< 100
                                                          oSelection.MoveRight(wdCell)
                                                ELSE
                                                ENDIF
                                      ENDFOR
                             ENDFOR
                        oSelection.MoveDown(wdLine)
*****END Grid/Start Word list
 
                             oSelection.Font.Name="Arial"
                             oSelection.Font.Size=12
                             oSelection.Font.Bold=1
                            
                             oSelection.TypeParagraph
*                           .ActiveWindow.View.TableGridlines=0
#if .f.
                             .Selection.TypeParagraph
                             .ActiveDocument.DefaultTabStop=110
                             FOR i = 1 TO 3
                                      FOR j = 1 TO 5
                                                .Selection.TypeText("SOFTBALL")
                                                IF j < 5
                                                          .Selection.TypeText(CHR(9))
                                                ENDIF
                                      ENDFOR
                                      .Selection.TypeParagraph
                             ENDFOR
#endif
#if .t.
                             .ActiveDocument.Tables.Add(.Selection.Range,3,5)
                             WITH .ActiveDocument.Tables(this.nPuzNo*2) as WORD.Table
                                      .TopPadding=0
                                      .BottomPadding=0
                                      .LeftPadding=0
                                      .RightPadding=0
                                      .Rows.Alignment= 1  && wdAlignRowCenter
                                      .Rows.HeightRule= 2  && wdRowHeightExactly
                                      .Rows.Height=14
                                      .Spacing=0
                             ENDWITH
                             SELECT word FROM words INTO CURSOR WordListAlpha READWRITE
*                           SELECT word FROM wordlist WHERE word != cName ORDER BY 1 INTO CURSOR WordListAlpha READWRITE
                             GO BOTTOM
                             REPLACE word WITH "[NAME?]"
*                           INSERT INTO WordListAlpha VALUES ("[NAME?]")
                             nWords=RECCOUNT()
                             nCols=5
                             nRows = 3
                             FOR i = 1 TO nCols
                                      FOR j = 1 TO nRows
                                                ndx = (i-1) * nRows + (j-1)
                                                IF ndx < nWords
                                                          GO ndx+1
                                                          .Selection.TypeText(word)
                                                          IF i *j< 15
                                                                   .Selection.MoveRight(wdCell)
                                                          ENDIF
                                                ENDIF
                                      ENDFOR
                             ENDFOR
 
 
*!*                                  FOR i = 1 TO 15
*!*                                            .Selection.TypeText("SOFTBALL")
 
*!*                                            IF i < 15
*!*                                                     .Selection.MoveRight(wdCell)
*!*                                            ELSE
*!*                                            ENDIF
*!*                                  ENDFOR
#endif
                   ENDWITH
                   RETURN
         
 
                   FOR j = 1 TO numX
                             ?SPACE(6)
                             FOR i = 1 TO numY
                                      IF aGrid[i,j]=' '
                                                ??CHR(65+RAND()*26)+" "  && random letter
                                      ELSE
                                                ??aGrid[i,j]+" "
                                      ENDIF
                             ENDFOR
                   ENDFOR
                   SELECT word FROM wordlist WHERE word != cName INTO CURSOR WordListAlpha READWRITE
*                  SELECT word FROM wordlist WHERE word != cName ORDER BY 1 INTO CURSOR WordListAlpha READWRITE
                   INSERT INTO WordListAlpha VALUES ("[NAME?]")
                   nWords=RECCOUNT()
                   nCols=5
                   nRows = INT(_tally/nCols)
                   IF nRows*nCols != _tally
                             nRows=nRows+1
                   ENDIF
                   ?
                   ?
                   FOR j = 1 TO nRows
                             FOR i = 1 TO nCols
                                      ndx = (i-1) * nRows + (j-1)
                                      IF ndx < nWords
                                                GO ndx+1
                                                ??word
                                      ENDIF
                             ENDFOR
                             ?
                   ENDFOR
                   ?"Word Search by Calvin Hsia & Visual FoxPro", DATETIME()
                   *Word Search by Calvin Hsia & Visual FoxPro http://blogs.msdn.com/calvin_hsia/archive/2006/01/10/511258.aspx
                   RETURN .t.
ENDDEFINE