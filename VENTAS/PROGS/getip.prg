

LOCAL Midir

loSock = CREATEOBJECT('MSWinsock.Winsock.1') 
Midir = loSock.LocalIP &&Si el textbox se llama asi 
?midir

loBrowser=NEWOBJECT("_webform",HOME()+"gallery\_webview") 
loBrowser.olewebBROWSER.Navigate2("http://192.168.1.79:81/sqmweb/registro")
loBrowser.Show(1)