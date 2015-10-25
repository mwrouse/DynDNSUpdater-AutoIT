; ============================================================================
; Program....: Dynamic DNS Auto-Updater
; Author.....: Michael Rouse (michael@michaelrouse.net)
; Date.......: 06/19/2013
; Description: Detects an IP change and then automatically updates DynDNS
; ============================================================================

#include <Inet.au3>
#include <Date.au3>

; VARIABLES - Need to be filled out for DynDNS to work
Global $hotsname = "" ; Example: mydomain.com
Global $username = ""
Global $password = ""

IP() ;Starts the script

Func IP()
   Local $IP = _GetIP()
   Check($IP)
EndFunc

Func Check($oldIP) ;This function will loop until the IP has changed
   While 1 = 1
	  Local $IP = _GetIP() ;Will check for a new IP
	  Local $IP2 = $oldIP ;Sets the IP from IP() as the old IP for comparison

	  If $IP == $IP2 Then
		 ;Do Nothing because the IP has not changed
		 Sleep(100)

	  ElseIf $IP == "-1" Then ;No internet connection
		 While 1 = 1 ;This loop until an internet connection is made
			local $connection = CheckConnection()
			If $connection == TRUE Then
			   Check($IP2)
			Else
			   ;Do nothing
			EndIf
		 WEnd
	  Else
		 Update($IP, $IP2)
	  EndIf
   WEnd
EndFunc

Func Update($IP, $IP2)
   DirCreate("C:\Dynamic DNS") 				; Creates dir for log and INetGet If it doesn't already exist
   DirRemove("C:\Dynamic DNS\domains", 1) 	; Removes any old InetGet files
   DirCreate("C:\Dynamic DNS\domains") 		; Creates a new folder for INetGet files

   InetGet("https://dyndns.topdns.com/update?hostname="&$hostname&"&username="&$username&"&password="&$password, "C:\Dynamic DNS\domains\domain1.txt") ;Updates hostname
   InetGet("https://dyndns.topdns.com/update?hostname=*."&$hostname&"&username="&$username&"&password="&$password, "C:\Dynamic DNS\domains\domain2.txt") ;Updates *.hostname

   Local $domain1 = FileRead("C:\Dynamic DNS\domains\domain1.txt", 5) ; Grabs first 5 letters of domain1.txt file for comparison
   Local $domain2 = FileRead("C:\Dynamic DNS\domains\domain2.txt", 5) ; Grabs first 5 letters of domain2.txt file for comparison

   ; Check to see If DynDNS reported Abuse on the update
   If $domain1 == "abuse" or $domain2 == "abuse" Then
	  WriteLog("TRUE", $IP, $IP2) ; Write IP change and abuse to the log
   Else
	  WriteLog("FALSE", $IP, $IP2) ; Write IP change to the log
   EndIf
EndFunc

Func WriteLog($abuse, $IP, $IP2)
   If $abuse == "TRUE" Then
	  FileWriteLine("C:\Dynamic DNS\log.txt", _NowDate() & " " & _NowTime(3) & "-The IP changed from " & $IP2 & " to " & $IP & ". DynDNS also reported abuse on the account.")
	  IP() ;Starts the script over
   Else
	  FileWriteLine("C:\Dynamic DNS\log.txt", _NowDate() & " " & _NowTime(3) & "-The IP changed from " & $IP2 & " to " & $IP & ".")
	  IP() ;Starts the script over
   EndIf
EndFunc

Func CheckConnection()
   Local $ping = Ping("www.google.com", 5) ; Will ping Google.com
   If $ping Then
	  Return TRUE ;Computer has internet access
   Else
	  Return FALSE ;Computer does not have internet access
   EndIf
EndFunc
