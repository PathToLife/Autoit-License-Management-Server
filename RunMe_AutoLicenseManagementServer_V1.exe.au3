#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Add_Constants=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Sean Zeng

 Script Function:
	Server for passing license information to network clients via udp.
	Main Loop

 MIT LICENSE

 func WIKI: https://www.autoitscript.com/wiki/Function_list
 good coding practises: https://www.autoitscript.com/wiki/Best_coding_practices

 note to self; check out control send https://www.autoitscript.com/autoit3/docs/functions/ControlSend.htm

 serverip: 120.136.2.78

#ce ----------------------------------------------------------------------------

; Program variables
#region ;Safe-to-edit things are below
Global $sProgramName = "MegaWeb License Server V1" ; Name of server for GUI and clients to recieve
Global $TCPserverIP = @IPAddress1 ; IP for license Server, or use 0.0.0.0 to use all IP's
Global $TCPserverPORT = "3347" ; PORT for license Server
Global $TCPserverListenSOCKET ; The starting connection for clients to communicate with
Global $TCPmaxClients = 200
#endregion ;Stuff you shouldn't touch is below

; Dependancies
#include <File.au3> ; For doing operations on files
#include <FileConstants.au3> ; Constants to be included in an AutoIt v3 script when using File functions. Modifying these will change the operation of the File Functions.
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3> ; Same as above but for MSG boxes
#include <WinAPIFiles.au3> ; Win API for UDP communications
#include <Date.au3> ; Date and time4

#include <Misc.au3> ; Allow only one instance of program to be run, we use singleton

#include <WindowsConstants.au3>

; Program Function Scripts from working directories
#include "libConfig.au3" ; Includes Configuration file writer
#include "libGUI.au3" ; Includes GUI, handles all console out
#include "libError.au3" ; Includes Error Msg boxes etc
#include "libTCPserver.au3" ; Serverside handling of TCP protocols. Very similar to client code, but for multiple client sockets

; TCP: Client#01 -> IP Server Port $tcpPORT -> Get Socket#01 from $sockets[$maxClients] -> Establish connection

; Library program variables
Dim $g_bCloseConfim = TRUE;

;-----------------------------MAIN_LOOP-----------------------------

 ; Make sure only once instance of server script is running

ProgramStart()
Func ProgramStart()

	; Read config information from config.txt
	; uses @WorkingDir to find the file
	CONFIGStart()

	; GUI start
	StartGUI()
	GUICtrlSetState($g_idCheckbox, True) ; Show Date in Console out
	GUIConsoleOut("Program Started")

	sleep(1000)

	;GUIConsoleOut("PC60 192.168.88.160 License #1 CSGO ")
	;GUIConsoleOut("PC60 192.168.88.160 Starting CSGO #1")

	TCPstart()

EndFunc

While 1

	TCPRun() ; Scan for TCP connections and data. Contains 5ms high precision delay

WEnd
