#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Sean Zeng

 Script Function:
	Server for passing license information to network clients via udp.

	TCP Serverside

 MIT LICENSE

 Thanks to https://www.autoitscript.com/forum/topic/137221-fast-multi-client-tcp-server/
 Autoit: Ken Piper for laying out multiple client TCP server framework

#ce ----------------------------------------------------------------------------

#include-once

#include "libError.au3"
#include "libGUI.au3"

;-- For running TCPserver standalone, testing purposes
If Not IsDeclared("TCPserverIP") Then

	Global $TCPserverIP = "127.0.0.1" ; Local Computer IP LoopBack
	Global $TCPserverPORT = 65412
	Global $TCPclients = 200

EndIf

; program variables
Global $TCPtimeout = 15000 ; Max Idle time: 15 Sec before connection is called dead
Global $TCPmaxPacketSize = 2048 ; 2048 Max size of packet per check 2KB
Global $TCPclients[1][4] ;[Index][Socket, IP, Timestamp, Buffer]
Global $Ws2_32 = DllOpen("Ws2_32.dll") ;Open Ws2_32.dll, it might get used a lot
Global $NTDLL = DllOpen("ntdll.dll") ;Open ntdll.dll, it WILL get used a lot
Global $CleanupTimer = TimerInit() ;This is used to time when things should be cleaned up
Global $TCPserverListenSOCKET

$TCPclients[0][0] = 0

Func TCPStart()

	Local $iError = 0 ; Error String

	TCPStartup(); Start the TCP service
	Opt("TCPTimeout", 0) ; make redundant TCP TCPtimeout of autoit

	OnAutoItExitRegister("ShutdownTCP") ; Make sure TCPport is freed up

	GUIConsoleOut("TCP Server Started "&"Listening IP: "&$TCPserverIP&" PORT: "&$TCPserverPORT)

	$TCPserverListenSOCKET =  TCPListen($TCPserverIP, $TCPserverPORT, $TCPclients) ;Start listening on the given IP/port

	If $TCPserverListenSOCKET = -1 Then
		GUIConsoleOut("Unable to intialize Listening Socket")
		errorFun(3)
	ElseIf $TCPserverListenSOCKET = 0 Then
		GUIConsoleOut("Listening Socket taken, unable to use")
		errorFun(4)
	Else
		GUICtrlSetData($g_labelIP, "Server Ready | LISTENING IP: "&$TCPserverIP&" PORT: "&$TCPserverPORT)
	EndIf

	If @error Then
		; Someone is probably already listening on this IP Address and Port (script already running?).
        $iError = @error
        MsgBox(BitOR($MB_SYSTEMMODAL, $MB_ICONHAND), "", "Server:" & @CRLF & "Could not listen, Error code: " & $iError)
        Return False
    EndIf

EndFunc

;------------------------MAIN_RUN_FUNCTION------------------------
Func TCPRun()
	USleep(5000, $NTDLL) ;This is needed because TCPTCPtimeout is disabled. Without this it will run one core at ~100%.
    ;The USleep function takes MICROseconds, not milliseconds, so 1000 = 1ms delay.
    ;When working with this granularity, you have to take in to account the time it takes to complete USleep().
    ;1000us (1ms) is about as fast as this should be set. If you need more performance, set this from 5000 to 1000,
    ;but doing so will make it consume a bit more CPU time to get that extra bit of performance.

	Check() ;Check recv buffers and do things

	If TimerDiff($CleanupTimer) > 1000 Then ;If it has been more than 1000ms since Cleanup() was last called, call it now
        $CleanupTimer = TimerInit() ;Reset $CleanupTimer, so it is ready to be called again
        Cleanup() ;Clean up the dead connections
    EndIf

	Local $iSock = TCPAccept($TCPserverListenSOCKET) ;See if anything wants to connect
    If $iSock = -1 Then Return ;If nothing wants to connect, restart at the top of the loop
    Local $iSize = UBound($TCPclients, 1) ;Something wants to connect, so get the number of people currently connected here
	GUIConsoleOut("Client Establishing connection...")
    If $iSize - 1 > $TCPclients And $TCPclients > 0 Then ;If $TCPclients is greater than 0 (meaning if there is a max connection limit) then check if that has been reached
        TCPCloseSocket($iSock) ;It has been reached, close the new connection and continue back at the top of the loop
		GUIConsoleOut("Client Denied Connection: Max Clients of "&$iSize&"Reached ")
        Return
    EndIf

    ReDim $TCPclients[$iSize + 1][4] ;There is room for a new connection, allocate space for it here
    $TCPclients[0][0] = $iSize ;Update the number of connected clients
    $TCPclients[$iSize][0] = $iSock ;Set the socket ID of the connection
    $TCPclients[$iSize][1] = SocketToIP($iSock, $Ws2_32) ;Set the IP Address the connection is from
    $TCPclients[$iSize][2] = TimerInit() ;Set the timestamp for the last known activity timer
    $TCPclients[$iSize][3] = "" ;Blank the recv buffer

	GUIConsoleOut("Client #"&$iSize&" Connected, Socket:"&$TCPclients[$iSize][0]&" IP:"&$TCPclients[$iSize][1])

EndFunc

;------------------------CONTROL_FUNCTIONS------------------------

Func Check() ;Function for processing
    If $TCPclients[0][0] < 1 Then Return ;If there are no clients connected, stop the function right now

    For $i = 1 To $TCPclients[0][0] ;Loop through all connected clients
        $sRecv = TCPRecv($TCPclients[$i][0], $TCPmaxPacketSize) ;Read $TCPmaxPacketSize bytes from the current client's buffer
        If $sRecv <> "" Then $TCPclients[$i][3] &= $sRecv ;If there was more data sent from the client, add it to the buffer
        If $TCPclients[$i][3] = "" Then ContinueLoop ;If the buffer is empty, stop right here and check more clients
        $TCPclients[$i][2] = TimerInit() ;If it got this far, there is data to be parsed, so update the activity timer

        #region ;Example packet processing stuff here. This is handling for a simple "echo" server with per-packet handling
            $sRecv = StringLeft($TCPclients[$i][3], StringInStr($TCPclients[$i][3], "$END", 0, -1)) ;Pull all data to the left of the last @CRLF in the buffer

            ;This does NOT pull the first complete packet, this pulls ALL complete packets, leaving only potentially incomplete packets in the buffer
            If $sRecv = "" Then ContinueLoop ;Check if there were any complete "packets"
			GUIConsoleOut("Data Recieved from IP:"&$TCPclients[$i][1]&" Data:'"&$sRecv&"'")

            $TCPclients[$i][3] = StringTrimLeft($TCPclients[$i][3], StringLen($sRecv) + 1) ;remove what was just read from the client's buffer
            $sPacket = StringSplit($sRecv, "$END", 1) ;Split all complete packets up in to an array, so it is easy to work with them
            For $j = 1 To $sPacket[0] ;Loop through each complete packet; This is where any packet processing should be done
                TCPSend($TCPclients[$i][0], "Echoing line: " & $sPacket[$j] & @CRLF) ;Echo back the packet the client sent
				GUIConsoleOut("Sending: "&$sPacket[$j]&" To IP:"&$TCPclients[$i][1])
            Next
        #endregion ;Example
    Next
EndFunc

Func Cleanup() ;Clean up any disconnected clients to regain resources
    If $TCPclients[0][0] < 1 Then Return ;If no clients are connected then return
    Local $iNewSize = 0
    For $i = 1 To $TCPclients[0][0] ;Loop through all connected clients
        $TCPclients[$i][3] &= TCPRecv($TCPclients[$i][0], $TCPmaxPacketSize) ;Dump any data not-yet-seen in to their recv buffer
        If @error > 0 Or TimerDiff($TCPclients[$i][2]) > $TCPtimeout Then ;Check to see if the connection has been inactive for a while or if there was an error
            TCPCloseSocket($TCPclients[$i][0]) ;If yes, close the connection
            $TCPclients[$i][0] = -1 ;Set the socket ID to an invalid socket
        Else
            $iNewSize += 1
        EndIf
    Next
    If $iNewSize < $TCPclients[0][0] Then ;If any dead connections were found, drop them from the client array and resize the array
        Local $iSize = UBound($TCPclients, 2) - 1
        Local $aTemp[$iNewSize + 1][$iSize + 1]
        Local $iCount = 1
        For $i = 1 To $TCPclients[0][0]
            If $TCPclients[$i][0] = -1 Then ContinueLoop
            For $j = 0 To $iSize
                $aTemp[$iCount][$j] = $TCPclients[$i][$j]
            Next
            $iCount += 1
        Next
        $aTemp[0][0] = $iNewSize
        $TCPclients = $aTemp
    EndIf
EndFunc

Func Close()

EndFunc

Func SocketToIP($iSock, $hDLL = "Ws2_32.dll") ;A rewrite of that _SocketToIP function that has been floating around for ages
    Local $structName = DllStructCreate("short;ushort;uint;char[8]")
    Local $sRet = DllCall($hDLL, "int", "getpeername", "int", $iSock, "ptr", DllStructGetPtr($structName), "int*", DllStructGetSize($structName))
    If Not @error Then
        $sRet = DllCall($hDLL, "str", "inet_ntoa", "int", DllStructGetData($structName, 3))
        If Not @error Then Return $sRet[0]
    EndIf
    Return "0.0.0.0" ;Something went wrong, return an invalid IP
EndFunc

Func USleep($iUsec, $hDLL = "ntdll.dll") ;A rewrite of the _HighPrecisionSleep function made by monoceres (Thanks!)
    Local $hStruct = DllStructCreate("int64")
    DllStructSetData($hStruct, 1, -1 * ($iUsec * 10))
    DllCall($hDLL, "dword", "ZwDelayExecution", "int", 0, "ptr", DllStructGetPtr($hStruct))
EndFunc

Func ShutdownTCP()
	GUIConsoleOut("Shutting down TCP Connections")

	DllClose($Ws2_32) ;Close the open handle to Ws2_32.dll
    DllClose($NTDLL) ;Close the open handle to ntdll.dll
    For $i = 1 To $TCPclients[0][0] ;Loop through the connected clients
        TCPCloseSocket($TCPclients[$i][0]) ;Force the client's connection closed
    Next
	TCPShutdown() ; Close the TCP service
	Sleep(500)
EndFunc ;==>